import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';

bool isBusinessOwner(BuildContext context, int ownerId) {
  AppUser appUser =
      Provider.of<AppUserNotifier>(context, listen: false).appUser!;

  return appUser.id_app_user == ownerId || appUser.isAdmin;
}
