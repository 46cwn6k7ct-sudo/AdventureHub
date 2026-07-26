import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '£', decimalDigits: 0);
    final planned = trip.budget.fold<double>(
      0,
      (sum, item) => sum + item.planned,
    );
    final actual = trip.budget.fold<double>(
      0,
      (sum, item) => sum + item.actual,
    );
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Budget')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList.list(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip budget',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        money.format(planned - actual),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Text('remaining'),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value:
                            planned == 0 ? 0 : (actual / planned).clamp(0, 1),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${money.format(actual)} of ${money.format(planned)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...trip.budget.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${money.format(item.actual)} / ${money.format(item.planned)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: item.planned == 0
                                ? 0
                                : (item.actual / item.planned).clamp(0, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
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
