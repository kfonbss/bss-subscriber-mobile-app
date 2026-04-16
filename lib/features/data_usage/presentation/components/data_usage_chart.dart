part of '../pages/data_usage_view.dart';

class _DataUsageChart extends StatefulWidget {
  final List<GraphDataEntity> graphData;
  final String period;
  final Function(String) onPeriodChanged;

  const _DataUsageChart({
    required this.graphData,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  State<_DataUsageChart> createState() => _DataUsageChartState();
}

class _DataUsageChartState extends State<_DataUsageChart> {
  late List<FlSpot> _usageSpots;
  late double _adjustedMaxY;
  late Color _belowBarColor;

  // Allocated once per app-lifetime — AppColor.kYellowBackground and the
  // radius are compile-time constants so the whole BoxDecoration is too.
  static const _periodButtonDecoration = BoxDecoration(
    color: AppColor.kYellowBackground,
    borderRadius: BorderRadius.all(Radius.circular(12.5)),
  );

  @override
  void initState() {
    super.initState();
    _recompute(widget.graphData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cached here so build() doesn't call withValues() on every frame.
    _belowBarColor =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
  }

  @override
  void didUpdateWidget(_DataUsageChart old) {
    super.didUpdateWidget(old);
    if (!identical(old.graphData, widget.graphData)) {
      _recompute(widget.graphData);
    }
  }

  void _recompute(List<GraphDataEntity> data) {
    _usageSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble() + 1, e.value.usageGb))
        .toList();
    final maxY = data.isNotEmpty
        ? data.map((e) => e.usageGb).reduce((a, b) => a > b ? a : b)
        : 10.0;
    _adjustedMaxY = maxY * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.graphData.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  context.bssSubL10n.dataUsage,
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
                    decoration: _periodButtonDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.bssSubL10n.weekly,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                  onSelected: widget.onPeriodChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'DAY',
                      child: Row(
                        children: [
                          const Icon(Icons.today, size: 18),
                          const SizedBox(width: 12),
                          Text(context.bssSubL10n.day),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'WEEK',
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_view_week, size: 18),
                          const SizedBox(width: 12),
                          Text(context.bssSubL10n.week),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'MONTH',
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_view_month, size: 18),
                          const SizedBox(width: 12),
                          Text(context.bssSubL10n.month),
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
                  maxX: widget.graphData.length.toDouble(),
                  minY: 0,
                  maxY: _adjustedMaxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: _adjustedMaxY / 5,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0x26808080), // grey @ 15% opacity
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
                        interval: _adjustedMaxY / 5,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            context.bssSubL10n.valueInGb(value.toInt().toString()),
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
                          if (index < 0 || index >= widget.graphData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.graphData[index].day,
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
                      spots: _usageSpots,
                      isCurved: true,
                      barWidth: 1.5,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _belowBarColor,
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
