import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Itinerary')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.separated(
              itemCount: trip.itinerary.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _DayCard(
                day: trip.itinerary[index],
                initiallyExpanded: index == 0,
              ),
            ),
          ),
        ],
      );
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.initiallyExpanded});
  final ItineraryDay day;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: CircleAvatar(
            backgroundColor: day.isTravelDay
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              day.isTravelDay
                  ? Icons.directions_transit
                  : Icons.explore_outlined,
            ),
          ),
          title: Text(
            day.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${DateFormat('EEE, d MMM').format(day.date)} • ${day.city}',
          ),
          children: [
            const Divider(),
            for (final activity in day.activities)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        activity.time,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (activity.note.isNotEmpty)
                            Text(
                              activity.note,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Open directions',
                      onPressed: () {},
                      icon: const Icon(Icons.directions_outlined),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
