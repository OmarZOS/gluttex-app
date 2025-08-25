import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/supplier_form_page.dart';
import 'package:gluttex_ui/components/supplier_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_locations_screen.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildPanelContent(
    BuildContext context,
    List<Supplier> suppliers,
    bool isLoading,
    ScrollController scrollController,
    Function focusOnLocation) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context)!;
  final isDarkMode = theme.brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Drag Handle
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          loc.providersText,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 8),

      // Supplier List
      Expanded(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : suppliers.isEmpty
                ? Center(
                    child: Text(
                      loc.notFoundError,
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      final category = loc.providerCategoryTextList
                          .split(",")[supplier.productProviderTypeId - 1];

                      return Card(
                        color: (isDarkMode)
                            ? theme.colorScheme.primaryContainer
                                .withOpacity(0.2)
                            : null,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          // tileColor: theme.colorScheme.onSurfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Image.network(
                                GluttexConstants.fsBaseUrl +
                                    (supplier.supplier_image_url ?? ""),

                                // fit: BoxFit.cover, // Covers all available space
                                width: 40,
                                height: 40,
                                alignment:
                                    Alignment.center, // Centers the image
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return
                                      // SizedBox.expand(
                                      // Fallback also fills space
                                      // child:
                                      SvgPicture.asset(
                                    'assets/icons/${supplier.productProviderTypeId}.svg',
                                    package: "gluttex_localiser",
                                    width: 30,
                                    height: 30,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    // ),
                                  );
                                },
                                key: ValueKey(supplier.supplier_image_url),
                              )),
                          title: Wrap(
                            spacing: 8, // space between items
                            runSpacing: 4, // space between lines if wrapped
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                supplier.providerName,
                                style: theme.textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category, // e.g. "Restaurant"
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          subtitle: Text(
                            AppLocalizations.of(context)!.by_organisation(
                                supplier.provider_organisation_name),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.locationDot,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () => focusOnLocation(
                              supplier.locationLatitude,
                              supplier.locationLongitude,
                            ),
                          ),
                          onTap: () {
                            showSupplierDetails(context, supplier);
                          },
                        ),
                      );
                    },
                  ),
      ),
    ],
  );
}
