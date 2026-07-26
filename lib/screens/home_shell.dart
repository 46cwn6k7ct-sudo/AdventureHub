import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/trip_repository.dart';
import 'bookings_screen.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'itinerary_screen.dart';
import 'more_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});
  final TripRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final Future<Trip> _trip = widget.repository.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Trip>(
      future: _trip,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Could not load trip data.\n${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final trip = snapshot.data!;
        final pages = [
          DashboardScreen(trip: trip),
          ItineraryScreen(trip: trip),
          BookingsScreen(trip: trip),
          BudgetScreen(trip: trip),
          MoreScreen(trip: trip),
        ];
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _index, children: pages),
          ),
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
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
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
