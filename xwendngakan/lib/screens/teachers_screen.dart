import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../data/constants.dart';
import '../widgets/app_snackbar.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2,
                color: isDark ? Colors.white : AppTheme.darkSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'مامۆستاکان',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      isDark ? AppTheme.darkBg : AppTheme.lightBg,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TeacherListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherFormView()),
          );
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Iconsax.user_add, color: Colors.white),
        label: const Text('تۆمارکردنی مامۆستا', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}

class TeacherListView extends StatefulWidget {
  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  List<Map<String, dynamic>> _teachers = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final teachers = await ApiService.getTeachers(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        type: _selectedFilter == 'all' ? null : _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _teachers = teachers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'هەڵە لە بارکردنی داتاکان';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'گەڕان بە ناو، شار...',
                    prefixIcon: const Icon(Iconsax.search_normal_1, color: AppTheme.primary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _loadTeachers(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      _buildFilterTab('👨‍🏫 هەمووی', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterTab('🎓 زانکۆ', 'university'),
                      const SizedBox(width: 8),
                      _buildFilterTab('🏫 قوتابخانە', 'school'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? _buildShimmerLoading()
              : _error != null
                  ? Center(child: Text(_error!))
                  : _teachers.isEmpty
                      ? const Center(child: Text('هیچ مامۆستایەک نەدۆزرایەوە'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _teachers.length,
                          itemBuilder: (context, index) => _buildTeacherCard(_teachers[index]),
                        ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedFilter = value);
          _loadTeachers();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : (isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? AppTheme.primary : (isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final name = teacher['name'] ?? '';
    final typeLabel = teacher['type_label'] ?? '';
    final photo = teacher['photo'];
    final experienceYears = teacher['experience_years'];
    final hourlyRate = teacher['hourly_rate'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow(),
        border: Border.all(color: AppTheme.lightBorder),
      ),
      child: InkWell(
        onTap: () => _showTeacherDetails(teacher),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
                image: photo != null && photo.toString().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage('${ApiService.serverBase}$photo'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: photo == null || photo.toString().isEmpty
                  ? Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (experienceYears != null) ...[
                        _buildTag('$experienceYears ساڵ', Icons.history_rounded, Colors.blue),
                        const SizedBox(width: 8),
                      ],
                      if (hourlyRate != null)
                        _buildTag('$hourlyRate دینار', Icons.payments_outlined, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
    final name = teacher['name'] ?? '';
    final typeLabel = teacher['type_label'] ?? '';
    final city = teacher['city'] ?? '';
    final phone = teacher['phone'] ?? '';
    final experienceYears = teacher['experience_years'];
    final hourlyRate = teacher['hourly_rate'];
    final about = teacher['about'] ?? '';
    final photo = teacher['photo'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBg : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(32),
                      image: photo != null && photo.toString().isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage('${ApiService.serverBase}$photo'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photo == null || photo.toString().isEmpty
                        ? Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(typeLabel, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 32),
                  _buildDetailRow(Iconsax.location5, 'شار', city),
                  if (experienceYears != null) _buildDetailRow(Iconsax.medal_star5, 'ئەزموون', '$experienceYears ساڵ'),
                  if (hourlyRate != null) _buildDetailRow(Iconsax.wallet_money5, 'نرخی کاتژمێرێک', '$hourlyRate دینار'),
                  _buildDetailRow(Iconsax.call5, 'تەلەفۆن', phone),
                  if (about.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('دەربارە', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 12),
                    Text(about, style: const TextStyle(fontSize: 15, height: 1.6)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(child: CircularProgressIndicator());
  }
}

class TeacherFormView extends StatefulWidget {
  const TeacherFormView({super.key});

  @override
  State<TeacherFormView> createState() => _TeacherFormViewState();
}

class _TeacherFormViewState extends State<TeacherFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _aboutController = TextEditingController();

  String? _selectedType;
  String? _selectedCity;
  File? _photo;
  File? _subjectPhoto;

  final List<String> _cities = AppConstants.cities['عێراق'] ?? [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(title: const Text('تۆمارکردنی مامۆستا'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'ناوی سیانی', 'ناوی تەواو...', Iconsax.user, isRequired: true),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'ژمارەی تەلەفۆن', '07XX XXX XXXX', Iconsax.call, isRequired: true, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildDropdown('جۆری مامۆستا', _selectedType, ['مامۆستای زانکۆ', 'مامۆستای قوتابخانە'], (v) => setState(() => _selectedType = v), isRequired: true),
              const SizedBox(height: 16),
              _buildDropdown('شار', _selectedCity, _cities, (v) => setState(() => _selectedCity = v), isRequired: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_experienceController, 'ئەزموون', '0', Iconsax.medal_star, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_hourlyRateController, 'نرخ', '0', Iconsax.wallet_money, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildImagePicker('وێنەی مامۆستا', _photo, () => _pickImage(true))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildImagePicker('وێنەی بابەت', _subjectPhoto, () => _pickImage(false))),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(_aboutController, 'دەربارە', 'کەمێک دەربارەی خۆت...', Iconsax.user_tag, maxLines: 4),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(28)),
      child: const Row(
        children: [
          Icon(Iconsax.teacher5, color: Colors.white, size: 36),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مامۆستا بە!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('ببە بە مامۆستای تایبەت لە ئەپەکەمان', style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isRequired = false, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: isRequired ? (v) => v == null || v.isEmpty ? 'پێویستە' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          validator: isRequired ? (v) => v == null ? 'پێویستە' : null : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.category, color: AppTheme.primary, size: 20),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
            child: file != null ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(file, fit: BoxFit.cover)) : const Icon(Iconsax.image, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ناردنی داواکاری', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }

  Future<void> _pickImage(bool isTeacher) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null) setState(() => isTeacher ? _photo = File(res.files.single.path!) : _subjectPhoto = File(res.files.single.path!));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final res = await ApiService.submitTeacher(
      name: _nameController.text,
      phone: _phoneController.text,
      type: _selectedType == 'مامۆستای زانکۆ' ? 'university' : 'school',
      city: _selectedCity!,
      experienceYears: int.tryParse(_experienceController.text) ?? 0,
      hourlyRate: int.tryParse(_hourlyRateController.text) ?? 0,
      about: _aboutController.text,
      photo: _photo,
      subjectPhoto: _subjectPhoto,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        _showSuccessDialog();
        _clearForm();
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _experienceController.clear();
    _hourlyRateController.clear();
    _aboutController.clear();
    setState(() {
      _photo = null;
      _subjectPhoto = null;
      _selectedCity = null;
      _selectedType = null;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سەرکەوتوو بوو'),
        content: const Text('داواکارییەکەت نێردرا'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('باشە'))],
      ),
    );
  }
}
