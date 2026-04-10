import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/app_provider.dart';
import '../models/institution.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';
import '../data/constants.dart';
import 'detail_screen.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  String _selectedType = 'all';
  Institution? _selectedInstitution;
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;
  double _currentZoom = 7.0;

  static const _defaultCenter = LatLng(36.1912, 44.0094);

  final _typeColors = <String, Color>{
    'gov': const Color(0xFF003f88),
    'priv': const Color(0xFF8b5cf6),
    'inst5': const Color(0xFF0ea5e9),
    'inst2': const Color(0xFF22d3ee),
    'school': const Color(0xFFf59e0b),
    'kg': const Color(0xFFf472b6),
    'dc': const Color(0xFFfb923c),
    'lang': const Color(0xFF2dd4bf),
    'edu': const Color(0xFF84cc16),
    'eve_uni': const Color(0xFF818cf8),
    'eve_inst': const Color(0xFF60a5fa),
  };

  static const _cityCenters = <String, LatLng>{
    'هەولێر': LatLng(36.1912, 44.0094),
    'سلێمانی': LatLng(35.5568, 45.4351),
    'دهۆک': LatLng(36.8669, 42.9503),
    'هەڵەبجە': LatLng(35.1787, 45.9864),
    'گەرمیان': LatLng(34.6289, 45.3650),
    'ڕاپەڕین': LatLng(35.6553, 45.1477),
    'زاخۆ': LatLng(37.1445, 42.6872),
    'کەلار': LatLng(34.6289, 45.3650),
    'شەقڵاوە': LatLng(36.4027, 44.3222),
    'ڕەواندوز': LatLng(36.6156, 44.5284),
    'کۆیە': LatLng(36.0833, 44.6333),
    'سۆران': LatLng(36.6533, 44.5414),
    'ئاکرێ': LatLng(36.7419, 43.8819),
    'ئامێدی': LatLng(37.0922, 43.4875),
    'چەمچەماڵ': LatLng(35.5314, 44.8292),
    'ڕانیە': LatLng(36.2528, 44.8822),
    'پەنجوێن': LatLng(35.6167, 45.9333),
    'کفری': LatLng(34.6917, 44.9542),
    'دەربەندیخان': LatLng(35.1111, 45.6917),
    'بەغدا': LatLng(33.3152, 44.3661),
    'مووسڵ': LatLng(36.3350, 43.1189),
    'بەسرە': LatLng(30.5085, 47.7804),
    'کەرکووک': LatLng(35.4681, 44.3922),
    'نەجەف': LatLng(32.0000, 44.3364),
    'کەربەلا': LatLng(32.6160, 44.0243),
    'تکریت': LatLng(34.5957, 43.6788),
    'پیرمام': LatLng(36.3944, 44.9478),
    'کووت': LatLng(32.5153, 45.8317),
    'ڕەمادی': LatLng(33.4259, 43.3075),
    'ناسریە': LatLng(31.0439, 46.2575),
    'عەمارە': LatLng(31.8356, 47.1581),
    'دیوانیە': LatLng(31.9929, 44.9258),
    'حیڵە': LatLng(32.4637, 44.4212),
    'بەعقووبە': LatLng(33.7473, 44.6553),
    'فەڵووجە': LatLng(33.3531, 43.7811),
    'سەمایە': LatLng(34.1981, 44.2006),
    'سامەراء': LatLng(34.1960, 43.8747),
    'عانە': LatLng(34.3719, 41.9453),
    'هیت': LatLng(33.6361, 42.8250),
    'بەردەڕەش': LatLng(36.4800, 43.2700),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _selectInstitution(Institution inst, LatLng pos) {
    setState(() => _selectedInstitution = inst);
    _cardController.forward(from: 0);
    _mapController.move(pos, math.max(_mapController.camera.zoom, 10.0));
  }

  void _clearSelection() {
    if (_selectedInstitution == null) return;
    _cardController.reverse().then((_) {
      if (mounted) setState(() => _selectedInstitution = null);
    });
  }

  LatLng _getBaseLocation(Institution inst) {
    if (inst.lat != null && inst.lng != null && inst.lat != 0 && inst.lng != 0) {
      return LatLng(inst.lat!, inst.lng!);
    }
    return _cityCenters[inst.city] ?? _defaultCenter;
  }

  Map<int, LatLng> _computePositions(List<Institution> list) {
    final groups = <String, List<Institution>>{};
    for (final inst in list) {
      final base = _getBaseLocation(inst);
      final key = '${base.latitude},${base.longitude}';
      groups.putIfAbsent(key, () => []).add(inst);
    }
    final positions = <int, LatLng>{};
    for (final entry in groups.entries) {
      final base = _getBaseLocation(entry.value.first);
      if (entry.value.length == 1) {
        positions[entry.value.first.id] = base;
      } else {
        const offsetStep = 0.004;
        for (var i = 0; i < entry.value.length; i++) {
          if (i == 0) {
            positions[entry.value[i].id] = base;
          } else {
            final angle = i * 0.8;
            final r = offsetStep * (0.5 + i * 0.3);
            positions[entry.value[i].id] = LatLng(
              base.latitude + r * math.cos(angle),
              base.longitude + r * math.sin(angle),
            );
          }
        }
      }
    }
    return positions;
  }

  List<Institution> _getFilteredInstitutions(AppProvider prov) {
    final all = prov.allInstitutions;
    if (_selectedType == 'all') return all;
    return all.where((i) => i.type == _selectedType).toList();
  }

  int _countForType(String type, AppProvider prov) {
    if (type == 'all') return prov.allInstitutions.length;
    return prov.allInstitutions.where((i) => i.type == type).length;
  }

  // ── Clustering ──
  // Returns two lists: individual markers (when zoom >= 12) or clusters
  static const double _clusterZoomThreshold = 11.0;

  List<_Cluster> _computeClusters(List<Institution> institutions) {
    // At high zoom, each institution is its own "cluster" of 1
    if (_currentZoom >= _clusterZoomThreshold) {
      return institutions.map((inst) {
        final pos = _getBaseLocation(inst);
        return _Cluster(center: pos, institutions: [inst]);
      }).toList();
    }

    // Grid-cell clustering based on zoom
    final cellSize = _currentZoom < 7 ? 1.5 : (_currentZoom < 9 ? 0.5 : 0.15);
    final cells = <String, List<Institution>>{};

    for (final inst in institutions) {
      final pos = _getBaseLocation(inst);
      final cellX = (pos.latitude / cellSize).floor();
      final cellY = (pos.longitude / cellSize).floor();
      final key = '$cellX:$cellY';
      cells.putIfAbsent(key, () => []).add(inst);
    }

    return cells.entries.map((entry) {
      final insts = entry.value;
      double latSum = 0, lngSum = 0;
      for (final i in insts) {
        final p = _getBaseLocation(i);
        latSum += p.latitude;
        lngSum += p.longitude;
      }
      return _Cluster(
        center: LatLng(latSum / insts.length, lngSum / insts.length),
        institutions: insts,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final institutions = _getFilteredInstitutions(prov);
    final positions = _computePositions(institutions);
    final clusters = _computeClusters(institutions);

    return Scaffold(
      body: Stack(
        children: [
          // ─── Map ───
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 7.0,
              minZoom: 5,
              maxZoom: 18,
              onTap: (_, __) => _clearSelection(),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  final newZoom = camera.zoom;
                  if ((newZoom - _currentZoom).abs() > 0.3) {
                    setState(() => _currentZoom = newZoom);
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}@2x.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.xwendngakan.app',
              ),
              // Pulsing ring for selected marker
              if (_selectedInstitution != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final pos = positions[_selectedInstitution!.id] ?? _defaultCenter;
                    final color = _typeColors[_selectedInstitution!.type] ?? AppTheme.primary;
                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 70,
                          height: 70,
                          child: Center(
                            child: Container(
                              width: 60 * _pulseAnimation.value,
                              height: 60 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color.withOpacity(0.4 * (1 - _pulseAnimation.value) + 0.1),
                                  width: 2,
                                ),
                                color: color.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              // Institution markers / clusters
              MarkerLayer(
                markers: clusters.map((cluster) {
                  if (cluster.count == 1) {
                    // Single institution — original pin style
                    final inst = cluster.institutions.first;
                    final color = _typeColors[inst.type] ?? AppTheme.primary;
                    final isSelected = _selectedInstitution?.id == inst.id;
                    final pos = positions[inst.id] ?? cluster.center;
                    return Marker(
                      point: pos,
                      width: isSelected ? 56 : 44,
                      height: isSelected ? 66 : 54,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _selectInstitution(inst, pos),
                        child: _MapPin(inst: inst, color: color, isSelected: isSelected),
                      ),
                    );
                  } else {
                    // Cluster marker
                    return Marker(
                      point: cluster.center,
                      width: 56,
                      height: 56,
                      child: GestureDetector(
                        onTap: () {
                          final zoom = math.min(_currentZoom + 2.5, 18.0);
                          _mapController.move(cluster.center, zoom);
                          setState(() => _currentZoom = zoom);
                        },
                        child: _ClusterMarker(count: cluster.count),
                      ),
                    );
                  }
                }).toList(),
              ),
            ],
          ),

          // ─── Top gradient fade ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 110,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.8),
                      (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Top bar (glassmorphism) ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.map_1, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                S.of(context, 'mapView'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                _selectedType == 'all'
                                    ? '${institutions.length} ${S.of(context, 'mapView')}'
                                    : '${institutions.length} / ${prov.allInstitutions.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _GlassButton(
                          icon: Iconsax.gps,
                          isDark: isDark,
                          onTap: () {
                            _mapController.move(_defaultCenter, 7.0);
                            _clearSelection();
                            setState(() => _selectedType = 'all');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Filter chips ───
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('all', S.of(context, 'all'), isDark, prov),
                  ...AppConstants.typeGradients.keys.map(
                    (type) => _buildFilterChip(type, prov.typeLabel(type), isDark, prov),
                  ),
                ],
              ),
            ),
          ),

          // ─── Zoom controls ───
          Positioned(
            right: 16,
            bottom: _selectedInstitution != null ? 190 : 40,
            child: Column(
              children: [
                _GlassButton(
                  icon: Iconsax.add,
                  isDark: isDark,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    math.min(_mapController.camera.zoom + 1, 18),
                  ),
                ),
                const SizedBox(height: 8),
                _GlassButton(
                  icon: Iconsax.minus,
                  isDark: isDark,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    math.max(_mapController.camera.zoom - 1, 5),
                  ),
                ),
              ],
            ),
          ),

          // ─── Selected institution card ───
          if (_selectedInstitution != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _buildInstitutionCard(_selectedInstitution!, isDark, prov),
                ),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildFilterChip(String type, String label, bool isDark, AppProvider prov) {
    final isOn = _selectedType == type;
    final color = type == 'all' ? AppTheme.primary : (_typeColors[type] ?? AppTheme.primary);
    final count = _countForType(type, prov);
    final icon = AppConstants.typeIcons[type];

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isOn ? 14 : 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: isOn
                ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                : null,
            color: isOn ? null : (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: isOn ? null : Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            ),
            boxShadow: [
              if (isOn) BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == 'all')
                Icon(Iconsax.element_equal, size: 14,
                    color: isOn ? Colors.white : (isDark ? Colors.white : const Color(0xFF64748B)))
              else if (icon != null)
                Icon(icon, size: 14,
                    color: isOn ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                  color: isOn ? Colors.white : (isDark ? Colors.white : const Color(0xFF475569)),
                ),
              ),
              if (isOn) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionCard(Institution inst, bool isDark, AppProvider prov) {
    final colors = AppConstants.typeGradients[inst.type] ?? [AppTheme.primary, AppTheme.accent, AppTheme.primary];
    final name = inst.nameForLang(prov.language);
    final typeIcon = AppConstants.typeIcons[inst.type] ?? Icons.school;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(institution: inst)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.82),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors[1].withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[1].withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient accent line
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colors[0], colors[1], colors[2]]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Logo / avatar
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colors[0], colors[1]],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[1].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: inst.logo.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: inst.logo,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Center(
                                    child: Icon(typeIcon, color: Colors.white, size: 24),
                                  ),
                                  errorWidget: (_, __, ___) => Center(
                                    child: Icon(typeIcon, color: Colors.white, size: 24),
                                  ),
                                )
                              : Center(
                                  child: Icon(typeIcon, color: Colors.white, size: 24),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Iconsax.location, size: 13, color: colors[1]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    inst.city.isNotEmpty ? inst.city : S.of(context, 'unknown'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colors[1].withOpacity(isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    prov.typeLabel(inst.type),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colors[1],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors[1].withOpacity(0.15), colors[2].withOpacity(0.08)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Iconsax.arrow_right_3, size: 18, color: colors[1]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Cluster data model
// ────────────────────────────────────────────────────────────────

class _Cluster {
  final LatLng center;
  final List<Institution> institutions;
  _Cluster({required this.center, required this.institutions});
  int get count => institutions.length;
}

// ────────────────────────────────────────────────────────────────
// Cluster marker widget
// ────────────────────────────────────────────────────────────────

class _ClusterMarker extends StatelessWidget {
  final int count;
  const _ClusterMarker({required this.count});

  @override
  Widget build(BuildContext context) {
    final size = count > 99 ? 56.0 : count > 9 ? 50.0 : 44.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  final Institution inst;
  final Color color;
  final bool isSelected;

  const _MapPin({required this.inst, required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 50.0 : 40.0;
    final pinHeight = isSelected ? 62.0 : 50.0;
    return SizedBox(
      width: size,
      height: pinHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pin tail (triangle)
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size(14, isSelected ? 14 : 10),
              painter: _PinTailPainter(color: color, isSelected: isSelected),
            ),
          ),
          // Pin head (circle with logo)
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: isSelected ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSelected ? 0.5 : 0.25),
                    blurRadius: isSelected ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: inst.logo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: inst.logo,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => _PinIcon(color: color, type: inst.type),
                          errorWidget: (_, __, ___) => _PinIcon(color: color, type: inst.type),
                        )
                      : _PinIcon(color: color, type: inst.type),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinIcon extends StatelessWidget {
  final Color color;
  final String type;
  const _PinIcon({required this.color, required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = AppConstants.typeIcons[type] ?? Icons.school;
    return Center(child: Icon(icon, size: 16, color: color));
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  _PinTailPainter({required this.color, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);

    if (isSelected) {
      // Shadow for depth
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) =>
      old.color != color || old.isSelected != isSelected;
}

// ────────────────────────────────────────────────────────────────
// Glass button helper
// ────────────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
