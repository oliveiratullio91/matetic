import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'math_topics.dart';

class SubjectSummary {
  const SubjectSummary({
    required this.title,
    required this.badge,
    required this.progress,
    required this.color,
  });

  final String title;
  final String badge;
  final double progress;
  final Color color;
}

class ChapterDefinition {
  const ChapterDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.unlockStarsRequired,
  });

  final int id;
  final String title;
  final String subtitle;
  final Color themeColor;
  final int unlockStarsRequired;
}

enum GameModeId {
  campaign,
  training,
  timeAttack,
  survival,
  comboRush,
  event,
}

enum PhaseModifierType {
  lightning,
  recovery,
  precision,
  comboSurge,
  jackpot,
}

class PhaseModifierDefinition {
  const PhaseModifierDefinition({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final PhaseModifierType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

enum SecondaryObjectiveType {
  noMistakes,
  reachCombo,
  finishWithTimeLeft,
  correctAnswersAtLeast,
}

class SecondaryObjectiveDefinition {
  const SecondaryObjectiveDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
  });

  final String id;
  final String title;
  final String description;
  final SecondaryObjectiveType type;
  final int targetValue;
}

class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.targetScore,
    required this.durationInSeconds,
    required this.totalQuestions,
    required this.ruleSummary,
    required this.focusTopics,
    required this.secondaryObjectives,
    required this.modifiers,
    required this.difficultyTier,
    this.unlockStarsRequired = 0,
    this.baseScorePerHit = 120,
    this.scorePenaltyOnMiss = 35,
    this.timePenaltyOnMiss = 4,
    this.speedBonusMultiplier = 6,
    this.comboScoreMultiplier = 18,
    this.extraSecondsOnCorrect = 0,
    this.scoreGainMultiplier = 1.0,
    this.maxWrongAnswers,
    this.pauseEnabled = true,
    this.isBoss = false,
  });

  final int id;
  final int chapterId;
  final String title;
  final String description;
  final int targetScore;
  final int durationInSeconds;
  final int totalQuestions;
  final String ruleSummary;
  final List<MathTopic> focusTopics;
  final List<SecondaryObjectiveDefinition> secondaryObjectives;
  final List<PhaseModifierDefinition> modifiers;
  final int difficultyTier;
  final int unlockStarsRequired;
  final int baseScorePerHit;
  final int scorePenaltyOnMiss;
  final int timePenaltyOnMiss;
  final int speedBonusMultiplier;
  final int comboScoreMultiplier;
  final int extraSecondsOnCorrect;
  final double scoreGainMultiplier;
  final int? maxWrongAnswers;
  final bool pauseEnabled;
  final bool isBoss;
}

class GameModeDefinition {
  const GameModeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.color,
    required this.icon,
    required this.targetScore,
    required this.durationInSeconds,
    required this.totalQuestions,
    required this.ruleSummary,
    required this.focusTopics,
    required this.secondaryObjectives,
    this.modifiers = const <PhaseModifierDefinition>[],
    this.baseScorePerHit = 120,
    this.scorePenaltyOnMiss = 35,
    this.timePenaltyOnMiss = 4,
    this.speedBonusMultiplier = 6,
    this.comboScoreMultiplier = 18,
    this.extraSecondsOnCorrect = 0,
    this.scoreGainMultiplier = 1.0,
    this.pauseEnabled = true,
    this.maxWrongAnswers,
    this.difficultyTier = 6,
  });

  final GameModeId id;
  final String title;
  final String description;
  final String badge;
  final Color color;
  final IconData icon;
  final int targetScore;
  final int durationInSeconds;
  final int totalQuestions;
  final String ruleSummary;
  final List<MathTopic> focusTopics;
  final List<SecondaryObjectiveDefinition> secondaryObjectives;
  final List<PhaseModifierDefinition> modifiers;
  final int baseScorePerHit;
  final int scorePenaltyOnMiss;
  final int timePenaltyOnMiss;
  final int speedBonusMultiplier;
  final int comboScoreMultiplier;
  final int extraSecondsOnCorrect;
  final double scoreGainMultiplier;
  final bool pauseEnabled;
  final int? maxWrongAnswers;
  final int difficultyTier;
}

const int totalChapters = 25;
const int levelsPerChapter = 20;
const int totalCampaignLevels = totalChapters * levelsPerChapter;

const List<Color> _chapterPalette = <Color>[
  Color(0xFF2D55FF),
  Color(0xFF13C4A3),
  Color(0xFFFF7B54),
  Color(0xFFFFB703),
  Color(0xFF8E5CFF),
  Color(0xFFEF476F),
  Color(0xFF00A6FB),
  Color(0xFF2A9D8F),
];

final List<ChapterDefinition> sampleChapters = _buildSampleChapters();
final List<SubjectSummary> sampleSubjects = _buildSampleSubjects();
final List<LevelDefinition> sampleLevelDefinitions = _buildSampleLevelDefinitions();

const sampleGameModes = <GameModeDefinition>[
  GameModeDefinition(
    id: GameModeId.campaign,
    title: 'Campanha',
    description: 'Segue o mapa, libera fases e acumula estrelas.',
    badge: 'Principal',
    color: Color(0xFF2D55FF),
    icon: Icons.route_rounded,
    targetScore: 0,
    durationInSeconds: 0,
    totalQuestions: 0,
    ruleSummary: 'Use o mapa para escolher a fase ideal do seu progresso.',
    focusTopics: [MathTopic.addition, MathTopic.subtraction],
    secondaryObjectives: [],
    modifiers: <PhaseModifierDefinition>[],
  ),
  GameModeDefinition(
    id: GameModeId.training,
    title: 'Treino guiado',
    description: 'Escolha um topico especifico e faca rodadas para corrigir suas fraquezas.',
    badge: 'Estudo',
    color: Color(0xFF4C7DFF),
    icon: Icons.psychology_alt_rounded,
    targetScore: 1600,
    durationInSeconds: 90,
    totalQuestions: 10,
    difficultyTier: 4,
    ruleSummary: 'Foco em um topico por vez, sem pressa exagerada e com espaco para reforcar padroes.',
    focusTopics: [MathTopic.addition],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'training_clean',
        title: 'Rodada limpa',
        description: 'Conclua o treino sem errar nenhuma resposta.',
        type: SecondaryObjectiveType.noMistakes,
        targetValue: 0,
      ),
      SecondaryObjectiveDefinition(
        id: 'training_correct8',
        title: 'Oito acertos',
        description: 'Chegue a pelo menos 8 acertos na sessao de treino.',
        type: SecondaryObjectiveType.correctAnswersAtLeast,
        targetValue: 8,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.recovery,
        title: 'Folego extra',
        description: 'Cada acerto devolve alguns segundos ao cronometro.',
        icon: Icons.favorite_rounded,
        color: Color(0xFF13C4A3),
      ),
    ],
    baseScorePerHit: 110,
    timePenaltyOnMiss: 2,
    comboScoreMultiplier: 12,
    extraSecondsOnCorrect: 2,
  ),
  GameModeDefinition(
    id: GameModeId.timeAttack,
    title: 'Contra o tempo',
    description: 'Pontue o maximo possivel antes do relogio zerar.',
    badge: 'Solo',
    color: Color(0xFFFF7B54),
    icon: Icons.timer_rounded,
    targetScore: 2600,
    durationInSeconds: 70,
    totalQuestions: 12,
    difficultyTier: 8,
    ruleSummary: 'Velocidade vale muito. Cada segundo economizado aumenta o potencial da corrida.',
    focusTopics: [
      MathTopic.addition,
      MathTopic.subtraction,
      MathTopic.multiplication,
      MathTopic.mixedOperations,
    ],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'time_combo4',
        title: 'Combo x4',
        description: 'Alcance um combo de 4 em qualquer momento da corrida.',
        type: SecondaryObjectiveType.reachCombo,
        targetValue: 4,
      ),
      SecondaryObjectiveDefinition(
        id: 'time_correct9',
        title: 'Nove acertos',
        description: 'Chegue a pelo menos 9 respostas corretas.',
        type: SecondaryObjectiveType.correctAnswersAtLeast,
        targetValue: 9,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.lightning,
        title: 'Relampago',
        description: 'Velocidade vale ainda mais nesta corrida.',
        icon: Icons.bolt_rounded,
        color: Color(0xFFFF7B54),
      ),
    ],
    speedBonusMultiplier: 10,
    comboScoreMultiplier: 16,
  ),
  GameModeDefinition(
    id: GameModeId.survival,
    title: 'Sobrevivencia',
    description: 'Cada erro pesa. Aguente o maximo de perguntas vivas.',
    badge: 'Tatico',
    color: Color(0xFF13C4A3),
    icon: Icons.favorite_rounded,
    targetScore: 2100,
    durationInSeconds: 85,
    totalQuestions: 12,
    difficultyTier: 9,
    ruleSummary: 'Voce so pode errar 3 vezes. A fase termina assim que a margem acaba.',
    focusTopics: [
      MathTopic.subtraction,
      MathTopic.multiplication,
      MathTopic.division,
      MathTopic.equations,
    ],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'survival_nomiss',
        title: 'Sem erro ate a metade',
        description: 'Mantenha a rodada limpa ate completar 6 perguntas.',
        type: SecondaryObjectiveType.correctAnswersAtLeast,
        targetValue: 6,
      ),
      SecondaryObjectiveDefinition(
        id: 'survival_combo5',
        title: 'Combo x5',
        description: 'Atinga um combo de 5 durante a sobrevivencia.',
        type: SecondaryObjectiveType.reachCombo,
        targetValue: 5,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.precision,
        title: 'Precisao total',
        description: 'O modo encerra cedo se os erros se acumularem demais.',
        icon: Icons.gps_fixed_rounded,
        color: Color(0xFF13C4A3),
      ),
    ],
    scorePenaltyOnMiss: 20,
    timePenaltyOnMiss: 0,
    maxWrongAnswers: 3,
  ),
  GameModeDefinition(
    id: GameModeId.comboRush,
    title: 'Combo Rush',
    description: 'Modo de streak alto com grande peso no multiplicador.',
    badge: 'Skill',
    color: Color(0xFFFFB703),
    icon: Icons.local_fire_department_rounded,
    targetScore: 3000,
    durationInSeconds: 72,
    totalQuestions: 11,
    difficultyTier: 10,
    ruleSummary: 'O combo decide tudo aqui. Errou, perde muito ritmo.',
    focusTopics: [
      MathTopic.multiplication,
      MathTopic.division,
      MathTopic.percentages,
      MathTopic.powers,
    ],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'combo7',
        title: 'Combo x7',
        description: 'Atinga um combo de 7 para dominar o modo.',
        type: SecondaryObjectiveType.reachCombo,
        targetValue: 7,
      ),
      SecondaryObjectiveDefinition(
        id: 'combo_time15',
        title: 'Sobrar 15 segundos',
        description: 'Finalize a corrida com boa sobra de tempo.',
        type: SecondaryObjectiveType.finishWithTimeLeft,
        targetValue: 15,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.comboSurge,
        title: 'Surto de combo',
        description: 'Combos rendem pontos extras e ditam o ritmo da fase.',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFFB703),
      ),
    ],
    comboScoreMultiplier: 30,
    speedBonusMultiplier: 5,
    scoreGainMultiplier: 1.15,
  ),
  GameModeDefinition(
    id: GameModeId.event,
    title: 'Evento relampago',
    description: 'Rotacao especial da semana com mistura de topicos.',
    badge: 'Evento',
    color: Color(0xFF8E5CFF),
    icon: Icons.auto_awesome_rounded,
    targetScore: 3200,
    durationInSeconds: 70,
    totalQuestions: 10,
    difficultyTier: 11,
    ruleSummary: 'Mistura todos os topicos da temporada e entrega recompensas extras.',
    focusTopics: [
      MathTopic.addition,
      MathTopic.subtraction,
      MathTopic.multiplication,
      MathTopic.division,
      MathTopic.mixedOperations,
      MathTopic.fractions,
      MathTopic.percentages,
      MathTopic.powers,
      MathTopic.equations,
      MathTopic.sequences,
    ],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'event_nomiss',
        title: 'Rodada limpa',
        description: 'Conclua o evento sem errar nenhuma resposta.',
        type: SecondaryObjectiveType.noMistakes,
        targetValue: 0,
      ),
      SecondaryObjectiveDefinition(
        id: 'event_correct8',
        title: 'Oito acertos',
        description: 'Chegue a pelo menos 8 acertos no evento.',
        type: SecondaryObjectiveType.correctAnswersAtLeast,
        targetValue: 8,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.jackpot,
        title: 'Rodada bonus',
        description: 'Fase especial com ganho de score ampliado.',
        icon: Icons.redeem_rounded,
        color: Color(0xFF8E5CFF),
      ),
      PhaseModifierDefinition(
        type: PhaseModifierType.lightning,
        title: 'Ritmo de evento',
        description: 'As respostas rapidas ficam ainda mais valiosas.',
        icon: Icons.flash_on_rounded,
        color: Color(0xFFFFB703),
      ),
    ],
    baseScorePerHit: 130,
    speedBonusMultiplier: 8,
    comboScoreMultiplier: 20,
    scoreGainMultiplier: 1.2,
  ),
];

GameModeDefinition buildTrainingModeForTopic({
  required MathTopic topic,
  required int difficultyTier,
}) {
  final normalizedDifficulty = math.max(3, math.min(12, difficultyTier));
  return GameModeDefinition(
    id: GameModeId.training,
    title: 'Treino de ${topic.label}',
    description: 'Sessao focada em ${topic.label.toLowerCase()} para revisar o que mais precisa de reforco.',
    badge: 'Treino',
    color: const Color(0xFF4C7DFF),
    icon: Icons.school_rounded,
    targetScore: 1400 + (normalizedDifficulty * 70),
    durationInSeconds: 92,
    totalQuestions: 10,
    difficultyTier: normalizedDifficulty,
    ruleSummary: 'Rodada concentrada em ${topic.label.toLowerCase()} com ritmo mais controlado para reforco.',
    focusTopics: [topic],
    secondaryObjectives: [
      SecondaryObjectiveDefinition(
        id: 'training_precision_${topic.name}',
        title: 'Precisao limpa',
        description: 'Conclua este treino sem respostas erradas.',
        type: SecondaryObjectiveType.noMistakes,
        targetValue: 0,
      ),
      SecondaryObjectiveDefinition(
        id: 'training_hits_${topic.name}',
        title: 'Oito acertos',
        description: 'Chegue a pelo menos 8 acertos nesta sessao de treino.',
        type: SecondaryObjectiveType.correctAnswersAtLeast,
        targetValue: 8,
      ),
    ],
    modifiers: [
      PhaseModifierDefinition(
        type: PhaseModifierType.recovery,
        title: 'Pulso de treino',
        description: 'Cada acerto traz um pequeno respiro para estudar com consistencia.',
        icon: Icons.psychology_alt_rounded,
        color: Color(0xFF4C7DFF),
      ),
    ],
    baseScorePerHit: 105 + (normalizedDifficulty * 4),
    scorePenaltyOnMiss: 24,
    timePenaltyOnMiss: 2,
    speedBonusMultiplier: 4,
    comboScoreMultiplier: 12,
    extraSecondsOnCorrect: 2,
    pauseEnabled: true,
  );
}

List<ChapterDefinition> _buildSampleChapters() {
  return List<ChapterDefinition>.generate(totalChapters, (index) {
    final chapterNumber = index + 1;
    final chapterBlock = index ~/ 5;
    final chapterColor = _chapterPalette[index % _chapterPalette.length];
    final unlockStars = index == 0 ? 0 : index * 24;

    return ChapterDefinition(
      id: chapterNumber,
      title: 'Capitulo $chapterNumber',
      subtitle: _chapterSubtitle(chapterBlock, chapterNumber),
      themeColor: chapterColor,
      unlockStarsRequired: unlockStars,
    );
  }, growable: false);
}

List<SubjectSummary> _buildSampleSubjects() {
  return <SubjectSummary>[
    SubjectSummary(
      title: 'Fundamentos em cadeia',
      badge: 'Capitulos 1 a 8',
      progress: 0.18,
      color: sampleChapters[0].themeColor,
    ),
    SubjectSummary(
      title: 'Fracoes, taxas e leitura rapida',
      badge: 'Capitulos 9 a 16',
      progress: 0.08,
      color: sampleChapters[9].themeColor,
    ),
    SubjectSummary(
      title: 'Desafios finais e chefes',
      badge: 'Capitulos 17 a 25',
      progress: 0.02,
      color: sampleChapters[20].themeColor,
    ),
  ];
}

List<LevelDefinition> _buildSampleLevelDefinitions() {
  return List<LevelDefinition>.generate(totalCampaignLevels, (index) {
    final levelId = index + 1;
    final chapterId = (index ~/ levelsPerChapter) + 1;
    final levelInChapter = (index % levelsPerChapter) + 1;
    final chapter = sampleChapters[chapterId - 1];
    final isBoss = levelInChapter == levelsPerChapter;
    final difficultyTier = 1 + ((chapterId - 1) * 2) + ((levelInChapter - 1) ~/ 5);
    final focusTopics = _topicsForLevel(chapterId, levelInChapter);
    final modifiers = _buildPhaseModifiers(
      chapterId: chapterId,
      levelInChapter: levelInChapter,
      isBoss: isBoss,
    );
    final totalQuestions = math.min(18, 8 + ((chapterId - 1) ~/ 3) + (levelInChapter ~/ 4));
    final durationInSeconds = math.max(
      42,
      92 - chapterId - (levelInChapter * 2) + (isBoss ? -4 : 0),
    );
    final targetScore =
        920 + (levelId * 22) + (chapterId * 36) + (levelInChapter * 10) + (isBoss ? 260 : 0);
    final unlockStarsRequired =
        chapter.unlockStarsRequired + (((levelInChapter - 1) ~/ 4) * 6);
    final baseScorePerHit = 104 + (difficultyTier * 5) + (isBoss ? 12 : 0);
    final scorePenaltyOnMiss = 18 + (difficultyTier * 3) + (isBoss ? 10 : 0);
    final timePenaltyOnMiss = math.min(11, 3 + ((difficultyTier - 1) ~/ 2) + (isBoss ? 1 : 0));
    final speedBonusMultiplier = 4 + ((difficultyTier - 1) % 5) + (isBoss ? 1 : 0);
    final comboScoreMultiplier = 12 + (difficultyTier * 2) + (levelInChapter >= 14 ? 4 : 0);

    return LevelDefinition(
      id: levelId,
      chapterId: chapterId,
      title: _levelTitle(chapterId, levelInChapter, isBoss),
      description: _levelDescription(chapterId, levelInChapter, focusTopics, isBoss),
      targetScore: targetScore,
      durationInSeconds: durationInSeconds,
      totalQuestions: totalQuestions,
      ruleSummary: _levelRuleSummary(
        chapterId: chapterId,
        levelInChapter: levelInChapter,
        focusTopics: focusTopics,
        isBoss: isBoss,
        modifiers: modifiers,
      ),
      focusTopics: focusTopics,
      secondaryObjectives: _buildSecondaryObjectives(
        levelId: levelId,
        chapterId: chapterId,
        levelInChapter: levelInChapter,
        durationInSeconds: durationInSeconds,
        totalQuestions: totalQuestions,
        isBoss: isBoss,
      ),
      modifiers: modifiers,
      difficultyTier: difficultyTier,
      unlockStarsRequired: unlockStarsRequired,
      baseScorePerHit: baseScorePerHit,
      scorePenaltyOnMiss: scorePenaltyOnMiss,
      timePenaltyOnMiss: timePenaltyOnMiss,
      speedBonusMultiplier:
          speedBonusMultiplier + (modifiers.any((modifier) => modifier.type == PhaseModifierType.lightning) ? 3 : 0),
      comboScoreMultiplier:
          comboScoreMultiplier + (modifiers.any((modifier) => modifier.type == PhaseModifierType.comboSurge) ? 8 : 0),
      extraSecondsOnCorrect:
          modifiers.any((modifier) => modifier.type == PhaseModifierType.recovery) ? 2 : 0,
      scoreGainMultiplier:
          modifiers.any((modifier) => modifier.type == PhaseModifierType.jackpot) ? 1.2 : 1.0,
      maxWrongAnswers:
          modifiers.any((modifier) => modifier.type == PhaseModifierType.precision) ? 2 : null,
      pauseEnabled: !isBoss && levelInChapter % 9 != 0,
      isBoss: isBoss,
    );
  }, growable: false);
}

String _chapterSubtitle(int chapterBlock, int chapterNumber) {
  return switch (chapterBlock) {
    0 => 'Base de calculo mental, velocidade e consistencia do capitulo $chapterNumber.',
    1 => 'Multiplicacao, divisao e operacoes mistas sob pressao crescente.',
    2 => 'Fracoes, porcentagem e leitura rapida de situacoes numericas.',
    3 => 'Equacoes, sequencias e padroes com menos tempo por rodada.',
    _ => 'Capitulos finais com mistura total de topicos e chefes mais exigentes.',
  };
}

List<MathTopic> _topicsForLevel(int chapterId, int levelInChapter) {
  final chapterBlock = (chapterId - 1) ~/ 4;

  switch (chapterBlock) {
    case 0:
      if (levelInChapter <= 6) {
        return const <MathTopic>[MathTopic.addition, MathTopic.subtraction];
      }
      if (levelInChapter <= 13) {
        return const <MathTopic>[
          MathTopic.addition,
          MathTopic.subtraction,
          MathTopic.multiplication,
        ];
      }
      return const <MathTopic>[
        MathTopic.addition,
        MathTopic.subtraction,
        MathTopic.multiplication,
        MathTopic.division,
      ];
    case 1:
      if (levelInChapter <= 7) {
        return const <MathTopic>[
          MathTopic.multiplication,
          MathTopic.division,
        ];
      }
      return const <MathTopic>[
        MathTopic.multiplication,
        MathTopic.division,
        MathTopic.mixedOperations,
      ];
    case 2:
      if (levelInChapter <= 8) {
        return const <MathTopic>[
          MathTopic.fractions,
          MathTopic.percentages,
          MathTopic.division,
        ];
      }
      return const <MathTopic>[
        MathTopic.fractions,
        MathTopic.percentages,
        MathTopic.mixedOperations,
      ];
    case 3:
      if (levelInChapter <= 8) {
        return const <MathTopic>[
          MathTopic.equations,
          MathTopic.sequences,
          MathTopic.multiplication,
        ];
      }
      return const <MathTopic>[
        MathTopic.equations,
        MathTopic.sequences,
        MathTopic.powers,
        MathTopic.mixedOperations,
      ];
    case 4:
      return const <MathTopic>[
        MathTopic.powers,
        MathTopic.percentages,
        MathTopic.fractions,
        MathTopic.equations,
      ];
    default:
      return const <MathTopic>[
        MathTopic.addition,
        MathTopic.subtraction,
        MathTopic.multiplication,
        MathTopic.division,
        MathTopic.mixedOperations,
        MathTopic.fractions,
        MathTopic.percentages,
        MathTopic.powers,
        MathTopic.equations,
        MathTopic.sequences,
      ];
  }
}

String _levelTitle(int chapterId, int levelInChapter, bool isBoss) {
  if (chapterId == 1 && levelInChapter == 1) {
    return 'Aquecimento';
  }

  if (isBoss) {
    return 'Chefe do capitulo';
  }

  const titles = <String>[
    'Ritmo inicial',
    'Combos curtos',
    'Pressao leve',
    'Janela rapida',
    'Mistura guiada',
    'Curva de foco',
    'Leitura tatica',
    'Cadencia alta',
    'Operacao dupla',
    'Resposta limpa',
    'Sinal trocado',
    'Pressao crescente',
    'Controle fino',
    'Fase turbo',
    'Leitura relampago',
    'Passo firme',
    'Virada de ritmo',
    'Escalada final',
    'Pre-boss',
  ];

  final safeIndex = math.max(0, math.min(titles.length - 1, levelInChapter - 2));
  return titles[safeIndex];
}

String _levelDescription(
  int chapterId,
  int levelInChapter,
  List<MathTopic> focusTopics,
  bool isBoss,
) {
  final topicNames = focusTopics.take(3).map((topic) => topic.label).join(', ');
  if (isBoss) {
    return 'Rodada especial do capitulo $chapterId com mistura mais dura de $topicNames e alvo alto de score.';
  }
  return 'Fase $levelInChapter do capitulo $chapterId focada em $topicNames, com dificuldade crescente e menos margem para erros.';
}

String _levelRuleSummary({
  required int chapterId,
  required int levelInChapter,
  required List<MathTopic> focusTopics,
  required bool isBoss,
  required List<PhaseModifierDefinition> modifiers,
}) {
  final firstTopic = focusTopics.first.label;
  if (isBoss) {
    return 'Modo chefe: sem pausa facil, pressao alta e rotacao completa de topicos como $firstTopic.';
  }
  if (modifiers.isNotEmpty) {
    final modifierLabel = modifiers.first.title.toLowerCase();
    return 'Fase com $modifierLabel, foco em $firstTopic e leitura mais variada ao longo da rodada.';
  }
  if (levelInChapter <= 5) {
    return 'Construa ritmo e precision com foco em $firstTopic e penalidade controlada por erro.';
  }
  if (levelInChapter <= 12) {
    return 'A fase premia velocidade e comeca a punir respostas erradas com mais forca.';
  }
  return 'Controle de combo, leitura rapida e transicao constante entre topicos do capitulo $chapterId.';
}

List<PhaseModifierDefinition> _buildPhaseModifiers({
  required int chapterId,
  required int levelInChapter,
  required bool isBoss,
}) {
  if (isBoss) {
    return const <PhaseModifierDefinition>[
      PhaseModifierDefinition(
        type: PhaseModifierType.precision,
        title: 'Chefe sem margem',
        description: 'Poucos erros sao permitidos nesta rodada de chefe.',
        icon: Icons.gpp_good_rounded,
        color: Color(0xFFFF7B54),
      ),
      PhaseModifierDefinition(
        type: PhaseModifierType.comboSurge,
        title: 'Combo do chefe',
        description: 'A fase premia sequencias longas para escalar o score.',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFFB703),
      ),
    ];
  }

  final modifiers = <PhaseModifierDefinition>[];

  if (levelInChapter % 5 == 0) {
    modifiers.add(
      const PhaseModifierDefinition(
        type: PhaseModifierType.lightning,
        title: 'Fase relampago',
        description: 'A velocidade rende mais pontos e muda o ritmo da rodada.',
        icon: Icons.bolt_rounded,
        color: Color(0xFFFF7B54),
      ),
    );
  }
  if (levelInChapter % 4 == 0) {
    modifiers.add(
      const PhaseModifierDefinition(
        type: PhaseModifierType.comboSurge,
        title: 'Combo em dobro',
        description: 'O multiplicador de combo fica mais forte nesta fase.',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFFB703),
      ),
    );
  }
  if (levelInChapter % 6 == 0) {
    modifiers.add(
      const PhaseModifierDefinition(
        type: PhaseModifierType.recovery,
        title: 'Folego extra',
        description: 'Cada acerto devolve tempo e sustenta a corrida.',
        icon: Icons.favorite_rounded,
        color: Color(0xFF13C4A3),
      ),
    );
  }
  if (levelInChapter % 7 == 0) {
    modifiers.add(
      const PhaseModifierDefinition(
        type: PhaseModifierType.precision,
        title: 'Janela de precisao',
        description: 'A fase aceita poucos erros antes de encerrar.',
        icon: Icons.gps_fixed_rounded,
        color: Color(0xFF2D55FF),
      ),
    );
  }
  if (chapterId % 3 == 0 && levelInChapter.isEven) {
    modifiers.add(
      const PhaseModifierDefinition(
        type: PhaseModifierType.jackpot,
        title: 'Fase bonus',
        description: 'Os pontos desta fase rendem mais do que o normal.',
        icon: Icons.redeem_rounded,
        color: Color(0xFF8E5CFF),
      ),
    );
  }

  if (modifiers.length > 2) {
    return modifiers.take(2).toList(growable: false);
  }
  return modifiers;
}

List<SecondaryObjectiveDefinition> _buildSecondaryObjectives({
  required int levelId,
  required int chapterId,
  required int levelInChapter,
  required int durationInSeconds,
  required int totalQuestions,
  required bool isBoss,
}) {
  final comboTarget = math.min(10, 3 + ((chapterId - 1) ~/ 3) + ((levelInChapter - 1) ~/ 6));
  final correctTarget = math.min(totalQuestions, math.max(4, totalQuestions - 2));
  final timeTarget = math.max(8, durationInSeconds ~/ 4);

  if (isBoss) {
    return <SecondaryObjectiveDefinition>[
      SecondaryObjectiveDefinition(
        id: 'boss_clean_$levelId',
        title: 'Execucao limpa',
        description: 'Conclua o chefe sem nenhum erro.',
        type: SecondaryObjectiveType.noMistakes,
        targetValue: 0,
      ),
      SecondaryObjectiveDefinition(
        id: 'boss_combo_$levelId',
        title: 'Combo de elite',
        description: 'Atinga combo x$comboTarget durante o chefe.',
        type: SecondaryObjectiveType.reachCombo,
        targetValue: comboTarget,
      ),
    ];
  }

  return <SecondaryObjectiveDefinition>[
    SecondaryObjectiveDefinition(
      id: 'combo_$levelId',
      title: 'Combo x$comboTarget',
      description: 'Atinga ao menos combo x$comboTarget em algum momento da fase.',
      type: SecondaryObjectiveType.reachCombo,
      targetValue: comboTarget,
    ),
    SecondaryObjectiveDefinition(
      id: 'correct_$levelId',
      title: '$correctTarget acertos',
      description: 'Chegue a pelo menos $correctTarget respostas corretas nesta rodada.',
      type: SecondaryObjectiveType.correctAnswersAtLeast,
      targetValue: correctTarget,
    ),
    if (levelInChapter % 3 == 0)
      SecondaryObjectiveDefinition(
        id: 'time_$levelId',
        title: 'Sobrar $timeTarget s',
        description: 'Finalize a fase com pelo menos $timeTarget segundos no cronometro.',
        type: SecondaryObjectiveType.finishWithTimeLeft,
        targetValue: timeTarget,
      )
    else
      SecondaryObjectiveDefinition(
        id: 'clean_$levelId',
        title: 'Sem erro',
        description: 'Conclua a fase sem respostas erradas.',
        type: SecondaryObjectiveType.noMistakes,
        targetValue: 0,
      ),
  ];
}
