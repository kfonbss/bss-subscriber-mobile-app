part of '../pages/data_usage_view.dart';

class _DataUsageChart extends StatelessWidget {
  final List<GraphDataEntity> graphData;
  final String period;
  final Function(String) onPeriodChanged;

  const _DataUsageChart({
    required this.graphData,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (graphData.isEmpty) {
      return const SizedBox.shrink();
    }

    final usageSpots = graphData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble() + 1, e.value.usageGb))
        .toList();

    final maxY = graphData.isNotEmpty
        ? graphData.map((e) => e.usageGb).reduce((a, b) => a > b ? a : b)
        : 10.0;

    final adjustedMaxY = maxY * 1.2;

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: AppStyles.boxDecorationLarge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Data Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.kYellowBackground,
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Weekly',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                  onSelected: onPeriodChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'DAY',
                      child: Row(
                        children: [
                          Icon(Icons.today, size: 18),
                          SizedBox(width: 12),
                          Text('Day'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'WEEK',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_view_week, size: 18),
                          SizedBox(width: 12),
                          Text('Week'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'MONTH',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_view_month, size: 18),
                          SizedBox(width: 12),
                          Text('Month'),
                        ],
                      ),
                    ),
                  ],
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  color: AppColor.kMainBackgroundColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: graphData.length.toDouble(),
                  minY: 0,
                  maxY: adjustedMaxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: adjustedMaxY / 5,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: adjustedMaxY / 5,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            '${value.toInt()} GB',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: AppColor.kTextSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt() - 1;
                          if (index < 0 || index >= graphData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              graphData[index].day,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: AppColor.kTextSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (barData, spotIndexes) =>
                        spotIndexes.map((_) => null).toList(),
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      getTooltipColor: (LineBarSpot touchedSpot) =>
                          AppColor.kSecondaryBackgroundColor,
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: usageSpots,
                      isCurved: true,
                      barWidth: 1.5,
                      color: theme.colorScheme.primary,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
