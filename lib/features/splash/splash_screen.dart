import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/shell_frame.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PlayerProfileController.instance.refreshSessionPresence());
    });
    _redirectTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      final session = PlayerProfileController.instance.session;
      final nextRoute = !session.completedOnboarding
          ? AppRoute.onboarding
          : session.signedIn
              ? AppRoute.home
              : AppRoute.login;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ShellFrame(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 40,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Matetic',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 420,
                child: Text(
                  'Treino matematico com cara de jogo competitivo: fases rapidas, ranking e progressao constante.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4A5572),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
