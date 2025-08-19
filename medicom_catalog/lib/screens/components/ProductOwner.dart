import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:provider/provider.dart';

bool isProductOwner(BuildContext context, int ownerId) {
  AppUser appUser =
      Provider.of<AppUserNotifier>(context, listen: false).appUser!;

  return appUser.id_app_user == ownerId || appUser.isAdmin;
}
