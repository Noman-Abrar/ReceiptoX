import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/receipt_model.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  final List<ReceiptModel> receipts;

  const StatsScreen({super.key, required this.receipts});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Map<String, double> _monthlyTotals() {
    final totals = <String, double>{};
    for (final r in receipts) {
      final key = _monthNames[r.date.month - 1];
      totals[key] = (totals[key] ?? 0) + r.amount;
    }
    return totals;
  }

  Map<String, double> _categoryTotals() {
    final totals = <String, double>{};
    for (final r in receipts) {
      totals[r.category] = (totals[r.category] ?? 0) + r.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Text(
            'No spending data yet.\nScan a receipt to see stats.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
        ),
      );
    }

    final monthly = _monthlyTotals();
    final monthKeys = monthly.keys.toList();
    final category = _categoryTotals();
    final totalSpent = category.values.fold(0.0, (a, b) => a + b);

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Monthly Spending',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                backgroundColor: AppColors.background,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthKeys.length) return const SizedBox();
                        return Text(monthKeys[index], style: const TextStyle(color: Colors.white70, fontSize: 12));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) =>
                          Text('\$${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ),
                ),
                barGroups: List.generate(monthKeys.length, (index) {
                  final amount = monthly[monthKeys[index]] ?? 0;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: amount,
                      color: AppColors.primary,
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    )
                  ]);
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Category-wise Expenses',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: category.entries.map((e) {
                  final percent = totalSpent > 0 ? (e.value / totalSpent) * 100 : 0;
                  return PieChartSectionData(
                    value: e.value,
                    title: '${percent.toStringAsFixed(1)}%',
                    color: AppColors.categoryColor(e.key),
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: category.keys
                .map((c) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: AppColors.categoryColor(c), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(c, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text('Total Receipts: ${receipts.length}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
