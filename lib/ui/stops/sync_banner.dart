import 'package:flutter/material.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final isSynced = pendingCount == 0;

    final message = isSynced
        ? 'All outcomes synced'
        : pendingCount == 1
        ? '1 outcome waiting to sync'
        : '$pendingCount outcomes waiting to sync';

    return Semantics(
      label: message,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSynced
                  ? [const Color(0xFF0F9D78), const Color(0xFF087F65)]
                  : [const Color(0xFFE89A35), const Color(0xFFD97706)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isSynced
                            ? const Color(0xFF0F9D78)
                            : const Color(0xFFE89A35))
                        .withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSynced ? Icons.cloud_done_rounded : Icons.sync_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSynced ? 'Sync Complete' : 'Sync Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!isSynced)
                Text(
                  '$pendingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
