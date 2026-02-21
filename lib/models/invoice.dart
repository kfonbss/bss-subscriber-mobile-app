class Invoice {
  final String invoiceNo;
  final String grossAmount;
  final String invoiceDate;
  final String time;
  final String month;
  final String status;
  final double revenue;
  final double lnpShare;
  final double monthlyIncentive;
  final double netShare;
  final double invoiceValue;
  final double netPayable;

  const Invoice({
    required this.invoiceNo,
    required this.grossAmount,
    required this.invoiceDate,
    required this.time,
    required this.status, required this.month, required this.revenue, required this.lnpShare, required this.monthlyIncentive, required this.netShare, required this.invoiceValue, required this.netPayable,
  });
}