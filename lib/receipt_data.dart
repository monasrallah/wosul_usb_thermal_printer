class ReceiptData {
  final String restaurantName;
  final String dateTime;
  final List<ReceiptItem> items;
  final double total;
  final String qrData;

  ReceiptData({
    required this.restaurantName,
    required this.dateTime,
    required this.items,
    required this.total,
    required this.qrData,
  });

  static ReceiptData generateSampleReceipt() {
    final now = DateTime.now();
    final dateTime = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} '
        '${now.hour >= 12 ? 'PM' : 'AM'}';

    final items = [
      ReceiptItem(name: 'Burger', quantity: 2, price: 9.99),
      ReceiptItem(name: 'Fries', quantity: 1, price: 3.99),
      ReceiptItem(name: 'Soda', quantity: 2, price: 1.99),
      ReceiptItem(name: 'Salad', quantity: 1, price: 7.99),
      ReceiptItem(name: 'Ice Cream', quantity: 1, price: 4.99),
    ];

    final total = items.fold(0.0, (sum, item) => sum + (item.quantity * item.price));

    return ReceiptData(
      restaurantName: 'Tasty Bites Restaurant',
      dateTime: dateTime,
      items: items,
      total: total,
      qrData: 'https://example.com/receipt/${now.millisecondsSinceEpoch}',
    );
  }
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
