import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Sva polja su obavezna');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await ApiService.register(_emailController.text.trim(), _passwordController.text, _nameController.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else {
      setState(() => _error = result['error'] as String?);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A0A2E), AppColors.background])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white)),
                const SizedBox(height: 30),
                Center(child: Container(width: 64, height: 64, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))]), child: const Icon(Icons.nightlife_rounded, size: 32, color: Colors.black))),
                const SizedBox(height: 40),
                Text('Registracija', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Kreiraj račun i započni.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))), child: Row(children: [const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20), const SizedBox(width: 10), Expanded(child: Text(_error!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)))])),
                  const SizedBox(height: 16),
                ],
                TextField(controller: _nameController, enabled: !_loading, style: GoogleFonts.inter(color: Colors.white), decoration: const InputDecoration(hintText: 'Ime i prezime', prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary))),
                const SizedBox(height: 16),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, enabled: !_loading, style: GoogleFonts.inter(color: Colors.white), decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary))),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: _obscurePassword, enabled: !_loading, onSubmitted: (_) => _signup(), style: GoogleFonts.inter(color: Colors.white), decoration: InputDecoration(hintText: 'Lozinka', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)))),
                const SizedBox(height: 32),
                AnimatedContainer(duration: const Duration(milliseconds: 200), width: double.infinity, height: 54, decoration: BoxDecoration(gradient: _loading ? null : AppColors.primaryGradient, color: _loading ? AppColors.surfaceLight : null, borderRadius: BorderRadius.circular(14), boxShadow: _loading ? null : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: ElevatedButton(onPressed: _loading ? null : _signup, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, disabledBackgroundColor: Colors.transparent),
                    child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)) : Text('Registriraj se', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)))),
                const SizedBox(height: 28),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Već imaš račun? ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)), GestureDetector(onTap: () => Navigator.of(context).pop(), child: Text('Prijavi se', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)))])),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
