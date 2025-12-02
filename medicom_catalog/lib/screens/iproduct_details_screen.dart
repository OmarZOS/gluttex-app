import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/iProduct.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:provider/provider.dart';

class IProductDetailsScreen extends StatelessWidget {
  final IProduct iproduct;

  const IProductDetailsScreen({Key? key, required this.iproduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Back Button
          SliverAppBar(
            expandedHeight: 320,
            collapsedHeight: 80,
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.only(top: 12, left: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
                color: colorScheme.onSurface,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(context),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(GluttexConstants.kDefaultPaddin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Header with Gluten Badge
                    _buildProductHeader(context),
                    const SizedBox(height: 28),

                    // Key Information Cards
                    _buildInfoCards(context),
                    const SizedBox(height: 32),

                    // Detailed Information
                    _buildDetailedInfo(context),
                    const SizedBox(height: 32),

                    // Available Products Section
                    _buildAvailableProducts(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Color
        Container(
          color: colorScheme.primary.withOpacity(0.05),
        ),

        // Product Image or Gradient
        if (iproduct.iproductImageUrl != null &&
            iproduct.iproductImageUrl!.isNotEmpty)
          Image.network(
            iproduct.iproductImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: colorScheme.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colorScheme.surface.withOpacity(0.3),
                colorScheme.surface.withOpacity(0.8),
                colorScheme.surface,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(
                iproduct.iproductName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Brand
              if (iproduct.iproductBrand.isNotEmpty)
                Text(
                  iproduct.iproductBrand,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              const SizedBox(height: 16),

              // Barcode with copy functionality
              _buildBarcodeSection(context),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Gluten Free Badge (Premium Medal Style)
        _buildGlutenFreeBadge(context),
      ],
    );
  }

  Widget _buildGlutenFreeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isGlutenFree = iproduct.iproductGlutenStatus == 'gluten_free';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isGlutenFree
            ? const RadialGradient(
                colors: [
                  Color(0xFF10B981), // Emerald
                  Color(0xFF059669),
                  Color(0xFF047857),
                ],
                center: Alignment.topLeft,
                radius: 0.8,
              )
            : RadialGradient(
                colors: [
                  colorScheme.error,
                  colorScheme.error.withOpacity(0.8),
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: isGlutenFree
                ? const Color(0xFF10B981).withOpacity(0.5)
                : colorScheme.error.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 20,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),

          // Middle Ring
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),

          // Inner Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGlutenFree ? Icons.verified : Icons.warning_rounded,
                size: 32,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isGlutenFree ? 'GLUTEN\nFREE' : 'CONTAINS\nGLUTEN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Shine Effect
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  iproduct.iproductBarcode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Monospace',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
            onPressed: () {
              // Copy barcode to clipboard
              // Clipboard.setData(ClipboardData(text: iproduct.iproductBarcode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Barcode copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInfoCard(
          context,
          icon: Icons.price_change_rounded,
          title: 'Price',
          value: iproduct.formattedPrice,
          color: colorScheme.primary,
          isRecent: iproduct.isPriceRecent,
        ),
        _buildInfoCard(
          context,
          icon: _getSourceIcon(iproduct.iproductSource),
          title: 'Source',
          value: _getSourceText(iproduct.iproductSource),
          color: colorScheme.secondary,
        ),
        _buildInfoCard(
          context,
          icon: Icons.model_training_rounded,
          title: 'Model',
          value: iproduct.iproductModelName,
          color: colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isRecent = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              if (isRecent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Recent',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Created',
            value: _formatDate(iproduct.iproductCreatedAt),
          ),
          _buildDetailRow(
            context,
            icon: Icons.update_rounded,
            label: 'Last Updated',
            value: _formatDate(iproduct.iproductUpdatedAt),
          ),
          if (iproduct.iproductLastPriceUpdate != null)
            _buildDetailRow(
              context,
              icon: Icons.price_check_rounded,
              label: 'Price Updated',
              value: _formatDate(iproduct.iproductLastPriceUpdate!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableProducts(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available Products',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Live Search',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Real products from providers matching this barcode',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // FutureBuilder for real products
        Consumer<ProductNotifier>(
          builder: (context, productNotifier, child) {
            // Initialize search for this barcode once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Only search if not already searching and we haven't searched for this barcode
              final alreadySearched = productNotifier.currentSearchQuery ==
                  iproduct.iproductBarcode;
              if (!productNotifier.isLoading && !alreadySearched) {
                productNotifier.searchProducts(iproduct.iproductBarcode,
                    reset: true);
              }
            });

            // Check if current search matches our barcode
            final isRelevantSearch =
                productNotifier.currentSearchQuery == iproduct.iproductBarcode;

            if (productNotifier.isLoading && isRelevantSearch) {
              return _buildProductsLoading(context);
            }

            // Get products from notifier
            final products = productNotifier.products;

            // Filter by barcode match (since search might not filter perfectly)
            final matchingProducts = products.where((product) {
              // You might need to check product.barcode or other fields
              // Adjust based on your Product model
              return product.product_barcode == iproduct.iproductBarcode ||
                  product.product_barcode!.contains(iproduct.iproductBarcode);
            }).toList();

            if (matchingProducts.isEmpty) {
              // If we're not loading and have no results
              if (!productNotifier.isLoading && isRelevantSearch) {
                return _buildNoProductsFound(context);
              }
              // If we haven't searched yet or search is for something else
              return _buildProductsLoading(context);
            }

            return _buildProductsList(context, matchingProducts);
          },
        )
      ],
    );
  }

  Future<void> _searchRealProducts(BuildContext context, String barcode) async {
    // Use your ProductNotifier to search for real products
    final notifier = context.read<ProductNotifier>();
    return await notifier.searchProducts(barcode);
  }

  Widget _buildProductsLoading(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Searching for products...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsError(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load products',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Error: $error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsFound(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No real products found matching this barcode. Try scanning again or check other stores.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, List<Product> products) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 100,
                width: double.infinity,
                color: colorScheme.surfaceVariant,
                child: product.product_image_url != null
                    ? Image.network(
                        product.product_image_url!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          size: 40,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
              ),

              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.product_name ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Provider
                      Row(
                        children: [
                          Icon(
                            Icons.store_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (product.product_provider_id ?? 0) as String,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Icon(
                            Icons.price_change_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (product.product_price ?? 0.0) as String,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getSourceIcon(String source) {
    if (source.contains('ai') || source.contains('generated')) {
      return Icons.psychology_rounded;
    } else if (source.contains('manual') || source.contains('user')) {
      return Icons.person_rounded;
    } else if (source.contains('scan')) {
      return Icons.qr_code_scanner_rounded;
    }
    return Icons.source_rounded;
  }

  String _getSourceText(String source) {
    if (source.contains('ai_generated')) return 'AI Generated';
    if (source.contains('manual')) return 'Manual Entry';
    if (source.contains('scan')) return 'Scanned';
    return source.replaceAll('_', ' ').toTitleCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

// Models (adjust based on your actual models)

// Mock ProductNotifier for demonstration
// class ProductNotifier {
//   Future<List<RealProduct>> searchProductsByBarcode(String barcode) async {
//     // Implement your actual search logic here
//     await Future.delayed(const Duration(seconds: 2));

//     // Mock data
//     return [
//       RealProduct(
//         id: '1',
//         name: 'Organic Gluten Free Bread',
//         providerName: 'Whole Foods Market',
//         price: 4.99,
//         imageUrl: 'https://via.placeholder.com/150',
//       ),
//       RealProduct(
//         id: '2',
//         name: 'Premium Gluten Free Pasta',
//         providerName: 'Trader Joe\'s',
//         price: 3.49,
//       ),
//       RealProduct(
//         id: '3',
//         name: 'Gluten Free Cookies',
//         providerName: 'Walmart',
//         price: 2.99,
//       ),
//     ];
//   }
// }

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }
}
