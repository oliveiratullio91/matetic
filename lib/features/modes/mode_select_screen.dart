import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/data/sample_data.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import '../game/game_screen.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShellFrame(
        maxWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                SizedBox(
                  width: 820,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecao de modos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Campanha, modos solo e evento especial prontos para alimentar a rotina do jogador.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF4A5572),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: sampleGameModes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _ModeCard(mode: sampleGameModes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode});

  final GameModeDefinition mode;

  @override
  Widget build(BuildContext context) {
    final isCampaign = mode.id == GameModeId.campaign;
    final isTraining = mode.id == GameModeId.training;
    final isEvent = mode.id == GameModeId.event;

    return SectionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: mode.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(mode.icon, color: mode.color, size: 34),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(mode.badge)),
              if (!isCampaign) Chip(label: Text('${mode.durationInSeconds}s')),
            ],
          ),
          const SizedBox(height: 12),
          Text(mode.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            mode.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            mode.ruleSummary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              if (isCampaign) {
                Navigator.of(context).pushNamed(AppRoute.map);
                return;
              }
              if (isTraining) {
                Navigator.of(context).pushNamed(AppRoute.training);
                return;
              }
              if (isEvent) {
                Navigator.of(context).pushNamed(AppRoute.events);
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(quickMode: mode),
                ),
              );
            },
            icon: Icon(
              isCampaign
                  ? Icons.map_rounded
                  : isTraining
                      ? Icons.school_rounded
                      : Icons.play_arrow_rounded,
            ),
            label: Text(
              isCampaign
                  ? 'Abrir campanha'
                  : isTraining
                      ? 'Abrir treino'
                      : isEvent
                          ? 'Abrir evento'
                      : 'Jogar modo',
            ),
          ),
        ],
      ),
    );
  }
}
