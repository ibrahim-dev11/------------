import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/common_widgets.dart';

enum _ForgotStep { email, otp, newPassword, done }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _api = ApiService();
  _ForgotStep _step = _ForgotStep.email;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  bool _loading = false;
  String? _error;

  String get _otp => _otpCtrl.map((c) => c.text).join();

  Future<void> _sendOtp() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final r = await _api.forgotPassword(_emailCtrl.text.trim());
    setState(() { _loading = false; });
    if (r.success) {
      setState(() => _step = _ForgotStep.otp);
    } else {
      setState(() => _error = r.error);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) return;
    setState(() { _loading = true; _error = null; });
    final r = await _api.verifyResetCode(_emailCtrl.text.trim(), _otp);
    setState(() { _loading = false; });
    if (r.success) {
      setState(() => _step = _ForgotStep.newPassword);
    } else {
      setState(() => _error = r.error);
    }
  }

  Future<void> _resetPassword() async {
    if (_passCtrl.text.length < 6) return;
    setState(() { _loading = true; _error = null; });
    final r = await _api.resetPassword(
        _emailCtrl.text.trim(), _otp, _passCtrl.text);
    setState(() { _loading = false; });
    if (r.success) {
      setState(() => _step = _ForgotStep.done);
    } else {
      setState(() => _error = r.error);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF4F6EF7)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('🔐', style: TextStyle(fontSize: 34))),
                        ),
                        const SizedBox(height: 12),
                        Text(l.forgotPassword.replaceAll('?', ''),
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                fontFamily: 'NotoSansArabic')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                          blurRadius: 30)],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildStep(context, l),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppLocalizations l) {
    if (_step == _ForgotStep.done) {
      return Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(l.resetPassword,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('تۆمارکردنی وشەی نهێنی نوێ سەرکەوتوو بوو',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GradientButton(
            text: l.login,
            onPressed: () => context.go('/login'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        if (_step == _ForgotStep.email) ...[
          Text(l.email, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: l.sendOtp,
            gradient: AppColors.cyanGradient,
            onPressed: _sendOtp,
            isLoading: _loading,
          ),
        ] else if (_step == _ForgotStep.otp) ...[
          Text(l.enterOtp, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(_emailCtrl.text, style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 20),
          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _OtpBox(
              controller: _otpCtrl[i],
              onFilled: (val) {
                if (val.isNotEmpty && i < 5) {
                  FocusScope.of(context).nextFocus();
                }
                setState(() {});
              },
            )),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: l.done,
            gradient: AppColors.cyanGradient,
            onPressed: _verifyOtp,
            isLoading: _loading,
          ),
          TextButton(
            onPressed: _sendOtp,
            child: Text(l.resendOtp),
          ),
        ] else if (_step == _ForgotStep.newPassword) ...[
          Text(l.resetPassword, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l.password,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: l.resetPassword,
            gradient: AppColors.cyanGradient,
            onPressed: _resetPassword,
            isLoading: _loading,
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onFilled;

  const _OtpBox({required this.controller, required this.onFilled});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: controller.text.isNotEmpty ? 1.5 : 0.8,
        ),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onFilled,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textWhite : AppColors.textDark,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
