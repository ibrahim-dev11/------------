import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/institutions_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class PathFinderScreen extends StatefulWidget {
  const PathFinderScreen({super.key});

  @override
  State<PathFinderScreen> createState() => _PathFinderScreenState();
}

class _PathFinderScreenState extends State<PathFinderScreen> {
  int _currentStep = 0;
  
  // Selection States
  double _average = 85.0;
  String? _selectedInterest;
  String? _selectedCity;
  String? _selectedType;

  final List<Map<String, dynamic>> _interests = [
    {'id': 'medical', 'name': 'پزیشکی', 'icon': Icons.medical_services_rounded},
    {'id': 'engineering', 'name': 'ئەندازیاری', 'icon': Icons.engineering_rounded},
    {'id': 'it', 'name': 'تەکنەلۆژیا', 'icon': Icons.computer_rounded},
    {'id': 'law', 'name': 'یاسا', 'icon': Icons.gavel_rounded},
    {'id': 'business', 'name': 'کارگێڕی', 'icon': Icons.business_center_rounded},
    {'id': 'arts', 'name': 'هونەر', 'icon': Icons.palette_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('ڕێبەرە زیرەکەکەت', style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentStep 
                        ? AppColors.primary 
                        : (isDark ? Colors.white10 : Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildCurrentStep(isDark),
            ),
          ),
          
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('پێشتر', style: TextStyle(fontFamily: 'NotoSansArabic')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: _currentStep == 3 ? 'دۆزینەوەی ئەنجام' : 'دواتر',
                    onPressed: () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _showResults();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0: return _stepAverage(isDark);
      case 1: return _stepInterests(isDark);
      case 2: return _stepCity(isDark);
      case 3: return _stepType(isDark);
      default: return const SizedBox();
    }
  }

  Widget _stepAverage(bool isDark) {
    return Column(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.school_rounded, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'نمرەی پۆلی ١٢ت چەندە؟',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 40),
        Text(
          _average.toInt().toString(),
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        Slider(
          value: _average,
          min: 50,
          max: 100,
          activeColor: AppColors.primary,
          onChanged: (val) => setState(() => _average = val),
        ),
      ],
    );
  }

  Widget _stepInterests(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'حەزت لە کام بووارەیە؟',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _interests.length,
            itemBuilder: (context, index) {
              final item = _interests[index];
              final isSelected = _selectedInterest == item['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedInterest = item['id']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], color: isSelected ? Colors.white : AppColors.primary, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        item['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textDark),
                          fontFamily: 'NotoSansArabic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stepCity(bool isDark) {
    final cities = ['هەموو شارەکان', 'هەولێر', 'سلێمانی', 'دهۆک', 'هەڵەبجە', 'کەرکوک'];
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'لە کام شار بێت؟',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = _selectedCity == city || (city == 'هەموو شارەکان' && _selectedCity == null);
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = city == 'هەموو شارەکان' ? null : city),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: isSelected ? AppColors.primary : AppColors.textGrey),
                        const SizedBox(width: 16),
                        Text(
                          city,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'NotoSansArabic',
                            color: isSelected ? AppColors.primary : (isDark ? Colors.white : AppColors.textDark),
                          ),
                        ),
                        const Spacer(),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepType(bool isDark) {
    final types = [
      {'id': null, 'name': 'هەردووکی', 'icon': Icons.all_inclusive_rounded},
      {'id': 'public', 'name': 'حکومی', 'icon': Icons.account_balance_rounded},
      {'id': 'private', 'name': 'ئەهلی', 'icon': Icons.business_rounded},
    ];
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'جۆری دامەزراوەکە؟',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'NotoSansArabic'),
          ),
          const SizedBox(height: 24),
          ...types.map((type) {
            final isSelected = _selectedType == type['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type['id'] as String?),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(type['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textGrey, size: 28),
                    const SizedBox(width: 20),
                    Text(
                      type['name'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'NotoSansArabic',
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white : AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showResults() {
    // Navigate to results screen or show in a modal
    context.push('/institutions', extra: {
      'filter': {
        'city': _selectedCity,
        'type': _selectedType,
        'interest': _selectedInterest,
        'average': _average,
      }
    });
  }
}
