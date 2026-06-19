// organisation_management_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

class OrganisationManagementPopup extends StatefulWidget {
  final Function(Organisation?) onOrganisationUpdated;

  const OrganisationManagementPopup({
    super.key,
    required this.onOrganisationUpdated,
  });

  @override
  State<OrganisationManagementPopup> createState() =>
      _OrganisationManagementPopupState();
}

class _OrganisationManagementPopupState
    extends State<OrganisationManagementPopup> {
  late SupplierChangeNotifier _notifier;
  List<Organisation> _organisations = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _operationKey;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  Organisation? _editingOrganisation;

  @override
  void initState() {
    super.initState();
    _loadOrganisations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganisations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _notifier = Provider.of<SupplierChangeNotifier>(context, listen: false);

      // Use the new getOrganisationsList method or fetch if empty
      if (_notifier.organisations.isEmpty) {
        await _notifier.fetchOrganisations(reset: true);
      }

      _organisations = List.from(_notifier.organisations);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshOrganisations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use the refreshOrganisations method to clear cache and fetch fresh
      final refreshed = await _notifier.refreshOrganisations(clearCache: true);
      _organisations = refreshed;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrganisation() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter organisation name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_editingOrganisation == null) {
        // Create new organisation using the notifier
        final newOrg = Organisation(
          id_provider_organisation: 0,
          provider_organisation_name: name,
          provider_organisation_desc: _descController.text.trim(),
        );

        final created = await _notifier.createOrganisation(newOrg);

        if (created != null) {
          setState(() {
            _organisations.insert(0, created);
            _resetForm();
          });

          widget.onOrganisationUpdated(created);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Organisation created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to create organisation');
        }
      } else {
        // Update existing organisation
        final updatedOrg = Organisation(
          id_provider_organisation:
              _editingOrganisation!.id_provider_organisation,
          provider_organisation_name: name,
          provider_organisation_desc: _descController.text.trim(),
        );

        final updated = await _notifier.updateOrganisation(updatedOrg);

        if (updated != null) {
          setState(() {
            final index = _organisations.indexWhere((o) =>
                o.id_provider_organisation ==
                _editingOrganisation!.id_provider_organisation);
            if (index != -1) {
              _organisations[index] = updated;
            }
            _resetForm();
          });

          widget.onOrganisationUpdated(updated);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Organisation updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to update organisation');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteOrganisation(Organisation org) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organisation'),
        content: Text(
            'Are you sure you want to delete "${org.provider_organisation_name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final deleted = await _notifier.deleteOrganisation(
        org.id_provider_organisation,
      );

      if (deleted) {
        setState(() {
          _organisations.removeWhere((o) =>
              o.id_provider_organisation == org.id_provider_organisation);
        });

        widget.onOrganisationUpdated(null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organisation deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete organisation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _editOrganisation(Organisation org) {
    setState(() {
      _editingOrganisation = org;
      _nameController.text = org.provider_organisation_name;
      _descController.text = org.provider_organisation_desc;
    });
  }

  void _resetForm() {
    setState(() {
      _editingOrganisation = null;
      _nameController.clear();
      _descController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manage Organisations',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom:
                      BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_editingOrganisation != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        label: Text(
                            'Editing: ${_editingOrganisation!.provider_organisation_name}'),
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: _resetForm,
                      ),
                    ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Organisation Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_editingOrganisation != null)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Cancel Edit'),
                        ),
                      const Spacer(),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveOrganisation,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(_editingOrganisation == null
                                  ? Icons.add
                                  : Icons.save),
                          label: Text(_editingOrganisation == null
                              ? 'Add Organisation'
                              : 'Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.list, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Existing Organisations',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20),
                    onPressed: _isLoading ? null : _refreshOrganisations,
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_organisations.length} total',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // List of organisations
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: theme.colorScheme.error),
                              const SizedBox(height: 16),
                              Text('Error: $_error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadOrganisations,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _organisations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.business_outlined,
                                      size: 48,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No organisations found',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Click "Add Organisation" to create one',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _organisations.length,
                              itemBuilder: (context, index) {
                                final org = _organisations[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      child: Text(
                                        org.provider_organisation_name[0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(org.provider_organisation_name),
                                    subtitle: org.provider_organisation_desc
                                            .isNotEmpty
                                        ? Text(
                                            org.provider_organisation_desc,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 20),
                                          onPressed: _isSaving
                                              ? null
                                              : () => _editOrganisation(org),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 20),
                                          color: Colors.red,
                                          onPressed: _isSaving
                                              ? null
                                              : () => _deleteOrganisation(org),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
