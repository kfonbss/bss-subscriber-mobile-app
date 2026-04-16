part of '../pages/data_usage_view.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity? session;

  const SessionCard({super.key, required this.session});

  static final _dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final s = session!;
    final l10n = context.bssSubL10n;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Container(
      width: double.infinity,
      decoration: AppStyles.boxDecorationLarge,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sessionInformation, style: sectionStyle),
          const SizedBox(height: 10),
          _infoRow(l10n.startTime, _dateFormat.format(s.startTime), labelStyle, valueStyle),
          _infoRow(
            l10n.endTime,
            s.endTime != null ? _dateFormat.format(s.endTime!) : l10n.ongoing,
            labelStyle,
            valueStyle,
          ),
          _infoRow(l10n.duration, s.sessionDuration, labelStyle, valueStyle),
          const SizedBox(height: 16),

          Text(l10n.dataUsage, style: sectionStyle),
          const SizedBox(height: 10),
          _infoRow(l10n.upload, l10n.valueInMb(s.uploadMb.toString()), labelStyle, valueStyle),
          _infoRow(l10n.download, l10n.valueInMb(s.downloadMb.toString()), labelStyle, valueStyle),
          _infoRow(l10n.total, l10n.valueInMb(s.totalMb.toString()), labelStyle, valueStyle),
          const SizedBox(height: 16),

          Text(l10n.networkDetails, style: sectionStyle),
          const SizedBox(height: 10),
          _infoRow(l10n.mac, s.networkDetails.mac, labelStyle, valueStyle),
          _infoRow(l10n.framedIp, s.networkDetails.framedIp, labelStyle, valueStyle),
          _infoRow(l10n.framedIpv6Prefix, s.networkDetails.framedIpv6Prefix, labelStyle, valueStyle),
          _infoRow(l10n.framedIpv6Delegated, s.networkDetails.framedIpv6Delegated, labelStyle, valueStyle),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, TextStyle? labelStyle, TextStyle? valueStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
