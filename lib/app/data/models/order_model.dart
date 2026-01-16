class OrderModel {
  final int id;
  final String title;
  final double amount;
  final String status;
  final String date;

  OrderModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });
}
