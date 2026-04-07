import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';
import '../services/app_localizations.dart';
import 'map_picker_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;
  const RegisterScreen({super.key, this.onSubmitted});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = '';
  final String _country = 'عێراق';
  String _city = '';
  bool _showOptional = false;
  File? _logoFile;

  final _nkuC = TextEditingController();
  final _nenC = TextEditingController();
  final _cityC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _webC = TextEditingController();
  final _addrC = TextEditingController();
  final _descC = TextEditingController();
  // Dynamic colleges & departments
  final List<_CollegeEntry> _colleges = [];
  // KG/DC fields
  final _kgAgeC = TextEditingController();
  final _kgHoursC = TextEditingController();
  // Social
  final _fbC = TextEditingController();
  final _waC = TextEditingController();

  double? _lat;
  double? _lng;

  bool _isSubmitting = false;

  bool get _isKgDcType => _type == 'kg' || _type == 'dc';

  bool get _hasColleges =>
      _type == 'gov' || _type == 'priv' || _type == 'eve_uni';

  @override
  void dispose() {
    for (final c in [
      _nkuC, _nenC, _phoneC, _emailC, _webC, _addrC, _descC,
      _kgAgeC, _kgHoursC, _fbC, _waC,
    ]) {
      c.dispose();
    }
    for (final college in _colleges) {
      college.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prov = context.watch<AppProvider>();

    // Check login - show login prompt if not logged in
    if (!prov.isLoggedIn) {
      return _buildLoginRequired(isDark);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          S.of(context, 'registerInstitution'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF422006)
                      : const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF854D0E)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⏳', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        S.of(context, 'adminApprovalNotice'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Required Section
              _sectionCard(
                isDark: isDark,
                icon: Iconsax.info_circle,
                title: S.of(context, 'mainInfo'),
                children: [
                  // Image picker
                  _buildLogoPicker(isDark),
                  const SizedBox(height: 14),
                  _field(S.of(context, 'institutionName'), _nkuC, S.of(context, 'institutionNameHint')),
                  const SizedBox(height: 14),
                  _field(S.of(context, 'city'), _cityC, S.of(context, 'cityHint')),
                  const SizedBox(height: 14),
                  _label(S.of(context, 'typeRequired'), isDark),
                  const SizedBox(height: 8),
                  _buildTypeSelector(isDark),
                  const SizedBox(height: 14),
                  // Address with geolocator (city extracted automatically)
                  _addressFieldWithLocation(isDark),
                ],
              ),

              const SizedBox(height: 14),

              // Optional Section Toggle
              _buildToggleSection(
                isDark: isDark,
                label: S.of(context, 'moreInfo'),
                isOpen: _showOptional,
                onTap: () => setState(() => _showOptional = !_showOptional),
              ),

              // Optional Fields (6 sections matching detail view)
              if (_showOptional) ...[
                const SizedBox(height: 14),

                // ─── ١. دەربارە (About) ───
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.document_text_1,
                  title: S.of(context, 'about'),
                  children: [
                    _field(S.of(context, 'englishName'), _nenC, 'English name...', isLTR: true),
                    const SizedBox(height: 12),
                    _field(
                      S.of(context, 'aboutInstitution'),
                      _descC,
                      S.of(context, 'aboutHint'),
                      maxLines: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── ٢. بەشەکان (Sections/Departments) ───
                if (_type != 'school' && _type != 'kg' && _type != 'dc')
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.book_1,
                  title: S.of(context, 'sections'),
                  children: [
                    ..._colleges.asMap().entries.map((entry) {
                      final i = entry.key;
                      final college = entry.value;
                      return _buildCollegeCard(i, college, isDark);
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _colleges.add(_CollegeEntry());
                          });
                        },
                        icon: const Icon(Iconsax.add_circle, size: 18),
                        label: Text(_hasColleges
                            ? S.of(context, 'addCollege')
                            : S.of(context, 'addDept')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── ٣. KG/DC ───
                if (_isKgDcType)
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.wallet_2,
                  title: S.of(context, 'extraInfo'),
                  children: [
                    _field(S.of(context, 'admissionAge'), _kgAgeC, S.of(context, 'admissionAgeHint')),
                    const SizedBox(height: 12),
                    _field(S.of(context, 'workHours'), _kgHoursC, S.of(context, 'workHoursHint')),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── ٤. پەیوەندی (Contact) ───
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.call,
                  title: S.of(context, 'contact'),
                  children: [
                    _field(S.of(context, 'phone'), _phoneC, '07XX XXX XXXX', isLTR: true),
                    const SizedBox(height: 12),
                    _field(S.of(context, 'email'), _emailC, 'info@example.com', isLTR: true),
                    const SizedBox(height: 12),
                    _field(S.of(context, 'website'), _webC, 'https://...', isLTR: true),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── ٥. سۆشیال (Social Media) ───
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.share,
                  title: S.of(context, 'social'),
                  children: [
                    _socialField('Facebook', _fbC, Iconsax.message,
                        const Color(0xFF1877F2)),
                    const SizedBox(height: 10),
                    _socialField('WhatsApp', _waC, Iconsax.message,
                        const Color(0xFF25D366)),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.success, AppTheme.success2],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Iconsax.send_15,
                        color: Colors.white, size: 20),
                    label: Text(
                      S.of(context, 'submitToAdmin'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    final prov = context.watch<AppProvider>();

    // Use dynamic types from API, fallback to constants
    final List<MapEntry<String, String>> typeEntries;
    final Map<String, String> emojiMap;

    if (prov.hasInstitutionTypes) {
      typeEntries = prov.institutionTypes
          .map((t) => MapEntry(t['key'] as String, prov.localizedField(t, 'name')))
          .toList();
      emojiMap = {
        for (final t in prov.institutionTypes)
          t['key'] as String: (t['emoji'] as String?) ?? '📌',
      };
    } else {
      typeEntries = prov.localizedTypeLabels.entries.toList();
      emojiMap = AppConstants.typeEmojis;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: typeEntries.map((e) {
        final isSelected = _type == e.key;
        final emoji = emojiMap[e.key] ?? '📌';
        return GestureDetector(
          onTap: () => setState(() => _type = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : (isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoPicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickLogo,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                image: _logoFile != null
                    ? DecorationImage(
                        image: FileImage(_logoFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _logoFile == null
                  ? Icon(Iconsax.camera, size: 32,
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              _logoFile == null ? S.of(context, 'addLogo') : S.of(context, 'changeLogo'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _logoFile = File(result.files.single.path!);
      });
    }
  }

  Widget _socialField(
      String label, TextEditingController c, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: c,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFE2E8F0) : null),
            decoration: InputDecoration(
              hintText: '$label...',
              hintStyle: TextStyle(
                fontSize: 12,
                color:
                    isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary
                      .withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE8E8E8),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required bool isDark,
    required String label,
    required bool isOpen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOpen ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
              size: 18,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF475569),
              ),
            ),
            const Spacer(),
            Icon(
              isOpen ? Iconsax.minus_cirlce : Iconsax.add_circle,
              size: 20,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF555555),
      ),
    );
  }

  Widget _addressFieldWithLocation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(S.of(context, 'addressRequired'), isDark),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _addrC,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFE2E8F0) : null),
                decoration: InputDecoration(
                  hintText: S.of(context, 'addressHint'),
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFBBBBBB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Map picker button
            SizedBox(
              height: 48,
              width: 48,
              child: Material(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openMapPicker,
                  child: Center(
                    child: Icon(Iconsax.location,
                        color: AppTheme.primary, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLocation: _lat != null && _lng != null
              ? LatLng(_lat!, _lng!)
              : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
        final city = result['city'] as String? ?? '';
        final address = result['address'] as String? ?? '';
        if (city.isNotEmpty) {
          _city = city;
          _cityC.text = city;
        }
        if (address.isNotEmpty) {
          _addrC.text = address;
        }
      });
    }
  }

  Widget _field(String label, TextEditingController c, String hint,
      {bool isLTR = false, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          textDirection: isLTR ? TextDirection.ltr : null,
          textAlign: isLTR ? TextAlign.left : TextAlign.start,
          maxLines: maxLines,
          style: TextStyle(
              fontSize: 13, color: isDark ? const Color(0xFFE2E8F0) : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color:
                  isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRequired(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context, 'registerInstitution'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.lock_1,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context, 'loginRequired'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context, 'loginRequiredDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.login, size: 20),
                  label: Text(
                    S.of(context, 'goToLogin'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final nku = _nkuC.text.trim();
    if (nku.isEmpty) {
      AppSnackbar.error(context, S.of(context, 'errorNameRequired'));
      return;
    }
    if (_type.isEmpty) {
      AppSnackbar.error(context, S.of(context, 'errorTypeRequired'));
      return;
    }
    if (_addrC.text.trim().isEmpty) {
      AppSnackbar.error(context, S.of(context, 'errorAddressRequired'));
      return;
    }

    // Validate optional fields if provided
    final email = _emailC.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      AppSnackbar.error(context, S.of(context, 'invalidEmail'));
      return;
    }

    final phone = _phoneC.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^[\d\s\-\+\(\)]{7,20}$').hasMatch(phone)) {
      AppSnackbar.error(context, S.of(context, 'invalidPhone'));
      return;
    }

    final web = _webC.text.trim();
    if (web.isNotEmpty) {
      final uri = Uri.tryParse(web);
      if (uri == null || (!uri.hasScheme && !web.contains('.'))) {
        AppSnackbar.error(context, S.of(context, 'invalidUrl'));
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final inst = Institution(
      id: 0,
      nku: nku,
      nen: _nenC.text.trim(),
      type: _type,
      country: _country,
      city: _cityC.text.trim().isNotEmpty ? _cityC.text.trim() : _city,
      phone: _phoneC.text.trim(),
      email: _emailC.text.trim(),
      web: _webC.text.trim(),
      addr: _addrC.text.trim(),
      desc: _descC.text.trim(),
      colleges: _serializeColleges(),
      depts: '',

      kgAge: _kgAgeC.text.trim(),
      kgHours: _kgHoursC.text.trim(),
      lat: _lat,
      lng: _lng,
      fb: _fbC.text.trim(),
      wa: _waC.text.trim(),
      logo: _logoFile?.path ?? '',
      approved: false,
    );

    try {
      if (!ApiService.isLoggedIn) {
        AppSnackbar.error(context, S.of(context, 'errorLoginFirst'));
        return;
      }

      final res = await ApiService.createInstitution(inst, logoFile: _logoFile);
      debugPrint('API Response: $res');

      if (res['success'] == true) {
        // No local addInstitution here; fetchFromApi will update the list from backend

        // Clear form
        for (final c in [
      _nkuC, _nenC, _cityC, _phoneC, _emailC, _webC, _addrC, _descC,
          _kgAgeC, _kgHoursC, _fbC, _waC,
        ]) {
          c.clear();
        }
        for (final college in _colleges) {
          college.dispose();
        }
        _colleges.clear();
        setState(() {
          _type = '';
          _city = '';
          _lat = null;
          _lng = null;
          _showOptional = false;
          _logoFile = null;
        });

        if (mounted) {
          AppSnackbar.success(context, S.of(context, 'submitSuccess'));
        }
      } else {
        final msg = res['message'] ?? S.of(context, 'errorOccurred');
        if (mounted) AppSnackbar.error(context, '${S.of(context, 'error')} $msg');
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (mounted) {
        AppSnackbar.error(context, '${S.of(context, 'submitFailed')}: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    
    // گەڕانەوە بۆ هۆم
    widget.onSubmitted?.call();
  }

  // ─── Colleges/Departments Helpers ───

  String _serializeColleges() {
    final data = _colleges
        .where((c) => c.nameController.text.trim().isNotEmpty)
        .map((c) => {
              'name': c.nameController.text.trim(),
              'depts': c.deptControllers
                  .map((d) => d.text.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
            })
        .toList();
    if (data.isEmpty) return '';
    return jsonEncode(data);
  }

  Widget _buildCollegeCard(int index, _CollegeEntry college, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3F5E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // College header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  college.nameController.text.isEmpty
                      ? _hasColleges
                          ? S.of(context, 'collegeN', {'n': '${index + 1}'})
                          : S.of(context, 'deptN', {'n': '${index + 1}'})
                      : college.nameController.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _colleges[index].dispose();
                    _colleges.removeAt(index);
                  });
                },
                icon: const Icon(Iconsax.trash, size: 18),
                color: Colors.red[400],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // College name field
          TextFormField(
            controller: college.nameController,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFE2E8F0) : null,
            ),
            decoration: InputDecoration(
              hintText: _hasColleges ? S.of(context, 'collegeNameHint') : S.of(context, 'deptNameHint'),
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
              ),
              prefixIcon: Icon(Iconsax.building_4, size: 18, color: AppTheme.primary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          // Departments list
          ...college.deptControllers.asMap().entries.map((deptEntry) {
            final di = deptEntry.key;
            final deptC = deptEntry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 16),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: deptC,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFE2E8F0) : null,
                      ),
                      decoration: InputDecoration(
                        hintText: _hasColleges ? S.of(context, 'deptNameHint') : S.of(context, 'subDeptHint'),
                        hintStyle: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFFBBBBBB),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        college.deptControllers[di].dispose();
                        college.deptControllers.removeAt(di);
                      });
                    },
                    child: Icon(Iconsax.close_circle,
                        size: 18, color: Colors.red[300]),
                  ),
                ],
              ),
            );
          }),
          // Add department button
          TextButton.icon(
            onPressed: () {
              setState(() {
                college.deptControllers.add(TextEditingController());
              });
            },
            icon: Icon(Iconsax.add, size: 16, color: AppTheme.primary),
            label: Text(
              _hasColleges ? S.of(context, 'addDeptSub') : S.of(context, 'addBranch'),
              style: TextStyle(fontSize: 12, color: AppTheme.primary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollegeEntry {
  final TextEditingController nameController = TextEditingController();
  final List<TextEditingController> deptControllers = [];

  void dispose() {
    nameController.dispose();
    for (final c in deptControllers) {
      c.dispose();
    }
  }
}
