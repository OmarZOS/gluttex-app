import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/ResponseHandler.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await Provider.of<AppUserNotifier>(context, listen: false)
          .signInWithUsernameAndPassword(
        _usernameController.text,
        _passwordController.text,
      );

      ResponseHandler.handleResponse(
        context: context,
        statusCode: 200,
        responseCode: "SUCCESSFULL_LOGIN",
        finalMessage: AppLocalizations.of(context)!.successfullLoginMsg,
      );
      globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on GluttexException catch (error) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: error.statusCode ?? 300,
        responseCode: error.message,
        finalMessage: error.message,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AppUserNotifier>(context, listen: false)
          .signInAsGuest();
      globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on GluttexException catch (error) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: error.statusCode ?? 300,
        responseCode: error.message,
        finalMessage: error.message,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithSocial(Future Function() socialLogin) async {
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await socialLogin();
    } on GluttexException catch (error) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: error.statusCode ?? 300,
        responseCode: error.message,
        finalMessage: "",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Logo and Welcome Section
                  _buildHeaderSection(context, theme, isDarkMode),
                  const SizedBox(height: 32),

                  // Login Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Username Field
                            TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .usernameText,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    // filled: true,
                                    // fillColor: colors.surfaceVariant.withOpacity(0.4),
                                  ),
                                  // keyboardType: TextInputType.emailAddress,
                                  // textInputAction: TextInputAction.next,
                                  // validator: (value) => value?.isEmpty ?? true
                                  //     ? AppLocalizations.of(context)!.pleaseInputUsernameMsg
                                  //     : null,
                                )),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.passwordText,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    colors.surfaceVariant.withOpacity(0.4),
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!
                                      .pleaseInputPasswordMsg;
                                }
                                if (value!.length < 6) {
                                  return AppLocalizations.of(context)!
                                      .passwordLengthConstraintMsg;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .forgotPasswordText,
                                  style: TextStyle(color: colors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: colors.primary,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.loginText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guest Mode Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _loginAsGuest,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colors.primary),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueAsGuestText,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colors.onSurface.withOpacity(0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.orText,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colors.onSurface.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        color: Colors.red,
                        isEnabled: false,
                        onPressed: () => _loginWithSocial(
                          () => Provider.of<AppUserNotifier>(context,
                                  listen: false)
                              .signInWithGoogle(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildSocialLoginButton(
                        icon: FontAwesomeIcons.facebook,
                        color: Colors.blue,
                        isEnabled: false,
                        onPressed: () => _loginWithSocial(
                          () => Provider.of<AppUserNotifier>(context,
                                  listen: false)
                              .signInWithFacebook(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Register Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.noAccountText,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationForm(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.registerText,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          height: 120,
          color: isDarkMode ? Colors.white : null,
        ),
        const SizedBox(height: 16),

        // Welcome Text
        Text(
          AppLocalizations.of(context)!.welcomeBackMsg,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.pleaseLoginMsg,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: FaIcon(
        icon,
        size: 28,
        color: isEnabled
            ? color
            : isDarkMode
                ? Colors.grey[600]
                : Colors.grey[400],
      ),
      onPressed: isEnabled && !_isLoading ? onPressed : null,
      style: IconButton.styleFrom(
        backgroundColor: isEnabled
            ? Theme.of(context).colorScheme.surface
            : isDarkMode
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.grey[200]!.withOpacity(0.5),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isEnabled
                ? Theme.of(context).dividerColor
                : isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
    );
  }
}
