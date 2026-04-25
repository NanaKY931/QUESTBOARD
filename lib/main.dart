import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/auth_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService().init();
  } catch (_) {}

  runApp(const QuestBoardApp());
}

class QuestBoardApp extends StatelessWidget {
  const QuestBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'QuestBoard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const Bootloader(),
          );
        },
      ),
    );
  }
}


// ─────────────────────────────────────────────────
// Boot splash / router
// ─────────────────────────────────────────────────
class Bootloader extends StatelessWidget {
  const Bootloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.of(context).bg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(80),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield, size: 64, color: AppColors.gold),
                  ),
                  const SizedBox(height: 28),
                  Text('QUESTBOARD', style: AppText.display(size: 26)),
                  const SizedBox(height: 6),
                  Text(
                    'Forging your destiny...',
                    style: AppText.label(size: 12, color: AppColors.of(context).textMuted, spacing: 1),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.player == null) {
          // If authenticated but no stats yet, go to onboarding
          if (provider.isAuthenticated) return const OnboardingScreen();
          
          // If not authenticated, check if it's the first run
          final themeProv = context.watch<ThemeProvider>();
          if (themeProv.isFirstRun) {
            return const IntroScreen();
          }
          
          return const AuthScreen();
        }
        
        return const DashboardScreen();
      },
    );
  }
}
