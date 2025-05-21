import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_home/screens/components/category_picker.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class AppUserEditFormScreen extends StatefulWidget {
  final AppUser? appUser;

  const AppUserEditFormScreen({super.key, required this.appUser});

  @override
  State<AppUserEditFormScreen> createState() => _AppUserEditFormScreenState();
}

class _AppUserEditFormScreenState extends State<AppUserEditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late AppUser _editedUser;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.appUser!.copyWith(); // Create a deep copy
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _imageChanged = true;
          _editedUser = _editedUser.copyWith(
              // app_user_image: Uint8List.fromList(await pickedFile.readAsBytes()),
              );
        });
      }
    } on PlatformException catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.message}');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      await GluttexLocator.get<AppUserService>().updateAppUser(_editedUser);
      await Provider.of<AppUserNotifier>(context, listen: false)
          .fetchAppUser('${_editedUser.id_app_user}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.putSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, _editedUser);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(AppLocalizations.of(context)!.putFailure);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.personalInformation),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: null,
            // onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(theme),
                    const SizedBox(height: 24),

                    // Personal Info Section
                    _buildSectionHeader(loc.personalInformation, theme),
                    _buildTextFormField(
                      label: loc.firstName,
                      initialValue: _editedUser.personFirstName,
                      onSaved: (v) => _editedUser =
                          _editedUser.copyWith(personFirstName: v),
                    ),
                    _buildTextFormField(
                      label: loc.lastName,
                      initialValue: _editedUser.personLastName,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(personLastName: v),
                    ),

                    // Account Info Section
                    _buildSectionHeader(loc.accountInformation, theme),
                    _buildTextFormField(
                      label: loc.username,
                      initialValue: _editedUser.app_user_name,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(app_user_name: v),
                    ),

                    // Category Picker
                    // _buildCategoryPicker(),

                    // Submit Button
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: Text(loc.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _editedUser.app_user_image != null
                  ? MemoryImage(_editedUser.app_user_image!)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
            ),
            FloatingActionButton.small(
              // heroTag: null,
              onPressed: _pickImage,
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
        if (_imageChanged)
          Column(
            children: [
              const SizedBox(height: GluttexConstants.kDefaultPaddin),
              TextButton(
                onPressed: () => setState(() {
                  _editedUser = _editedUser.copyWith(app_user_image: null);
                  _imageChanged = false;
                }),
                child: Text(
                  AppLocalizations.of(context)!.removePhoto,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String? initialValue,
    required void Function(String?) onSaved,
    int maxLength = 300,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        maxLength: maxLength,
        validator: (value) {
          if (value?.isEmpty ?? true)
            return AppLocalizations.of(context)!.fieldRequired;
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  // Widget _buildCategoryPicker() {
  //   return FutureBuilder<List<AppUserCategory>?>(
  //     future: Provider.of<AppUserNotifier>(context, listen: false)
  //         .categories,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const LinearProgressIndicator();
  //       }

  //       if (snapshot.hasError) {
  //         return Text("AppLocalizations.of(context)!.loadError");
  //       }

  //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return Text("AppLocalizations.of(context)!.noCategories");
  //       }

  //       return Padding(
  //         padding: const EdgeInsets.only(bottom: 16),
  //         child: CategoryPicker(
  //           category_id: _editedUser.app_user_type_id ?? 1,
  //           categories: snapshot.data!,
  //           onCategoryChanged: (id) {
  //             setState(() {
  //               _editedUser = _editedUser.copyWith(app_user_type_id: id);
  //             });
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
}
