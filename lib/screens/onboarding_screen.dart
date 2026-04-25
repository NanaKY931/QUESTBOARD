import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      context.read<GameProvider>().createPlayer(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.bg(context)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Animated glowing shield icon ──
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) => Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(
                              (100 * _glowAnim.value).round(),
                            ),
                            blurRadius: 60 * _glowAnim.value,
                            spreadRadius: 10 * _glowAnim.value,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: const Icon(Icons.shield, size: 90, color: AppColors.gold),
                  ),
                  const SizedBox(height: 36),

                  // ── Brand title ──
                  Text('QUESTBOARD', style: AppText.display(size: 32)),
                  const SizedBox(height: 6),
                  Text(
                    'YOUR LEGEND BEGINS HERE',
                    style: AppText.label(
                      size: 11,
                      color: AppColors.of(context).textMuted,
                      spacing: 4,
                    ),
                  ),
                  const SizedBox(height: 52),

                  // ── Input card ──
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.of(context).borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(12),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADVENTURER NAME',
                          style: AppText.label(
                            size: 10,
                            color: AppColors.of(context).textMuted,
                            spacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: AppText.body(size: 18),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name...',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.gold),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),

                        // ── CTA button ──
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _submit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: AppGradients.gold,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withAlpha(90),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                'BEGIN ADVENTURE',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'An epic journey of discipline awaits.',
                    style: AppText.label(size: 12, color: AppColors.of(context).textMuted, spacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
