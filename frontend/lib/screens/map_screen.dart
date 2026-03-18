import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/club.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Club? _selectedClub;

  void _onMarkerTap(Club club) {
    setState(() => _selectedClub = club);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(45.810, 15.970),
            initialZoom: 13.5,
            onTap: (_, __) => setState(() => _selectedClub = null),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
              userAgentPackageName: 'com.nightpulse.app',
            ),
            MarkerLayer(
              markers: mockClubs.map((club) {
                final isSelected = _selectedClub?.id == club.id;
                return Marker(
                  point: LatLng(club.latitude, club.longitude),
                  width: isSelected ? 52 : 44,
                  height: isSelected ? 52 : 44,
                  child: GestureDetector(
                    onTap: () => _onMarkerTap(club),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: club.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: club.gradientColors.first.withOpacity(0.5),
                            blurRadius: isSelected ? 16 : 10,
                            spreadRadius: isSelected ? 2 : 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.nightlife_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Search on map...',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom sheet for selected club
        if (_selectedClub != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ClubPreviewSheet(
              club: _selectedClub!,
              onClose: () => setState(() => _selectedClub = null),
            ),
          ),
      ],
    );
  }
}

class _ClubPreviewSheet extends StatelessWidget {
  final Club club;
  final VoidCallback onClose;

  const _ClubPreviewSheet({required this.club, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    // Club color dot
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: club.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.nightlife_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.music_note_rounded,
                                  size: 14, color: AppColors.tertiary),
                              const SizedBox(width: 4),
                              Text(
                                club.currentGenre,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.local_fire_department_rounded,
                                  size: 14, color: const Color(0xFFFF6D00)),
                              const SizedBox(width: 4),
                              Text(
                                '${club.crowdRating}/10',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favorite
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.star_border_rounded,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Stats row
                Row(
                  children: [
                    _QuickStat(
                      icon: Icons.euro_rounded,
                      label: '${club.entryPrice.toInt()}€',
                      subtitle: 'Entry',
                    ),
                    _QuickStat(
                      icon: Icons.access_time_rounded,
                      label: '${club.queueMinutes}m',
                      subtitle: 'Queue',
                    ),
                    _QuickStat(
                      icon: Icons.update_rounded,
                      label: club.lastUpdated,
                      subtitle: 'Updated',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Safe area padding at bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
