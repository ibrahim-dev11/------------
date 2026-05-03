import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../services/app_localizations.dart';
import 'section_selection_screen.dart';
import 'teachers_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameC = TextEditingController();
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
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _signup() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final pass = _passC.text.trim();

    if (name.isEmpty) {
      _showMsg(S.of(context, 'enterName'));
      return;
    }
    if (email.isEmpty) {
      _showMsg(S.of(context, 'enterEmail'));
      return;
    }
    // Email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      _showMsg(S.of(context, 'invalidEmail'));
      return;
    }
    if (pass.isEmpty) {
      _showMsg(S.of(context, 'enterPassword'));
      return;
    }
    if (pass.length < 6) {
      _showMsg(S.of(context, 'passwordMinLength'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AppProvider>();
      final result = await provider.register(name, email, pass, pass);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        AppSnackbar.success(
            context, result['message'] ?? S.of(context, 'signupSuccess'));

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

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
          _showMsg(result['message'] ?? S.of(context, 'errorOccurred'));
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
                    ? [AppTheme.darkBg, AppTheme.darkSurface, AppTheme.darkBg]
                    : [AppTheme.lightBg, AppTheme.lightBg, Colors.white],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative blob top-left
          Positioned(
            top: -80,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative blob bottom-right
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                    Colors.transparent,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: screenH * 0.08),

                        // Logo
                        _buildLogo(isDark),

                        const SizedBox(height: 28),

                        // Title
                        ShaderMask(
                          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                          child: Text(
                            S.of(context, 'signupTitle'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context, 'signupSubtitle'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : AppTheme.lightTextSub,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Form card
                        _buildFormCard(isDark),

                        const SizedBox(height: 24),

                        // Login link
                        _buildLoginRow(isDark),

                        const SizedBox(height: 14),

                        // Teacher registration
                        _buildTeacherRegisterCard(isDark),

                        const SizedBox(height: 50),
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
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(8, 16),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Iconsax.teacher5,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Iconsax.user_add5, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                S.of(context, 'signupFormHeader'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Name
          _buildInputField(
            controller: _nameC,
            label: S.of(context, 'fullName'),
            hint: S.of(context, 'fullNameHint'),
            icon: Iconsax.user5,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Email
          _buildInputField(
            controller: _emailC,
            label: S.of(context, 'email'),
            hint: 'name@example.com',
            icon: Iconsax.sms5,
            isDark: isDark,
            isLtr: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password
          _buildInputField(
            controller: _passC,
            label: S.of(context, 'password'),
            hint: '••••••••',
            icon: Iconsax.lock5,
            isDark: isDark,
            isLtr: true,
            isPassword: true,
            obscureState: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
          ),

          const SizedBox(height: 12),

          // Password hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Iconsax.info_circle5, size: 14, color: AppTheme.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(
                  S.of(context, 'minChars'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Signup button
          _buildGradientButton(
            onPressed: _isLoading ? null : _signup,
            isLoading: _isLoading,
            label: S.of(context, 'signupTitle'),
            icon: Iconsax.user_add5,
            gradient: [AppTheme.primary, AppTheme.primary2],
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
    bool? obscureState,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white70 : AppTheme.lightTextSub,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          textDirection: isLtr ? TextDirection.ltr : null,
          textAlign: isLtr ? TextAlign.left : TextAlign.start,
          obscureText: isPassword ? (obscureState ?? true) : false,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : AppTheme.darkSurface,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (obscureState ?? true) ? Iconsax.eye_slash : Iconsax.eye,
                      color: isDark ? Colors.white30 : Colors.grey[400],
                      size: 22,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context, 'haveAccount'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : AppTheme.lightTextSub,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                S.of(context, 'goToLoginLink'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ماموستایت؟',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : AppTheme.lightTextSub,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
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
              shaderCallback: (bounds) => AppTheme.accentGradient.createShader(bounds),
              child: const Text(
                'خۆت تۆمار بکە',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
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
