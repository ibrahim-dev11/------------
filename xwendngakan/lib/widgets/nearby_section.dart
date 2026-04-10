import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/constants.dart';
import '../models/institution.dart';
import '../providers/app_provider.dart';
import '../services/app_localizations.dart';
import '../screens/detail_screen.dart';
import '../screens/map_picker_screen.dart';

class NearbySection extends StatelessWidget {
  final bool isDark;

  const NearbySection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    // Not loaded yet – show discover button
    if (!prov.hasLocation && !prov.isLoadingLocation) {
      return _buildDiscoverButton(context, prov);
    }

    // Loading location
    if (prov.isLoadingLocation) {
      return _buildLoading(context);
    }

    // Location denied
    if (prov.locationDenied) {
      return const SizedBox.shrink();
    }

    final nearby = prov.nearbyInstitutions;
    if (nearby.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            children: [
              Icon(Iconsax.location, size: 18, color: const Color(0xFF0EA5E9)),
              const SizedBox(width: 6),
              Text(
                S.of(context, 'nearbyTitle'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nearby.length,
            itemBuilder: (context, i) {
              final inst = nearby[i];
              final dist = prov.distanceTo(inst);
              return _buildNearbyCard(context, inst, dist, prov);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverButton(BuildContext context, AppProvider prov) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // GPS button
          Expanded(
            child: GestureDetector(
              onTap: () => prov.fetchUserLocation(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFF7DD3FC),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Iconsax.gps, size: 18, color: Color(0xFF0EA5E9)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context, 'nearbyDiscover'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            S.of(context, 'nearbyDiscoverDesc'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Map picker button
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(builder: (_) => const MapPickerScreen()),
              );
              if (result != null && context.mounted) {
                prov.setUserLocation(
                  result['lat'] as double,
                  result['lng'] as double,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFF7DD3FC),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.map_1, size: 20, color: Color(0xFF0EA5E9)),
                  const SizedBox(height: 2),
                  Text(
                    S.of(context, 'nearbyMap'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0EA5E9),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              S.of(context, 'nearbyLoading'),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyCard(BuildContext context, Institution inst, double? dist, AppProvider prov) {
    final emoji = AppConstants.typeEmojis[inst.type] ?? '📌';
    final name = inst.nameForLang(prov.language);
    final distText = dist != null
        ? (dist < 1 ? '${(dist * 1000).round()} م' : '${dist.toStringAsFixed(1)} کم')
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(institution: inst)),
      ),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EDF5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: inst.logo.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: CachedNetworkImage(
                              imageUrl: inst.logo,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          )
                        : Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              // Distance
              if (distText.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.routing_2,
                      size: 10,
                      color: const Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      distText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
