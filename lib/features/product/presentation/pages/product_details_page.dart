import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../../models/product_model.dart';
import '../widgets/add_edit_product_form.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  void _showEditProductDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${product.name}'),
          content: AddEditProductForm(
            product: product,
            onSubmit: (name, category, price, stock) {
              final updatedProduct = ProductModel(
                id: product.id,
                name: name,
                category: category,
                price: price,
                stock: stock,
              );
              context.read<ProductCubit>().updateProduct(updatedProduct);
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded) {
          ProductModel? product;
          try {
            product = state.products.firstWhere((p) => p.id == productId);
          } catch (e) {
            product = null;
          }

          if (product == null) {
            return const Center(
              child: Text(
                'Product not found!',
                style: TextStyle(fontSize: 24),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Product ID:', product.id.toString()),
                          _buildDetailRow('Category:', product.category),
                          _buildDetailRow('Price:', '\$${product.price.toStringAsFixed(2)}'),
                          _buildDetailRow('Stock Status:', product.stock > 0 ? "In Stock" : "Out of Stock"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16)
                    ),
                    onPressed: () {
                      _showEditProductDialog(context, product!);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Product'),
                  )
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }


}