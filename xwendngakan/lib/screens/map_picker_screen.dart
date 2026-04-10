import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iconsax/iconsax.dart';
import '../services/app_localizations.dart';
import '../theme/app_theme.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedLocation;
  String _address = '';
  String _city = '';
  bool _isLoading = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Default to Erbil center
    _selectedLocation = widget.initialLocation ?? const LatLng(36.1912, 44.0094);
    _reverseGeocode(_selectedLocation);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isLoading = true);
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _city = p.locality ?? p.administrativeArea ?? p.subAdministrativeArea ?? '';
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((s) => s != null && s.isNotEmpty);
        _address = parts.join('، ');
      }
    } catch (_) {
      _address = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context, 'enableGPS'))),
          );
        }
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context, 'enableGPS'))),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final newPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedLocation = newPos);
      _mapController.move(newPos, 15);
      await _reverseGeocode(newPos);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context, 'locationFailed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context, 'pickLocation'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'lat': _selectedLocation.latitude,
                        'lng': _selectedLocation.longitude,
                        'city': _city,
                        'address': _address,
                      });
                    },
              icon: const Icon(Iconsax.tick_circle, size: 18),
              label: Text(S.of(context, 'confirm'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 13,
                onTap: (tapPosition, point) async {
                  setState(() => _selectedLocation = point);
                  await _reverseGeocode(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.xwendngakan.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // My location button
            Positioned(
              left: 16,
              bottom: 140,
              child: FloatingActionButton.small(
                heroTag: 'myLocation',
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                onPressed: _isLocating ? null : _goToMyLocation,
                child: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Iconsax.gps, size: 20, color: AppTheme.primary),
              ),
            ),

            // Bottom info card
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.location5, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context, 'selectedLocation'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    else ...[
                      if (_city.isNotEmpty)
                        Text(
                          _city,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                          ),
                        ),
                      if (_address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _address,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
