import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'WELCOME ADVENTURER',
      'desc': 'Your daily tasks are no longer chores. They are quests. Your life is no longer a routine. It is a legend.',
      'icon': '🛡️',
    },
    {
      'title': 'MASTER YOUR FOCUS',
      'desc': 'Every quest completed grants you EXP. Every streak maintained empowers your spirit. Forge discipline through fire.',
      'icon': '⚔️',
    },
    {
      'title': 'RISE TO GLORY',
      'desc': 'Ascend from E-Class to S-Class. Unlock ancient achievements and build a trophy room of your triumphs.',
      'icon': '🏆',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withAlpha(20),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _pages.length,
                    itemBuilder: (context, idx) {
                      final page = _pages[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page['icon']!,
                              style: const TextStyle(fontSize: 80),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: AppText.display(size: 28),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page['desc']!,
                              textAlign: TextAlign.center,
                              style: AppText.body(size: 16, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.gold : colors.borderSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.read<ThemeProvider>().setFirstRunComplete();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppGradients.gold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(60),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'BEGIN YOUR LEGEND' : 'CONTINUE',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
