import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  static const List<Color> colors = [
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (sum, v) => sum + v);
    final entries = widget.data.entries.toList();

    final percentages = entries.map((e) => e.value / total * 100).toList();

    final minVisiblePercent = 5.0;
    final displayValues = <double>[];

    for (final pct in percentages) {
      displayValues.add(pct < minVisiblePercent ? minVisiblePercent : pct);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == touchedIndex;
                    final fontSize = isTouched ? 14.0 : 10.0;
                    final radius = isTouched ? 65.0 : 55.0;
                    final realPercentage = percentages[i];

                    final displayText = realPercentage < 1
                        ? '<1%'
                        : '${realPercentage.toStringAsFixed(0)}%';

                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: displayValues[i],
                      title: displayText,
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 2),
                        ],
                      ),
                      titlePositionPercentageOffset: 0.55,
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(entries.length, (i) {
                final pct = percentages[i];
                final pctText = pct < 1
                    ? '(<1%)'
                    : '(${pct.toStringAsFixed(0)}%)';

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entries[i].key} $pctText',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: touchedIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: List.generate(entries.length, (i) {
                return Text(
                  '${entries[i].key}: ${Formatters.currency(entries[i].value)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
