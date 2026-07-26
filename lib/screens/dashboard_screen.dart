import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = trip.startDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final planned = trip.budget.fold<double>(
      0,
      (sum, item) => sum + item.planned,
    );
    final actual = trip.budget.fold<double>(
      0,
      (sum, item) => sum + item.actual,
    );
    final next = trip.bookings
        .where((item) => !item.date.isBefore(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Adventure Hub'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.list(
            children: [
              _HeroCard(
                trip: trip,
                countdown: days > 0 ? '$days days to go' : 'Adventure underway',
              ),
              const SizedBox(height: 24),
              const SectionHeader('At a glance'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      icon: Icons.route,
                      value: '${trip.itinerary.length}',
                      label: 'Trip days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      icon: Icons.savings_outlined,
                      value: '£${(planned - actual).round()}',
                      label: 'Remaining',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader('Next booking'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: next.isEmpty
                      ? const Text('All upcoming bookings will appear here.')
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.confirmation_number_outlined),
                          ),
                          title: Text(
                            next.first.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${DateFormat('EEE, d MMM').format(next.first.date)} • ${next.first.note}',
                          ),
                          trailing: StatusChip(next.first.status),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader('Trip progress'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value:
                            planned == 0 ? 0 : (actual / planned).clamp(0, 1),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '£${actual.round()} planned or paid of £${planned.round()} budgeted',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.trip, required this.countdown});
  final Trip trip;
  final String countdown;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🇬🇧  ${trip.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(trip.subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 28),
            Text(
              countdown,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('d MMM').format(trip.startDate)} – ${DateFormat('d MMM yyyy').format(trip.endDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(label),
            ],
          ),
        ),
      );
}
