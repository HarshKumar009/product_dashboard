import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['title'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
    );
  }

  @override
  List<Object?> get props => [id, name, category, price, stock];
}