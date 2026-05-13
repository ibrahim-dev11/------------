import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
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

  List<Map<String, dynamic>> _getInterests(AppLocalizations l) => [
    {'id': 'medical', 'name': l.medical, 'icon': Icons.medical_services_rounded},
    {'id': 'engineering', 'name': l.engineering, 'icon': Icons.engineering_rounded},
    {'id': 'it', 'name': l.it, 'icon': Icons.computer_rounded},
    {'id': 'law', 'name': l.law, 'icon': Icons.gavel_rounded},
    {'id': 'business', 'name': l.business, 'icon': Icons.business_center_rounded},
    {'id': 'arts', 'name': l.arts, 'icon': Icons.palette_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(l.pathFinder, style: const TextStyle(fontFamily: 'Rabar', fontWeight: FontWeight.bold)),
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
              child: _buildCurrentStep(isDark, l),
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
                      child: Text(l.previous, style: const TextStyle(fontFamily: 'Rabar')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: _currentStep == 3 ? l.findResults : l.next,
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

  Widget _buildCurrentStep(bool isDark, AppLocalizations l) {
    switch (_currentStep) {
      case 0: return _stepAverage(isDark, l);
      case 1: return _stepInterests(isDark, l);
      case 2: return _stepCity(isDark, l);
      case 3: return _stepType(isDark, l);
      default: return const SizedBox();
    }
  }

  Widget _stepAverage(bool isDark, AppLocalizations l) {
    return Column(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.school_rounded, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        Text(
          l.whatIsYourGrade,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Rabar'),
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

  Widget _stepInterests(bool isDark, AppLocalizations l) {
    final interests = _getInterests(l);
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l.whichFieldDoYouLike,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Rabar'),
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
            itemCount: interests.length,
            itemBuilder: (context, index) {
              final item = interests[index];
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
                      Icon(item['icon'] as IconData, color: isSelected ? Colors.white : AppColors.primary, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        item['name'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textDark),
                          fontFamily: 'Rabar',
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

  Widget _stepCity(bool isDark, AppLocalizations l) {
    final cities = [l.all, 'هەولێر', 'سلێمانی', 'دهۆک', 'هەڵەبجە', 'کەرکوک'];
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l.whichCity,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Rabar'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = _selectedCity == city || (city == l.all && _selectedCity == null);
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = city == l.all ? null : city),
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
                            fontFamily: 'Rabar',
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

  Widget _stepType(bool isDark, AppLocalizations l) {
    final types = [
      {'id': null, 'name': l.both, 'icon': Icons.all_inclusive_rounded},
      {'id': 'public', 'name': l.public, 'icon': Icons.account_balance_rounded},
      {'id': 'private', 'name': l.private, 'icon': Icons.business_rounded},
    ];
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l.institutionTypeQuestion,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Rabar'),
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
                        fontFamily: 'Rabar',
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
