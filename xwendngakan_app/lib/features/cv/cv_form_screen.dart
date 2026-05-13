import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _gradYearCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  // Removed _uniCtrl, _addressCtrl, _languagesCtrl, _skillsCtrl as per request
  final _prevWorkCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();

  List<Map<String, String>> _selectedLangs = [];
  List<String> _selectedSkills = [];
  final List<String> _langLevels = ['سەرەتایی', 'مامناوەند', 'باش', 'زۆرباش'];

  String? _city;
  String? _gender;
  String? _educationLevel;
  XFile? _photo;
  bool _loading = false;
  bool _submitted = false;
  
  // Hardcoded as requested
  final List<String> _eduLevels = [
    'خوێندنی ناوەندی',
    'ئامادەیی',
    'دیپلۆم',
    'بکالۆریۆس',
    'ماستەر',
    'دکتۆرا'
  ];

  final _picker = ImagePicker();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _fadeAnim = CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _fieldCtrl.dispose();
    _gradYearCtrl.dispose();
    _expCtrl.dispose();
    _notesCtrl.dispose();
    _prevWorkCtrl.dispose();
    _socialCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _photo = img);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for City and Gender which are dropdowns/autocomplete
    if (_city == null || _city!.trim().isEmpty) {
      _showError('تکایە شار / شوێنی نیشتەجێبوون دیاری بکە');
      return;
    }
    if (_gender == null) {
      _showError('تکایە ڕەگەز دیاری بکە');
      return;
    }
    if (_educationLevel == null) {
      _showError('تکایە ئاستی خوێندن دیاری بکە');
      return;
    }

    setState(() => _loading = true);
    final r = await _api.submitCv({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'age': _ageCtrl.text.trim(),
      'city': _city ?? '',
      'gender': _gender ?? '',
      'field': _fieldCtrl.text.trim(),
      'education_level': _educationLevel ?? '',
      'graduation_year': _gradYearCtrl.text.trim(),
      'experience': _expCtrl.text.trim(),
      'skills': _selectedSkills.where((s) => s.trim().isNotEmpty).join(', '),
      'notes': _notesCtrl.text.trim(),
      // Format languages as "Lang (Level), Lang (Level)"
      'languages': _selectedLangs.map((l) => "${l['name']} (${l['level']})").join(', '),
      'previous_work': _prevWorkCtrl.text.trim(),
      'social_links': _socialCtrl.text.trim(),
    }, photoPath: _photo?.path);
    setState(() => _loading = false);
    
    if (!mounted) return;
    if (r.success) {
      setState(() => _submitted = true);
    } else {
      _showError(r.error ?? 'Submission failed');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Rabar')),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_submitted) return const _SuccessScreen();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F3FF),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
              top: -80,
              right: -60,
              child: _Blob(
                  size: 280,
                  color: AppColors.primary
                      .withValues(alpha: isDark ? 0.12 : 0.07))),
          Positioned(
              bottom: 100,
              left: -80,
              child: _Blob(
                  size: 220,
                  color: AppColors.purple
                      .withValues(alpha: isDark ? 0.10 : 0.05))),
          Positioned(
              top: 200,
              left: -40,
              child: _Blob(
                  size: 150,
                  color: AppColors.success
                      .withValues(alpha: isDark ? 0.08 : 0.04))),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    _buildHeader(context, l, isDark),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              _buildPhotoSection(isDark),
                              const SizedBox(height: 28),
                              
                              // Section 1: Personal Info
                              _buildSection(
                                context,
                                isDark,
                                icon: Icons.person_rounded,
                                color: AppColors.primary,
                                title: 'زانیاری کەسی',
                                children: [
                                  _PremiumField(
                                      controller: _nameCtrl,
                                      label: 'ناوی سیانی تەواو',
                                      hint: 'وەک: ئیبراهیم ئیسماعیل محەمەد',
                                      icon: Icons.badge_outlined,
                                      isDark: isDark,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'تکایە ئەم خانەیە پڕبکەرەوە'
                                          : null),
                                  const SizedBox(height: 14),
                                  Row(children: [
                                    Expanded(
                                        child: _PremiumField(
                                            controller: _phoneCtrl,
                                            label: 'ژمارەی مۆبایل',
                                            hint: 'وەک: 0750xxxxxxx',
                                            icon: Icons.phone_outlined,
                                            isDark: isDark,
                                            keyboardType: TextInputType.phone,
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) return 'تکایە ئەم خانەیە پڕبکەرەوە';
                                              if (!RegExp(r'^(07)[0-9]{9}$').hasMatch(v.trim())) return 'ژمارەی مۆبایل دروست نییە';
                                              return null;
                                            })),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _PremiumField(
                                            controller: _ageCtrl,
                                            label: 'تەمەن',
                                            hint: 'وەک: 25',
                                            icon: Icons.cake_outlined,
                                            isDark: isDark,
                                            keyboardType: TextInputType.number,
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) return 'تکایە تەمەن بنووسە';
                                              if (int.tryParse(v.trim()) == null) return 'تەمەن دروست نییە';
                                              return null;
                                            })),
                                  ]),
                                  const SizedBox(height: 14),
                                  _PremiumField(
                                      controller: _emailCtrl,
                                      label: 'ئیمەیڵ',
                                      icon: Icons.email_outlined,
                                      isDark: isDark,
                                      keyboardType: TextInputType.emailAddress,
                                      hint: 'example@gmail.com',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'تکایە ئیمەیڵەکەت بنووسە';
                                        if (!v.contains('@')) return 'ئیمەیڵ دروست نییە';
                                        return null;
                                      }),
                                  const SizedBox(height: 14),
                                  _CityAutocomplete(
                                    value: _city,
                                    label: 'شار / شوێنی نیشتەجێبوون',
                                    isDark: isDark,
                                    onChanged: (v) => setState(() => _city = v),
                                  ),
                                  const SizedBox(height: 14),
                                  _PremiumDropdown<String>(
                                    value: _gender,
                                    label: 'ڕەگەز',
                                    icon: Icons.people_outline,
                                    isDark: isDark,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'male',
                                          child: Text('♂ نێر',
                                              style: TextStyle(fontFamily: 'Rabar'))),
                                      DropdownMenuItem(
                                          value: 'female',
                                          child: Text('♀ مێ',
                                              style: TextStyle(fontFamily: 'Rabar'))),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _gender = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Section 2: Education
                              _buildSection(
                                context,
                                isDark,
                                icon: Icons.school_rounded,
                                color: AppColors.success,
                                title: 'خوێندن',
                                children: [
                                  _PremiumField(
                                      controller: _fieldCtrl,
                                      label: 'پسپۆڕی / بەشی خوێندن',
                                      icon: Icons.book_outlined,
                                      isDark: isDark,
                                      hint: 'وەک: زانستی کۆمپیوتەر',
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'تکایە ئەم خانەیە پڕبکەرەوە'
                                          : null),
                                  const SizedBox(height: 14),
                                  Row(children: [
                                    Expanded(
                                        child: _PremiumDropdown<String>(
                                      value: _educationLevel,
                                      label: 'ئاستی خوێندن',
                                      icon: Icons.military_tech_outlined,
                                      isDark: isDark,
                                      items: _eduLevels
                                          .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e,
                                                  style: const TextStyle(
                                                      fontFamily: 'Rabar',
                                                      fontSize: 13))))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _educationLevel = v),
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _PremiumField(
                                            controller: _gradYearCtrl,
                                            label: 'ساڵی دەرچوون',
                                            icon: Icons.calendar_today_outlined,
                                            isDark: isDark,
                                            hint: 'وەک: 2024',
                                            keyboardType: TextInputType.number,
                                            validator: (v) {
                                              if (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) {
                                                return 'تکایە ساڵێکی دروست بنووسە';
                                              }
                                              return null;
                                            })),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Section 3: Experience & Skills
                              _buildSection(
                                context,
                                isDark,
                                icon: Icons.work_rounded,
                                color: AppColors.accent,
                                title: 'ئەزموون و تواناکان',
                                children: [
                                  _PremiumField(
                                      controller: _expCtrl,
                                      label: 'ئەزموونی کار',
                                      icon: Icons.work_outline,
                                      isDark: isDark,
                                      hint: 'کورتەیەک لە ئەزموونی کار',
                                      maxLines: 3),
                                  const SizedBox(height: 14),
                                  _PremiumField(
                                      controller: _prevWorkCtrl,
                                      label: 'شوێنی کارکردنی پێشوو (ئارەزوومەندانە)',
                                      icon: Icons.business_center_outlined,
                                      isDark: isDark,
                                      hint: 'وەک: کۆمپانیای ئاسیاسێڵ، نەخۆشخانەی...'),
                                  const SizedBox(height: 14),
                                  // Dynamic Skills Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(children: [
                                        Icon(Icons.star_outline, color: AppColors.primary, size: 20),
                                        SizedBox(width: 8),
                                        Text('تواناکان / شارەزاییەکان', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rabar')),
                                      ]),
                                      TextButton.icon(
                                        onPressed: () => setState(() => _selectedSkills.add('')),
                                        icon: const Icon(Icons.add_circle_outline, size: 18),
                                        label: const Text('زیادکردن', style: TextStyle(fontFamily: 'Rabar')),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_selectedSkills.isEmpty)
                                    Center(child: Text('هیچ توانایەک زیاد نەکراوە', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'Rabar'))),
                                  ..._selectedSkills.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: entry.value,
                                              onChanged: (v) => _selectedSkills[idx] = v,
                                              decoration: InputDecoration(
                                                hintText: 'وەک: گرافیک دیزاین، مایکرۆسۆفت وۆرد...',
                                                isDense: true,
                                                hintStyle: const TextStyle(fontSize: 12, fontFamily: 'Rabar'),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                            onPressed: () => setState(() => _selectedSkills.removeAt(idx)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 24),
                                  
                                  // Dynamic Languages Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(children: [
                                        Icon(Icons.language_outlined, color: AppColors.primary, size: 20),
                                        SizedBox(width: 8),
                                        Text('زمانەکان', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rabar')),
                                      ]),
                                      TextButton.icon(
                                        onPressed: () => setState(() => _selectedLangs.add({'name': '', 'level': 'مامناوەند'})),
                                        icon: const Icon(Icons.add_circle_outline, size: 18),
                                        label: const Text('زیادکردن', style: TextStyle(fontFamily: 'Rabar')),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_selectedLangs.isEmpty)
                                    Center(child: Text('هیچ زمانێک زیاد نەکراوە', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontFamily: 'Rabar'))),
                                  ..._selectedLangs.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              initialValue: entry.value['name'],
                                              onChanged: (v) => _selectedLangs[idx]['name'] = v,
                                              decoration: InputDecoration(
                                                hintText: 'ناوی زمان',
                                                isDense: true,
                                                hintStyle: const TextStyle(fontSize: 12, fontFamily: 'Rabar'),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: DropdownButtonFormField<String>(
                                              value: entry.value['level'],
                                              isExpanded: true,
                                              items: _langLevels.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12, fontFamily: 'Rabar')))).toList(),
                                              onChanged: (v) => setState(() => _selectedLangs[idx]['level'] = v!),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                            onPressed: () => setState(() => _selectedLangs.removeAt(idx)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 14),
                                  const SizedBox(height: 14),
                                  _PremiumField(
                                      controller: _socialCtrl,
                                      label: 'LinkedIn / Facebook (ئارەزوومەندانە)',
                                      icon: Icons.link_outlined,
                                      isDark: isDark,
                                      hint: 'لینکی هەژمارەکەت لێرە دابنێ'),
                                  const SizedBox(height: 14),
                                  _PremiumField(
                                      controller: _notesCtrl,
                                      label: 'تێبینی زیاتر',
                                      icon: Icons.notes_outlined,
                                      isDark: isDark,
                                      hint: 'هەر زانیارییەکی تر کە بە پێویستی دەزانیت...',
                                      maxLines: 3),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildSubmitButton(isDark),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _GlassBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              isDark: isDark,
              onTap: () => context.pop()),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.uploadCv,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontFamily: 'Rabar')),
                Text(l.cvBankSubtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontFamily: 'Rabar'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('CV',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickPhoto,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _photo == null
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.purple.withValues(alpha: 0.15)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(color: AppColors.primary, width: 2.5),
                image: _photo != null
                    ? DecorationImage(
                        image: FileImage(File(_photo!.path)), fit: BoxFit.cover)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: _photo == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: AppColors.primary, size: 30),
                        SizedBox(height: 4),
                        Text('وێنەی کەسی',
                            style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Rabar',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ],
                    )
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : color.withValues(alpha: 0.12),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontFamily: 'Rabar')),
              ]),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10))
        ],
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: _loading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('CV ـەکەت بنێرە',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Rabar')),
                SizedBox(width: 10),
                Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ]),
      ),
    );
  }
}

// ── Premium Input Field ──
class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;
  final String? Function(String?)? validator;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
          fontFamily: 'Rabar',
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelStyle: TextStyle(
            fontFamily: 'Rabar',
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 13),
        hintStyle: TextStyle(
            fontFamily: 'Rabar',
            color: isDark ? Colors.white30 : Colors.black26,
            fontSize: 12),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.6),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 2)),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

// ── City Autocomplete (searchable) ──
class _CityAutocomplete extends StatefulWidget {
  final String? value;
  final String label;
  final bool isDark;
  final void Function(String?) onChanged;

  const _CityAutocomplete({
    required this.value,
    required this.label,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_CityAutocomplete> createState() => _CityAutocompleteState();
}

class _CityAutocompleteState extends State<_CityAutocomplete> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, bool isDark) => InputDecoration(
        labelText: label,
        hintText: 'وەک: هەولێر، سلێمانی...',
        prefixIcon: const Icon(Icons.location_on_outlined,
            color: AppColors.primary, size: 20),
        suffixIcon:
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
        labelStyle: TextStyle(
            fontFamily: 'Rabar',
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 13),
        hintStyle: TextStyle(
            fontFamily: 'Rabar',
            color: isDark ? Colors.white30 : Colors.black26,
            fontSize: 12),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.value ?? ''),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.trim();
        if (q.isEmpty) return AppConstants.iraqiCities;
        return AppConstants.iraqiCities.where((c) => c.contains(q)).toList();
      },
      onSelected: (val) {
        _ctrl.text = val;
        widget.onChanged(val);
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: (_) => onSubmit(),
          onChanged: widget.onChanged, // Update typed values even without selection
          style: TextStyle(
              fontFamily: 'Rabar',
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 14),
          decoration: _decoration(widget.label, isDark),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05)),
                itemBuilder: (context, index) {
                  final city = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(city),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(city,
                            style: TextStyle(
                                fontFamily: 'Rabar',
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Premium Dropdown ──
class _PremiumDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData icon;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  const _PremiumDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: TextStyle(
          fontFamily: 'Rabar',
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelStyle: TextStyle(
            fontFamily: 'Rabar',
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 13),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

// ── Glass Button ──
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassBtn(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06)),
            ),
            child: Icon(icon,
                color: isDark ? Colors.white : Colors.black87, size: 20),
          ),
        ),
      ),
    );
  }
}

// ── Blob ──
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

// ── Success Screen ──
class _SuccessScreen extends StatefulWidget {
  const _SuccessScreen();
  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F3FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.successGradient),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 52),
                )),
            const SizedBox(height: 32),
            FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Text('CV ـەکەت بە سەرکەوتوویی تۆمارکرا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontFamily: 'Rabar')),
                  const SizedBox(height: 16),
                  Text(
                      'زانیارییەکانت بە سەرکەوتوویی نێردران. چاوەروان بە تا بڵاو دەکرێتەوە',
                      style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontFamily: 'Rabar',
                          height: 1.6),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: AppColors.successGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ]),
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('باشە',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Rabar')),
                    ),
                  ),
                ])),
          ]),
        ),
      ),
    );
  }
}
