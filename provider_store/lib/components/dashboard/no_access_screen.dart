import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'pending_invitations_dialog.dart';

class NoAccessScreen extends StatelessWidget {
  final AppUser currentUser;
  final PersonnelNotifier personnelNotifier;
  final VoidCallback? onReturn; // Optional callback for return action

  const NoAccessScreen({
    required this.currentUser,
    required this.personnelNotifier,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUserNotifier>(
      builder: (context, userNotifier, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)?.accessRequired ?? 'Access Required',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => _handleReturn(context),
              tooltip: AppLocalizations.of(context)?.returnBack ?? 'Return',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: NoAccessContent(
                currentUser: currentUser,
                personnelNotifier: personnelNotifier,
                onReturn: onReturn,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleReturn(BuildContext context) {
    if (onReturn != null) {
      onReturn!();
    } else {
      // Default behavior: navigate back if possible
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // If can't pop, close the app or navigate to home
        // Option 1: Close the app
        // SystemNavigator.pop();

        // Option 2: Navigate to home screen
        // Navigator.of(context).pushReplacementNamed('/home');

        // For now, just show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.returnBack ??
                  'Return to previous screen',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

class NoAccessContent extends StatelessWidget {
  final AppUser currentUser;
  final PersonnelNotifier personnelNotifier;
  final VoidCallback? onReturn;

  const NoAccessContent({
    required this.currentUser,
    required this.personnelNotifier,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localizations?.accessRequired ?? 'Access Required',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          localizations?.needBusinessAssignment ??
              'You need to be assigned to a business to access management features.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          localizations?.contactAdminOrJoinTeam ??
              'Contact your administrator or join a business team.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        NoAccessButtons(
          currentUser: currentUser,
          personnelNotifier: personnelNotifier,
          onReturn: onReturn,
        ),
      ],
    );
  }
}

class NoAccessButtons extends StatelessWidget {
  final AppUser currentUser;
  final PersonnelNotifier personnelNotifier;
  final VoidCallback? onReturn;

  const NoAccessButtons({
    required this.currentUser,
    required this.personnelNotifier,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final userId = currentUser.idAppUser ?? 0;

    return Column(
      children: [
        // Return Button
        OutlinedButton.icon(
          onPressed: () => _handleReturn(context),
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.primary),
          label: Text(
            localizations?.returnBack ?? 'Return Back',
            style: TextStyle(color: colorScheme.primary),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _refreshAccess(context),
          icon: Icon(Icons.refresh_rounded, color: colorScheme.onPrimary),
          label: Text(
            localizations?.checkAccessStatus ?? 'Check Access Status',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showPendingInvitations(context, userId),
          icon: Icon(Icons.mail_outline, color: colorScheme.primary),
          label: Text(
            localizations?.viewPendingInvitations ?? 'View Pending Invitations',
            style: TextStyle(color: colorScheme.primary),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _handleReturn(BuildContext context) {
    if (onReturn != null) {
      onReturn!();
    } else {
      // Default behavior: navigate back if possible
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // If can't pop, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.returnBack ??
                  'Return to previous screen',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshAccess(BuildContext context) async {
    await personnelNotifier.loadPersonnel(
      supplierId: 0,
      includePending: true,
      reset: true,
    );

    if (context.mounted) {
      final colorScheme = Theme.of(context).colorScheme;
      final localizations = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.accessRefreshed ?? 'Access privileges refreshed',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showPendingInvitations(BuildContext context, int userId) {
    final pendingRules = personnelNotifier.getPendingRulesForUser(userId);

    if (pendingRules.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      final localizations = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.noPendingInvitations ?? 'No pending invitations',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PendingInvitationsDialog(
        pendingRules: pendingRules,
        personnelNotifier: personnelNotifier,
      ),
    );
  }
}
