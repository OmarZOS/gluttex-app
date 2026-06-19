import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/product_form_data.dart';
import 'package:event/assistant_change_notifier.dart';
import 'package:ui/components/ImagePickerSection.dart';
import 'package:product_catalog/screens/components/form/ai_assistance_section.dart';
import 'package:product_catalog/screens/components/form/ai_assistant.dart';
import 'package:product_catalog/screens/components/form/form_controllers.dart';
import 'package:product_catalog/screens/components/form/form_initializer.dart';
import 'package:product_catalog/screens/components/form/loading_overlay.dart';
import 'package:product_catalog/screens/components/form/product_form_fields.dart';
import 'package:product_catalog/screens/components/form/submit_handler.dart';
import 'package:product_catalog/screens/components/form/submit_section.dart';
import 'package:provider/provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => ProductFormScreenState();
}

class ProductFormScreenState extends State<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductFormData _formData = ProductFormData();
  final FormControllers _controllers = FormControllers();
  late FormStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = FormStateManager(
      formData: _formData,
      controllers: _controllers,
    );
    _stateManager.initialize();
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_stateManager.initialized) {
      _stateManager.initializeFromArguments(context);
    }
  }

  Future<void> _submitForm() async {
    await SubmitHandler.submitForm(
      context: context,
      formKey: _formKey,
      formData: _formData,
      controllers: _controllers,
      isUpdate: _stateManager.isUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        return Scaffold(
          appBar: _buildAppBar(localizations, colorScheme),
          // Update the floating action button to use the new AiAssistant class
          floatingActionButton: assistantNotifier.isLoading
              ? null
              : FloatingActionButton(
                  onPressed: () =>
                      AiAssistant.showOptions(context, _formData, _controllers),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.auto_awesome),
                ),
          body: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceVariant.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (!_stateManager.isUpdate)
                        AiAssistanceSection(
                            formData: _formData, controllers: _controllers),
                      if (_formData.image != null ||
                          (_formData.imageUrl != null &&
                              _formData.imageUrl!.isNotEmpty))
                        _buildImagePickerSection(),
                      const SizedBox(height: 24),
                      ProductFormFields(
                        formData: _formData,
                        controllers: _controllers,
                        formKey: _formKey,
                        isUpdate: _stateManager.isUpdate,
                      ),
                      const SizedBox(height: 32),
                      SubmitSection(
                        onSubmit: _submitForm,
                        isUpdate: _stateManager.isUpdate,
                        hasAiData: false, // Replace with actual AI data check
                      ),
                    ],
                  ),
                ),
              ),

              if (assistantNotifier.isLoading) const LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(AppLocalizations localizations, ColorScheme colorScheme) {
    return AppBar(
      title: Text(_stateManager.isUpdate
          ? localizations.updateProductText
          : localizations.addProductTxt),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    );
  }

  Widget _buildImagePickerSection() {
    return Consumer<AssistantNotifier>(
      builder: (context, assistantNotifier, child) {
        return ImagePickerSection(
          initialImageUrl: _formData.imageUrl ?? "",
          entityType: 'product',
          ownerId: '${_formData.ownerId}',
          entityId: '${_formData.productId}',
          onImageUploaded: (newImage) {
            setState(() {
              _formData.image = newImage;
              _formData.imageId = 0;
            });
          },
          capturedImageFile: _formData.imageFile,
        );
      },
    );
  }
}
