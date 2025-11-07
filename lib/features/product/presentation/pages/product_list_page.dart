import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/product_model.dart';
import '../widgets/add_edit_product_form.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (context.read<ProductCubit>().state is! ProductLoaded) {
      context.read<ProductCubit>().fetchInitialProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductCubit>().fetchMoreProducts();
    }
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              context.read<ProductCubit>().deleteProduct(product.id);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: AddEditProductForm(
            onSubmit: (name, category, price, stock) {
              final currentState = context.read<ProductCubit>().state;
              if (currentState is ProductLoaded) {
                final newId = currentState.products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
                final newProduct = ProductModel(id: newId, name: name, category: category, price: price, stock: stock);
                context.read<ProductCubit>().addProduct(newProduct);
              }
            },
          ),
        );
      },
    );
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
    context.read<ProductCubit>().sortProducts(columnIndex, ascending);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading || state is ProductInitial) {
                    return _buildLoadingShimmer();
                  } else if (state is ProductLoaded) {
                    final productsToShow = state.filteredProducts ?? state.products;

                    if (productsToShow.isEmpty && state.filteredProducts != null) {
                      return const Center(child: Text('No products match your search.'));
                    }
                    if (productsToShow.isEmpty) {
                      return const Center(child: Text('No products available. Add one to get started!'));
                    }

                    final totalProducts = state.totalProducts;
                    final inStock = state.totalInStock;
                    final categories = state.totalCategories;

                    return AnimationLimiter(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: productsToShow.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildSummaryCards(totalProducts, inStock, categories);
                          }
                          if (index >= productsToShow.length + 1) {
                            return state.hasReachedMax ? const SizedBox.shrink() : const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                          }
                          final product = productsToShow[index - 1];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildProductListItem(product),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is ProductError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Something went wrong!'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductListItem(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/product/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(product.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(product.category, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            product.stock > 0 ? '${product.stock} in Stock' : 'Out of Stock',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          labelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                          backgroundColor: product.stock > 0 ? Colors.green.shade600 : Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context, product),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: [
          Row(
            children: List.generate(3, (_) => Expanded(child: Card(child: SizedBox(height: 100, child: Container(color: Colors.white))))),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (_) => Card(child: ListTile(
            leading: const CircleAvatar(),
            title: Container(width: double.infinity, height: 16, color: Colors.white),
            subtitle: Container(width: 100, height: 12, color: Colors.white),
          )),
          ),
        ],
      ),
    );
  }




  Widget _buildSummaryCards(int total, int inStock, int categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildSummaryCard(icon: Icons.inventory_2_outlined, title: 'Total Products', value: total.toString(), color: Colors.blue),
              _buildSummaryCard(icon: Icons.check_circle_outline, title: 'In Stock', value: inStock.toString(), color: Colors.green),
              _buildSummaryCard(icon: Icons.category_outlined, title: 'Categories', value: categories.toString(), color: Colors.orange),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String title, required String value, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }




  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Products',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or category...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) {
                    context.read<ProductCubit>().filterProducts(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort Products',
                onSelected: (value) {
                  final parts = value.split('_');
                  final columnIndex = int.parse(parts[0]);
                  final ascending = parts[1] == 'asc';
                  _sort(columnIndex, ascending);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: '0_asc', child: Text('Sort by ID (Ascending)')),
                  const PopupMenuItem<String>(value: '0_desc', child: Text('Sort by ID (Descending)')),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(value: '1_asc', child: Text('Sort by Name (A-Z)')),
                  const PopupMenuItem<String>(value: '1_desc', child: Text('Sort by Name (Z-A)')),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(value: '3_asc', child: Text('Sort by Price (Low to High)')),
                  const PopupMenuItem<String>(value: '3_desc', child: Text('Sort by Price (High to Low)')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


}
