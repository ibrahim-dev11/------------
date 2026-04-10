import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../services/app_localizations.dart';
import 'signup_screen.dart';
import 'section_selection_screen.dart';
import 'forgot_password_screen.dart';
import 'teachers_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailC.text.trim();
    final pass = _passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg(S.of(context, 'enterEmailPassword'));
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      _showMsg(S.of(context, 'invalidEmail'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AppProvider>();
      final result = await provider.login(email, pass);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        AppSnackbar.success(
            context, result['message'] ?? S.of(context, 'loginSuccess'));
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SectionSelectionScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
          (route) => false,
        );
      } else {
        final errors = result['errors'];
        if (errors != null && errors is Map) {
          final firstMsg = (errors.values.first as List).first;
          _showMsg(firstMsg.toString());
        } else {
          _showMsg(result['message'] ?? S.of(context, 'loginError'));
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMsg(S.of(context, 'connectionError'));
    }
  }

  void _showMsg(String msg) {
    AppSnackbar.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9), Colors.white],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative gradient blob top-right
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(isDark ? 0.15 : 0.1),
                    AppTheme.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Decorative gradient blob bottom-left
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(isDark ? 0.12 : 0.08),
                    AppTheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(height: screenH * 0.06),

                        // Logo
                        _buildLogo(isDark),

                        const SizedBox(height: 28),

                        // Welcome text
                        Text(
                          S.of(context, 'appName'),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context, 'welcomeLogin'),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Form card
                        _buildFormCard(isDark),

                        const SizedBox(height: 28),

                        // Signup link
                        _buildSignupRow(isDark),

                        const SizedBox(height: 12),

                        // Teacher registration
                        _buildTeacherRegisterCard(isDark),

                      

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(-5, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          const Center(
            child: Text('📚', style: TextStyle(fontSize: 42)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF3B82F6).withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withOpacity(0.6)
              : const Color(0xFFE2E8F0).withOpacity(0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      AppTheme.accent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Iconsax.login, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context, 'login'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Email
          _buildInputField(
            controller: _emailC,
            label: S.of(context, 'email'),
            hint: 'name@example.com',
            icon: Iconsax.sms,
            isDark: isDark,
            isLtr: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),

          // Password
          _buildInputField(
            controller: _passC,
            label: S.of(context, 'password'),
            hint: '••••••••',
            icon: Iconsax.lock,
            isDark: isDark,
            isLtr: true,
            isPassword: true,
          ),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
              ),
              child: Text(
                S.of(context, 'forgotPassword'),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login button
          _buildGradientButton(
            onPressed: _isLoading ? null : _login,
            isLoading: _isLoading,
            label: S.of(context, 'login'),
            icon: Iconsax.login,
            gradient: const [AppTheme.primary, AppTheme.accent],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isLtr = false,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.15)
                    : const Color(0xFF3B82F6).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textDirection: isLtr ? TextDirection.ltr : null,
            textAlign: isLtr ? TextAlign.left : TextAlign.start,
            obscureText: isPassword ? _obscure : false,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 16),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Iconsax.eye_slash : Iconsax.eye,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.5)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155).withOpacity(0.5)
                      : const Color(0xFFE2E8F0).withOpacity(0.8),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSignupRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.5)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withOpacity(0.4)
              : const Color(0xFFE2E8F0).withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context, 'noAccount'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const SignupScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ).createShader(bounds),
              child: Text(
                S.of(context, 'createAccount'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherRegisterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.5)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withOpacity(0.4)
              : const Color(0xFFE2E8F0).withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ماموستایت؟',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const TeacherFormView(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ).createShader(bounds),
              child: const Text(
                'خۆت تۆمار بکە',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
    }
