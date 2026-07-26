import 'package:flutter/material.dart';

import '../models/trip.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key, required this.groups});
  final List<PackingGroup> groups;

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  final Set<String> _packed = {};

  @override
  Widget build(BuildContext context) {
    final total = widget.groups.fold<int>(
      0,
      (sum, group) => sum + group.items.length,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Packing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_packed.length} of $total packed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : _packed.length / total,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final group in widget.groups) ...[
            Card(
              child: ExpansionTile(
                initiallyExpanded: group == widget.groups.first,
                title: Text(
                  group.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${group.items.where((item) => _packed.contains('${group.name}:$item')).length}/${group.items.length} packed',
                ),
                children: [
                  for (final item in group.items)
                    CheckboxListTile(
                      value: _packed.contains('${group.name}:$item'),
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) => setState(() {
                        final key = '${group.name}:$item';
                        checked == true
                            ? _packed.add(key)
                            : _packed.remove(key);
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
