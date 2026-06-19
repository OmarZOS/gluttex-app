import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

/// Custom localization extensions and helpers that work alongside
/// the auto-generated AppLocalizations.
///
/// This file is NOT auto-generated and can be modified freely.
class CustomLocalizations {
  final BuildContext context;

  CustomLocalizations(this.context);

  /// Access the auto-generated localizations
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  // --------------------------------------------------
  // INVENTORY & ACCESS RELATED
  // --------------------------------------------------
  String get noInventoryPrivilegesText => _l10n.noInventoryPrivilegesText;

  String labeledAmount(String quantifier) {
    switch (quantifier) {
      case "g":
        return _l10n.quantifier_g;
      case "kg":
        return _l10n.quantifier_kg;
      case "mg":
        return _l10n.quantifier_mg;
      case "L":
        return _l10n.quantifier_L;
      case "mL":
        return _l10n.quantifier_mL;
      case "pc":
        return _l10n.quantifier_pc;
      case "pkg":
        return _l10n.quantifier_pkg;
      case "box":
        return _l10n.quantifier_box;
      case "bag":
        return _l10n.quantifier_bag;
      case "slice":
        return _l10n.quantifier_slice;
      case "cup":
        return _l10n.quantifier_cup;
      default:
        return _l10n.notFoundError;
    }
  }

  String getLocalizedQuestion(int index) {
    switch (index) {
      case 1:
        return _l10n.question_1;
      case 2:
        return _l10n.question_2;
      case 3:
        return _l10n.question_3;
      case 4:
        return _l10n.question_4;
      case 5:
        return _l10n.question_5;
      case 6:
        return _l10n.question_6;
      case 7:
        return _l10n.question_7;
      case 8:
        return _l10n.question_8;
      case 9:
        return _l10n.question_9;
      case 10:
        return _l10n.question_10;
      case 11:
        return _l10n.question_11;
      case 12:
        return _l10n.question_12;
      case 13:
        return _l10n.question_13;
      case 14:
        return _l10n.question_14;
      case 15:
        return _l10n.question_15;
      case 16:
        return _l10n.question_16;
      case 17:
        return _l10n.question_17;
      case 18:
        return _l10n.question_18;
      case 19:
        return _l10n.question_19;
      case 20:
        return _l10n.question_20;
      case 21:
        return _l10n.question_21;
      case 22:
        return _l10n.question_22;
      case 23:
        return _l10n.question_23;
      case 24:
        return _l10n.question_24;
      case 25:
        return _l10n.question_25;
      case 26:
        return _l10n.question_26;
      case 27:
        return _l10n.question_27;
      case 28:
        return _l10n.question_28;
      case 29:
        return _l10n.question_29;
      case 30:
        return _l10n.question_30;
      case 31:
        return _l10n.question_31;
      case 32:
        return _l10n.question_32;
      case 33:
        return _l10n.question_33;
      case 34:
        return _l10n.question_34;
      case 35:
        return _l10n.question_35;
      case 36:
        return _l10n.question_36;
      case 37:
        return _l10n.question_37;
      case 38:
        return _l10n.question_38;
      case 39:
        return _l10n.question_39;
      case 40:
        return _l10n.question_40;
      case 41:
        return _l10n.question_41;
      case 42:
        return _l10n.question_42;
      case 43:
        return _l10n.question_43;
      case 44:
        return _l10n.question_44;
      case 45:
        return _l10n.question_45;
      case 46:
        return _l10n.question_46;
      case 47:
        return _l10n.question_47;
      case 48:
        return _l10n.question_48;
      case 49:
        return _l10n.question_49;
      case 50:
        return _l10n.question_50;
      case 51:
        return _l10n.question_51;
      case 52:
        return _l10n.question_52;
      case 53:
        return _l10n.question_53;
      case 54:
        return _l10n.question_54;
      case 55:
        return _l10n.question_55;
      case 56:
        return _l10n.question_56;
      case 57:
        return _l10n.question_57;
      case 58:
        return _l10n.question_58;
      case 59:
        return _l10n.question_59;
      case 60:
        return _l10n.question_60;
      case 61:
        return _l10n.question_61;
      case 62:
        return _l10n.question_62;
      case 63:
        return _l10n.question_63;
      case 64:
        return _l10n.question_64;
      case 65:
        return _l10n.question_65;
      case 66:
        return _l10n.question_66;
      case 67:
        return _l10n.question_67;
      case 68:
        return _l10n.question_68;
      case 69:
        return _l10n.question_69;
      case 70:
        return _l10n.question_70;
      case 71:
        return _l10n.question_71;
      case 72:
        return _l10n.question_72;
      case 73:
        return _l10n.question_73;
      case 74:
        return _l10n.question_74;
      case 75:
        return _l10n.question_75;
      case 76:
        return _l10n.question_76;
      case 77:
        return _l10n.question_77;
      case 78:
        return _l10n.question_78;
      case 79:
        return _l10n.question_79;
      case 80:
        return _l10n.question_80;
      case 81:
        return _l10n.question_81;
      case 82:
        return _l10n.question_82;
      case 83:
        return _l10n.question_83;
      case 84:
        return _l10n.question_84;
      case 85:
        return _l10n.question_85;
      case 86:
        return _l10n.question_86;
      case 87:
        return _l10n.question_87;
      case 88:
        return _l10n.question_88;
      case 89:
        return _l10n.question_89;
      case 90:
        return _l10n.question_90;
      case 91:
        return _l10n.question_91;
      case 92:
        return _l10n.question_92;
      case 93:
        return _l10n.question_93;
      case 94:
        return _l10n.question_94;
      case 95:
        return _l10n.question_95;
      case 96:
        return _l10n.question_96;
      case 97:
        return _l10n.question_97;
      case 98:
        return _l10n.question_98;
      case 99:
        return _l10n.question_99;
      case 100:
        return _l10n.question_100;
      default:
        return _l10n.notFoundError;
    }
  }

  String getLocalizedAnswerList(int index) {
    switch (index) {
      case 1:
        return _l10n.options_1;
      case 2:
        return _l10n.options_2;
      case 3:
        return _l10n.options_3;
      case 4:
        return _l10n.options_4;
      case 5:
        return _l10n.options_5;
      case 6:
        return _l10n.options_6;
      case 7:
        return _l10n.options_7;
      case 8:
        return _l10n.options_8;
      case 9:
        return _l10n.options_9;
      case 10:
        return _l10n.options_10;
      case 11:
        return _l10n.options_11;
      case 12:
        return _l10n.options_12;
      case 13:
        return _l10n.options_13;
      case 14:
        return _l10n.options_14;
      case 15:
        return _l10n.options_15;
      case 16:
        return _l10n.options_16;
      case 17:
        return _l10n.options_17;
      case 18:
        return _l10n.options_18;
      case 19:
        return _l10n.options_19;
      case 20:
        return _l10n.options_20;
      case 21:
        return _l10n.options_21;
      case 22:
        return _l10n.options_22;
      case 23:
        return _l10n.options_23;
      case 24:
        return _l10n.options_24;
      case 25:
        return _l10n.options_25;
      case 26:
        return _l10n.options_26;
      case 27:
        return _l10n.options_27;
      case 28:
        return _l10n.options_28;
      case 29:
        return _l10n.options_29;
      case 30:
        return _l10n.options_30;
      case 31:
        return _l10n.options_31;
      case 32:
        return _l10n.options_32;
      case 33:
        return _l10n.options_33;
      case 34:
        return _l10n.options_34;
      case 35:
        return _l10n.options_35;
      case 36:
        return _l10n.options_36;
      case 37:
        return _l10n.options_37;
      case 38:
        return _l10n.options_38;
      case 39:
        return _l10n.options_39;
      case 40:
        return _l10n.options_40;
      case 41:
        return _l10n.options_41;
      case 42:
        return _l10n.options_42;
      case 43:
        return _l10n.options_43;
      case 44:
        return _l10n.options_44;
      case 45:
        return _l10n.options_45;
      case 46:
        return _l10n.options_46;
      case 47:
        return _l10n.options_47;
      case 48:
        return _l10n.options_48;
      case 49:
        return _l10n.options_49;
      case 50:
        return _l10n.options_50;
      case 51:
        return _l10n.options_51;
      case 52:
        return _l10n.options_52;
      case 53:
        return _l10n.options_53;
      case 54:
        return _l10n.options_54;
      case 55:
        return _l10n.options_55;
      case 56:
        return _l10n.options_56;
      case 57:
        return _l10n.options_57;
      case 58:
        return _l10n.options_58;
      case 59:
        return _l10n.options_59;
      case 60:
        return _l10n.options_60;
      case 61:
        return _l10n.options_61;
      case 62:
        return _l10n.options_62;
      case 63:
        return _l10n.options_63;
      case 64:
        return _l10n.options_64;
      case 65:
        return _l10n.options_65;
      case 66:
        return _l10n.options_66;
      case 67:
        return _l10n.options_67;
      case 68:
        return _l10n.options_68;
      case 69:
        return _l10n.options_69;
      case 70:
        return _l10n.options_70;
      case 71:
        return _l10n.options_71;
      case 72:
        return _l10n.options_72;
      case 73:
        return _l10n.options_73;
      case 74:
        return _l10n.options_74;
      case 75:
        return _l10n.options_75;
      case 76:
        return _l10n.options_76;
      case 77:
        return _l10n.options_77;
      case 78:
        return _l10n.options_78;
      case 79:
        return _l10n.options_79;
      case 80:
        return _l10n.options_80;
      case 81:
        return _l10n.options_81;
      case 82:
        return _l10n.options_82;
      case 83:
        return _l10n.options_83;
      case 84:
        return _l10n.options_84;
      case 85:
        return _l10n.options_85;
      case 86:
        return _l10n.options_86;
      case 87:
        return _l10n.options_87;
      case 88:
        return _l10n.options_88;
      case 89:
        return _l10n.options_89;
      case 90:
        return _l10n.options_90;
      case 91:
        return _l10n.options_91;
      case 92:
        return _l10n.options_92;
      case 93:
        return _l10n.options_93;
      case 94:
        return _l10n.options_94;
      case 95:
        return _l10n.options_95;
      case 96:
        return _l10n.options_96;
      case 97:
        return _l10n.options_97;
      case 98:
        return _l10n.options_98;
      case 99:
        return _l10n.options_99;
      case 100:
        return _l10n.options_100;
      default:
        return _l10n.notFoundError;
    }
  }

  // --------------------------------------------------
  // FINANCE & PRICING
  // --------------------------------------------------
  String get financeAndPricing => _l10n.financeAndPricing;
  String get manageInvoicesAndConfigurePricing =>
      _l10n.manageInvoicesAndConfigurePricing;
  String get exportData => _l10n.exportData;

  /// Format currency with proper localization
  String formatCurrency(double amount, {String? symbol}) {
    final locale = Localizations.localeOf(context);
    final currencySymbol = symbol ?? 'DZD';

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Format date with proper localization
  String formatDate(DateTime date, {bool showTime = false}) {
    final locale = Localizations.localeOf(context);

    if (showTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // --------------------------------------------------
  // VALIDATION MESSAGES
  // --------------------------------------------------

  /// Dynamic validation message with field name
  String fieldRequired(String fieldName) =>
      _l10n.fieldRequired?.replaceAll('{field}', fieldName) ??
      '$fieldName is required';

  // --------------------------------------------------
  // COMMON ACTIONS
  // --------------------------------------------------
  String get save => _l10n.save;
  String get cancel => _l10n.cancel;
  String get confirm => _l10n.confirm;

  // --------------------------------------------------
  // ERROR MESSAGES
  // --------------------------------------------------
  String get serverError => _l10n.serverError;

  /// Dynamic error message with retry option
}

/// Extension for easy access in widgets
extension CustomLocalizationsExtension on BuildContext {
  CustomLocalizations get l10n => CustomLocalizations(this);

  /// Quick access to the original AppLocalizations
  AppLocalizations get originalL10n => AppLocalizations.of(this)!;
}
