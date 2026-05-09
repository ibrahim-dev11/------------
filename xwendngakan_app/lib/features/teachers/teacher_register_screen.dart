import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';

// Gold teacher palette
const _kGold1 = Color(0xFFD4A017);
const _kGold2 = Color(0xFFE8B84B);
const _kGoldGrad = LinearGradient(
  colors: [_kGold1, _kGold2],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  String? _city;
  String? _type;
  XFile? _photo;
  XFile? _subjectPhoto;
  bool _loading = false;
  bool _submitted = false;

  final _picker = ImagePicker();
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..forward();
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeIn));
    _slide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _expCtrl.dispose();
    _rateCtrl.dispose();
    _aboutCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(bool isSubject) async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => isSubject ? _subjectPhoto = img : _photo = img);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_city == null || _type == null) {
      _showError(l.required);
      return;
    }
    setState(() => _loading = true);
    final r = await _api.registerTeacher({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'city': _city!,
      'type': _type!,
      'experience_years': _expCtrl.text.trim(),
      'hourly_rate': _rateCtrl.text.trim(),
      'about': _aboutCtrl.text.trim(),
      'video_url': _videoCtrl.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (r.success) {
      setState(() => _submitted = true);
    } else {
      _showError(r.error ?? l.registerFailed);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF4757), Color(0xFFFF6B81)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4757).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'NotoSansArabic'))),
            ],
          ),
        ),
      ));
  }

  InputDecoration _inputDeco(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _kGold1),
      labelStyle: const TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _kGold1, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFFF4757)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // ── Success / Pending-approval screen ──────────────────────
    if (_submitted) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9),
        body: Stack(
          children: [
            // Gold gradient background blob
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: size.height * 0.42,
                decoration: const BoxDecoration(
                  gradient: _kGoldGrad,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(56),
                    bottomRight: Radius.circular(56),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Pending icon
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: _kGold1.withOpacity(0.35), blurRadius: 32, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: const Icon(Icons.pending_actions_rounded, color: _kGold1, size: 60),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'داواکاریەکەت نێردرا!',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold,
                      color: Colors.white, fontFamily: 'NotoSansArabic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Text(
                      'چاوەڕوانی تەسدیقی ئەدمین بە\nدوای پەسەندکردن دەردەکەوییتە لیستی مامۆستاکان',
                      style: TextStyle(
                        fontSize: 13, fontFamily: 'NotoSansArabic',
                        color: Colors.white.withOpacity(0.88), height: 1.75,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Steps card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildApprovalStep(1, 'داواکاری نێردرا', 'زانیاریەکانت وەرگیراون', true, isDark),
                          Divider(height: 22, color: isDark ? Colors.white12 : Colors.black12),
                          _buildApprovalStep(2, 'لەلایەن تیمەکەوە دەبینرێت', 'ئێمە داواکاریەکەت بەدیدەهێنین', false, isDark),
                          Divider(height: 22, color: isDark ? Colors.white12 : Colors.black12),
                          _buildApprovalStep(3, 'پەسەندکردن و بڵاوکردنەوە', 'دەردەکەوییتە لیستی مامۆستاکان', false, isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Home button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF534AB7), Color(0xFF7F77DD)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color(0xFF534AB7).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6))],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'بەرگەی سەرەکی',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'NotoSansArabic'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Main form ───────────────────────────────────────────────
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: _kGoldGrad,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  Positioned(
                    top: 140, left: -40,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Logo + title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 85, height: 85,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: const Center(
                                child: Icon(Icons.school_rounded, color: _kGold1, size: 44),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l.registerAsTeacher,
                              style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold,
                                color: Colors.white, fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'پرۆفایلەکەت پڕبکەرەوە',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.88), fontFamily: 'NotoSansArabic'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Form card
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : _kGold1.withOpacity(0.10),
                              blurRadius: 40, offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Photo pickers
                              Row(
                                children: [
                                  Expanded(
                                    child: _PhotoPicker(
                                      label: l.profilePhoto,
                                      icon: Icons.person_rounded,
                                      file: _photo,
                                      accentColor: _kGold1,
                                      onPick: () => _pickPhoto(false),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PhotoPicker(
                                      label: l.subjectPhoto,
                                      icon: Icons.menu_book_rounded,
                                      file: _subjectPhoto,
                                      accentColor: _kGold1,
                                      onPick: () => _pickPhoto(true),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Name
                              TextFormField(
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: _inputDeco(l.fullName, Icons.person_outline_rounded),
                                validator: (v) => (v == null || v.isEmpty) ? l.required : null,
                              ),
                              const SizedBox(height: 14),
                              // Phone
                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                decoration: _inputDeco(l.phone, Icons.phone_outlined, hint: '07xx xxx xxxx'),
                                validator: (v) => (v == null || v.isEmpty) ? l.required : null,
                              ),
                              const SizedBox(height: 14),
                              // Type
                              DropdownButtonFormField<String>(
                                value: _type,
                                decoration: _inputDeco(l.teacherType, Icons.category_outlined),
                                borderRadius: BorderRadius.circular(20),
                                items: [
                                  DropdownMenuItem(value: 'university', child: Text('🎓 ${l.university}', style: const TextStyle(fontFamily: 'NotoSansArabic'))),
                                  DropdownMenuItem(value: 'school', child: Text('🏫 ${l.school}', style: const TextStyle(fontFamily: 'NotoSansArabic'))),
                                ],
                                onChanged: (v) => setState(() => _type = v),
                              ),
                              const SizedBox(height: 14),
                              // City
                              DropdownButtonFormField<String>(
                                value: _city,
                                decoration: _inputDeco(l.city, Icons.location_on_outlined),
                                borderRadius: BorderRadius.circular(20),
                                items: AppConstants.iraqiCities.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: const TextStyle(fontFamily: 'NotoSansArabic')),
                                )).toList(),
                                onChanged: (v) => setState(() => _city = v),
                              ),
                              const SizedBox(height: 14),
                              // Exp + Rate row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _expCtrl,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      decoration: _inputDeco(l.experience, Icons.work_outline_rounded)
                                          .copyWith(suffixText: l.years),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _rateCtrl,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      decoration: _inputDeco(l.hourlyRate, Icons.monetization_on_outlined)
                                          .copyWith(suffixText: 'IQD'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // About
                              TextFormField(
                                controller: _aboutCtrl,
                                maxLines: 4,
                                decoration: _inputDeco(l.about, Icons.info_outline_rounded)
                                    .copyWith(alignLabelWithHint: true),
                              ),
                              const SizedBox(height: 14),
                              // Video URL
                              TextFormField(
                                controller: _videoCtrl,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                decoration: _inputDeco(
                                  'لینکی ڤیدیۆ',
                                  Icons.play_circle_outline_rounded,
                                  hint: 'https://youtube.com/...',
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  final uri = Uri.tryParse(v);
                                  if (uri == null || !uri.hasAbsolutePath || (!v.startsWith('http://') && !v.startsWith('https://'))) {
                                    return 'لینکی نادروستە';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              // Submit
                              SizedBox(
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [_kGold1, _kGold2]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: _kGold1.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    icon: _loading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                    label: Text(
                                      l.submit,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'NotoSansArabic'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back button overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 12),
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStep(int num, String title, String sub, bool done, bool isDark) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? _kGold1 : (isDark ? const Color(0xFF2A3A4A) : const Color(0xFFEEEEEE)),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    '$num',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14,
                  fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12, fontFamily: 'NotoSansArabic',
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final XFile? file;
  final Color accentColor;
  final VoidCallback onPick;

  const _PhotoPicker({
    required this.label,
    required this.icon,
    required this.accentColor,
    this.file,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: file != null ? accentColor : accentColor.withOpacity(0.3),
            width: file != null ? 1.5 : 1,
          ),
          image: file != null
              ? DecorationImage(image: FileImage(File(file!.path)), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: accentColor),
                  const SizedBox(height: 6),
                  Icon(Icons.add_circle_rounded, size: 18, color: accentColor.withOpacity(0.7)),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 11, color: accentColor, fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ],
              )
            : Stack(
                alignment: Alignment.topRight,
                children: [
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: _kGold1, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
