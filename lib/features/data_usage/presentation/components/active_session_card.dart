part of '../pages/data_usage_view.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity? session;

  const SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    return Container(
      width: double.infinity,
      decoration: AppStyles.boxDecorationLarge,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Start Time',
            dateFormat.format(session!.startTime),
            theme,
          ),
          _infoRow(
            'End Time',
            session!.endTime != null
                ? dateFormat.format(session!.endTime!)
                : 'Ongoing',
            theme,
          ),
          _infoRow('Duration', session!.sessionDuration, theme),
          const SizedBox(height: 16),

          Text(
            'Data Usage',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow('Upload', '${session!.uploadMb} MB', theme),
          _infoRow('Download', '${session!.downloadMb} MB', theme),
          _infoRow('Total', '${session!.totalMb} MB', theme),
          const SizedBox(height: 16),

          Text(
            'Network Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow('MAC', session!.networkDetails.mac, theme),
          _infoRow('Framed-IP', session!.networkDetails.framedIp, theme),
          _infoRow(
            'Framed-IPv6 Prefix',
            session!.networkDetails.framedIpv6Prefix,
            theme,
          ),
          _infoRow(
            'Framed-IPv6 Delegated',
            session!.networkDetails.framedIpv6Delegated,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
