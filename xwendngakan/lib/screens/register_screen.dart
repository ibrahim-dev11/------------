import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import 'create_post_screen.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';
import '../services/app_localizations.dart';
import 'map_picker_screen.dart';


class RegisterScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;
  final Institution? institution;
  final bool hideAppBar;

  final bool showTabs;

  const RegisterScreen({
    super.key,
    this.onSubmitted,
    this.institution,
    this.hideAppBar = false,
    this.showTabs = true,
  });

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
  File? _imgFile;

  final _nkuC = TextEditingController();
  final _nenC = TextEditingController();
  final _narC = TextEditingController(); // Arabic name
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
  final _tgC = TextEditingController();

  bool _isTranslating = false;
  double? _lat;
  double? _lng;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.institution != null) {
      final ins = widget.institution!;
      _type = ins.type;
      _nkuC.text = ins.nku;
      _nenC.text = ins.nen;
      _narC.text = ins.nar;
      _cityC.text = ins.city;
      _phoneC.text = ins.phone;
      _emailC.text = ins.email;
      _webC.text = ins.web;
      _addrC.text = ins.addr;
      _descC.text = ins.desc;
      _kgAgeC.text = ins.kgAge;
      _kgHoursC.text = ins.kgHours;
      _fbC.text = ins.fb;
      _waC.text = ins.wa;
      _tgC.text = ins.tg;
      _lat = ins.lat;
      _lng = ins.lng;

      // Handle colleges/depts split by newline
      if (ins.colleges.isNotEmpty || ins.depts.isNotEmpty) {
        final lines = (ins.colleges.isNotEmpty ? ins.colleges : ins.depts).split('\n');
        for (var line in lines) {
          if (line.trim().isNotEmpty) {
            final entry = _CollegeEntry();
            entry.nameController.text = line.trim();
            _colleges.add(entry);
          }
        }
      }
      
      // If there's any data in optional fields, show optional section
      if (ins.nen.isNotEmpty || ins.nar.isNotEmpty || ins.desc.isNotEmpty || _colleges.isNotEmpty || ins.wa.isNotEmpty) {
        _showOptional = true;
      }
    }
  }

  bool get _isKgDcType => _type == 'kg' || _type == 'dc';

  bool get _hasColleges =>
      _type == 'gov' || _type == 'priv' || _type == 'eve_uni';

  // ── Google Translate (free endpoint) ──
  Future<String> _fetchGoogleFree(String from, String to, String text) async {
    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$from&tl=$to&dt=t&q=${Uri.encodeComponent(text)}',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final buffer = StringBuffer();
      for (final part in (data[0] as List)) {
        if (part[0] != null) buffer.write(part[0]);
      }
      return buffer.toString().trim();
    }
    throw Exception('translate failed ${res.statusCode}');
  }

  Future<void> _translateName() async {
    final text = _nkuC.text.trim();
    if (text.isEmpty) {
      AppSnackbar.error(context, 'کوردی بنووسە پێش تانستلەیت');
      return;
    }
    setState(() => _isTranslating = true);
    try {
      final results = await Future.wait([
        _fetchGoogleFree('ckb', 'ar', text),
        _fetchGoogleFree('ckb', 'en', text),
      ]);
      if (!mounted) return;
      setState(() {
        _narC.text = results[0];
        _nenC.text = results[1];
        // Open optional section so user sees the filled fields
        _showOptional = true;
      });
    } catch (e) {
      // Silent error or log it internally if needed
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nkuC,
      _nenC,
      _narC,
      _phoneC,
      _emailC,
      _webC,
      _addrC,
      _descC,
      _kgAgeC,
      _kgHoursC,
      _fbC,
      _waC,
      _tgC,
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

    if (!context.watch<AppProvider>().isLoggedIn) {
      return _buildLoginRequired(isDark);
    }

    // Only show tabs if we are editing an existing institution AND showTabs is true
    final bool showTabs = widget.institution != null && widget.showTabs;

    if (!showTabs) {
      if (widget.hideAppBar) {
        return _buildScrollableForm(isDark);
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.institution == null
                ? S.of(context, 'registerInstitution')
                : S.of(context, 'editInstitution'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
        ),
        body: _buildScrollableForm(isDark),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(S.of(context, 'editInstitution'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          centerTitle: true,
          backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: S.of(context, 'mainInfo')),
              Tab(text: S.of(context, 'postsTab')),
            ],
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            _buildScrollableForm(isDark),
            _buildPostsManagementTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableForm(bool isDark) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF422006) : const Color(0xFFFEFCE8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Text('⏳', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      S.of(context, 'adminApprovalNotice'),
                      style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionCard(
              isDark: isDark,
              icon: Iconsax.info_circle,
              title: S.of(context, 'mainInfo'),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _imagePickerCard(
                        isDark: isDark,
                        file: _logoFile,
                        serverUrl: widget.institution?.logo,
                        label: 'لۆگۆ',
                        onTap: () => _pickImage(isLogo: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _imagePickerCard(
                        isDark: isDark,
                        file: _imgFile,
                        serverUrl: widget.institution?.img,
                        label: 'وێنەی دامەزراوە',
                        onTap: () => _pickImage(isLogo: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _field(S.of(context, 'institutionName'), _nkuC, S.of(context, 'institutionNameHint')),
                const SizedBox(height: 14),
                _field(S.of(context, 'city'), _cityC, S.of(context, 'cityHint')),
                const SizedBox(height: 14),
                _label(S.of(context, 'typeRequired'), isDark),
                const SizedBox(height: 8),
                _buildTypeSelector(isDark),
                const SizedBox(height: 14),
                _addressFieldWithLocation(isDark),
              ],
            ),
            const SizedBox(height: 14),
            _buildToggleSection(
              isDark: isDark,
              label: S.of(context, 'moreInfo'),
              isOpen: _showOptional,
              onTap: () => setState(() => _showOptional = !_showOptional),
            ),
            if (_showOptional) ...[
              const SizedBox(height: 14),
              _sectionCard(
                isDark: isDark,
                icon: Iconsax.document_text_1,
                title: S.of(context, 'about'),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(S.of(context, 'englishName'), isDark),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nenC,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFE2E8F0) : null),
                              decoration: InputDecoration(
                                hintText: 'English name...',
                                hintStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _translateButton(isDark),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _fieldRaw(label: 'ناوی عەرەبی', controller: _narC, hint: 'اسم المؤسسة بالعربي...', isDark: isDark, isRTL: true),
                  const SizedBox(height: 12),
                  _field(S.of(context, 'aboutInstitution'), _descC, S.of(context, 'aboutHint'), maxLines: 3),
                ],
              ),
              const SizedBox(height: 14),
              if (_type != 'school' && _type != 'kg' && _type != 'dc')
                _sectionCard(
                  isDark: isDark,
                  icon: Iconsax.book_1,
                  title: S.of(context, 'sections'),
                  children: [
                    ..._colleges.asMap().entries.map((entry) => _buildCollegeCard(entry.key, entry.value, isDark)),
                    const SizedBox(height: 8),
                    _addCollegeButton(),
                  ],
                ),
              const SizedBox(height: 14),
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
              _sectionCard(
                isDark: isDark,
                icon: Iconsax.share,
                title: S.of(context, 'social'),
                children: [
                  _socialField('Facebook', _fbC, Iconsax.message, const Color(0xFF1877F2)),
                  const SizedBox(height: 10),
                  _socialField('WhatsApp', _waC, Iconsax.message, const Color(0xFF25D366)),
                  const SizedBox(height: 10),
                  _socialField(S.of(context, 'telegram'), _tgC, Iconsax.send_1, const Color(0xFF0088CC)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsManagementTab(bool isDark) {
    if (widget.institution == null) return const SizedBox();
    
    return FutureBuilder<List<Post>>(
      future: ApiService.getInstitutionPosts(widget.institution!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final posts = snapshot.data ?? [];
        
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Post Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(institutionId: widget.institution!.id),
                      ),
                    );
                    if (result == true) setState(() {});
                  },
                  icon: const Icon(Iconsax.add_square),
                  label: Text(S.of(context, 'createPost')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              if (posts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Iconsax.document_text, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(S.of(context, 'noPosts'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                ...posts.map((p) => _buildPostAdminCard(p, isDark)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostAdminCard(Post p, bool isDark) {
    return Dismissible(
      key: Key('post_${p.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(Alignment.centerRight, isDark),
      confirmDismiss: (direction) => _confirmDeletePost(p.id),
      onDismissed: (direction) {
        // Handled by confirmDismiss success
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (p.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(p.image, width: 80, height: 80, fit: BoxFit.cover),
              )
            else
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const Icon(Iconsax.image, color: Colors.grey),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title.isNotEmpty ? p.title : 'بێ ناونیشان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(p.formattedDate, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDeletePost(int postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سڕینەوەی پۆست'),
        content: const Text('دڵنیایت دەتەوێت ئەم پۆستە بسڕیتەوە؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('نەخێر')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('بەڵێ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      final success = await ApiService.deletePost(postId);
      if (success && mounted) {
        AppSnackbar.success(context, 'پۆستەکە سڕایەوە');
        return true;
      }
    }
    return false;
  }



  Widget _translateButton(bool isDark) {
    return Container(
      height: 36,
      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isTranslating ? null : _translateName,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: _isTranslating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(S.of(context, 'translate'), style: const TextStyle(color: AppTheme.primary, fontSize: 11.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addCollegeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _colleges.add(_CollegeEntry())),
        icon: const Icon(Iconsax.add_circle, size: 18),
        label: Text(_hasColleges ? S.of(context, 'addCollege') : S.of(context, 'addDept')),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.success, AppTheme.success2]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppTheme.success.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: const Icon(Iconsax.send_15, color: Colors.white, size: 20),
          label: Text(S.of(context, 'submitToAdmin'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_type.isEmpty) {
      AppSnackbar.error(context, S.of(context, 'typeRequiredMsg'));
      return;
    }

    setState(() => _isSubmitting = true);

    final inst = Institution(
      id: widget.institution?.id ?? 0,
      userId: 0, // Server takes from token
      nku: _nkuC.text.trim(),
      nen: _nenC.text.trim(),
      nar: _narC.text.trim(),
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
      tg: _tgC.text.trim(),
      logo: _logoFile?.path ?? (widget.institution?.logo ?? ''),
      approved: widget.institution?.approved ?? false,
    );

    try {
      if (!ApiService.isLoggedIn) {
        AppSnackbar.error(context, S.of(context, 'errorLoginFirst'));
        return;
      }

      final Map<String, dynamic> res;
      if (widget.institution == null) {
        res = await ApiService.createInstitution(inst, logoFile: _logoFile, imgFile: _imgFile);
      } else {
        res = await ApiService.createInstitution(inst, logoFile: _logoFile, imgFile: _imgFile); 
      }
      debugPrint('API Response: $res');

      if (res['success'] == true) {
        if (widget.institution == null) {
          // Clear form only on create
          for (final c in [
            _nkuC,
            _nenC,
            _narC,
            _cityC,
            _phoneC,
            _emailC,
            _webC,
            _addrC,
            _descC,
            _kgAgeC,
            _kgHoursC,
            _fbC,
            _waC,
            _tgC,
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
            _imgFile = null;
          });
        }

        if (widget.institution == null && mounted) {
          AppSnackbar.success(context, S.of(context, 'submitSuccess'));
        } else if (mounted) {
          AppSnackbar.success(context, S.of(context, 'updateSuccess'));
        }
      } else {
        final msg = res['message'] ?? S.of(context, 'errorOccurred');
        if (mounted)
          AppSnackbar.error(context, '${S.of(context, 'error')} $msg');
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (mounted) {
        AppSnackbar.error(context, '${S.of(context, 'submitFailed')}: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    widget.onSubmitted?.call();
  }

  // ── Colleges/Departments Helpers ──

  String _serializeColleges() {
    final data = _colleges
        .where((c) => c.nameController.text.trim().isNotEmpty)
        .map(
          (c) => {
            'name': c.nameController.text.trim(),
            'depts': c.deptControllers
                .map((d) => d.text.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          },
        )
        .toList();
    if (data.isEmpty) return '';
    return jsonEncode(data);
  }

  Widget _buildCollegeCard(int index, _CollegeEntry college, bool isDark) {
    return Dismissible(
      key: ObjectKey(college),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(Alignment.centerRight, isDark),
      onDismissed: (direction) {
        setState(() {
          _colleges[index].dispose();
          _colleges.removeAt(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
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
                    color: isDark ? Colors.white : AppTheme.darkSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
              hintText: _hasColleges
                  ? S.of(context, 'collegeNameHint')
                  : S.of(context, 'deptNameHint'),
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFBBBBBB),
              ),
              prefixIcon: Icon(
                Iconsax.building_4,
                size: 18,
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSub,
              ),
            ),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 10),
          // Departments list
          ...college.deptControllers.asMap().entries.map((de) {
            final di = de.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: college.deptControllers[di],
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: _hasColleges
                            ? S.of(context, 'deptNameTitle')
                            : S.of(context, 'branchName'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                    child: Icon(
                      Iconsax.close_circle,
                      size: 18,
                      color: Colors.red[300],
                    ),
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
              _hasColleges
                  ? S.of(context, 'addDeptSub')
                  : S.of(context, 'addBranch'),
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
          .map(
            (t) => MapEntry(t['key'] as String, prov.localizedField(t, 'name')),
          )
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
                        ? AppTheme.darkSurface
                        : AppTheme.lightBg),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : (isDark
                          ? AppTheme.darkCard
                          : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
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
                              ? AppTheme.lightBg
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


  Future<void> _pickImage({bool isLogo = true}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      if (!mounted) return;
      setState(() {
        if (isLogo) {
          _logoFile = File(result.files.single.path!);
        } else {
          _imgFile = File(result.files.single.path!);
        }
      });
    }
  }

  Widget _imagePickerCard({
    required bool isDark,
    required File? file,
    required String? serverUrl,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3F5E) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file != null)
                Image.file(file, fit: BoxFit.cover)
              else if (serverUrl != null && serverUrl.isNotEmpty)
                Image.network(serverUrl, fit: BoxFit.cover)
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.camera, color: AppTheme.primary, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              if (file != null || (serverUrl != null && serverUrl.isNotEmpty))
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialField(
    String label,
    TextEditingController c,
    IconData icon,
    Color color,
  ) {
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
              color: isDark ? const Color(0xFFE2E8F0) : null,
            ),
            decoration: InputDecoration(
              hintText: '$label...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFBBBBBB),
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
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.darkCard : const Color(0xFFE8E8E8),
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
                  color: AppTheme.primary.withValues(
                    alpha: isDark ? 0.15 : 0.08,
                  ),
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
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            color: isDark ? AppTheme.darkCard : const Color(0xFFE8E8E8),
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
          color: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppTheme.darkCard : const Color(0xFFE2E8F0),
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
                    ? AppTheme.lightBg
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
        color: isDark ? AppTheme.lightBg : const Color(0xFF555555),
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
                  color: isDark ? const Color(0xFFE2E8F0) : null,
                ),
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
                    child: Icon(
                      Iconsax.location,
                      color: AppTheme.primary,
                      size: 22,
                    ),
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

  Widget _field(
    String label,
    TextEditingController c,
    String hint, {
    bool isLTR = false,
    int maxLines = 1,
  }) {
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
            fontSize: 13,
            color: isDark ? const Color(0xFFE2E8F0) : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
            ),
          ),
        ),
      ],
    );
  }

  /// Like [_field] but lets you explicitly set text direction (for Arabic RTL).
  Widget _fieldRaw({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    bool isRTL = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFE2E8F0) : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFBBBBBB),
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
        backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
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
                child: Icon(Iconsax.lock_1, size: 40, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context, 'loginRequired'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.darkSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context, 'loginRequiredDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.lightBg
                      : AppTheme.lightTextSub,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  Widget _buildSwipeBackground(Alignment alignment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
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
