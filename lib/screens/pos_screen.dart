import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vendify/models/product.dart';
import 'package:vendify/models/sale.dart';
import 'package:vendify/models/sale_detail.dart';
import 'package:vendify/services/auth_service.dart';
import 'package:vendify/services/product_service.dart';
import 'package:vendify/services/sale_service.dart';
import 'package:vendify/theme.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.salePrice * quantity;
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  final List<CartItem> _cart = [];
  String _searchQuery = '';
  String _paymentMethod = 'Efectivo';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productService = context.read<ProductService>();
      productService.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      if (_cart[existingIndex].quantity < product.stock) {
        setState(() => _cart[existingIndex].quantity++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock insuficiente')),
        );
      }
    } else {
      if (product.stock > 0) {
        setState(() => _cart.add(CartItem(product: product)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto sin stock')),
        );
      }
    }
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else if (quantity <= _cart[index].product.stock) {
      setState(() => _cart[index].quantity = quantity);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente')),
      );
    }
  }

  double get _subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _tax => _subtotal * 0.16;
  double get _total => _subtotal + _tax;

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final now = DateTime.now();

    final sale = Sale(
      userId: authService.currentUser!.id!,
      customerId: 1,
      subtotal: _subtotal,
      tax: _tax,
      total: _total,
      paymentMethod: _paymentMethod,
      createdAt: now,
      updatedAt: now,
    );

    final details = _cart.map((item) => SaleDetail(
      saleId: 0,
      productId: item.product.id!,
      productName: item.product.name,
      quantity: item.quantity,
      unitPrice: item.product.salePrice,
      subtotal: item.subtotal,
      createdAt: now,
      updatedAt: now,
    )).toList();

    final saleId = await context.read<SaleService>().createSale(sale, details);

    if (saleId != null) {
      for (var item in _cart) {
        await context.read<ProductService>().updateStock(
          item.product.id!,
          item.quantity,
        );
      }

      if (mounted) {
        setState(() => _cart.clear());
        _showSuccessDialog(saleId);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar la venta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(int saleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Venta Completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket #$saleId'),
            const SizedBox(height: AppSpacing.sm),
            Text('Total: \$${_total.toStringAsFixed(2)}'),
            Text('Método: $_paymentMethod'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;
    final productService = context.watch<ProductService>();
    
    final filteredProducts = _searchQuery.isEmpty
        ? productService.products
        : productService.searchProducts(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: AppSpacing.paddingMd,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _addToCart(product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 350,
            color: colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Container(
                  padding: AppSpacing.paddingMd,
                  color: colorScheme.primary,
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Carrito (${_cart.length})',
                        style: textTheme.titleMedium?.semiBold.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Carrito vacío',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: AppSpacing.paddingMd,
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return CartItemWidget(
                              item: item,
                              onRemove: () => _removeFromCart(index),
                              onQuantityChanged: (qty) => _updateQuantity(index, qty),
                            );
                          },
                        ),
                ),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: textTheme.bodyMedium),
                          Text('\$${_subtotal.toStringAsFixed(2)}', style: textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('IVA (16%):', style: textTheme.bodyMedium),
                          Text('\$${_tax.toStringAsFixed(2)}', style: textTheme.bodyMedium),
                        ],
                      ),
                      const Divider(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: textTheme.titleLarge?.semiBold),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: textTheme.titleLarge?.semiBold.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Método de Pago',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Efectivo', 'Tarjeta'].map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _paymentMethod = value!),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _cart.isEmpty ? null : _completeSale,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                          ),
                          child: const Text('Confirmar Venta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: colorScheme.primary,
              ),
              const Spacer(),
              Text(
                product.name,
                style: textTheme.titleSmall?.semiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '\$${product.salePrice.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.semiBold.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Stock: ${product.stock}',
                style: textTheme.bodySmall?.copyWith(
                  color: product.stock > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textStyles;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: AppSpacing.paddingSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.product.name,
                    style: textTheme.titleSmall?.semiBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '\$${item.product.salePrice.toStringAsFixed(2)} c/u',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => onQuantityChanged(item.quantity - 1),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    Padding(
                      padding: AppSpacing.horizontalSm,
                      child: Text(
                        '${item.quantity}',
                        style: textTheme.titleMedium?.semiBold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.semiBold.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
