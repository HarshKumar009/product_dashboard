import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';

class ProductResponse {
  final List<ProductModel> products;
  final int total;
  ProductResponse({required this.products, required this.total});
}

abstract class ProductRemoteDataSource {
  Future<ProductResponse> getProducts(int limit, int skip);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  ProductRemoteDataSourceImpl({required this.client});

  final String _baseUrl = "https://dummyjson.com/products";

  @override
  Future<ProductResponse> getProducts(int limit, int skip) async {
    final fullUrl = '$_baseUrl?limit=$limit&skip=$skip';
    final response = await client.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productListJson = data['products'];

      final int totalProducts = data['total'] ?? 0;

      final products = productListJson.map((json) => ProductModel.fromJson(json)).toList();

      return ProductResponse(products: products, total: totalProducts);
    } else {
      throw Exception('Failed to load products from API');
    }
  }
}