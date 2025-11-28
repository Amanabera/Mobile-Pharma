class Stock {
  final int id;
  final String product;
  final String category;
  final int quantity;
  final double price;
  final int userId;
  final String userName;
  final String createdAt;

  Stock({
    required this.id,
    required this.product,
    required this.category,
    required this.quantity,
    required this.price,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as int,
      product: json['product'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'category': category,
      'quantity': quantity,
      'price': price,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
    };
  }
}
