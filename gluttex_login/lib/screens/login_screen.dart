import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_login/screens/registration_screen.dart';
import 'package:gluttex_login/screens/web_view.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  static const _animationDuration = Duration(milliseconds: 800);
  static const _buttonAnimationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    _setLoading(true);
    FocusScope.of(context).unfocus();

    try {
      await context.read<AppUserNotifier>().signInWithUsernameAndPassword(
            _usernameController.text.trim(),
            _passwordController.text,
          );

      // _showSuccessMessage();
      _navigateToHome();
    } on GluttexException catch (error) {
      _handleError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loginAsGuest() async {
    _setLoading(true);

    try {
      await context.read<AppUserNotifier>().signInAsGuest();
      _navigateToHome();
    } on GluttexException catch (error) {
      _handleError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loginWithGoogle() async {
    _setLoading(true);
    FocusScope.of(context).unfocus();

    try {
      final result = await GoogleLoginManager.loginWithGoogle(context: context);

      if (result != null) {
        await context.read<AppUserNotifier>().signInWithGoogle(result);

        await Future.delayed(const Duration(milliseconds: 500));

        final authProvider = context.read<AppUserNotifier>();
        if (authProvider.isAuthenticated && mounted) {
          _navigateToHome();
        } else {
          throw Exception(AppLocalizations.of(context)!.failedAuthAfterSignIn);
        }
      }
    } on TimeoutException {
      _showSnackBar(AppLocalizations.of(context)!.loginTimeoutMsg);
    } catch (e) {
      _showSnackBar('${AppLocalizations.of(context)!.failedLogin} $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _showSuccessMessage() {
    ResponseHandler.handleResponse(
      context: context,
      statusCode: 200,
      responseCode: "SUCCESSFULL_LOGIN",
      finalMessage: AppLocalizations.of(context)!.successfullLoginMsg,
    );
  }

  void _navigateToHome() {
    globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _handleError(GluttexException error) {
    ResponseHandler.handleResponse(
      context: context,
      statusCode: error.statusCode ?? 300,
      responseCode: error.message,
      finalMessage: error.message,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegistrationForm(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Header Section with animations
                      _buildHeaderSection(theme, isDarkMode),
                      const SizedBox(height: 32),

                      // Login Form with slide animation
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildLoginForm(theme, colors),
                        ),
                      ),

                      // Social login section
                      _buildSocialLoginSection(),

                      // Registration prompt
                      _buildRegistrationPrompt(theme, colors),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Animated Logo
          ScaleTransition(
            scale: _fadeAnimation,
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              package: "gluttex_login",
              color: isDarkMode
                  ? GluttexConstants.backgroundDarkColor
                  : GluttexConstants.backgroundColor,
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 20),

          // Welcome Text
          Text(
            AppLocalizations.of(context)!.welcomeBackMsg,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.pleaseLoginMsg,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: colors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Username Field
              _buildTextField(
                controller: _usernameController,
                label: AppLocalizations.of(context)!.usernameText,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildPasswordField(colors),
              const SizedBox(height: 12),

              // Forgot Password
              _buildForgotPassword(colors),
              const SizedBox(height: 20),

              // Login Button
              _buildLoginButton(colors),
              // const SizedBox(height: 20),
              // // Guest login section
              // _buildGuestLoginSection(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textInputAction: textInputAction,
    );
  }

  Widget _buildPasswordField(ColorScheme colors) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.passwordText,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: 22,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colors.surfaceVariant.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return AppLocalizations.of(context)!.pleaseInputPasswordMsg;
        }
        if (value!.length < 5) {
          return AppLocalizations.of(context)!.passwordLengthConstraintMsg;
        }
        return null;
      },
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildForgotPassword(ColorScheme colors) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
          _showSnackBar(AppLocalizations.of(context)!.comingSoon);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          AppLocalizations.of(context)!.forgotPasswordText,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colors) {
    return AnimatedContainer(
      duration: _buttonAnimationDuration,
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : Text(AppLocalizations.of(context)!.loginText),
      ),
    );
  }

  Widget _buildGuestLoginSection(ColorScheme colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildDivider(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _loginAsGuest,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: colors.primary.withOpacity(0.7)),
                backgroundColor: colors.surface,
              ),
              child: Text(
                AppLocalizations.of(context)!.continueAsGuestText,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // _buildDivider(),
          // const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.signInWithText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 16),
          _buildSocialLoginButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(color: colors.onSurface.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.orText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.5),
                ),
          ),
        ),
        Expanded(
          child: Divider(color: colors.onSurface.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildSocialLoginTile(
        icon: FontAwesomeIcons.google,
        title: AppLocalizations.of(context)!.google,
        onPressed: _loginWithGoogle,
      ),
    );
  }

  Widget _buildSocialLoginTile({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: FaIcon(icon, color: const Color(0xFFDB4437)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFDB4437),
                  ),
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: _isLoading ? null : onPressed,
      ),
    );
  }

  // Widget _buildSocialLoginButton({
  //   required IconData icon,
  //   required Color color,
  //   required VoidCallback onPressed,
  // }) {
  //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  //   return AnimatedContainer(
  //     duration: _buttonAnimationDuration,
  //     child: IconButton(
  //       icon: FaIcon(icon, size: 24),
  //       onPressed: _isLoading ? null : onPressed,
  //       style: IconButton.styleFrom(
  //         backgroundColor: isDarkMode
  //             ? Colors.grey[800]!.withOpacity(0.3)
  //             : Colors.grey[100],
  //         padding: const EdgeInsets.all(16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           side: BorderSide(
  //             color: Theme.of(context).dividerColor.withOpacity(0.3),
  //             width: 1,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRegistrationPrompt(ThemeData theme, ColorScheme colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.noAccountText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _navigateToRegistration,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              AppLocalizations.of(context)!.registerText,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
