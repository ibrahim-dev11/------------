import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  int _step = 1; // 1: email, 2: code, 3: new password
  String? _resetToken;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackbar.error(context, S.of(context, 'enterValidEmail'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.forgotPassword(email);
      if (result['success'] == true) {
        setState(() => _step = 2);
        if (mounted) {
          AppSnackbar.success(context, result['message'] ?? S.of(context, 'codeSent'));
        }
      } else {
        if (mounted) {
          final errors = result['errors'];
          final msg = errors != null
              ? (errors['email']?.first ?? result['message'])
              : result['message'];
          AppSnackbar.error(context, msg ?? S.of(context, 'errorOccurred'));
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, S.of(context, 'connectionError'));
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      AppSnackbar.error(context, S.of(context, 'enterValidCode'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.verifyResetCode(
        _emailController.text.trim(),
        code,
      );
      if (result['success'] == true) {
        _resetToken = result['data']['reset_token'];
        setState(() => _step = 3);
      } else {
        if (mounted) {
          final errors = result['errors'];
          final msg = errors != null
              ? (errors['code']?.first ?? result['message'])
              : result['message'];
          AppSnackbar.error(context, msg ?? S.of(context, 'invalidCode'));
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, S.of(context, 'connectionError'));
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || password.length < 6) {
      AppSnackbar.error(context, S.of(context, 'passwordTooShort'));
      return;
    }

    if (password != confirm) {
      AppSnackbar.error(context, S.of(context, 'passwordsDoNotMatch'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.resetPassword(
        email: _emailController.text.trim(),
        resetToken: _resetToken!,
        password: password,
        passwordConfirmation: confirm,
      );

      if (result['success'] == true) {
        if (mounted) {
          AppSnackbar.success(context, result['message'] ?? S.of(context, 'passwordResetSuccess'));
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          final errors = result['errors'];
          final msg = errors != null
              ? (errors.values.first?.first ?? result['message'])
              : result['message'];
          AppSnackbar.error(context, msg ?? S.of(context, 'errorOccurred'));
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, S.of(context, 'connectionError'));
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context, 'forgotPassword'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              _buildProgressIndicator(isDark),
              const SizedBox(height: 32),

              // Step content
              if (_step == 1) _buildEmailStep(cardColor, textColor, hintColor),
              if (_step == 2) _buildCodeStep(cardColor, textColor, hintColor),
              if (_step == 3) _buildPasswordStep(cardColor, textColor, hintColor),

              const SizedBox(height: 24),

              // Action button
              _buildActionButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Row(
      children: [
        _buildStepCircle(1, isDark),
        Expanded(child: _buildStepLine(1, isDark)),
        _buildStepCircle(2, isDark),
        Expanded(child: _buildStepLine(2, isDark)),
        _buildStepCircle(3, isDark),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isDark) {
    final isActive = _step >= step;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppTheme.primary : (isDark ? Colors.white12 : Colors.grey[300]),
      ),
      child: Center(
        child: _step > step
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : (isDark ? Colors.white : Colors.black38),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int step, bool isDark) {
    final isActive = _step > step;
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : (isDark ? Colors.white12 : Colors.grey[300]),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmailStep(Color cardColor, Color textColor, Color hintColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context, 'enterEmail'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context, 'enterEmailDescription'),
          style: TextStyle(color: hintColor),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context, 'email'),
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Iconsax.sms, color: hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep(Color cardColor, Color textColor, Color hintColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context, 'enterCode'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context, 'enterCodeDescription'),
          style: TextStyle(color: hintColor),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: TextStyle(color: hintColor, letterSpacing: 8),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _sendCode,
          child: Text(
            S.of(context, 'resendCode'),
            style: const TextStyle(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(Color cardColor, Color textColor, Color hintColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context, 'enterNewPassword'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context, 'enterNewPasswordDescription'),
          style: TextStyle(color: hintColor),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context, 'newPassword'),
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Iconsax.lock, color: hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                  color: hintColor,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context, 'confirmPassword'),
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Iconsax.lock, color: hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Iconsax.eye_slash : Iconsax.eye,
                  color: hintColor,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isDark) {
    String label;
    VoidCallback? onPressed;

    switch (_step) {
      case 1:
        label = S.of(context, 'sendCode');
        onPressed = _sendCode;
        break;
      case 2:
        label = S.of(context, 'verifyCode');
        onPressed = _verifyCode;
        break;
      case 3:
        label = S.of(context, 'resetPassword');
        onPressed = _resetPassword;
        break;
      default:
        label = '';
        onPressed = null;
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
