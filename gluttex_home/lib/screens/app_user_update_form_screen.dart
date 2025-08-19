import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_constants/gluttex_response_codes.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class AppUserEditFormScreen extends StatefulWidget {
  // final AppUser? appUser;

  const AppUserEditFormScreen({super.key});

  @override
  State<AppUserEditFormScreen> createState() => _AppUserEditFormScreenState();
}

class _AppUserEditFormScreenState extends State<AppUserEditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late AppUser _editedUser;

  bool _initialized = false; // to prevent re-initialization

  File? _editedImage;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    // _editedUser = widget.appUser!.copyWith(); // Deep copy
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
          _editedImage = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: 500,
        responseCode: GluttexResponseCodes.put_success,
        finalMessage: AppLocalizations.of(context)!.putSuccess,
      );
      // _showErrorSnackbar('Failed to pick image: ${e.message}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final AppUser? user = args?["user"];
      _editedUser = user ?? AppUser.empty();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    // Copy editedUser now (because we modify it asynchronously later)
    var localUser = _editedUser;

    // Run tasks in background
    unawaited(Future(() async {
      try {
        if (_imageChanged && _editedImage != null) {
          GluttexImage image = GluttexLocator.get<GluttexImage>();
          image.setupImage(
            filepath: _editedImage!.path,
            filename: _editedImage!.path.split("/").last,
            entityType: 'user',
            ownerId: '${_editedUser.id_app_user}',
            entityId: '${_editedUser.id_app_user}',
          );
          final imageUrl = await image.uploadImage();

          localUser = localUser.copyWith(app_user_image_url: imageUrl);
        }

        await Provider.of<AppUserNotifier>(context, listen: false)
            .updateAppUserImage(localUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.putSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, localUser);
        }
      } catch (_) {
        if (mounted) {
          _showErrorSnackbar(AppLocalizations.of(context)!.putFailure);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.personalInformation),
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
                    _buildProfilePictureSection(theme, loc),
                    const SizedBox(height: 24),
                    _buildSectionHeader(loc.accountInformation, theme),
                    _buildTextFormField(
                      label: loc.username,
                      initialValue: _editedUser.app_user_name,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(app_user_name: v),
                    ),
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
                    _buildTextFormField(
                      label: loc.birthdayText,
                      initialValue: _editedUser.personBirthDate,
                      onSaved: (v) => _editedUser =
                          _editedUser.copyWith(personBirthDate: v),
                    ),
                    _buildTextFormField(
                      label: loc.genderText,
                      initialValue: _editedUser.personGender,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(personGender: v),
                    ),
                    _buildSectionHeader(loc.locationInfoText, theme),
                    _buildTextFormField(
                      label: loc.locationNameText,
                      initialValue: _editedUser.locationName,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(locationName: v),
                    ),
                    _buildTextFormField(
                      label: loc.locationText,
                      initialValue: _editedUser.addressCity,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(addressCity: v),
                    ),
                    _buildTextFormField(
                      label: loc.countryText,
                      initialValue: _editedUser.addressCountry,
                      onSaved: (v) =>
                          _editedUser = _editedUser.copyWith(addressCountry: v),
                    ),
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

  Widget _buildProfilePictureSection(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.25,
              backgroundImage:
                  _editedImage != null ? FileImage(_editedImage!) : null,
              child: _editedImage == null
                  ? CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.5,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: _editedUser.app_user_image_url != null
                          ? ClipOval(
                              child: Image.network(
                                GluttexConstants.fsBaseUrl +
                                    _editedUser.app_user_image_url!,
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: MediaQuery.of(context).size.width * 0.5,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.person,
                                          size: 60, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    )
                  : null,
            ),
            FloatingActionButton.small(
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
                  _imageChanged = false;
                  _editedImage = null;
                }),
                child: Text(
                  loc.removePhoto,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
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
    bool enabled = false, // <-- default value: disabled
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
        enabled: enabled, // <-- control editing here
        maxLength: maxLength,
        validator: (value) {
          if ((value?.isEmpty ?? true) && enabled) {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
