class MoneyModel {
  final String display;
  final String currency;
  final double amount;
  final int minorAmount;

  MoneyModel({
    required this.display,
    required this.currency,
    required this.amount,
    required this.minorAmount,
  });

  MoneyModel.fromJson(Map<String, dynamic> json)
      : display = json['display'],
        currency = json['currency'],
        amount =
            json['amount'] is int ? json['amount'].toDouble() : json['amount'],
        minorAmount = json['minor_amount'];
}
