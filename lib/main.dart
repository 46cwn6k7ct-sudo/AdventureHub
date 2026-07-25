import 'package:flutter/material.dart';
import 'pages/itinerary_page.dart';
import 'adventure_hub_remaining_pages.dart';
import 'models/trip_data.dart';

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
            body: Center(
              child: Text('Could not load trip data: ${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
          appBar: AppBar(title: Text(_titles[_index])),
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Itinerary',
              ),
              NavigationDestination(
                icon: Icon(Icons.wallet_outlined),
                selectedIcon: Icon(Icons.wallet),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Budget',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'More',
              ),
            ],
          ),
        );
      },
    );
  }
}
