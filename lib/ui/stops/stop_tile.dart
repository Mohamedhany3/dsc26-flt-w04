import 'package:flutter/material.dart';

import '../../domain/stop.dart';

class StopTile extends StatelessWidget {
  const StopTile({
    super.key,
    required this.stop,
    required this.onTap,
    required this.onCall,
  });

  final Stop stop;
  final VoidCallback onTap;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final (color, status) = switch (stop.status) {
      StopStatus.pending => (const Color(0xFFD97706), 'Pending'),
      StopStatus.delivered => (const Color(0xFF0F9D78), 'Delivered'),
      StopStatus.failed => (const Color(0xFFDC4545), 'Failed'),
    };

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: Key('stop-dot-${stop.id}'),
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stop.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202938),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stop.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B8492),
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                key: Key('call-${stop.id}'),
                tooltip: 'Call ${stop.customerName}',
                onPressed: onCall,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEAF5F1),
                  foregroundColor: const Color(0xFF0F9D78),
                ),
                icon: const Icon(Icons.call_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
