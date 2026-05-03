import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/app_snackbar.dart';
import '../models/institution.dart';
import 'institution_dashboard_screen.dart';

class InstitutionRequestScreen extends StatefulWidget {
  const InstitutionRequestScreen({super.key});

  @override
  State<InstitutionRequestScreen> createState() => _InstitutionRequestScreenState();
}

class _InstitutionRequestScreenState extends State<InstitutionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  bool _isFetchingStatus = true;
  String? _status;
  Institution? _myInstitution;
  Timer? _statusTimer;

  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final statusData = await ApiService.getInstitutionRequestStatus();
    final inst = await ApiService.getMyInstitution();
    if (!mounted) return;
    
    setState(() {
      _isFetchingStatus = false;
      _myInstitution = inst;
      if (statusData != null) {
        _status = statusData['status'];
      }
    });

    if (_status == 'pending' && _statusTimer == null) {
      _startStatusTimer();
    }
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final statusData = await ApiService.getInstitutionRequestStatus();
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (statusData != null && statusData['status'] != _status) {
        final inst = await ApiService.getMyInstitution();
        if (!mounted) return;
        setState(() {
          _status = statusData['status'];
          _myInstitution = inst;
        });
        if (_status == 'approved' || _status == 'rejected') {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await ApiService.submitInstitutionRequest(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      // Show success dialog or snackbar
      AppSnackbar.success(context, res['message'] ?? 'داواکاریەکەت نێردرا');
      
      setState(() {
        _status = 'pending';
      });
      _startStatusTimer();
    } else {
      AppSnackbar.error(context, res['message'] ?? 'هەڵەیەک ڕوویدا');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingStatus) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_status == 'approved') {
      return InstitutionDashboardScreen(
        initialInstitution: _myInstitution,
        onInstitutionCreated: () {
          _fetchStatus();
        },
      );
    }

    if (_status == 'rejected') {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('داواکاری تۆمارکردنی دامەزراوە'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  size: 80,
                  color: AppTheme.danger,
                ),
                const SizedBox(height: 24),
                const Text(
                  'داواکاریەکەت ڕەتکرایەوە',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'بەداخەوە ڕەزامەندی نەدرا لەسەر داواکارییەکەت لەلایەن بەڕێوەبەرەوە.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await ApiService.clearInstitutionRequest();
                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                      _status = null;
                      _statusTimer = null;
                    });
                  },
                  child: _isLoading 
                      ? const SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text('دووبارە داواکاری بنێرە'),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_status == 'pending') {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('داواکاری تۆمارکردنی دامەزراوە'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  size: 80,
                  color: AppTheme.warning,
                ),
                const SizedBox(height: 24),
                const Text(
                  'داواکاریەکەت لەژێر پێداچوونەوەدایە',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'تکایە چاوەڕێ بکە تاوەکو بەڕێوەبەر ڕەزامەندی دەدات. دوای ڕەزامەندی ڕاستەوخۆ دەتوانیت فۆڕمی دامەزراوە پڕ بکەیتەوە.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('داواکاری تۆمارکردنی دامەزراوە'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppTheme.navy : Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image or icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.supervised_user_circle_rounded,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'بەدەستهێنانی دەسەڵات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'پێش ئەوەی دامەزراوە زیاد بکەیت، پێویستە سەلماندنێک بنێریت بۆ ئەوەی ڕێگەت پێ بدرێت لەلایەن بەڕێوەبەرەوە.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                _buildTextField(
                  controller: _nameController,
                  label: 'ناوی سیانی',
                  hint: 'ناوی خۆت بنووسە...',
                  icon: Icons.person_outline_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: 'ژمارەی مۆبایل',
                  hint: '07XX XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Message
                _buildTextField(
                  controller: _messageController,
                  label: 'نامە (ئارەزوومەندانە)',
                  hint: 'زیاتر زانیاری بنوسە',
                  icon: Icons.message_outlined,
                  maxLines: 4,
                  isRequired: false,
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                        : const Text(
                            'ناردنی داواکاری',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.danger, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: isRequired
              ? (v) => v == null || v.trim().isEmpty ? 'ئەم بەشە پێویستە' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.primary) : null,
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
