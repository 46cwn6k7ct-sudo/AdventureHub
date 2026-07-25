import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AdventureHubApp());
}

class AdventureHubApp extends StatelessWidget {
  const AdventureHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventure Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315C4D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8CC7B0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AdventureHome(),
    );
  }
}

class AdventureHome extends StatefulWidget {
  const AdventureHome({super.key});

  @override
  State<AdventureHome> createState() => _AdventureHomeState();
}

class _AdventureHomeState extends State<AdventureHome> {
  int _index = 0;
  late final Future<TripData> _trip = TripData.load();

  static const _titles = ['Home', 'Itinerary', 'Bookings', 'Budget', 'More'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TripData>(
      future: _trip,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Could not load trip data: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!;
        final pages = [
          DashboardPage(data: data),
          ItineraryPage(data: data),
          BookingsPage(data: data),
          BudgetPage(data: data),
          MorePage(data: data),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_index]),
            centerTitle: false,
          ),
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Itinerary'),
              NavigationDestination(icon: Icon(Icons.wallet_outlined), selectedIcon: Icon(Icons.wallet), label: 'Bookings'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
              NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'More'),
            ],
          ),
        );
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.data});
  final TripData data;

  @override
  Widget build(BuildContext context) {
    final days = data.trip.startDate.difference(DateTime.now()).inDays;
    final next = data.itinerary.first;
    final totalCommitted = data.budget.fold<double>(0, (sum, item) => sum + item.committedGbp);

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
              Text('🇬🇧 ${data.trip.name}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                days >= 0 ? '$days days to go' : 'Adventure underway',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text('${DateFormat('d MMM').format(data.trip.startDate)} – ${DateFormat('d MMM yyyy').format(data.trip.endDate)} • ${data.trip.travellers}', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionTitle(title: 'First up'),
        InfoCard(
          icon: Icons.flight_takeoff,
          title: next.title,
          subtitle: '${DateFormat('EEE d MMM').format(next.date)} • ${next.location}\n${next.details}',
        ),
        const SizedBox(height: 16),
        SectionTitle(title: 'Trip snapshot'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            MetricCard(label: 'Trip days', value: '${data.trip.endDate.difference(data.trip.startDate).inDays + 1}', icon: Icons.calendar_today),
            MetricCard(label: 'Travellers', value: '5', icon: Icons.family_restroom),
            MetricCard(label: 'Stops', value: '${data.accommodation.length}', icon: Icons.hotel),
            MetricCard(label: 'Committed', value: '£${totalCommitted.toStringAsFixed(0)}', icon: Icons.payments),
          ],
        ),
        const SizedBox(height: 16),
        SectionTitle(title: 'Confirmed highlights'),
        ...data.wishlist.where((e) => e.priority == 'High').map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InfoCard(icon: Icons.star, title: item.title, subtitle: item.location),
              ),
            ),
      ],
    );
  }
}

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key, required this.data});
  final TripData data;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.itinerary.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data.itinerary[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(child: Text('${item.day}')),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${DateFormat('EEE d MMM').format(item.date)} • ${item.location}\n${item.details}'),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key, required this.data});
  final TripData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(title: 'Accommodation'),
        ...data.accommodation.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InfoCard(
              icon: Icons.hotel,
              title: item.property,
              subtitle: '${item.location} • ${item.dates}',
              trailing: StatusChip(label: item.status),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const SectionTitle(title: 'Transport'),
        ...data.transport.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InfoCard(
              icon: item.title.contains('train') ? Icons.train : Icons.directions_car,
              title: item.title,
              subtitle: '${item.provider} • £${item.costGbp.toStringAsFixed(2)}',
              trailing: StatusChip(label: item.status),
            ),
          ),
        ),
      ],
    );
  }
}

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key, required this.data});
  final TripData data;

  @override
  Widget build(BuildContext context) {
    final budgeted = data.budget.fold<double>(0, (sum, e) => sum + e.budgetGbp);
    final committed = data.budget.fold<double>(0, (sum, e) => sum + e.committedGbp);
    final progress = budgeted == 0 ? 0.0 : (committed / budgeted).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tracked budget', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('£${committed.toStringAsFixed(2)} committed', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('against £${budgeted.toStringAsFixed(2)} budgeted'),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 10),
                Text('Approx. NZ\$${(committed / data.trip.nzdToGbp).toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...data.budget.map((item) {
          final difference = item.budgetGbp - item.committedGbp;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Budget £${item.budgetGbp.toStringAsFixed(2)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('£${item.committedGbp.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(difference >= 0 ? '£${difference.toStringAsFixed(0)} left' : '£${difference.abs().toStringAsFixed(0)} over'),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
        MoreTile(
          icon: Icons.checklist,
          title: 'Packing list',
          subtitle: '${data.packing.values.expand((e) => e).length} items',
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
          subtitle: 'Coming in v0.2',
          page: PlaceholderPage(title: 'Travel journal'),
        ),
        const MoreTile(
          icon: Icons.map_outlined,
          title: 'Trip map',
          subtitle: 'Coming in v0.2',
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
  final Set<String> packed = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packing list')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: widget.data.packing.entries.map((section) {
          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(section.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: section.value.map((item) {
              final key = '${section.key}:$item';
              return CheckboxListTile(
                value: packed.contains(key),
                title: Text(item),
                onChanged: (selected) => setState(() {
                  selected == true ? packed.add(key) : packed.remove(key);
                }),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key, required this.data});
  final TripData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.wishlist.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = data.wishlist[index];
          return InfoCard(
            icon: item.priority == 'High' ? Icons.star : Icons.place_outlined,
            title: item.title,
            subtitle: item.location,
            trailing: StatusChip(label: item.priority),
          );
        },
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
          child: Text('$title is planned for the next release.', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class MoreTile extends StatelessWidget {
  const MoreTile({super.key, required this.icon, required this.title, required this.subtitle, required this.page});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.icon, required this.title, required this.subtitle, this.trailing});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle)),
        trailing: trailing,
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class TripData {
  TripData({
    required this.trip,
    required this.itinerary,
    required this.accommodation,
    required this.transport,
    required this.budget,
    required this.wishlist,
    required this.packing,
  });

  final Trip trip;
  final List<ItineraryItem> itinerary;
  final List<AccommodationItem> accommodation;
  final List<TransportItem> transport;
  final List<BudgetItem> budget;
  final List<WishlistItem> wishlist;
  final Map<String, List<String>> packing;

  static Future<TripData> load() async {
    final raw = await rootBundle.loadString('assets/data/trip_data.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return TripData(
      trip: Trip.fromJson(map['trip'] as Map<String, dynamic>),
      itinerary: (map['itinerary'] as List).map((e) => ItineraryItem.fromJson(e)).toList(),
      accommodation: (map['accommodation'] as List).map((e) => AccommodationItem.fromJson(e)).toList(),
      transport: (map['transport'] as List).map((e) => TransportItem.fromJson(e)).toList(),
      budget: (map['budget'] as List).map((e) => BudgetItem.fromJson(e)).toList(),
      wishlist: (map['wishlist'] as List).map((e) => WishlistItem.fromJson(e)).toList(),
      packing: (map['packing'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      ),
    );
  }
}

class Trip {
  Trip({required this.name, required this.startDate, required this.endDate, required this.travellers, required this.nzdToGbp});
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String travellers;
  final double nzdToGbp;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        name: json['name'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        travellers: json['travellers'] as String,
        nzdToGbp: (json['nzdToGbp'] as num).toDouble(),
      );
}

class ItineraryItem {
  ItineraryItem({required this.day, required this.date, required this.location, required this.title, required this.details});
  final int day;
  final DateTime date;
  final String location;
  final String title;
  final String details;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => ItineraryItem(
        day: json['day'] as int,
        date: DateTime.parse(json['date'] as String),
        location: json['location'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
      );
}

class AccommodationItem {
  AccommodationItem({required this.location, required this.property, required this.dates, required this.status});
  final String location;
  final String property;
  final String dates;
  final String status;

  factory AccommodationItem.fromJson(Map<String, dynamic> json) => AccommodationItem(
        location: json['location'] as String,
        property: json['property'] as String,
        dates: json['dates'] as String,
        status: json['status'] as String,
      );
}

class TransportItem {
  TransportItem({required this.title, required this.provider, required this.status, required this.costGbp});
  final String title;
  final String provider;
  final String status;
  final double costGbp;

  factory TransportItem.fromJson(Map<String, dynamic> json) => TransportItem(
        title: json['title'] as String,
        provider: json['provider'] as String,
        status: json['status'] as String,
        costGbp: (json['costGbp'] as num).toDouble(),
      );
}

class BudgetItem {
  BudgetItem({required this.category, required this.budgetGbp, required this.committedGbp});
  final String category;
  final double budgetGbp;
  final double committedGbp;

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        category: json['category'] as String,
        budgetGbp: (json['budgetGbp'] as num).toDouble(),
        committedGbp: (json['committedGbp'] as num).toDouble(),
      );
}

class WishlistItem {
  WishlistItem({required this.title, required this.location, required this.priority});
  final String title;
  final String location;
  final String priority;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        title: json['title'] as String,
        location: json['location'] as String,
        priority: json['priority'] as String,
      );
}
