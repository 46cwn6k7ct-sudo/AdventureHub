import 'package:flutter/material.dart';

import '../models/trip.dart';
import 'packing_screen.dart';
import 'wishlist_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('More')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.list(
              children: [
                _LinkCard(
                  icon: Icons.luggage_outlined,
                  title: 'Packing',
                  subtitle: 'Family checklists and progress',
                  onTap: () =>
                      _open(context, PackingScreen(groups: trip.packing)),
                ),
                const SizedBox(height: 12),
                _LinkCard(
                  icon: Icons.favorite_border,
                  title: 'Wishlist',
                  subtitle: 'Must-dos and ideas to consider',
                  onTap: () =>
                      _open(context, WishlistScreen(items: trip.wishlist)),
                ),
                const SizedBox(height: 12),
                _LinkCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Journal',
                  subtitle: 'Coming in the next release',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _LinkCard(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Trip and family preferences',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      );

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: CircleAvatar(child: Icon(icon)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
