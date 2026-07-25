import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/trip_data.dart';

// Cleaned up copy adapted from Downloads; pages accept `dynamic data`
// to avoid circular imports with `main.dart` which defines TripData.

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.data});

  final TripData data;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysToGo = data.trip.startDate.difference(now).inDays;
    final totalCommitted = data.budget.fold<double>(
      0.0,
      (double sum, BudgetItem item) => sum + item.committedGbp,
    );

    final upcoming = data.itinerary.where((ItineraryItem item) {
      return !item.date.isBefore(
        DateTime(now.year, now.month, now.day),
      );
    }).toList();

    final next = upcoming.isNotEmpty ? upcoming.first : data.itinerary.last;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
                '🇬🇧 ${data.trip.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                daysToGo > 0
                    ? '$daysToGo days to go'
                    : daysToGo == 0
                        ? 'Your adventure starts today'
                        : 'Adventure underway',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 18),
              Text(
                '${DateFormat('d MMM').format(data.trip.startDate)} – '
                '${DateFormat('d MMM yyyy').format(data.trip.endDate)}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                data.trip.travellers,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Next up'),
        InfoCard(
          icon: Icons.explore_outlined,
          title: next.title,
          subtitle:
              '${DateFormat('EEE d MMM').format(next.date)} • ${next.location}\n'
              '${next.details}',
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Trip snapshot'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            MetricCard(
              label: 'Trip days',
              value:
                  '${data.trip.endDate.difference(data.trip.startDate).inDays + 1}',
              icon: Icons.calendar_today,
            ),
            const MetricCard(
              label: 'Travellers',
              value: '5',
              icon: Icons.family_restroom,
            ),
            MetricCard(
              label: 'Stays',
              value: '${data.accommodation.length}',
              icon: Icons.hotel,
            ),
            MetricCard(
              label: 'Committed',
              value: '£${totalCommitted.toStringAsFixed(0)}',
              icon: Icons.payments,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Top highlights'),
        ...data.wishlist
            .where((WishlistItem item) => item.priority.toLowerCase() == 'high')
            .map(
              (WishlistItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InfoCard(
                  icon: Icons.star,
                  title: item.title,
                  subtitle: item.location,
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
      ],
    );
  }
}

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key, required this.data});

  final TripData data;

  @override
  Widget build(BuildContext context) {
    final confirmedAccommodation = data.accommodation.where(
      (AccommodationItem item) => item.status.toLowerCase().contains('confirm'),
    );

    final confirmedTransport = data.transport.where(
      (TransportItem item) => item.status.toLowerCase().contains('confirm'),
    );

    final confirmedCount =
        confirmedAccommodation.length + confirmedTransport.length;
    final totalCount = data.accommodation.length + data.transport.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BookingSummaryCard(
          confirmed: confirmedCount,
          total: totalCount,
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Accommodation'),
        ...data.accommodation.map(
          (AccommodationItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconBox(
                      icon: Icons.hotel,
                      colour: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.property,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(item.location),
                          const SizedBox(height: 4),
                          Text(
                            item.dates,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label: item.status),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const SectionTitle(title: 'Transport'),
        ...data.transport.map(
          (TransportItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconBox(
                      icon: _transportIcon(item.title),
                      colour: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(item.provider),
                          const SizedBox(height: 4),
                          Text(
                            '£${item.costGbp.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label: item.status),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static IconData _transportIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('train') || value.contains('rail')) {
      return Icons.train;
    }
    if (value.contains('flight') || value.contains('air')) {
      return Icons.flight;
    }
    if (value.contains('ferry')) {
      return Icons.directions_boat;
    }

    return Icons.directions_car;
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({
    required this.confirmed,
    required this.total,
  });

  final int confirmed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : confirmed / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('$confirmed of $total bookings confirmed'),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key, required this.data});

  final TripData data;

  @override
  Widget build(BuildContext context) {
    final budgeted = data.budget.fold<double>(
      0.0,
      (double sum, BudgetItem item) => sum + item.budgetGbp,
    );

    final committed = data.budget.fold<double>(
      0.0,
      (double sum, BudgetItem item) => sum + item.committedGbp,
    );

    final remaining = budgeted - committed;
    final progress =
        budgeted == 0 ? 0.0 : (committed / budgeted).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip budget',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  '£${committed.toStringAsFixed(2)} committed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text('of £${budgeted.toStringAsFixed(2)} budgeted'),
                const SizedBox(height: 18),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BudgetStat(
                        label: remaining >= 0 ? 'Remaining' : 'Over budget',
                        value: '£${remaining.abs().toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BudgetStat(
                        label: 'Approx. NZD',
                        value:
                            'NZ\$${(committed / data.trip.nzdToGbp).toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Categories'),
        ...data.budget.map(
          (BudgetItem item) {
            final difference = item.budgetGbp - item.committedGbp;
            final itemProgress = item.budgetGbp == 0
                ? 0.0
                : (item.committedGbp / item.budgetGbp)
                    .clamp(0.0, 1.0)
                    .toDouble();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '£${item.committedGbp.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Budget £${item.budgetGbp.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: itemProgress),
                      const SizedBox(height: 8),
                      Text(
                        difference >= 0
                            ? '£${difference.toStringAsFixed(2)} remaining'
                            : '£${difference.abs().toStringAsFixed(2)} over',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.data});

  final TripData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                Icons.apps,
                size: 34,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip tools',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Everything else you need for the adventure.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        MoreTile(
          icon: Icons.checklist,
          title: 'Packing list',
          subtitle:
              '${data.packing.values.expand((items) => items).length} items',
          page: PackingPage(data: data),
        ),
        MoreTile(
          icon: Icons.favorite_outline,
          title: 'Wishlist',
          subtitle: '${data.wishlist.length} attractions and ideas',
          page: WishlistPage(data: data),
        ),
        const MoreTile(
          icon: Icons.photo_camera_outlined,
          title: 'Travel journal',
          subtitle: 'Coming in a future update',
          page: PlaceholderPage(title: 'Travel journal'),
        ),
        const MoreTile(
          icon: Icons.map_outlined,
          title: 'Trip map',
          subtitle: 'Coming in a future update',
          page: PlaceholderPage(title: 'Trip map'),
        ),
      ],
    );
  }
}

class PackingPage extends StatefulWidget {
  const PackingPage({super.key, required this.data});

  final TripData data;

  @override
  State<PackingPage> createState() => _PackingPageState();
}

class _PackingPageState extends State<PackingPage> {
  final Set<String> packed = <String>{};

  int get totalItems =>
      widget.data.packing.values.expand((items) => items).length;

  @override
  Widget build(BuildContext context) {
    final progress = totalItems == 0 ? 0.0 : packed.length / totalItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Packing list')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${packed.length} of $totalItems packed',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.data.packing.entries.map(
            (MapEntry<String, List<String>> section) {
                final sectionPacked = section.value.where((String item) {
                  return packed.contains('${section.key}:$item');
                }).length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    section.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('$sectionPacked of ${section.value.length} packed'),
                  children: section.value.map(
                    (String item) {
                      final key = '${section.key}:$item';

                      return CheckboxListTile(
                        value: packed.contains(key),
                        title: Text(item),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              packed.add(key);
                            } else {
                              packed.remove(key);
                            }
                          });
                        },
                      );
                    },
                  ).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key, required this.data});

  final TripData data;

  @override
  Widget build(BuildContext context) {
    final highPriority = data.wishlist.where(
      (item) => item.priority.toLowerCase() == 'high',
    );

    final otherItems = data.wishlist.where(
      (item) => item.priority.toLowerCase() != 'high',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (highPriority.isNotEmpty) ...[
            const SectionTitle(title: 'Must do'),
            ...highPriority.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoCard(
                  icon: Icons.star,
                  title: item.title,
                  subtitle: item.location,
                  trailing: StatusChip(label: item.priority),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (otherItems.isNotEmpty) ...[
            const SectionTitle(title: 'More ideas'),
            ...otherItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoCard(
                  icon: Icons.place_outlined,
                  title: item.title,
                  subtitle: item.location,
                  trailing: StatusChip(label: item.priority),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 18),
              Text(
                '$title is planned for a future release.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoreTile extends StatelessWidget {
  const MoreTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _IconBox(
          icon: icon,
          colour: Theme.of(context).colorScheme.secondaryContainer,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _IconBox(
          icon: icon,
          colour: Theme.of(context).colorScheme.secondaryContainer,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: trailing,
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.colour,
  });

  final IconData icon;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon),
    );
  }
}
