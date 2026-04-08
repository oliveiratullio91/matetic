import 'package:flutter/material.dart';

import '../../core/state/campaign_progress.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import 'game_screen.dart';

class LevelPreviewScreen extends StatelessWidget {
  const LevelPreviewScreen({
    super.key,
    required this.levelId,
  });

  final int levelId;

  @override
  Widget build(BuildContext context) {
    final level = CampaignProgressController.instance.levelById(levelId);
    final rewards = PlayerProfileController.instance.previewRewardForRun(
      starsEarned: 3,
      objectivesCompleted: level.secondaryObjectives.length,
    );

    return Scaffold(
      body: ShellFrame(
        maxWidth: 980,
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
                  width: 760,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${level.isBoss ? 'Chefe' : 'Fase'} ${level.id}: ${level.title}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 840;

                  final summary = _SummaryCard(level: level, rewards: rewards);
                  final objectives = _ObjectivesCard(level: level);

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(child: summary),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(child: objectives),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        summary,
                        const SizedBox(height: 20),
                        objectives,
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.level,
    required this.rewards,
  });

  final LevelProgressView level;
  final RewardBundle rewards;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: level.isBoss
                    ? const [Color(0xFFFFB703), Color(0xFFFF7B54)]
                    : const [Color(0xFF2D55FF), Color(0xFF13C4A3)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.isBoss ? 'Modo chefe' : 'Preparar corrida',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  level.ruleSummary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _PreviewRow(label: 'Meta principal', value: '${level.targetScore} pontos'),
          _PreviewRow(label: 'Capitulo', value: '${level.chapterId}'),
          _PreviewRow(label: 'Tempo de fase', value: '${level.durationInSeconds}s'),
          _PreviewRow(label: 'Perguntas', value: '${level.totalQuestions}'),
          _PreviewRow(label: 'Trava de estrelas', value: '${level.unlockStarsRequired}'),
          _PreviewRow(
            label: 'Pausa',
            value: level.pauseEnabled ? 'Permitida' : 'Desativada',
          ),
          _PreviewRow(label: 'Recompensa forte', value: '+${rewards.coins} moedas'),
          _PreviewRow(label: 'XP de referencia', value: '+${rewards.xp} XP'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: level.focusTopics
                .map((topic) => Chip(label: Text(topic.label)))
                .toList(growable: false),
          ),
          if (level.modifiers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Modificadores da fase',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...level.modifiers.map(
              (modifier) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: modifier.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: modifier.color.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      Icon(modifier.icon, color: modifier.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              modifier.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              modifier.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF55607B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: List<Widget>.generate(3, (index) {
              final active = index < level.stars;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.star_rounded,
                  size: 30,
                  color: active ? const Color(0xFFFFB703) : const Color(0xFFD6DBEA),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            level.completed
                ? 'Melhor resultado salvo: ${level.stars}/3 estrelas'
                : 'Ainda sem resultado salvo nesta fase',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF66718F),
            ),
          ),
          if (level.perfectClear) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D8),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFFFD166)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 18,
                    color: Color(0xFFFFB703),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selo de fase perfeita salvo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFB67100),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E9F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historico da fase',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _PreviewRow(label: 'Vezes jogada', value: '${level.timesPlayed}'),
                _PreviewRow(label: 'Melhor score', value: '${level.bestScore}'),
                _PreviewRow(label: 'Melhor combo', value: 'x${level.bestCombo}'),
                _PreviewRow(
                  label: 'Objetivos completos',
                  value:
                      '${level.completedObjectivesCount}/${level.secondaryObjectives.length}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectivesCard extends StatelessWidget {
  const _ObjectivesCard({required this.level});

  final LevelProgressView level;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objetivos secundarios',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Complete a meta principal e tente bater estes desafios para buscar a melhor execucao da fase.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          const SizedBox(height: 18),
          ...level.secondaryObjectives.map(
            (objective) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ObjectiveTile(
                title: objective.title,
                description: objective.description,
                completed: level.completedObjectiveIds.contains(objective.id),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(levelId: level.id),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Iniciar fase'),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ObjectiveTile extends StatelessWidget {
  const _ObjectiveTile({
    required this.title,
    required this.description,
    required this.completed,
  });

  final String title;
  final String description;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFEAFBF7) : const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed ? const Color(0xFF13C4A3) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: completed
                    ? const Color(0xFF13C4A3)
                    : const Color(0xFF94A1BD),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
        ],
      ),
    );
  }
}
