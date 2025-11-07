import '../../data/datasources/product_remote_data_source.dart';

abstract class ProductRepository {
  Future<ProductResponse> getProducts(int limit, int skip);
}