import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import '../user_onboarding_screen.dart';
import 'verification_screen.dart';

enum _CredentialType { email, phone }

enum _AuthMode { signIn, signUp }

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen>
    with SingleTickerProviderStateMixin {
  _AuthMode _mode = _AuthMode.signIn;
  _CredentialType _credentialType = _CredentialType.email;
  bool _rememberMe = true;
  bool _showSignInPassword = false;
  bool _showSignUpPassword = false;
  bool _showSignUpConfirmPassword = false;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == _AuthMode.signIn ? _AuthMode.signUp : _AuthMode.signIn;
      _credentialType = _CredentialType.email;
    });
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (!_signInFormKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.signIn(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text.trim(),
        remember: _rememberMe,
      );
      await _navigatePostAuth(context, authProvider);
    } on ApiException catch (error) {
      _showError(context, error.message);
    }
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (!_signUpFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    final email = _signUpEmailController.text.trim();
    try {
      await authProvider.signUp(
        email: email,
        password: _signUpPasswordController.text.trim(),
        fullName: _signUpNameController.text.trim().isEmpty
            ? null
            : _signUpNameController.text.trim(),
        remember: _rememberMe,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VerificationScreen(email: email),
      ));
      await _navigatePostAuth(context, authProvider);
    } on ApiException catch (error) {
      _showError(context, error.message);
    }
  }

  Future<void> _navigatePostAuth(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    if (!mounted) return;
    if (authProvider.needsOnboarding) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserOnboardingScreen()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  void _showError(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.secondaryRed,
      ),
    );
  }

  void _handleCredentialTap(_CredentialType type) {
    if (type == _CredentialType.phone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone sign-in is coming soon. Try email for now!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _credentialType = type);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 640;
            final cardWidth = isWide ? 520.0 : constraints.maxWidth * 0.92;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24,
                vertical: isWide ? 48 : 24,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 24),
                        _buildModeSwitcher(theme),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _mode == _AuthMode.signIn
                              ? _buildSignInForm(context, authProvider)
                              : _buildSignUpForm(context, authProvider),
                        ),
                        const SizedBox(height: 24),
                        _buildSocialLogins(theme),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final isSignIn = _mode == _AuthMode.signIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: AppTheme.headingLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          child: Text(isSignIn ? 'Welcome Back' : 'Get Started Now'),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          child: Text(
            isSignIn
                ? 'Login to access your dashboard'
                : 'Create an account to explore all our tools',
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher(ThemeData theme) {
    final isSignIn = _mode == _AuthMode.signIn;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.primaryBlue.withOpacity(0.08),
          ),
          child: Row(
            children: [
              _ModeChip(
                label: 'Login',
                isActive: isSignIn,
                onTap: () {
                  if (!isSignIn) _toggleMode();
                },
              ),
              const SizedBox(width: 8),
              _ModeChip(
                label: 'Sign Up',
                isActive: !isSignIn,
                onTap: () {
                  if (isSignIn) _toggleMode();
                },
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _toggleMode,
          child: Text(isSignIn ? 'Need an account?' : 'Have an account?'),
        ),
      ],
    );
  }

  Widget _buildSignInForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCredentialSwitch(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _credentialType == _CredentialType.email
                ? Column(
                    key: const ValueKey('email-signin'),
                    children: [
                      _buildTextField(
                        controller: _signInEmailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _signInPasswordController,
                        label: 'Password',
                        obscure: !_showSignInPassword,
                        onVisibilityToggle: () {
                          setState(() => _showSignInPassword = !_showSignInPassword);
                        },
                      ),
                    ],
                  )
                : _buildComingSoonPanel(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? true),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset flow is coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: authProvider.isLoading ? 0.96 : 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : () => _handleSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Log in'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCredentialSwitch(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _credentialType == _CredentialType.email
                ? Column(
                    key: const ValueKey('email-signup'),
                    children: [
                      _buildTextField(
                        controller: _signUpNameController,
                        label: 'Full name',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _signUpEmailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                        prefixIcon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _signUpPasswordController,
                        label: 'Create password',
                        obscure: !_showSignUpPassword,
                        onVisibilityToggle: () {
                          setState(() => _showSignUpPassword = !_showSignUpPassword);
                        },
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _signUpConfirmPasswordController,
                        label: 'Confirm password',
                        obscure: !_showSignUpConfirmPassword,
                        onVisibilityToggle: () {
                          setState(() => _showSignUpConfirmPassword = !_showSignUpConfirmPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _signUpPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : _buildComingSoonPanel(),
          ),
          const SizedBox(height: 12),
          Text(
            'By signing up you agree to our Terms of Service and Privacy Policy.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: authProvider.isLoading ? 0.96 : 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : () => _handleSignUp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create account'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCredentialSwitch() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CredentialChip(
              label: 'Phone Number',
              icon: Icons.phone_rounded,
              isActive: _credentialType == _CredentialType.phone,
              onTap: () => _handleCredentialTap(_CredentialType.phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CredentialChip(
              label: 'Email',
              icon: Icons.email_outlined,
              isActive: _credentialType == _CredentialType.email,
              onTap: () => _handleCredentialTap(_CredentialType.email),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ?? _passwordValidator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }

  Widget _buildComingSoonPanel() {
    return Container(
      key: const ValueKey('coming-soon'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_outlined, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Phone authentication and social login are launching soon. Stay tuned! ',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogins(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          'Or continue with',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _SocialLoginButton(label: 'Google', icon: Icons.g_mobiledata),
            _SocialLoginButton(label: 'Facebook', icon: Icons.facebook),
            _SocialLoginButton(label: 'Apple', icon: Icons.apple),
          ],
        ),
      ],
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final email = value.trim();
    const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialChip extends StatelessWidget {
  const _CredentialChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppTheme.primaryBlue : AppTheme.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: 0.6,
        child: OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label login is coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(icon, color: AppTheme.textSecondary),
          label: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}
