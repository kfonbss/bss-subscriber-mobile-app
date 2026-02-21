/// Parameters for initiating a wallet topup request.
class TopupParams {
  final double amount;
  final String type;

  const TopupParams({required this.amount, required this.type});

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'type': type};
  }
}
