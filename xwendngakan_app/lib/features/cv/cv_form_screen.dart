import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/api_service.dart';
import '../../shared/widgets/common_widgets.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _gradYearCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _city;
  String? _gender;
  String? _educationLevel;
  XFile? _photo;
  bool _loading = false;
  bool _submitted = false;
  List<String> _eduLevels = ['بکالۆریۆس', 'ماستەر', 'دکتۆرا', 'دیپلۆم', 'ئامادەیی'];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEduLevels();
  }

  Future<void> _loadEduLevels() async {
    final r = await _api.getEducationLevels();
    if (r.success && r.data != null) {
      setState(() => _eduLevels = r.data!);
    }
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
    _skillsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _photo = img);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
      'skills': _skillsCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (r.success) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r.error ?? 'Submission failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_submitted) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 20),
                  Text(l.successTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(l.cvSubmitSuccess,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  GradientButton(
                    text: l.done,
                    gradient: const LinearGradient(
                        colors: [AppColors.purple, AppColors.primary]),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.uploadCv),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purple.withOpacity(0.1),
                      border: Border.all(color: AppColors.purple, width: 2),
                      image: _photo != null
                          ? DecorationImage(image: FileImage(File(_photo!.path)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photo == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppColors.purple, size: 28),
                              SizedBox(height: 4),
                              Text('Photo', style: TextStyle(fontSize: 10, color: AppColors.purple)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, '📋 ${l.personalInfo}'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l.fullName, prefixIcon: const Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.isEmpty) ? l.required : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l.phone, prefixIcon: const Icon(Icons.phone_outlined)),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.age, prefixIcon: const Icon(Icons.cake_outlined)),
                )),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _city,
                decoration: InputDecoration(labelText: l.city, prefixIcon: const Icon(Icons.location_on_outlined)),
                items: AppConstants.iraqiCities.map((c) => DropdownMenuItem(
                    value: c, child: Text(c, style: const TextStyle(fontFamily: 'NotoSansArabic')))).toList(),
                onChanged: (v) => setState(() => _city = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: l.gender, prefixIcon: const Icon(Icons.people_outline)),
                items: [
                  DropdownMenuItem(value: 'male', child: Text('♂️ ${l.male}')),
                  DropdownMenuItem(value: 'female', child: Text('♀️ ${l.female}')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 20),
              _sectionLabel(context, '🎓 ${l.education}'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _fieldCtrl,
                decoration: InputDecoration(
                  labelText: l.fieldOfStudy,
                  prefixIcon: const Icon(Icons.book_outlined),
                ),
                validator: (v) => (v == null || v.isEmpty) ? l.required : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _educationLevel,
                  decoration: InputDecoration(labelText: l.educationLevel),
                  items: _eduLevels.map((e) => DropdownMenuItem(
                      value: e, child: Text(e, style: const TextStyle(fontFamily: 'NotoSansArabic')))).toList(),
                  onChanged: (v) => setState(() => _educationLevel = v),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _gradYearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.graduationYear),
                )),
              ]),
              const SizedBox(height: 20),
              _sectionLabel(context, '💼 ${l.experience}'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _expCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.experience,
                  prefixIcon: const Icon(Icons.work_outline),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.skills,
                  prefixIcon: const Icon(Icons.star_outline),
                  alignLabelWithHint: true,
                  hintText: 'Flutter, Dart, Python...',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.notes,
                  prefixIcon: const Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                text: l.submit,
                gradient: const LinearGradient(colors: [AppColors.purple, AppColors.primary]),
                onPressed: _submit,
                isLoading: _loading,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    ),
  );
}
