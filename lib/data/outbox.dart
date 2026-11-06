import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/delivery_outcome.dart';
import 'local_store.dart';

/// The storage key for the whole queue (a JSON document).
const String outboxStorageKey = 'tawseel.outbox.v1';

enum EntryStatus { pending, rejected }

/// One queued outcome. Immutable; the outbox replaces entries with [copyWith].
final class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.outcome,
    this.attempts = 0,
    this.status = EntryStatus.pending,
    this.rejectionReason,
  });

  /// Generated on the phone when the outcome is recorded; sent as the
  /// Idempotency-Key header.
  final String id;
  final DeliveryOutcome outcome;

  /// How many times this entry has been sent, whatever the answer was.
  final int attempts;
  final EntryStatus status;
  final String? rejectionReason;

  OutboxEntry copyWith({
    DeliveryOutcome? outcome,
    int? attempts,
    EntryStatus? status,
    String? rejectionReason,
  }) => OutboxEntry(
    id: id,
    outcome: outcome ?? this.outcome,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    rejectionReason: rejectionReason ?? this.rejectionReason,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'outcome': outcome.toJson(),
    'attempts': attempts,
    'status': status.name,
    'rejectionReason': rejectionReason,
  };

  factory OutboxEntry.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final outcome = json['outcome'];
    final attempts = json['attempts'];
    final status = json['status'];
    final reason = json['rejectionReason'];
    if (id is! String ||
        outcome is! Map ||
        attempts is! int ||
        status is! String ||
        (reason != null && reason is! String)) {
      throw FormatException('bad outbox entry: $json');
    }
    return OutboxEntry(
      id: id,
      outcome: DeliveryOutcome.fromJson(outcome.cast<String, Object?>()),
      attempts: attempts,
      status: EntryStatus.values.byName(status),
      rejectionReason: reason as String?,
    );
  }

  @override
  String toString() =>
      'OutboxEntry($id, ${outcome.parcelId}, attempts: $attempts, ${status.name})';
}

/// What one sync run did.
final class SyncReport {
  const SyncReport({
    required this.sent,
    required this.rejected,
    required this.remaining,
    this.authRequired = false,
    this.retryAfter,
  });

  /// Entries the server accepted in this run (200, 201 or 409).
  final int sent;

  /// Entries the server rejected in this run (400 or 422).
  final int rejected;

  /// Pending entries left after the run.
  final int remaining;

  /// True when the run stopped on a 401.
  final bool authRequired;

  /// Set when the run stopped on a transient failure: wait this long.
  final Duration? retryAfter;

  @override
  String toString() =>
      'SyncReport(sent: $sent, rejected: $rejected, '
      'remaining: $remaining, authRequired: $authRequired, '
      'retryAfter: $retryAfter)';
}

/// 5 s × 2^(n−1), capped at 300 s. [consecutiveFailures] must be at least 1,
/// otherwise throw ArgumentError.

Duration retryDelay(int consecutiveFailures) {
  if (consecutiveFailures < 1) {
    throw ArgumentError('consecutiveFailures must be at least 1');
  }

  if (consecutiveFailures >= 7) {
    return const Duration(seconds: 300);
  }

  final seconds = 5 * (1 << (consecutiveFailures - 1));

  return Duration(seconds: seconds);
}

/// An offline-first queue of delivery outcomes. See the README for the rules.
///
/// Keep the constructor and the public method signatures exactly.
class Outbox {
  Outbox({
    required this._store,
    required this._client,
    required this._baseUrl,
    required this._newId,
  });

  // ignore: unused_field
  final LocalStore _store;
  // ignore: unused_field
  final http.Client _client;
  // ignore: unused_field
  final Uri _baseUrl;
  // ignore: unused_field
  final String Function() _newId;
  List<OutboxEntry>? _entries;

  Future<void> _load() async {
    final raw = await _store.read(outboxStorageKey);

    if (raw == null) {
      _entries = [];
      return;
    }

    final data = jsonDecode(raw) as List;

    _entries = data.map((item) {
      return OutboxEntry.fromJson(Map<String, Object?>.from(item as Map));
    }).toList();
  }

  Future<void> _save() async {
    await _store.write(
      outboxStorageKey,
      jsonEncode(_entries!.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> record(DeliveryOutcome outcome) async {
    final valid =
        outcome.parcelId.trim().isNotEmpty &&
        outcome.recordedAt.isUtc &&
        (outcome.status == OutcomeStatus.delivered
            ? outcome.codCollectedPiasters >= 0 && outcome.reason == null
            : outcome.reason != null && outcome.codCollectedPiasters == 0);

    if (!valid) {
      throw ArgumentError('Invalid outcome');
    }

    if (_entries == null) {
      await _load();
    }

    final index = _entries!.indexWhere(
      (entry) =>
          entry.outcome.parcelId == outcome.parcelId &&
          entry.status == EntryStatus.pending &&
          entry.attempts == 0,
    );

    if (index != -1) {
      final old = _entries![index];
      _entries![index] = OutboxEntry(id: old.id, outcome: outcome);
    } else {
      _entries!.add(OutboxEntry(id: _newId(), outcome: outcome));
    }

    await _save();
  }

  /// Pending entries, in send order.
  Future<List<OutboxEntry>> pending() async {
    if (_entries == null) {
      await _load();
    }

    return _entries!
        .where((entry) => entry.status == EntryStatus.pending)
        .toList();
  }

  Future<List<OutboxEntry>> rejected() async {
    if (_entries == null) {
      await _load();
    }

    return _entries!
        .where((entry) => entry.status == EntryStatus.rejected)
        .toList();
  }

  Future<int> pendingCount() async {
    final entries = await pending();
    return entries.length;
  }

  Future<SyncReport>? _syncFuture;

  Future<SyncReport> sync() {
    return _syncFuture ??= _performSync().whenComplete(() {
      _syncFuture = null;
    });
  }

  Future<SyncReport> _performSync() async {
    await _load();

    var sent = 0;
    var rejectedCount = 0;
    var authRequired = false;
    Duration? retryAfter;

    var index = 0;

    while (index < _entries!.length) {
      final entry = _entries![index];

      if (entry.status != EntryStatus.pending) {
        index++;
        continue;
      }

      final updatedEntry = OutboxEntry(
        id: entry.id,
        outcome: entry.outcome,
        attempts: entry.attempts + 1,
      );

      _entries![index] = updatedEntry;
      await _save();

      try {
        final response = await _client.post(
          _baseUrl.resolve('/v1/outcomes'),
          headers: {
            'Content-Type': 'application/json',
            'Idempotency-Key': entry.id,
          },
          body: jsonEncode({'id': entry.id, ...entry.outcome.toJson()}),
        );

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 409) {
          _entries!.removeAt(index);
          sent++;
          await _save();
          continue;
        }

        if (response.statusCode == 400 || response.statusCode == 422) {
          String reason = 'HTTP ${response.statusCode}';

          try {
            final body = jsonDecode(response.body);
            if (body is Map && body['message'] is String) {
              reason = body['message'] as String;
            }
          } catch (_) {}

          _entries![index] = OutboxEntry(
            id: entry.id,
            outcome: entry.outcome,
            attempts: updatedEntry.attempts,
            status: EntryStatus.rejected,
            rejectionReason: reason,
          );

          rejectedCount++;
          await _save();
          index++;
          continue;
        }

        if (response.statusCode == 401) {
          authRequired = true;
          break;
        }

        retryAfter = retryDelay(updatedEntry.attempts);
        break;
      } on http.ClientException {
        retryAfter = retryDelay(updatedEntry.attempts);
        break;
      }
    }

    return SyncReport(
      sent: sent,
      rejected: rejectedCount,
      remaining: _entries!
          .where((entry) => entry.status == EntryStatus.pending)
          .length,
      authRequired: authRequired,
      retryAfter: retryAfter,
    );
  }
}
