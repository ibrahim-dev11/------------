import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _fieldController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedEducationLevel;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _graduationYearController.dispose();
    _fieldController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 28),
                
                // Section 1: Personal Info
                _buildSectionTitle('👤', 'زانیاری کەسی'),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _nameController,
                  label: 'ناوی سیانی',
                  hint: 'ناوی سیانی تەواو',
                  prefixIcon: Icons.person_outline_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'ژ.مۆبایل',
                        hint: '07XX XXX XXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'شار',
                        hint: 'هەولێر',
                        prefixIcon: Icons.location_on_outlined,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _ageController,
                        label: 'تەمەن',
                        hint: '25',
                        prefixIcon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'ڕەگەز',
                        value: _selectedGender,
                        items: ['نێر', 'مێ'],
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'ئیمەیڵ (ئیختیاری)',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 28),
                
                // Section 2: Education
                _buildSectionTitle('🎓', 'زانیاری خوێندن'),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _fieldController,
                  label: 'بواری خوێندن / پیشە',
                  hint: 'ئەندازیاری کۆمپیوتەر',
                  prefixIcon: Icons.school_outlined,
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'ئاستی خوێندن',
                        value: _selectedEducationLevel,
                        items: ['پۆلی یەکەم', 'پۆلی دووەم', 'پۆلی سێیەم', 'پۆلی چوارەم', 'دەرچوو', 'ماستەر', 'دکتۆرا'],
                        onChanged: (v) => setState(() => _selectedEducationLevel = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _graduationYearController,
                        label: 'ساڵی دەرچوون',
                        hint: '2024',
                        prefixIcon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Section 3: Skills & Experience
                _buildSectionTitle('💼', 'ئەزموون و تواناکان'),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _skillsController,
                  label: 'تواناکان',
                  hint: 'ئینگلیزی، کۆمپیوتەر، شوفێری...',
                  prefixIcon: Icons.star_outline_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _experienceController,
                  label: 'ئەزموونی کار (ئیختیاری)',
                  hint: 'ئەزموونەکانت بنووسە...',
                  prefixIcon: Icons.work_outline_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _notesController,
                  label: 'تێبینی زیاتر (ئیختیاری)',
                  hint: 'هەر شتێکی تر...',
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                _buildSubmitButton(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.accent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تۆمارکردنی CV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'زانیاریەکانت پڕبکەوە و ناردن بکە',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppTheme.primary, size: 22),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8ECF0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 14 : 0,
        ),
      ),
      validator: isRequired
          ? (value) => value?.trim().isEmpty ?? true ? 'پێویستە' : null
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8ECF0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Theme.of(context).cardColor,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppTheme.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'ناردنی CV',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.submitCv(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        city: _cityController.text.trim(),
        age: _ageController.text.trim().isEmpty ? null : int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        graduationYear: _graduationYearController.text.trim(),
        field: _fieldController.text.trim(),
        educationLevel: _selectedEducationLevel,
        experience: _experienceController.text.trim(),
        skills: _skillsController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog();
        _clearForm();
      } else {
        _showErrorSnackbar(result['message'] ?? 'هەڵەیەک ڕوویدا');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('تکایە پەیوەندیت بە ئینتەرنێت هەبێت');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'سەرکەوتوو بوو! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'CVکەت بە سەرکەوتوویی تۆمارکرا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'باشە',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _cityController.clear();
    _ageController.clear();
    _graduationYearController.clear();
    _fieldController.clear();
    _experienceController.clear();
    _skillsController.clear();
    _notesController.clear();
    setState(() {
      _selectedGender = null;
      _selectedEducationLevel = null;
    });
  }
}
