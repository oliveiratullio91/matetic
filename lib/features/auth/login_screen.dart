import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 920;

    return Scaffold(
      body: ShellFrame(
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _HeroPanel(theme: theme)),
                  const SizedBox(width: 28),
                  Expanded(
                    child: _LoginPanel(
                      nameController: _nameController,
                      submitting: _submitting,
                      onGuestLogin: _handleGuestLogin,
                      onGoogleLogin: _handleGoogleLogin,
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _HeroPanel(theme: theme),
                    const SizedBox(height: 20),
                    _LoginPanel(
                      nameController: _nameController,
                      submitting: _submitting,
                      onGuestLogin: _handleGuestLogin,
                      onGoogleLogin: _handleGoogleLogin,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _handleGuestLogin() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    await PlayerProfileController.instance.signInAsGuest(
      displayName: _nameController.text,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.home, (route) => false);
  }

  Future<void> _handleGoogleLogin() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    await PlayerProfileController.instance.signInWithGoogleMock();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.home, (route) => false);
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'MVP jogavel',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Matematica com ritmo de puzzle online.',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 18),
          Text(
            'Monte combos, vença o cronômetro, suba no ranking e destrave fases cada vez mais desafiadoras.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _InfoChip(icon: Icons.bolt_rounded, label: 'Partidas curtas'),
              _InfoChip(icon: Icons.public_rounded, label: 'Web + mobile'),
              _InfoChip(icon: Icons.emoji_events_rounded, label: 'Ranking e ligas'),
              _InfoChip(icon: Icons.map_rounded, label: 'Mapa por niveis'),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temporada de lancamento',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Comece pela campanha, junte estrelas, cumpra missoes e equipe seu perfil com moedas e XP.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.nameController,
    required this.submitting,
    required this.onGuestLogin,
    required this.onGoogleLogin,
  });

  final TextEditingController nameController;
  final bool submitting;
  final Future<void> Function() onGuestLogin;
  final Future<void> Function() onGoogleLogin;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrar no Matetic',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'A entrada local já está pronta para onboarding, perfil, loja, missões e progresso salvo. O login Google fica em modo mock até a integração real.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do jogador',
              hintText: 'Ex.: Tullio Prime',
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: submitting ? null : onGuestLogin,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Continuar como visitante'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: submitting ? null : onGoogleLogin,
            icon: const Icon(Icons.account_circle_rounded),
            label: const Text('Entrar com Google (mock)'),
          ),
          const SizedBox(height: 18),
          Text(
            'Sessao persistida, onboarding salvo e fluxo pronto para integrar autenticacao real depois.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF66718F),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
