import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/common_widgets.dart';

class AddLostItemScreen extends StatefulWidget {
  const AddLostItemScreen({super.key});

  @override
  State<AddLostItemScreen> createState() => _AddLostItemScreenState();
}

class _AddLostItemScreenState extends State<AddLostItemScreen> {
  String _type = 'lost';
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(l.publishNew, style: const TextStyle(fontFamily: 'Rabar', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'lost'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _type == 'lost' ? const Color(0xFFFF4757) : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _type == 'lost' ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12)),
                      ),
                      child: Center(
                        child: Text(
                          '${l.lost} 🔴',
                          style: TextStyle(
                            fontFamily: 'Rabar',
                            fontWeight: FontWeight.bold,
                            color: _type == 'lost' ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'found'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _type == 'found' ? const Color(0xFF2ED573) : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _type == 'found' ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12)),
                      ),
                      child: Center(
                        child: Text(
                          '${l.found} 🟢',
                          style: TextStyle(
                            fontFamily: 'Rabar',
                            fontWeight: FontWeight.bold,
                            color: _type == 'found' ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Image Upload Placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.primary.withOpacity(0.7)),
                  const SizedBox(height: 8),
                  Text(l.addPhoto, style: const TextStyle(fontFamily: 'Rabar', fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Form Fields
            Text(l.itemName, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rabar', color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(l.where, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rabar', color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(l.moreInfo, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Rabar', color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            GradientButton(
              text: l.publish,
              icon: Icons.send_rounded,
              onPressed: () {
                if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.fillAllInfo, style: const TextStyle(fontFamily: 'Rabar'))),
                  );
                  return;
                }
                
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.publishedSuccess, style: const TextStyle(fontFamily: 'Rabar'))),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
