import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/institution.dart';
import '../services/app_localizations.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  Institution? _selectedInstitution;

  // Default to Iraq/Kurdistan region
  static const LatLng _defaultCenter = LatLng(36.1901, 44.0091);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  List<Marker> _buildMarkers(AppProvider prov) {
    final institutions = prov.filteredInstitutions;
    final markers = <Marker>[];

    for (final inst in institutions) {
      if (inst.lat != null && inst.lng != null) {
        markers.add(
          Marker(
            point: LatLng(inst.lat!, inst.lng!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => setState(() => _selectedInstitution = inst),
              child: Container(
                decoration: BoxDecoration(
                  color: _getMarkerColor(inst.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getMarkerIcon(inst.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'gov':
      case 'priv':
      case 'eve_uni':
        return AppTheme.accent;
      case 'school':
        return AppTheme.primary;
      case 'kg':
      case 'dc':
        return AppTheme.gold;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getMarkerIcon(String type) {
    switch (type) {
      case 'gov':
      case 'priv':
      case 'eve_uni':
        return Iconsax.building_35;
      case 'school':
        return Iconsax.teacher;
      case 'kg':
      case 'dc':
        return Iconsax.people5;
      default:
        return Iconsax.location5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markers = _buildMarkers(prov);

    return Directionality(
      textDirection: prov.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
        body: Stack(
          children: [
            // Flutter Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 8,
                onTap: (_, __) => setState(() => _selectedInstitution = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),

            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back button
                    _buildCircleButton(
                      icon: prov.isRtl ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2,
                      onTap: () => Navigator.pop(context),
                      isDark: isDark,
                    ),
                    const Spacer(),
                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.map5,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context, 'map'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.lightText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${markers.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // My location button
                    _buildCircleButton(
                      icon: Iconsax.gps5,
                      onTap: _goToMyLocation,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // Selected institution card
            if (_selectedInstitution != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: _buildSelectedCard(prov, isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? Colors.white : AppTheme.lightText,
        ),
      ),
    );
  }

  Widget _buildSelectedCard(AppProvider prov, bool isDark) {
    final inst = _selectedInstitution!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(institution: inst)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _getMarkerColor(inst.type).withValues(alpha: 0.1),
              ),
              child: inst.logo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: inst.logo,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          _getMarkerIcon(inst.type),
                          color: _getMarkerColor(inst.type),
                          size: 30,
                        ),
                      ),
                    )
                  : Icon(
                      _getMarkerIcon(inst.type),
                      color: _getMarkerColor(inst.type),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    inst.nameForLang(prov.language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.lightText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location5,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        inst.city,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppTheme.lightTextSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMarkerColor(inst.type).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prov.typeLabel(inst.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _getMarkerColor(inst.type),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Arrow
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                prov.isRtl ? Iconsax.arrow_left_2 : Iconsax.arrow_right_3,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToMyLocation() {
    final prov = context.read<AppProvider>();
    if (prov.userLat != null && prov.userLng != null) {
      _mapController.move(
        LatLng(prov.userLat!, prov.userLng!),
        14,
      );
    }
  }
}
