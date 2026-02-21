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
          'Session History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ListView.separated(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, index) =>
              _SessionListTile(session: sessionHistory[index]),
          separatorBuilder: (_, __) => SizedBox(height: 16),
          itemCount: sessionHistory.length,
        ),
      ],
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final SessionEntity session;

  const _SessionListTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy HH:mm a');

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
                  dateFormat.format(session.startTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration : ${session.sessionDuration}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(width: 24),
                    Text(
                      '"Total : ${session.totalMb} MB',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
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
