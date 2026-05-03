import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';

class ReportScreen extends StatefulWidget {
  final int institutionId;
  final String institutionName;

  const ReportScreen({
    super.key,
    required this.institutionId,
    required this.institutionName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedType;
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, String>> _reportTypes = [
    {
      'key': 'incorrect_info',
      'name': 'زانیاری هەڵە',
      'name_en': 'Incorrect Information',
      'name_ar': 'معلومات خاطئة',
      'icon': 'warning',
    },
    {
      'key': 'closed',
      'name': 'داخراوە',
      'name_en': 'Closed / No longer exists',
      'name_ar': 'مغلق',
      'icon': 'close_circle',
    },
    {
      'key': 'duplicate',
      'name': 'دووبارەیە',
      'name_en': 'Duplicate',
      'name_ar': 'مكرر',
      'icon': 'copy',
    },
    {
      'key': 'spam',
      'name': 'سپام',
      'name_en': 'Spam / Fake',
      'name_ar': 'بريد غير مرغوب',
      'icon': 'shield_cross',
    },
    {
      'key': 'other',
      'name': 'هۆکاری تر',
      'name_en': 'Other',
      'name_ar': 'أخرى',
      'icon': 'more',
    },
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  IconData _getIconForType(String iconName) {
    switch (iconName) {
      case 'warning':
        return Iconsax.warning_2;
      case 'close_circle':
        return Iconsax.close_circle;
      case 'copy':
        return Iconsax.copy;
      case 'shield_cross':
        return Iconsax.shield_cross;
      case 'more':
        return Iconsax.more;
      default:
        return Iconsax.flag;
    }
  }

  String _getLocalizedType(Map<String, String> type, String lang) {
    if (lang == 'en') return type['name_en'] ?? type['name']!;
    if (lang == 'ar') return type['name_ar'] ?? type['name']!;
    return type['name']!;
  }

  Future<void> _submitReport() async {
    if (_selectedType == null) {
      AppSnackbar.error(context, S.of(context, 'selectReportType'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.reportInstitution(
        institutionId: widget.institutionId,
        type: _selectedType!,
        description: _descriptionController.text.trim(),
      );

      if (result['success'] == true) {
        if (mounted) {
          AppSnackbar.success(
            context,
            result['message'] ?? S.of(context, 'reportSubmitted'),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          AppSnackbar.error(
            context,
            result['message'] ?? S.of(context, 'errorOccurred'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, S.of(context, 'connectionError'));
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFF);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white : Colors.black38;

    // Get current language (default to Kurdish)
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context, 'reportInstitution'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institution name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.building, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.institutionName,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Report type selection
            Text(
              S.of(context, 'selectReportType'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(_reportTypes.length, (index) {
              final type = _reportTypes[index];
              final isSelected = _selectedType == type['key'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedType = type['key']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : (isDark ? Colors.white12 : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getIconForType(type['icon']!),
                            color: isSelected ? AppTheme.primary : hintColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getLocalizedType(type, lang),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Iconsax.tick_circle5,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Description
            Text(
              S.of(context, 'additionalDetails'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context, 'additionalDetailsOptional'),
              style: TextStyle(color: hintColor, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: S.of(context, 'describeIssue'),
                  hintStyle: TextStyle(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                    : Text(
                        S.of(context, 'submitReport'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
