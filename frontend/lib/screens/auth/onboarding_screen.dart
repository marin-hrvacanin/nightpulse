import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<String> _selectedGenres = {};

  final List<_GenreOption> _genres = [
    _GenreOption('Pop', Icons.music_note_rounded, [const Color(0xFFE040FB), const Color(0xFFFF4081)]),
    _GenreOption('Techno', Icons.equalizer_rounded, [const Color(0xFF448AFF), const Color(0xFF00E5FF)]),
    _GenreOption('Trap', Icons.mic_rounded, [const Color(0xFFFF6D00), const Color(0xFFFFAB00)]),
    _GenreOption('House', Icons.headphones_rounded, [const Color(0xFF7C4DFF), const Color(0xFFB388FF)]),
  ];

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A2E),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Progress dots
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 28,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 28,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'Kakvu glazbu\nvoliš?',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Odaberi omiljene žanrove za personalizirani feed.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Genre grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: _genres.length,
                    itemBuilder: (context, index) {
                      final genre = _genres[index];
                      final isSelected = _selectedGenres.contains(genre.name);
                      return _GenreCard(
                        genre: genre,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedGenres.remove(genre.name);
                            } else {
                              _selectedGenres.add(genre.name);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Finish button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: _selectedGenres.isNotEmpty
                        ? AppColors.primaryGradient
                        : null,
                    color: _selectedGenres.isEmpty ? AppColors.surfaceLight : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _selectedGenres.isNotEmpty
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _selectedGenres.isNotEmpty ? _finish : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      'Završi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _selectedGenres.isNotEmpty
                            ? Colors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreOption {
  final String name;
  final IconData icon;
  final List<Color> colors;

  _GenreOption(this.name, this.icon, this.colors);
}

class _GenreCard extends StatelessWidget {
  final _GenreOption genre;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreCard({
    required this.genre,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? genre.colors
                : [AppColors.surface, AppColors.surfaceLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: genre.colors.first.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              genre.icon,
              size: 42,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              genre.name,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
