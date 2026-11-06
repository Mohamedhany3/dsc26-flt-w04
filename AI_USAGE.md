
# AI usage: dsc26-flt-w04

## 1. Tools I used

- ChatGPT for understanding requirements, debugging, and reviewing Flutter code.

## 2. My best prompts

1. Help me implement the Outbox class according to the README requirements, including persistence, retries, and handling HTTP responses.
2. Review my Flutter UI code and help me fix responsive layout issues, text overflow, and RTL support while keeping all required test keys.

## 3. One bug I found in AI-generated outbox or layout code, and how

The initial StopTile implementation used a fixed height of 64 pixels. This caused text overflow when addresses were long or when the text scale was increased. I noticed the problem while reviewing the README requirements and testing the layout. I fixed it by removing the fixed height and using a Row with Expanded so the tile can grow based on its content.

## 4. Why 409 is a success, and why corrections are appended after an attempt

I want to keep a history of all operations in the correct order without modifying any operation that might have already reached the server. Operations should be saved locally while the device is offline, then synced with the server once the internet connection is restored.

If the internet disconnects before an operation is sent, it should remain pending in local storage until it can be sent successfully.

If the server returns a 409 status code, it means the operation has already been processed, so we should treat it as successful and remove it from the pending queue.

When a correction is needed after an attempt, we append it as a new operation instead of replacing the old one, to preserve the operation history.
