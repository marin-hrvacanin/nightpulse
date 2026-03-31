import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/club.dart';
import '../services/api_service.dart';

class LiveReviewScreen extends StatefulWidget {
  const LiveReviewScreen({super.key});

  @override
  State<LiveReviewScreen> createState() => _LiveReviewScreenState();
}

class _LiveReviewScreenState extends State<LiveReviewScreen> {
  Club? _selectedClub;
  int? _crowdRating;
  int? _atmosphereRating;
  String? _selectedGenre;
  int? _waitMinutes;
  bool _isSubmitting = false;
  bool _submitted = false;
  List<Club> _nearbyClubs = [];
  bool _loadingClubs = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyClubs();
  }

  Future<void> _loadNearbyClubs() async {
    setState(() => _loadingClubs = true);
    // Use Zagreb center as default; in production use device GPS
    final clubs = await ApiService.getNearbyClubs(45.813, 15.977, radius: 5000);
    if (mounted) setState(() { _nearbyClubs = clubs; _loadingClubs = false; });
  }

  bool get _allRated =>
      _selectedClub != null &&
      _crowdRating != null &&
      _atmosphereRating != null &&
      _selectedGenre != null &&
      _waitMinutes != null;

  void _selectClub(Club club) {
    setState(() {
      _selectedClub = club;
      _crowdRating = null;
      _atmosphereRating = null;
      _selectedGenre = null;
      _waitMinutes = null;
      _submitted = false;
    });
  }

  void _submit() async {
    if (!_allRated || _selectedClub == null) return;
    setState(() => _isSubmitting = true);

    final result = await ApiService.submitReview(
      clubId: _selectedClub!.id,
      crowdRating: _crowdRating!,
      atmosphereRating: _atmosphereRating!,
      musicGenre: _selectedGenre!,
      waitMinutes: _waitMinutes!,
      latitude: _selectedClub!.latitude,
      longitude: _selectedClub!.longitude,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() { _isSubmitting = false; _submitted = true; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _submitted = false;
          _selectedClub = null;
          _crowdRating = null;
          _atmosphereRating = null;
          _selectedGenre = null;
          _waitMinutes = null;
        });
      }
    } else {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Greška pri slanju')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ocijeni uživo',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Club selector - horizontal scroll with photo banners
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  itemCount: _nearbyClubs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final club = _nearbyClubs[index];
                    final isSelected = _selectedClub?.id == club.id;
                    return _ClubBanner(
                      club: club,
                      isSelected: isSelected,
                      onTap: () => _selectClub(club),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),

              // Range hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.secondary.withOpacity(0.6)),
                    const SizedBox(width: 5),
                    Text(
                      'Klubovi u krugu od 300m',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Review form (shown when club is selected)
              if (_selectedClub != null) ...[
                const SizedBox(height: 24),
                if (_submitted)
                  Center(child: _buildSubmittedState())
                else ...[
                  // Crowd
                  _EmojiRatingCategory(
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFFFF6D00),
                    label: 'Gužva',
                    subtitle: 'Koliko je puno?',
                    selectedValue: _crowdRating,
                    emojis: const ['\u{1F634}', '\u{1F60C}', '\u{1F60A}', '\u{1F525}', '\u{1F4A5}'],
                    onSelect: (v) => setState(() => _crowdRating = v),
                  ),

                  // Atmosphere
                  _EmojiRatingCategory(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFFE040FB),
                    label: 'Atmosfera',
                    subtitle: 'Kakav je đir?',
                    selectedValue: _atmosphereRating,
                    emojis: const ['\u{1F634}', '\u{1F610}', '\u{1F60E}', '\u{1F389}', '\u{1F680}'],
                    onSelect: (v) => setState(() => _atmosphereRating = v),
                  ),

                  // Music genre
                  _GenreSelector(
                    selectedGenre: _selectedGenre,
                    onSelect: (v) => setState(() => _selectedGenre = v),
                  ),

                  // Wait time
                  _WaitTimeSelector(
                    selectedMinutes: _waitMinutes,
                    onSelect: (v) => setState(() => _waitMinutes = v),
                  ),

                  const SizedBox(height: 28),

                  // Share Vibe button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _allRated ? 1.0 : 0.3,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _allRated
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _allRated && !_isSubmitting ? _submit : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt_rounded,
                                            color: Colors.black, size: 22),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Podijeli vibe',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ] else ...[
                // Empty state
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.tertiary.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.nightlife_rounded,
                              size: 34,
                              color: AppColors.primary.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Odaberi klub iznad',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Odaberi klub u kojem si da podijeliš\nšto se trenutno događa',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Vibe podijeljen!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hvala što držiš puls živim',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Club banner card with gradient background as "photo" ---
class _ClubBanner extends StatelessWidget {
  final Club club;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClubBanner({
    required this.club,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: club.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: club.gradientColors.first.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Photo or pattern fallback
            if (club.imageAsset != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 17 : 20),
                  child: Image.asset(
                    club.imageAsset!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 17 : 20),
                  child: CustomPaint(painter: _PatternPainter()),
                ),
              ),
            // Dark gradient at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSelected ? 17 : 20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            // Selected checkmark
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 18, color: club.gradientColors.first),
                ),
              ),
            // Club info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.music_note_rounded,
                          size: 12, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        club.currentGenre,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        club.lastUpdated,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Emoji-based rating row ---
class _EmojiRatingCategory extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final int? selectedValue;
  final List<String> emojis;
  final ValueChanged<int> onSelect;

  const _EmojiRatingCategory({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.selectedValue,
    required this.emojis,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectedValue != null
              ? iconColor.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedValue != null)
                Text(
                  emojis[selectedValue! - 1],
                  style: const TextStyle(fontSize: 22),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(emojis.length, (i) {
              final value = i + 1;
              final isActive = selectedValue == value;
              return GestureDetector(
                onTap: () => onSelect(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? iconColor.withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? iconColor.withOpacity(0.5)
                          : AppColors.border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emojis[i],
                      style: TextStyle(fontSize: isActive ? 26 : 22),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- Genre selector for Music ---
class _GenreSelector extends StatelessWidget {
  final String? selectedGenre;
  final ValueChanged<String> onSelect;

  const _GenreSelector({
    required this.selectedGenre,
    required this.onSelect,
  });

  static const _genres = [
    ('Pop', Icons.music_note_rounded, Color(0xFFE040FB)),
    ('Techno', Icons.equalizer_rounded, Color(0xFF448AFF)),
    ('Trap', Icons.mic_rounded, Color(0xFFFF6D00)),
    ('House', Icons.headphones_rounded, Color(0xFF7C4DFF)),
  ];

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF00E5FF);
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectedGenre != null
              ? iconColor.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note_rounded,
                    size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Glazba',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Koji žanr svira?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedGenre != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedGenre!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _genres.map((g) {
              final (name, genreIcon, color) = g;
              final isActive = selectedGenre == name;
              return GestureDetector(
                onTap: () => onSelect(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? color.withOpacity(0.6)
                          : AppColors.border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(genreIcon, size: 16,
                          color: isActive ? color : AppColors.textSecondary),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? color : AppColors.textSecondary,
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
}

// --- Wait time selector (0-20 min) ---
class _WaitTimeSelector extends StatelessWidget {
  final int? selectedMinutes;
  final ValueChanged<int> onSelect;

  const _WaitTimeSelector({
    required this.selectedMinutes,
    required this.onSelect,
  });

  static const _options = [0, 5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectedMinutes != null
              ? const Color(0xFF448AFF).withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF448AFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.access_time_rounded,
                    size: 20, color: Color(0xFF448AFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Čekanje na ulazu',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Koliko se čeka?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedMinutes != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF448AFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selectedMinutes}m',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF448AFF),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _options.map((mins) {
              final isActive = selectedMinutes == mins;
              return GestureDetector(
                onTap: () => onSelect(mins),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF448AFF).withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF448AFF).withOpacity(0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mins == 0 ? '0' : '${mins}m',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF448AFF)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = -size.height; i < size.width; i += 24) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
