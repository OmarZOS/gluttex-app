// organisation_management_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
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

      // Fetch organisations if needed
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

  Future<void> _saveOrganisation() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter organisation name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_editingOrganisation == null) {
        // Create new organisation
        final newOrg = Organisation(
          id_provider_organisation: 0,
          provider_organisation_name: name,
          provider_organisation_desc: _descController.text.trim(),
        );

        // Note: You'll need to add a createOrganisation method to your SupplierChangeNotifier
        // await _notifier.createOrganisation(newOrg);

        // For now, just add to local list
        setState(() {
          _organisations.insert(0, newOrg);
          _resetForm();
        });

        widget.onOrganisationUpdated(newOrg);
      } else {
        // Update existing organisation
        final updatedOrg = Organisation(
          id_provider_organisation:
              _editingOrganisation!.id_provider_organisation,
          provider_organisation_name: name,
          provider_organisation_desc: _descController.text.trim(),
        );

        // Note: You'll need to add an updateOrganisation method
        // await _notifier.updateOrganisation(updatedOrg);

        setState(() {
          final index = _organisations.indexWhere((o) =>
              o.id_provider_organisation ==
              _editingOrganisation!.id_provider_organisation);
          if (index != -1) {
            _organisations[index] = updatedOrg;
          }
          _resetForm();
        });

        widget.onOrganisationUpdated(updatedOrg);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organisation saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOrganisation(Organisation org) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organisation'),
        content: Text(
            'Are you sure you want to delete "${org.provider_organisation_name}"?'),
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

    setState(() => _isLoading = true);

    try {
      // Note: You'll need to add a deleteOrganisation method
      // await _notifier.deleteOrganisation(org.id_provider_organisation);

      setState(() {
        _organisations.removeWhere(
            (o) => o.id_provider_organisation == org.id_provider_organisation);
      });

      widget.onOrganisationUpdated(null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organisation deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
    _editingOrganisation = null;
    _nameController.clear();
    _descController.clear();
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
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveOrganisation,
                          icon: Icon(_editingOrganisation == null
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
                      ? Center(child: Text('Error: $_error'))
                      : _organisations.isEmpty
                          ? const Center(child: Text('No organisations found'))
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
                                        ? Text(org.provider_organisation_desc,
                                            maxLines: 1)
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 20),
                                          onPressed: () =>
                                              _editOrganisation(org),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 20),
                                          color: Colors.red,
                                          onPressed: () =>
                                              _deleteOrganisation(org),
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
