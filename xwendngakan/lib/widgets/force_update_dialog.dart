import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class ForceUpdateDialog extends StatelessWidget {
  final String latestVersion;
  final String? storeUrl;
  final String? releaseNotes;
  final bool forceUpdate;
  final VoidCallback? onSkip;

  const ForceUpdateDialog({
    super.key,
    required this.latestVersion,
    this.storeUrl,
    this.releaseNotes,
    this.forceUpdate = false,
    this.onSkip,
  });

  static Future<void> show(
    BuildContext context, {
    required String latestVersion,
    String? storeUrl,
    String? releaseNotes,
    bool forceUpdate = false,
    VoidCallback? onSkip,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => ForceUpdateDialog(
        latestVersion: latestVersion,
        storeUrl: storeUrl,
        releaseNotes: releaseNotes,
        forceUpdate: forceUpdate,
        onSkip: onSkip,
      ),
    );
  }

  Future<void> _openStore() async {
    if (storeUrl != null && storeUrl!.isNotEmpty) {
      final uri = Uri.parse(storeUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white : Colors.black54;

    return WillPopScope(
      onWillPop: () async => !forceUpdate,
      child: Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.arrow_up_2,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                S.of(context, 'updateAvailable'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Version
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${S.of(context, 'version')} $latestVersion',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                forceUpdate
                    ? S.of(context, 'forceUpdateDesc')
                    : S.of(context, 'updateDesc'),
                style: TextStyle(color: hintColor, height: 1.5),
                textAlign: TextAlign.center,
              ),

              // Release notes
              if (releaseNotes != null && releaseNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context, 'whatsNew'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        releaseNotes!,
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _openStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    S.of(context, 'updateNow'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Skip button (only if not force update)
              if (!forceUpdate) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSkip?.call();
                  },
                  child: Text(
                    S.of(context, 'later'),
                    style: TextStyle(color: hintColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
