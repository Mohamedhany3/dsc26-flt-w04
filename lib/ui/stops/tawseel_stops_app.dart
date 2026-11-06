import 'package:flutter/material.dart';

import '../../domain/stop.dart';
import 'stop_tile.dart';
import 'sync_banner.dart';

class TawseelStopsApp extends StatefulWidget {
  const TawseelStopsApp({
    super.key,
    required this.stops,
    required this.pendingCount,
    this.textDirection = TextDirection.ltr,
  });

  final List<Stop> stops;
  final int pendingCount;
  final TextDirection textDirection;

  @override
  State<TawseelStopsApp> createState() => _TawseelStopsAppState();
}

class _TawseelStopsAppState extends State<TawseelStopsApp> {
  int selectedIndex = 0;

  Stop? get selectedStop {
    if (widget.stops.isEmpty) return null;
    if (selectedIndex >= widget.stops.length) return widget.stops.first;
    return widget.stops[selectedIndex];
  }

  Widget buildStopsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: widget.stops.length,
      itemBuilder: (context, i) => StopTile(
        key: Key('stop-${widget.stops[i].id}'),
        stop: widget.stops[i],
        onTap: () {
          setState(() {
            selectedIndex = i;
          });
        },
        onCall: () {},
      ),
    );
  }

  Widget buildDetails() {
    final stop = selectedStop;

    return KeyedSubtree(
      key: const Key('stop-detail'),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8EEE9)),
        ),
        child: stop == null
            ? const Center(child: Text('No stops available'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STOP DETAILS',
                      style: TextStyle(
                        color: Color(0xFF0F9D78),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF0F9D78),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      stop.customerName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF202938),
                          ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE8EEE9)),
                    const SizedBox(height: 16),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(color: Color(0xFF89919E), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF0F9D78),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stop.address,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Delivery Status',
                      style: TextStyle(color: Color(0xFF89919E), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stop.status.name,
                      style: const TextStyle(
                        color: Color(0xFF0F9D78),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0F9D78),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tawseel',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202938),
                  ),
                ),
                Text(
                  'Delivery management',
                  style: TextStyle(fontSize: 12, color: Color(0xFF89919E)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.stops.length} Stops',
              style: const TextStyle(
                color: Color(0xFF0F9D78),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawseel stops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F9D78)),
      ),
      builder: (context, child) =>
          Directionality(textDirection: widget.textDirection, child: child!),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              buildHeader(),
              SyncBanner(
                key: const Key('sync-banner'),
                pendingCount: widget.pendingCount,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Today\'s Deliveries',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202938),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.stops.length} orders',
                      style: const TextStyle(
                        color: Color(0xFF89919E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return KeyedSubtree(
                        key: const Key('layout-compact'),
                        child: buildStopsList(),
                      );
                    }

                    return KeyedSubtree(
                      key: const Key('layout-expanded'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 320, child: buildStopsList()),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFE8EEE9),
                          ),
                          Expanded(child: buildDetails()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
