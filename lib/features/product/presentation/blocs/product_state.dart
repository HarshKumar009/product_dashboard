import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final bool hasReachedMax;
  final List<ProductModel>? filteredProducts;
  final int totalProducts;

  final int totalInStock;
  final int totalCategories;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.filteredProducts,
    this.totalProducts = 0,
    this.totalInStock = 0,
    this.totalCategories = 0,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    bool? hasReachedMax,
    List<ProductModel>? filteredProducts,
    bool? clearFilter,
    int? totalProducts,
    int? totalInStock,
    int? totalCategories,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filteredProducts: clearFilter == true ? null : filteredProducts ?? this.filteredProducts,
      totalProducts: totalProducts ?? this.totalProducts,
      totalInStock: totalInStock ?? this.totalInStock,
      totalCategories: totalCategories ?? this.totalCategories,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax, filteredProducts, totalProducts, totalInStock, totalCategories];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object> get props => [message];
}