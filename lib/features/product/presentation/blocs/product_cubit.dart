import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_dashboard/features/product/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;
  final int _limit = 15;

  ProductCubit({required this.productRepository}) : super(ProductInitial());

  Future<void> fetchInitialProducts() async {
    try {
      emit(ProductLoading());

      final allProductsResponse = await productRepository.getProducts(0, 0);
      final allProducts = allProductsResponse.products;

      final int trueTotalInStock = allProducts.where((p) => p.stock > 0).length;
      final int trueTotalCategories = allProducts.map((p) => p.category).toSet().length;

      final firstPageResponse = await productRepository.getProducts(_limit, 0);

      emit(ProductLoaded(
        products: firstPageResponse.products,
        totalProducts: allProductsResponse.total,
        totalInStock: trueTotalInStock,
        totalCategories: trueTotalCategories,
        hasReachedMax: firstPageResponse.products.isEmpty,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchMoreProducts() async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final response = await productRepository.getProducts(_limit, currentState.products.length);
        if (response.products.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(currentState.copyWith(
            products: List.of(currentState.products)..addAll(response.products),
            hasReachedMax: false,
          ));
        }
      } catch (e) {
      }
    }
  }

  void addProduct(ProductModel product) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final updatedList = List<ProductModel>.from(currentState.products)..add(product);
      emit(currentState.copyWith(products: updatedList));
    }
  }


  void sortProducts(int columnIndex, bool ascending) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final products = List<ProductModel>.from(currentState.products);

      products.sort((a, b) {
        int comparison;
        switch (columnIndex) {
          case 0:
            comparison = a.id.compareTo(b.id);
            break;
          case 1:
            comparison = a.name.compareTo(b.name);
            break;
          case 2:
            comparison = a.category.compareTo(b.category);
            break;
          case 3:
            comparison = a.price.compareTo(b.price);
            break;
          case 4:
            comparison = a.stock.compareTo(b.stock);
            break;
          default:
            return 0;
        }
        return ascending ? comparison : -comparison;
      });

      emit(currentState.copyWith(products: products));
    }
  }


  void updateProduct(ProductModel updatedProduct) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      final updatedList = currentState.products.map((product) {
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      emit(currentState.copyWith(products: updatedList));
    }
  }

  void deleteProduct(int productId) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      final updatedList = currentState.products.where((product) => product.id != productId).toList();

      emit(currentState.copyWith(products: updatedList));
    }
  }

  void filterProducts(String query) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      if (query.isEmpty) {
        emit(currentState.copyWith(clearFilter: true));
      } else {
        final filtered = currentState.products.where((product) {
          final queryLower = query.toLowerCase();
          return product.name.toLowerCase().contains(queryLower) ||
              product.category.toLowerCase().contains(queryLower);
        }).toList();
        emit(currentState.copyWith(filteredProducts: filtered));
      }
    }
  }
}