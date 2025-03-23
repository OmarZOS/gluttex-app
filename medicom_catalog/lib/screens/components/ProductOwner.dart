import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

bool is_product_owner(BuildContext context, int ownerId) {
  // return true;
  return Provider.of<AppUserNotifier>(context, listen: false)
          .appUser!
          .id_app_user ==
      ownerId;
}
