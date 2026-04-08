import 'package:flutter/material.dart';

import 'math_topics.dart';
import 'sample_data.dart';
import 'shop_data.dart';

class SeasonRewardDefinition {
  const SeasonRewardDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredWins,
    required this.coins,
    this.unlockItemId,
  });

  final String id;
  final String title;
  final String description;
  final int requiredWins;
  final int coins;
  final String? unlockItemId;
}

class EventChallengeDefinition {
  const EventChallengeDefinition({
    required this.id,
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.mode,
    this.isBoss = false,
  });

  final String id;
  final int stageNumber;
  final String title;
  final String description;
  final int rewardCoins;
  final GameModeDefinition mode;
  final bool isBoss;
}

class SeasonEventDefinition {
  const SeasonEventDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.bannerLabel,
    required this.color,
    required this.rewardItemIds,
    required this.rewards,
    required this.bonusChapter,
  });

  final String id;
  final String title;
  final String subtitle;
  final String bannerLabel;
  final Color color;
  final List<String> rewardItemIds;
  final List<SeasonRewardDefinition> rewards;
  final List<EventChallengeDefinition> bonusChapter;
}

final currentSeasonEvent = SeasonEventDefinition(
  id: 'season_comet_festival',
  title: 'Festival do Cometa',
  subtitle: 'Temporada com fases bonus, missao sazonal e recompensas exclusivas.',
  bannerLabel: 'Evento ativo',
  color: const Color(0xFF8E5CFF),
  rewardItemIds: const [seasonThemeId, seasonFrameId, seasonEffectId],
  rewards: const [
    SeasonRewardDefinition(
      id: 'season_reward_1',
      title: 'Tema Comet Festival',
      description: 'Ganhe 1 vitoria no evento para liberar o tema sazonal.',
      requiredWins: 1,
      coins: 120,
      unlockItemId: seasonThemeId,
    ),
    SeasonRewardDefinition(
      id: 'season_reward_3',
      title: 'Moldura Comet Frame',
      description: 'Ganhe 3 vitorias para liberar a moldura exclusiva.',
      requiredWins: 3,
      coins: 180,
      unlockItemId: seasonFrameId,
    ),
    SeasonRewardDefinition(
      id: 'season_reward_5',
      title: 'Efeito Comet Trail',
      description: 'Ganhe 5 vitorias para liberar o efeito sazonal.',
      requiredWins: 5,
      coins: 240,
      unlockItemId: seasonEffectId,
    ),
  ],
  bonusChapter: [
    EventChallengeDefinition(
      id: 'event_stage_1',
      stageNumber: 1,
      title: 'Portal 1: Sprint de Aquecimento',
      description: 'Entrada rapida com mistura leve e bonus de velocidade.',
      rewardCoins: 90,
      mode: GameModeDefinition(
        id: GameModeId.event,
        title: 'Sprint de Aquecimento',
        description: 'Rodada curta para abrir o capitulo bonus da temporada.',
        badge: 'Bonus',
        color: Color(0xFF8E5CFF),
        icon: Icons.rocket_launch_rounded,
        targetScore: 1850,
        durationInSeconds: 58,
        totalQuestions: 9,
        difficultyTier: 7,
        ruleSummary: 'Abertura rapida da temporada. Velocidade pesa bastante.',
        focusTopics: [
          MathTopic.addition,
          MathTopic.subtraction,
          MathTopic.multiplication,
        ],
        secondaryObjectives: [
          SecondaryObjectiveDefinition(
            id: 'event_stage_1_combo',
            title: 'Combo x4',
            description: 'Abra a temporada com um combo x4.',
            type: SecondaryObjectiveType.reachCombo,
            targetValue: 4,
          ),
        ],
        modifiers: [
          PhaseModifierDefinition(
            type: PhaseModifierType.lightning,
            title: 'Relampago',
            description: 'Resposta rapida vale ainda mais.',
            icon: Icons.bolt_rounded,
            color: Color(0xFFFFB703),
          ),
        ],
        speedBonusMultiplier: 11,
      ),
    ),
    EventChallengeDefinition(
      id: 'event_stage_2',
      stageNumber: 2,
      title: 'Portal 2: Fronteira de Precisao',
      description: 'Fase tensa com poucos erros permitidos.',
      rewardCoins: 110,
      mode: GameModeDefinition(
        id: GameModeId.event,
        title: 'Fronteira de Precisao',
        description: 'Rodada de controle fino com foco em sequencia limpa.',
        badge: 'Bonus',
        color: Color(0xFF2D55FF),
        icon: Icons.gps_fixed_rounded,
        targetScore: 2250,
        durationInSeconds: 70,
        totalQuestions: 10,
        difficultyTier: 8,
        ruleSummary: 'Fase de precisao. Dois erros e a margem acaba.',
        focusTopics: [
          MathTopic.division,
          MathTopic.fractions,
          MathTopic.percentages,
        ],
        secondaryObjectives: [
          SecondaryObjectiveDefinition(
            id: 'event_stage_2_clean',
            title: 'Sem erro',
            description: 'Passe pela fase com leitura limpa.',
            type: SecondaryObjectiveType.noMistakes,
            targetValue: 0,
          ),
        ],
        modifiers: [
          PhaseModifierDefinition(
            type: PhaseModifierType.precision,
            title: 'Precisao total',
            description: 'Poucos erros antes do encerramento.',
            icon: Icons.gps_fixed_rounded,
            color: Color(0xFF2D55FF),
          ),
        ],
        maxWrongAnswers: 2,
      ),
    ),
    EventChallengeDefinition(
      id: 'event_stage_3',
      stageNumber: 3,
      title: 'Portal 3: Combo de Meteoros',
      description: 'Fase com surto de combo e pontuacao alta.',
      rewardCoins: 130,
      mode: GameModeDefinition(
        id: GameModeId.event,
        title: 'Combo de Meteoros',
        description: 'Modo agressivo para esticar streak e score.',
        badge: 'Bonus',
        color: Color(0xFFFF7B54),
        icon: Icons.local_fire_department_rounded,
        targetScore: 2700,
        durationInSeconds: 72,
        totalQuestions: 10,
        difficultyTier: 9,
        ruleSummary: 'Segure o combo e colha a maior parte da pontuacao.',
        focusTopics: [
          MathTopic.multiplication,
          MathTopic.mixedOperations,
          MathTopic.powers,
        ],
        secondaryObjectives: [
          SecondaryObjectiveDefinition(
            id: 'event_stage_3_combo',
            title: 'Combo x6',
            description: 'Atinga streak de alto nivel.',
            type: SecondaryObjectiveType.reachCombo,
            targetValue: 6,
          ),
        ],
        modifiers: [
          PhaseModifierDefinition(
            type: PhaseModifierType.comboSurge,
            title: 'Combo em dobro',
            description: 'O multiplicador cresce mais nesta fase.',
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFFF7B54),
          ),
        ],
        comboScoreMultiplier: 28,
      ),
    ),
    EventChallengeDefinition(
      id: 'event_stage_4',
      stageNumber: 4,
      title: 'Portal 4: Bolsa de Cristais',
      description: 'Rodada bonus com ganho ampliado e foco em leitura rapida.',
      rewardCoins: 160,
      mode: GameModeDefinition(
        id: GameModeId.event,
        title: 'Bolsa de Cristais',
        description: 'Fase sazonal de recompensa forte antes do chefe.',
        badge: 'Bonus',
        color: Color(0xFF13C4A3),
        icon: Icons.redeem_rounded,
        targetScore: 2900,
        durationInSeconds: 68,
        totalQuestions: 10,
        difficultyTier: 10,
        ruleSummary: 'Fase bonus: cada acerto vale mais que o normal.',
        focusTopics: [
          MathTopic.percentages,
          MathTopic.fractions,
          MathTopic.sequences,
        ],
        secondaryObjectives: [
          SecondaryObjectiveDefinition(
            id: 'event_stage_4_hits',
            title: 'Nove acertos',
            description: 'Feche a fase bonus com consistencia.',
            type: SecondaryObjectiveType.correctAnswersAtLeast,
            targetValue: 9,
          ),
        ],
        modifiers: [
          PhaseModifierDefinition(
            type: PhaseModifierType.jackpot,
            title: 'Fase bonus',
            description: 'Pontuacao ampliada durante todo o portal.',
            icon: Icons.redeem_rounded,
            color: Color(0xFF13C4A3),
          ),
        ],
        scoreGainMultiplier: 1.25,
      ),
    ),
    EventChallengeDefinition(
      id: 'event_stage_5',
      stageNumber: 5,
      title: 'Portal 5: Chefe Cometa',
      description: 'Chefe final do capitulo bonus da temporada.',
      rewardCoins: 220,
      isBoss: true,
      mode: GameModeDefinition(
        id: GameModeId.event,
        title: 'Chefe Cometa',
        description: 'Encontro final da temporada com mistura completa de topicos.',
        badge: 'Chefe',
        color: Color(0xFFFFB703),
        icon: Icons.whatshot_rounded,
        targetScore: 3400,
        durationInSeconds: 74,
        totalQuestions: 11,
        difficultyTier: 11,
        ruleSummary: 'Chefe sazonal: dois modificadores ativos e margem curta para erro.',
        focusTopics: [
          MathTopic.mixedOperations,
          MathTopic.percentages,
          MathTopic.powers,
          MathTopic.equations,
          MathTopic.sequences,
        ],
        secondaryObjectives: [
          SecondaryObjectiveDefinition(
            id: 'event_stage_5_clean',
            title: 'Chefe limpo',
            description: 'Conclua o chefe sem erros.',
            type: SecondaryObjectiveType.noMistakes,
            targetValue: 0,
          ),
          SecondaryObjectiveDefinition(
            id: 'event_stage_5_combo',
            title: 'Combo x7',
            description: 'Segure a pressao do chefe com combo alto.',
            type: SecondaryObjectiveType.reachCombo,
            targetValue: 7,
          ),
        ],
        modifiers: [
          PhaseModifierDefinition(
            type: PhaseModifierType.precision,
            title: 'Janela de precisao',
            description: 'Poucos erros sao permitidos.',
            icon: Icons.gps_fixed_rounded,
            color: Color(0xFFFFB703),
          ),
          PhaseModifierDefinition(
            type: PhaseModifierType.comboSurge,
            title: 'Combo do chefe',
            description: 'Combos rendem muito mais no confronto final.',
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFFF7B54),
          ),
        ],
        comboScoreMultiplier: 30,
        maxWrongAnswers: 2,
        pauseEnabled: false,
      ),
    ),
  ],
);

EventChallengeDefinition? eventChallengeById(String id) {
  for (final challenge in currentSeasonEvent.bonusChapter) {
    if (challenge.id == id) {
      return challenge;
    }
  }
  return null;
}
