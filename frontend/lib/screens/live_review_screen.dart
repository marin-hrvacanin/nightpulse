import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/club.dart';

class LiveReviewScreen extends StatefulWidget {
  const LiveReviewScreen({super.key});

  @override
  State<LiveReviewScreen> createState() => _LiveReviewScreenState();
}

class _LiveReviewScreenState extends State<LiveReviewScreen> {
  Club? _selectedClub;
  double _crowdRating = 5.0;
  String _selectedGenre = 'Techno';
  double _entryPrice = 10.0;
  double _queueTime = 10.0;
  bool _isSubmitting = false;
  bool _submitted = false;

  // Simulated nearby clubs (within 300m)
  final List<Club> _nearbyClubs = mockClubs.take(2).toList();

  void _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _submitted = false;
        _selectedClub = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Live Review',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Share what\'s happening right now',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Range banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.15),
                      AppColors.tertiary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RANGE - CCA 300m',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'You must be near the venue to post a review',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Pull to refresh hint
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward_rounded,
                          size: 14, color: AppColors.textSecondary.withOpacity(0.5)),
                      const SizedBox(width: 6),
                      Text(
                        'Pull to refresh nearby clubs',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Nearby clubs header
              Text(
                'Nearby Clubs',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Nearby clubs list
              ...List.generate(_nearbyClubs.length, (index) {
                final club = _nearbyClubs[index];
                final isSelected = _selectedClub?.id == club.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedClub = club),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  club.gradientColors.first.withOpacity(0.2),
                                  club.gradientColors.last.withOpacity(0.08),
                                ],
                              )
                            : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? club.gradientColors.first.withOpacity(0.5)
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: club.gradientColors),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.nightlife_rounded,
                              color: Colors.white,
                              size: 22,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${club.currentGenre} • Updated ${club.lastUpdated}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 24,
                            )
                          else
                            const Icon(
                              Icons.radio_button_unchecked_rounded,
                              color: AppColors.border,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Review form
              if (_selectedClub != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _submitted
                      ? _buildSubmittedState()
                      : _buildReviewForm(),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedState() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Review submitted!',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Thanks for sharing the vibe',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate ${_selectedClub!.name}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // Crowd rating
        _ReviewSlider(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF6D00),
          label: 'Crowd Vibe',
          value: _crowdRating,
          min: 1,
          max: 10,
          displayValue: '${_crowdRating.round()}/10',
          onChanged: (v) => setState(() => _crowdRating = v),
        ),
        const SizedBox(height: 22),
        // Genre selector
        Text(
          'Current Genre',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Pop', 'Techno', 'Trap', 'House'].map((genre) {
            final isActive = genre == _selectedGenre;
            return GestureDetector(
              onTap: () => setState(() => _selectedGenre = genre),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  color: isActive ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? null : Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 16,
                      color: isActive ? Colors.black : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      genre,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        // Entry price
        _ReviewSlider(
          icon: Icons.euro_rounded,
          iconColor: AppColors.primary,
          label: 'Entry Price',
          value: _entryPrice,
          min: 0,
          max: 50,
          displayValue: '${_entryPrice.round()}€',
          onChanged: (v) => setState(() => _entryPrice = v),
        ),
        const SizedBox(height: 22),
        // Queue time
        _ReviewSlider(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFF448AFF),
          label: 'Queue Time',
          value: _queueTime,
          min: 0,
          max: 60,
          displayValue: '${_queueTime.round()} min',
          onChanged: (v) => setState(() => _queueTime = v),
        ),
        const SizedBox(height: 28),
        // Submit button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    'Submit Live Update',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReviewSlider extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _ReviewSlider({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: iconColor,
            inactiveTrackColor: iconColor.withOpacity(0.15),
            thumbColor: Colors.white,
            overlayColor: iconColor.withOpacity(0.15),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
