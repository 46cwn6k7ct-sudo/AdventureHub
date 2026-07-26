import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';
import '../widgets/common.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Bookings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.separated(
              itemCount: trip.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = trip.bookings[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(child: Icon(_icon(booking.type))),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('EEE, d MMM yyyy').format(booking.date)} • ${booking.note}',
                              ),
                            ],
                          ),
                        ),
                        StatusChip(booking.status),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  IconData _icon(String type) {
    switch (type.toLowerCase()) {
      case 'flight':
        return Icons.flight;
      case 'hotel':
        return Icons.hotel;
      case 'train':
        return Icons.train;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.local_activity;
    }
  }
}
