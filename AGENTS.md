
# Tawseel Flutter Project Rules

## Environment
- Use Flutter 3.47.6 and Dart 3.13.
- Keep the package name `dsc26_flt_w04` unchanged.
- Use the existing dependencies and pinned versions in pubspec.yaml.
- The HTTP client is `http` version 1.6.0.

## Commands
- Install dependencies with `flutter pub get`.
- Run all tests with `flutter test`.
- Run static analysis with `flutter analyze`.
- Run tests after every implementation change.

## Project Structure
- Outbox logic belongs in `lib/data/outbox.dart`.
- Local persistence is defined in `lib/data/local_store.dart`.
- Delivery models are in `lib/domain/delivery_outcome.dart`.
- Stop models are in `lib/domain/stop.dart`.
- Stop list UI belongs in `lib/ui/stops/`.

## Outbox Rules
- Persist outcomes locally before confirming successful recording.
- Preserve the original order of queued outcomes.
- Never replace an outcome that has already been attempted.
- Treat HTTP 409 as success because the server already has the outcome.
- Keep failed and unauthenticated requests pending when required.
- Send pending outcomes one at a time, oldest first.
- Use the existing idempotency key and request format.
- Prevent concurrent sync operations from sending duplicates.
- Store timestamps in UTC.
- Use integer piastres for all COD amounts.

## Flutter UI Rules
- Preserve the TawseelStopsApp constructor and required widget keys.
- Use available width to determine compact and expanded layouts.
- Support both LTR and RTL layouts.
- Support 200% text scaling without fixed row heights.
- Keep interactive controls at least 48x48 with accessible labels.
- Preserve the required sync banner semantics and live region.

## Before Completing a Task
- Inspect existing implementations before changing files.
- Do not modify files marked as given unless explicitly required.
- Add or update tests for new behavior.
- Never claim tests pass unless they have actually passed.
- Do not expose API keys, tokens, passwords, or personal data.
