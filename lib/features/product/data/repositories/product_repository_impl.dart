import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductResponse> getProducts(int limit, int skip) async {
    try {
      return await remoteDataSource.getProducts(limit, skip);
    } catch (e) {
      throw Exception('Error in repository: $e');
    }
  }
}