part of '../pages/data_usage_view.dart';

class DataUsageSessionHistoryCard extends StatelessWidget {
  final List<SessionEntity> sessionHistory;

  const DataUsageSessionHistoryCard({super.key, required this.sessionHistory});

  @override
  Widget build(BuildContext context) {
    if (sessionHistory.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.bssSubL10n.sessionHistory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < sessionHistory.length; i++) ...[
          _SessionListTile(session: sessionHistory[i]),
          if (i < sessionHistory.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final SessionEntity session;

  const _SessionListTile({required this.session});

  static final _dateFormat = DateFormat('dd MMM yyyy HH:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    final lightStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300);
    final l10n = context.bssSubL10n;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionHistoryDetailPage(session: session),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.boxDecorationMedium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateFormat.format(session.startTime),
                  style: boldStyle,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.durationValue(session.sessionDuration),
                      style: lightStyle,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      l10n.totalValueMb(session.totalMb.toString()),
                      style: lightStyle,
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColor.kRadioButtonTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
