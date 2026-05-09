import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/common_widgets.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // Mock Data
  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'title': 'سویچی ئۆتۆمبێل (تۆیۆتا)',
      'type': 'found',
      'location': 'زانکۆی سەلاحەدین - بەشی ئایتی',
      'date': '٢ کاتژمێر پێش ئێستا',
      'image': 'https://images.unsplash.com/photo-1582208151246-86d11f81df20?q=80&w=300&auto=format&fit=crop',
      'description': 'لەسەر مێزی کافتریاکە جێهێڵدرابوو. ئێستا لای پرسگەیە.',
      'user': 'ئەحمەد سیروان'
    },
    {
      'id': '2',
      'title': 'باجی زانکۆ (ID Card)',
      'type': 'lost',
      'location': 'زانکۆی جیهان - کەمپەسی سەرەکی',
      'date': 'دوێنێ',
      'image': null,
      'description': 'باجێکی خوێندکاری بەشی دەرمانسازییە، تکایە هەرکەسێک دۆزییەوە پەیوەندی بکات.',
      'user': 'سارا محەمەد'
    },
    {
      'id': '3',
      'title': 'چاویلکەی پزیشکی (ڕەش)',
      'type': 'found',
      'location': 'پەیمانگای تەکنیکی هەولێر',
      'date': 'ئەمڕۆ بەیانی',
      'image': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?q=80&w=300&auto=format&fit=crop',
      'description': 'لە ناو پۆلی ژمارە ٤ دۆزرایەوە.',
      'user': 'دەرهێن کاروان'
    },
    {
      'id': '4',
      'title': 'پاوەربانک (Anker)',
      'type': 'lost',
      'location': 'زانکۆی سۆران',
      'date': '٣ ڕۆژ پێش ئێستا',
      'image': 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?q=80&w=300&auto=format&fit=crop',
      'description': 'لە کتێبخانەی گشتی زانکۆ لێم ون بووە، ڕەنگی ڕەشە و کێبڵی تێدایە.',
      'user': 'هۆگر ئازاد'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    final typeIndex = _tabController.index;
    return _items.where((item) {
      final matchesSearch = item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            item['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTab = typeIndex == 0 || 
                         (typeIndex == 1 && item['type'] == 'lost') || 
                         (typeIndex == 2 && item['type'] == 'found');
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('ونبوو و دۆزراوە', style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          labelStyle: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'هەمووی'),
            Tab(text: 'ونبووەکان'),
            Tab(text: 'دۆزراوەکان'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lost-and-found/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('بڵاوکردنەوە', style: TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppSearchBar(
              hint: 'گەڕان بەدوای کلیل، باج، مۆبایل...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.white24 : Colors.black26),
                          const SizedBox(height: 16),
                          Text(
                            'هیچ شتێک نەدۆزرایەوە',
                            style: TextStyle(fontFamily: 'NotoSansArabic', color: isDark ? Colors.white54 : Colors.black54),
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isLost = item['type'] == 'lost';
                        
                        return GestureDetector(
                          onTap: () => _showItemDetails(context, item, isDark),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image or Placeholder
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                    image: item['image'] != null
                                        ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: item['image'] == null
                                      ? Icon(Icons.help_outline_rounded, size: 40, color: isDark ? Colors.white30 : Colors.black26)
                                      : null,
                                ),
                                
                                // Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLost ? const Color(0xFFFF4757).withOpacity(0.1) : const Color(0xFF2ED573).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isLost ? 'ونبوو' : 'دۆزراوە',
                                                style: TextStyle(
                                                  color: isLost ? const Color(0xFFFF4757) : const Color(0xFF2ED573),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'NotoSansArabic',
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item['date'],
                                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'NotoSansArabic'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['title'],
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_rounded, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['location'],
                                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'NotoSansArabic'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final isLost = item['type'] == 'lost';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Image
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(24),
                      image: item['image'] != null
                          ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover)
                          : null,
                    ),
                    child: item['image'] == null
                        ? Icon(Icons.help_outline_rounded, size: 80, color: isDark ? Colors.white24 : Colors.black12)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLost ? const Color(0xFFFF4757).withOpacity(0.1) : const Color(0xFF2ED573).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isLost ? '🔴 ونبووە' : '🟢 دۆزراوەتەوە',
                          style: TextStyle(
                            color: isLost ? const Color(0xFFFF4757) : const Color(0xFF2ED573),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item['date'],
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'NotoSansArabic'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    item['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'NotoSansArabic'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('شوێن', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'NotoSansArabic')),
                            Text(item['location'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text('زانیاری زیاتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic')),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, fontFamily: 'NotoSansArabic', height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  
                  // User info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(item['user'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('بڵاوکەرەوە', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54, fontFamily: 'NotoSansArabic')),
                              Text(item['user'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  GradientButton(
                    text: isLost ? 'من دۆزیومەتەوە!' : 'ئەوە هی منە!',
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('نامە نێردرا بۆ بڵاوکەرەوە بە سەرکەوتوویی!', style: TextStyle(fontFamily: 'NotoSansArabic'))),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
