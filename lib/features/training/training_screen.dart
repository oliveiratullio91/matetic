import 'package:flutter/material.dart';

import '../../core/data/sample_data.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import '../game/game_screen.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        final recommended = profile.recommendedTrainingTopic;
        final weakest = profile.weakestTopics;
        final mistakes = profile.recentMistakes.take(8).toList(growable: false);

        return Scaffold(
          body: ShellFrame(
            maxWidth: 1180,
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
                      width: 860,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Treino e revisao',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Revise erros recentes, enxergue seus topicos fracos e abra sessoes de treino focadas para evoluir com mais intencao.',
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
                      final wide = constraints.maxWidth >= 980;
                      final left = _TrainingMainColumn(
                        profile: profile,
                        recommended: recommended,
                        weakest: weakest,
                      );
                      final right = _ReviewColumn(
                        mistakes: mistakes,
                        recommended: recommended,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(child: left),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(child: right),
                            ),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            left,
                            const SizedBox(height: 20),
                            right,
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
      },
    );
  }
}

class _TrainingMainColumn extends StatelessWidget {
  const _TrainingMainColumn({
    required this.profile,
    required this.recommended,
    required this.weakest,
  });

  final PlayerProfileController profile;
  final TopicPerformanceView recommended;
  final List<TopicPerformanceView> weakest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treino recomendado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2D55FF),
                      Color(0xFF13C4A3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommended.topic.label,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommended.totalAttempts == 0
                          ? 'Esse topico ainda nao teve volume suficiente. Vale abrir uma rodada para criar base.'
                          : 'Esse topico esta com ${_formatAccuracy(recommended.accuracyRatio)} de aproveitamento e merece reforco agora.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF153091),
                      ),
                      onPressed: () => _openTraining(context, recommended),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Comecar treino'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Indicador de topicos fracos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              if (weakest.isEmpty)
                Text(
                  'Assim que voce errar algumas questoes, o jogo vai apontar aqui onde vale treinar mais.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                )
              else
                ...weakest.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TopicInsightTile(topic: topic),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treino por topico',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: profile.topicPerformance
                    .map(
                      (topic) => SizedBox(
                        width: 240,
                        child: _TopicActionCard(topic: topic),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewColumn extends StatelessWidget {
  const _ReviewColumn({
    required this.mistakes,
    required this.recommended,
  });

  final List<MistakeReviewEntry> mistakes;
  final TopicPerformanceView recommended;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revisao dos erros recentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              if (mistakes.isEmpty)
                Text(
                  'Ainda nao ha erros recentes salvos. Assim que voce errar uma resposta, ela aparece aqui com explicacao para revisao.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                )
              else
                ...mistakes.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MistakeTile(entry: entry),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proxima acao sugerida',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Text(
                'Depois de revisar seus erros, abra um treino de ${recommended.topic.label.toLowerCase()} para consolidar o ponto mais fraco do momento.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF55607B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicInsightTile extends StatelessWidget {
  const _TopicInsightTile({required this.topic});

  final TopicPerformanceView topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic.topic.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                topic.recommendationLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFD1495B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: topic.totalAttempts == 0 ? 0 : topic.accuracyRatio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: 8),
          Text(
            'Aproveitamento: ${_formatAccuracy(topic.accuracyRatio)} | Tentativas: ${topic.totalAttempts}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicActionCard extends StatelessWidget {
  const _TopicActionCard({required this.topic});

  final TopicPerformanceView topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.topic.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            topic.totalAttempts == 0
                ? 'Ainda sem historico'
                : 'Aproveitamento ${_formatAccuracy(topic.accuracyRatio)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openTraining(context, topic),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Treinar'),
          ),
        ],
      ),
    );
  }
}

class _MistakeTile extends StatelessWidget {
  const _MistakeTile({required this.entry});

  final MistakeReviewEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0CCD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(entry.topic.label)),
              Chip(label: Text(entry.difficultyLabel)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.prompt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Sua resposta: ${entry.selectedAnswer ?? '-'} | Correta: ${entry.correctAnswer}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

String _formatAccuracy(double value) {
  return '${(value * 100).round()}%';
}

void _openTraining(BuildContext context, TopicPerformanceView topic) {
  final suggestedDifficulty = topic.totalAttempts == 0
      ? 4
      : _clampInt((topic.wrongAnswers + 4) - (topic.correctAnswers ~/ 2), 4, 12);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GameScreen(
        quickMode: buildTrainingModeForTopic(
          topic: topic.topic,
          difficultyTier: suggestedDifficulty,
        ),
      ),
    ),
  );
}

int _clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
