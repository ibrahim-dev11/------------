import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/institutions_provider.dart';
import '../../data/models/institution_model.dart';
import '../../shared/widgets/common_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InstitutionsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.institutionMap,
            style: const TextStyle(
                fontFamily: 'Rabar', fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(36.1901, 44.0090), // Erbil center
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: isDark
                ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: prov.institutions.map((inst) {
              // Use real coordinates if available, otherwise mock them based on ID
              final lat = inst.lat ??
                  (36.1901 + (inst.id.hashCode % 100) / 5000.0 - 0.01);
              final lng = inst.lng ??
                  (44.0090 + (inst.name('en').hashCode % 100) / 5000.0 - 0.01);

              final typeColor = AppColors.typeColor(inst.type);

              return Marker(
                point: LatLng(lat, lng),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    _mapController.move(LatLng(lat, lng), 15.0);
                    _showInstitutionPreview(context, inst);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 50, color: typeColor),
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: inst.logoUrl.isNotEmpty
                                ? Image.network(inst.logoUrl, fit: BoxFit.cover)
                                : Icon(Icons.school, size: 16, color: typeColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showInstitutionPreview(BuildContext context, InstitutionModel inst) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.typeColor(inst.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: inst.logoUrl.isNotEmpty
                      ? Image.network(inst.logoUrl)
                      : Icon(Icons.school,
                          color: AppColors.typeColor(inst.type)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inst.name(l10n.languageCode),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rabar',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        inst.city ?? '',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontFamily: 'Rabar',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: l10n.viewDetails,
              onPressed: () {
                Navigator.pop(context);
                context.push('/institutions/${inst.id}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
