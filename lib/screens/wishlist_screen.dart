import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../widgets/common.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key, required this.items});
  final List<WishlistItem> items;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Icon(
                        item.priority == 'Must do'
                            ? Icons.star
                            : Icons.favorite_border,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text('${item.city} • ${item.priority}'),
                          if (item.note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(item.note),
                            ),
                        ],
                      ),
                    ),
                    StatusChip(item.status),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
