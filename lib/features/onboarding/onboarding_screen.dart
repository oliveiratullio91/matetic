import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  static const _pages = <({
    String title,
    String body,
    IconData icon,
  })>[
    (
      title: 'Treino que parece jogo',
      body:
          'Matetic foi desenhado para ser rapido, competitivo e recompensador. Cada fase dura pouco e sempre deixa vontade de melhorar.',
      icon: Icons.sports_esports_rounded,
    ),
    (
      title: 'Campanha, ranking e rotina',
      body:
          'Voce sobe no mapa, junta estrelas, cumpre missoes e constroi um perfil cada vez mais forte com moedas e XP.',
      icon: Icons.emoji_events_rounded,
    ),
    (
      title: 'Seu jeito de jogar',
      body:
          'Escolha uma base leve para comecar. Depois da primeira rodada, tudo pode ser ajustado no perfil e nas configuracoes.',
      icon: Icons.tune_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_step];

    return Scaffold(
      body: ShellFrame(
        maxWidth: 980,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: List<Widget>.generate(_pages.length, (index) {
                final active = index == _step;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(right: index == _pages.length - 1 ? 0 : 10),
                    height: 10,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        page.icon,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      page.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      page.body,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A5572),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_step == _pages.length - 1) ...[
                      Text(
                        'Perfil inicial',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _StarterChip(label: 'Leve'),
                          _StarterChip(label: 'Equilibrado'),
                          _StarterChip(label: 'Competitivo'),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _step--;
                                });
                              },
                              child: const Text('Voltar'),
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 14),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              if (_step < _pages.length - 1) {
                                setState(() {
                                  _step++;
                                });
                                return;
                              }

                              await PlayerProfileController.instance.completeOnboarding();
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.of(context).pushReplacementNamed(AppRoute.login);
                            },
                            child: Text(_step == _pages.length - 1 ? 'Comecar' : 'Avancar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
