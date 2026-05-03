import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../services/app_localizations.dart';

class EditScreen extends StatefulWidget {
  final Institution institution;
  final bool hideAppBar;

  const EditScreen({super.key, required this.institution, this.hideAppBar = false});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _nkuC;
  late TextEditingController _nenC;
  late TextEditingController _narC;
  late TextEditingController _webC;
  late TextEditingController _phoneC;
  late TextEditingController _emailC;
  late TextEditingController _collegesC;
  late TextEditingController _deptsC;
  late TextEditingController _descC;
  late TextEditingController _logoC;
  late TextEditingController _imgC;
  late String _city;

  @override
  void initState() {
    super.initState();
    final d = widget.institution;
    _nkuC = TextEditingController(text: d.nku);
    _nenC = TextEditingController(text: d.nen);
    _narC = TextEditingController(text: d.nar);
    _webC = TextEditingController(text: d.web);
    _phoneC = TextEditingController(text: d.phone);
    _emailC = TextEditingController(text: d.email);
    _collegesC = TextEditingController(text: d.colleges);
    _deptsC = TextEditingController(text: d.depts);
    _descC = TextEditingController(text: d.desc);
    _logoC = TextEditingController(text: d.logo);
    _imgC = TextEditingController(text: d.img);
    _city = d.city;
  }

  @override
  void dispose() {
    _nkuC.dispose();
    _nenC.dispose();
    _narC.dispose();
    _webC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _collegesC.dispose();
    _deptsC.dispose();
    _descC.dispose();
    _logoC.dispose();
    _imgC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cities = AppConstants.cities[widget.institution.country] ?? [];

    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(
        title: Text(S.of(context, 'editAdmin'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF422006) : const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE68A),
              ),
            ),
            child: Text(
              S.of(context, 'adminNotice'),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _field(S.of(context, 'kurdishName'), _nkuC),
          const SizedBox(height: 8),
          _field(S.of(context, 'englishName'), _nenC, isLTR: true),
          const SizedBox(height: 8),
          _field(S.of(context, 'arabicName'), _narC),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl(S.of(context, 'city'), isDark),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: cities.contains(_city) ? _city : null,
                      hint: Text(S.of(context, 'cityDropdownHint')),
                      items: cities
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _city = v ?? ''),
                      isExpanded: true,
                      dropdownColor: Theme.of(context).cardColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _field(S.of(context, 'website'), _webC, isLTR: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field(S.of(context, 'phone'), _phoneC, isLTR: true)),
              const SizedBox(width: 8),
              Expanded(child: _field(S.of(context, 'email'), _emailC, isLTR: true)),
            ],
          ),
          const SizedBox(height: 8),
          _field(S.of(context, 'colleges'), _collegesC, maxLines: 4),
          const SizedBox(height: 8),
          _field(S.of(context, 'departments'), _deptsC, maxLines: 4),
          const SizedBox(height: 8),
          _field(S.of(context, 'about'), _descC, maxLines: 3),
          const SizedBox(height: 8),
          _field(S.of(context, 'logoUrl'), _logoC, isLTR: true),
          const SizedBox(height: 8),
          _field(S.of(context, 'imageUrl'), _imgC, isLTR: true),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(S.of(context, 'save'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: Text(S.of(context, 'delete'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _lbl(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF555555),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {bool isLTR = false, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl(label, isDark),
        const SizedBox(height: 4),
        TextFormField(
          controller: c,
          textDirection: isLTR ? TextDirection.ltr : null,
          textAlign: isLTR ? TextAlign.left : TextAlign.start,
          maxLines: maxLines,
          style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFE2E8F0) : null),
        ),
      ],
    );
  }

  void _save() {
    final d = widget.institution;
    d.nku = _nkuC.text.trim();
    d.nen = _nenC.text.trim();
    d.nar = _narC.text.trim();
    d.web = _webC.text.trim();
    d.phone = _phoneC.text.trim();
    d.email = _emailC.text.trim();
    d.city = _city;
    d.colleges = _collegesC.text.trim();
    d.depts = _deptsC.text.trim();
    d.desc = _descC.text.trim();
    d.logo = _logoC.text.trim();
    d.img = _imgC.text.trim();
    d.approved = true;
    context.read<AppProvider>().updateInstitution(d);
    if (!widget.hideAppBar) {
      Navigator.pop(context);
    }
    AppSnackbar.success(context, S.of(context, 'savedSuccess'));
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.trash, color: AppTheme.danger, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context, 'delete'),
                textDirection: Directionality.of(context),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            S.of(context, 'deleteConfirm'),
            textDirection: Directionality.of(context),
            style: TextStyle(
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      S.of(context, 'no'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AppProvider>().deleteInstitution(widget.institution.id);
                      Navigator.pop(ctx);
                      if (!widget.hideAppBar) {
                        Navigator.pop(context);
                      }
                      AppSnackbar.deleted(context, S.of(context, 'deletedSuccess'));
                    },
                    icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
                    label: Text(S.of(context, 'yesDelete'),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
