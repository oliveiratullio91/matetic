import 'package:flutter/material.dart';

import '../core/state/player_profile_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/game/game_screen.dart';
import '../features/home/home_screen.dart';
import '../features/events/event_screen.dart';
import '../features/map/map_screen.dart';
import '../features/modes/mode_select_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/ranking/ranking_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/training/training_screen.dart';
import 'router.dart';
import 'theme.dart';

class MateticApp extends StatelessWidget {
  const MateticApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return MaterialApp(
          title: 'Matetic',
          debugShowCheckedModeBanner: false,
          theme: buildMateticTheme(
            themeId: profile.themeId,
            highContrast: profile.highContrast,
          ),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(profile.textScaleFactor),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: AppRoute.splash,
          routes: {
            AppRoute.splash: (_) => const SplashScreen(),
            AppRoute.onboarding: (_) => const OnboardingScreen(),
            AppRoute.login: (_) => const LoginScreen(),
            AppRoute.home: (_) => const HomeScreen(),
            AppRoute.modes: (_) => const ModeSelectScreen(),
            AppRoute.map: (_) => const MapScreen(),
            AppRoute.game: (_) => const GameScreen(),
            AppRoute.training: (_) => const TrainingScreen(),
            AppRoute.missions: (_) => const MissionsScreen(),
            AppRoute.events: (_) => const EventScreen(),
            AppRoute.ranking: (_) => const RankingScreen(),
            AppRoute.shop: (_) => const ShopScreen(),
            AppRoute.profile: (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
