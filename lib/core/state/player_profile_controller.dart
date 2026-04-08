import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/event_data.dart';
import '../data/math_topics.dart';
import '../data/sample_data.dart';
import '../data/shop_data.dart';

class SessionState {
  const SessionState({
    required this.completedOnboarding,
    required this.signedIn,
    required this.provider,
    required this.displayName,
  });

  final bool completedOnboarding;
  final bool signedIn;
  final String provider;
  final String displayName;
}

class MissionView {
  const MissionView({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.rewardCoins,
    required this.claimed,
    required this.cadence,
  });

  final String id;
  final String title;
  final String description;
  final int progress;
  final int target;
  final int rewardCoins;
  final bool claimed;
  final String cadence;

  bool get completed => progress >= target;
  double get progressRatio => (progress / target).clamp(0.0, 1.0);
}

class RankingEntryView {
  const RankingEntryView({
    required this.name,
    required this.score,
    required this.subtitle,
    required this.isPlayer,
  });

  final String name;
  final int score;
  final String subtitle;
  final bool isPlayer;
}

class RewardBundle {
  const RewardBundle({
    required this.coins,
    required this.xp,
  });

  final int coins;
  final int xp;
}

enum CalendarEntryState {
  claimed,
  current,
  locked,
}

class LoginCalendarEntry {
  const LoginCalendarEntry({
    required this.dayNumber,
    required this.rewardCoins,
    required this.state,
  });

  final int dayNumber;
  final int rewardCoins;
  final CalendarEntryState state;
}

class MistakeReviewEntry {
  const MistakeReviewEntry({
    required this.topic,
    required this.prompt,
    required this.explanation,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.difficultyLabel,
    required this.createdAt,
  });

  final MathTopic topic;
  final String prompt;
  final String explanation;
  final int correctAnswer;
  final int? selectedAnswer;
  final String difficultyLabel;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'topic': topic.name,
      'prompt': prompt,
      'explanation': explanation,
      'correctAnswer': correctAnswer,
      'selectedAnswer': selectedAnswer,
      'difficultyLabel': difficultyLabel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MistakeReviewEntry? fromJson(Map<String, dynamic> json) {
    final topicName = json['topic'] as String?;
    final prompt = json['prompt'] as String?;
    final explanation = json['explanation'] as String?;
    final correctAnswer = json['correctAnswer'] as int?;
    final difficultyLabel = json['difficultyLabel'] as String?;
    final createdAtRaw = json['createdAt'] as String?;
    if (topicName == null ||
        prompt == null ||
        explanation == null ||
        correctAnswer == null ||
        difficultyLabel == null ||
        createdAtRaw == null) {
      return null;
    }

    MathTopic? topic;
    for (final value in MathTopic.values) {
      if (value.name == topicName) {
        topic = value;
        break;
      }
    }
    if (topic == null) {
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) {
      return null;
    }

    return MistakeReviewEntry(
      topic: topic,
      prompt: prompt,
      explanation: explanation,
      correctAnswer: correctAnswer,
      selectedAnswer: json['selectedAnswer'] as int?,
      difficultyLabel: difficultyLabel,
      createdAt: createdAt,
    );
  }
}

class TopicPerformanceView {
  const TopicPerformanceView({
    required this.topic,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  final MathTopic topic;
  final int correctAnswers;
  final int wrongAnswers;

  int get totalAttempts => correctAnswers + wrongAnswers;
  double get accuracyRatio => totalAttempts == 0 ? 0 : correctAnswers / totalAttempts;
  String get recommendationLabel {
    if (totalAttempts == 0) {
      return 'Novo';
    }
    if (accuracyRatio < 0.45) {
      return 'Treinar urgente';
    }
    if (accuracyRatio < 0.7) {
      return 'Precisa de reforco';
    }
    return 'Bom ritmo';
  }
}

class AchievementView {
  const AchievementView({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.progressLabel,
  });

  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final String progressLabel;
}

class PlayerTitleView {
  const PlayerTitleView({
    required this.id,
    required this.label,
    required this.description,
    required this.unlocked,
    required this.equipped,
  });

  final String id;
  final String label;
  final String description;
  final bool unlocked;
  final bool equipped;
}

class LevelMilestoneRewardView {
  const LevelMilestoneRewardView({
    required this.level,
    required this.coins,
    required this.focusBoosters,
    required this.freezeBoosters,
    required this.claimed,
    required this.available,
  });

  final int level;
  final int coins;
  final int focusBoosters;
  final int freezeBoosters;
  final bool claimed;
  final bool available;
}

class MatchReplayView {
  const MatchReplayView({
    required this.sessionLabel,
    required this.modeLabel,
    required this.score,
    required this.starsEarned,
    required this.bestCombo,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.createdAt,
    required this.topicLabels,
  });

  final String sessionLabel;
  final String modeLabel;
  final int score;
  final int starsEarned;
  final int bestCombo;
  final int correctAnswers;
  final int wrongAnswers;
  final DateTime createdAt;
  final List<String> topicLabels;

  String get replaySummary =>
      '$correctAnswers acertos, $wrongAnswers erros e combo x$bestCombo';

  Map<String, dynamic> toJson() {
    return {
      'sessionLabel': sessionLabel,
      'modeLabel': modeLabel,
      'score': score,
      'starsEarned': starsEarned,
      'bestCombo': bestCombo,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'createdAt': createdAt.toIso8601String(),
      'topicLabels': topicLabels,
    };
  }

  static MatchReplayView? fromJson(Map<String, dynamic> json) {
    final sessionLabel = json['sessionLabel'] as String?;
    final modeLabel = json['modeLabel'] as String?;
    final score = json['score'] as int?;
    final starsEarned = json['starsEarned'] as int?;
    final bestCombo = json['bestCombo'] as int?;
    final correctAnswers = json['correctAnswers'] as int?;
    final wrongAnswers = json['wrongAnswers'] as int?;
    final createdAtRaw = json['createdAt'] as String?;
    if (sessionLabel == null ||
        modeLabel == null ||
        score == null ||
        starsEarned == null ||
        bestCombo == null ||
        correctAnswers == null ||
        wrongAnswers == null ||
        createdAtRaw == null) {
      return null;
    }
    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) {
      return null;
    }
    return MatchReplayView(
      sessionLabel: sessionLabel,
      modeLabel: modeLabel,
      score: score,
      starsEarned: starsEarned,
      bestCombo: bestCombo,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      createdAt: createdAt,
      topicLabels: ((json['topicLabels'] as List<dynamic>? ?? const <dynamic>[]))
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class WeeklyComparisonView {
  const WeeklyComparisonView({
    required this.playerScore,
    required this.previousScore,
    required this.delta,
    required this.trendLabel,
  });

  final int playerScore;
  final int previousScore;
  final int delta;
  final String trendLabel;
}

class SeasonMissionView {
  const SeasonMissionView({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.rewardCoins,
    required this.claimed,
  });

  final String id;
  final String title;
  final String description;
  final int progress;
  final int target;
  final int rewardCoins;
  final bool claimed;

  bool get completed => progress >= target;
  double get progressRatio => (progress / target).clamp(0.0, 1.0);
}

class PlayerProfileController extends ChangeNotifier {
  PlayerProfileController._();

  static final PlayerProfileController instance = PlayerProfileController._();

  static const _storageKey = 'matetic_player_profile_v1';
  static const List<int> _levelMilestoneSteps = <int>[2, 5, 8, 10, 15, 20];

  static const Map<String, String> _titleLabels = <String, String>{
    'rookie': 'Rookie do Mapa',
    'combo': 'Cadete do Combo',
    'strategist': 'Estrategista',
    'perfect': 'Sem Falhas',
    'training': 'Mentor do Treino',
    'legend': 'Lenda do Calculo',
  };

  static const Map<String, String> _titleDescriptions = <String, String>{
    'rookie': 'Titulo inicial para quem acabou de entrar na trilha.',
    'combo': 'Liberado ao dominar sequencias longas de acertos.',
    'strategist': 'Liberado por consistencia em muitas partidas.',
    'perfect': 'Liberado por execucoes perfeitas em fases reais.',
    'training': 'Liberado para quem usa o treino guiado com frequencia.',
    'legend': 'Liberado ao alcancar um nivel alto da conta.',
  };

  bool _completedOnboarding = false;
  bool _signedIn = false;
  String _provider = 'guest';
  String _displayName = 'Jogador';
  int _coins = 320;
  int _xp = 0;
  String _avatarId = defaultAvatarId;
  String _themeId = defaultThemeId;
  String _frameId = defaultFrameId;
  String _effectId = defaultEffectId;
  String _mascotId = defaultMascotId;
  final Set<String> _ownedItemIds = <String>{
    defaultAvatarId,
    defaultThemeId,
    defaultFrameId,
    defaultEffectId,
    defaultMascotId,
  };
  final Map<String, int> _boosterInventory = <String, int>{
    'booster_freeze': 1,
  };

  int _totalMatches = 0;
  int _totalCorrectAnswers = 0;
  int _totalWrongAnswers = 0;
  int _bestCombo = 0;
  int _bestScore = 0;
  int _highestStarsEarned = 0;
  int _totalPerfectRuns = 0;
  int _totalTrainingRuns = 0;
  final Map<String, int> _topicCorrectAnswers = <String, int>{};
  final Map<String, int> _topicWrongAnswers = <String, int>{};
  final List<MistakeReviewEntry> _recentMistakes = <MistakeReviewEntry>[];
  final List<MatchReplayView> _recentReplays = <MatchReplayView>[];
  String _activeTitleId = 'rookie';
  final Set<int> _claimedLevelMilestones = <int>{};
  String _seasonEventId = currentSeasonEvent.id;
  int _seasonEventRuns = 0;
  int _seasonEventWins = 0;
  int _seasonEventBossWins = 0;
  final Set<String> _claimedSeasonMissionIds = <String>{};
  final Set<String> _claimedSeasonRewardIds = <String>{};
  final Set<String> _completedEventChallengeIds = <String>{};

  String? _dailyRewardDate;
  String? _lastSessionDate;
  String? _lastChestClaimDate;
  int _dailyStreak = 0;
  int _currentVictoryStreak = 0;
  int _claimedVictoryChestMilestone = 0;
  int _dailyPerfectRuns = 0;
  int _dailyWinningRuns = 0;
  int _dailyTrainingRuns = 0;
  String _sessionWelcomeMessage = '';
  String _dailyMissionDate = '';
  int _dailyLevelsPlayed = 0;
  int _dailyStarsEarned = 0;
  int _dailyBestCombo = 0;
  final Set<String> _dailyClaimedMissionIds = <String>{};

  String _weeklyMissionDate = '';
  int _weeklyLevelsPlayed = 0;
  int _weeklyStarsEarned = 0;
  final Set<String> _weeklyClaimedMissionIds = <String>{};

  bool _soundEnabled = true;
  bool _reducedMotion = false;
  bool _highContrast = false;
  bool _largeText = false;
  bool _untimedTraining = false;

  SessionState get session => SessionState(
        completedOnboarding: _completedOnboarding,
        signedIn: _signedIn,
        provider: _provider,
        displayName: _displayName,
      );

  int get coins => _coins;
  int get xp => _xp;
  int get level => (_xp ~/ 450) + 1;
  int get xpIntoCurrentLevel => _xp % 450;
  String get displayName => _displayName;
  String get provider => _provider;
  String get avatarId => _avatarId;
  String get themeId => _themeId;
  String get frameId => _frameId;
  String get effectId => _effectId;
  String get mascotId => _mascotId;
  int get totalMatches => _totalMatches;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalWrongAnswers => _totalWrongAnswers;
  int get bestCombo => _bestCombo;
  int get bestScore => _bestScore;
  int get highestStarsEarned => _highestStarsEarned;
  int get totalPerfectRuns => _totalPerfectRuns;
  int get totalTrainingRuns => _totalTrainingRuns;
  int get dailyStreak => _dailyStreak;
  int get currentVictoryStreak => _currentVictoryStreak;
  int get seasonEventRuns => _seasonEventRuns;
  int get seasonEventWins => _seasonEventWins;
  int get seasonEventBossWins => _seasonEventBossWins;
  bool get soundEnabled => _soundEnabled;
  bool get reducedMotion => _reducedMotion;
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get untimedTraining => _untimedTraining;
  double get textScaleFactor => _largeText ? 1.12 : 1.0;
  bool get dailyRewardAvailable => _dailyRewardDate != _dayKey(DateTime.now());
  int get dailyRewardPreviewCoins => 60 + (dailyRewardAvailable ? _dailyStreak * 10 : 0);
  String get sessionWelcomeMessage => _sessionWelcomeMessage;
  int get seasonPassTier => (_xp ~/ 300) + 1;
  int get seasonPassProgress => _xp % 300;
  double get seasonPassProgressRatio => seasonPassProgress / 300;
  bool get trainingChestAvailable =>
      _dailyLevelsPlayed >= 3 && _lastChestClaimDate != _dayKey(DateTime.now());
  bool get victoryChestAvailable =>
      (_currentVictoryStreak ~/ 3) > _claimedVictoryChestMilestone;

  double get levelProgress => xpIntoCurrentLevel / 450;
  String get activeTitleLabel => _titleLabels[_activeTitleId] ?? _titleLabels['rookie']!;
  String get activeTitleDescription =>
      _titleDescriptions[_activeTitleId] ?? _titleDescriptions['rookie']!;
  int get unlockedAchievementsCount => achievements.where((achievement) => achievement.unlocked).length;
  int get availableLevelMilestoneRewardsCount =>
      levelMilestoneRewards.where((reward) => reward.available && !reward.claimed).length;
  List<MistakeReviewEntry> get recentMistakes => List<MistakeReviewEntry>.unmodifiable(_recentMistakes);
  List<MatchReplayView> get recentReplays => List<MatchReplayView>.unmodifiable(_recentReplays);
  WeeklyComparisonView get weeklyComparison {
    final playerScore = (_weeklyStarsEarned * 120) + (_weeklyLevelsPlayed * 70);
    final previousScore = (_totalMatches * 42) + (_bestCombo * 18);
    final delta = playerScore - previousScore;
    final trendLabel = delta >= 0 ? 'Subindo nesta semana' : 'Semana abaixo do seu ritmo';
    return WeeklyComparisonView(
      playerScore: playerScore,
      previousScore: previousScore,
      delta: delta,
      trendLabel: trendLabel,
    );
  }
  SeasonEventDefinition get currentSeason => currentSeasonEvent;
  bool get isWeekendEventWindow {
    final weekday = DateTime.now().weekday;
    return weekday == DateTime.friday ||
        weekday == DateTime.saturday ||
        weekday == DateTime.sunday;
  }
  double get seasonProgressRatio {
    final target = currentSeason.rewards.last.requiredWins;
    return (_seasonEventWins / target).clamp(0.0, 1.0);
  }
  List<SeasonMissionView> get seasonMissions {
    return <SeasonMissionView>[
      SeasonMissionView(
        id: 'season_runs',
        title: 'Rodar 3 portais',
        description: 'Participe de 3 corridas da temporada.',
        progress: _seasonEventRuns,
        target: 3,
        rewardCoins: 140,
        claimed: _claimedSeasonMissionIds.contains('season_runs'),
      ),
      SeasonMissionView(
        id: 'season_wins',
        title: 'Ganhar 2 portais',
        description: 'Venca 2 desafios sazonais para reforcar o progresso.',
        progress: _seasonEventWins,
        target: 2,
        rewardCoins: 180,
        claimed: _claimedSeasonMissionIds.contains('season_wins'),
      ),
      SeasonMissionView(
        id: 'season_boss',
        title: 'Derrubar o chefe',
        description: 'Conclua o portal final da temporada ao menos uma vez.',
        progress: _seasonEventBossWins,
        target: 1,
        rewardCoins: 220,
        claimed: _claimedSeasonMissionIds.contains('season_boss'),
      ),
    ];
  }

  List<LoginCalendarEntry> get loginCalendar {
    final todayClaimed = !dailyRewardAvailable;
    final currentDay = todayClaimed
        ? _clampInt(_dailyStreak, 1, 7)
        : _clampInt(_dailyStreak + 1, 1, 7);

    return List<LoginCalendarEntry>.generate(7, (index) {
      final dayNumber = index + 1;
      final reward = 60 + (index * 10);
      final state = todayClaimed && dayNumber <= currentDay
          ? CalendarEntryState.claimed
          : (!todayClaimed && dayNumber == currentDay)
              ? CalendarEntryState.current
              : CalendarEntryState.locked;

      return LoginCalendarEntry(
        dayNumber: dayNumber,
        rewardCoins: reward,
        state: state,
      );
    }, growable: false);
  }

  List<TopicPerformanceView> get topicPerformance {
    return MathTopic.values
        .map(
          (topic) => TopicPerformanceView(
            topic: topic,
            correctAnswers: _topicCorrectAnswers[topic.name] ?? 0,
            wrongAnswers: _topicWrongAnswers[topic.name] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  List<TopicPerformanceView> get weakestTopics {
    final attempted = topicPerformance.where((topic) => topic.totalAttempts > 0).toList();
    attempted.sort((a, b) {
      final accuracyCompare = a.accuracyRatio.compareTo(b.accuracyRatio);
      if (accuracyCompare != 0) {
        return accuracyCompare;
      }
      return b.totalAttempts.compareTo(a.totalAttempts);
    });
    return attempted.take(3).toList(growable: false);
  }

  TopicPerformanceView get recommendedTrainingTopic {
    final weakest = weakestTopics;
    if (weakest.isNotEmpty) {
      return weakest.first;
    }
    return topicPerformance.first;
  }

  List<AchievementView> get achievements {
    return <AchievementView>[
      AchievementView(
        id: 'first_win',
        title: 'Primeira vitoria',
        description: 'Conclua a primeira fase valendo estrela no mapa.',
        unlocked: _totalMatches >= 1 && _highestStarsEarned > 0,
        progressLabel: '${_totalMatches.clamp(0, 1)}/1 fase concluida',
      ),
      AchievementView(
        id: 'combo_8',
        title: 'Combo em chamas',
        description: 'Atinga combo x8 em qualquer partida.',
        unlocked: _bestCombo >= 8,
        progressLabel: 'Melhor combo: x$_bestCombo / x8',
      ),
      AchievementView(
        id: 'perfect_5',
        title: 'Execucao precisa',
        description: 'Some 5 fases perfeitas sem erros e com 3 estrelas.',
        unlocked: _totalPerfectRuns >= 5,
        progressLabel: 'Fases perfeitas: $_totalPerfectRuns / 5',
      ),
      AchievementView(
        id: 'training_8',
        title: 'Rotina de treino',
        description: 'Complete 8 sessoes de treino guiado.',
        unlocked: _totalTrainingRuns >= 8,
        progressLabel: 'Treinos concluidos: $_totalTrainingRuns / 8',
      ),
      AchievementView(
        id: 'level_10',
        title: 'Conta em ascensao',
        description: 'Alcance o nivel 10 da conta.',
        unlocked: level >= 10,
        progressLabel: 'Nivel atual: $level / 10',
      ),
      AchievementView(
        id: 'streak_7',
        title: 'Sete dias seguidos',
        description: 'Mantenha um streak diario de 7 dias.',
        unlocked: _dailyStreak >= 7,
        progressLabel: 'Streak atual: $_dailyStreak / 7',
      ),
    ];
  }

  List<PlayerTitleView> get titles {
    final unlockedIds = <String>{
      'rookie',
      if (_bestCombo >= 6) 'combo',
      if (_totalMatches >= 18) 'strategist',
      if (_totalPerfectRuns >= 3) 'perfect',
      if (_totalTrainingRuns >= 6) 'training',
      if (level >= 10) 'legend',
    };

    return _titleLabels.entries
        .map(
          (entry) => PlayerTitleView(
            id: entry.key,
            label: entry.value,
            description: _titleDescriptions[entry.key] ?? '',
            unlocked: unlockedIds.contains(entry.key),
            equipped: _activeTitleId == entry.key,
          ),
        )
        .toList(growable: false);
  }

  List<LevelMilestoneRewardView> get levelMilestoneRewards {
    return _levelMilestoneSteps
        .map(
          (milestone) => LevelMilestoneRewardView(
            level: milestone,
            coins: 90 + (milestone * 18),
            focusBoosters: milestone >= 8 ? 1 : 0,
            freezeBoosters: milestone >= 5 ? 1 : 0,
            claimed: _claimedLevelMilestones.contains(milestone),
            available: level >= milestone,
          ),
        )
        .toList(growable: false);
  }

  bool isSeasonRewardClaimed(String rewardId) => _claimedSeasonRewardIds.contains(rewardId);

  bool isEventChallengeCompleted(String challengeId) =>
      _completedEventChallengeIds.contains(challengeId);

  bool isEventChallengeUnlocked(String challengeId) {
    final challenges = currentSeason.bonusChapter;
    final index = challenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index < 0) {
      return false;
    }
    if (index == 0) {
      return true;
    }
    return _completedEventChallengeIds.contains(challenges[index - 1].id);
  }

  RewardBundle previewRewardForRun({
    required int starsEarned,
    required int objectivesCompleted,
  }) {
    return RewardBundle(
      xp: 80 + (starsEarned * 35) + (objectivesCompleted * 20),
      coins: 30 + (starsEarned * 15) + (objectivesCompleted * 10),
    );
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _completedOnboarding = json['completedOnboarding'] as bool? ?? false;
      _signedIn = json['signedIn'] as bool? ?? false;
      _provider = json['provider'] as String? ?? 'guest';
      _displayName = json['displayName'] as String? ?? 'Jogador';
      _coins = json['coins'] as int? ?? 320;
      _xp = json['xp'] as int? ?? 0;
      _avatarId = json['avatarId'] as String? ?? defaultAvatarId;
      _themeId = json['themeId'] as String? ?? defaultThemeId;
      _frameId = json['frameId'] as String? ?? defaultFrameId;
      _effectId = json['effectId'] as String? ?? defaultEffectId;
      _mascotId = json['mascotId'] as String? ?? defaultMascotId;
      _totalMatches = json['totalMatches'] as int? ?? 0;
      _totalCorrectAnswers = json['totalCorrectAnswers'] as int? ?? 0;
      _totalWrongAnswers = json['totalWrongAnswers'] as int? ?? 0;
      _bestCombo = json['bestCombo'] as int? ?? 0;
      _bestScore = json['bestScore'] as int? ?? 0;
      _highestStarsEarned = json['highestStarsEarned'] as int? ?? 0;
      _totalPerfectRuns = json['totalPerfectRuns'] as int? ?? 0;
      _totalTrainingRuns = json['totalTrainingRuns'] as int? ?? 0;
      _activeTitleId = json['activeTitleId'] as String? ?? 'rookie';
      _seasonEventId = json['seasonEventId'] as String? ?? currentSeasonEvent.id;
      _seasonEventRuns = json['seasonEventRuns'] as int? ?? 0;
      _seasonEventWins = json['seasonEventWins'] as int? ?? 0;
      _seasonEventBossWins = json['seasonEventBossWins'] as int? ?? 0;
      _dailyRewardDate = json['dailyRewardDate'] as String?;
      _lastSessionDate = json['lastSessionDate'] as String?;
      _lastChestClaimDate = json['lastChestClaimDate'] as String?;
      _dailyStreak = json['dailyStreak'] as int? ?? 0;
      _currentVictoryStreak = json['currentVictoryStreak'] as int? ?? 0;
      _claimedVictoryChestMilestone = json['claimedVictoryChestMilestone'] as int? ?? 0;
      _dailyPerfectRuns = json['dailyPerfectRuns'] as int? ?? 0;
      _dailyWinningRuns = json['dailyWinningRuns'] as int? ?? 0;
      _dailyTrainingRuns = json['dailyTrainingRuns'] as int? ?? 0;
      _sessionWelcomeMessage = json['sessionWelcomeMessage'] as String? ?? '';
      _dailyMissionDate = json['dailyMissionDate'] as String? ?? '';
      _dailyLevelsPlayed = json['dailyLevelsPlayed'] as int? ?? 0;
      _dailyStarsEarned = json['dailyStarsEarned'] as int? ?? 0;
      _dailyBestCombo = json['dailyBestCombo'] as int? ?? 0;
      _weeklyMissionDate = json['weeklyMissionDate'] as String? ?? '';
      _weeklyLevelsPlayed = json['weeklyLevelsPlayed'] as int? ?? 0;
      _weeklyStarsEarned = json['weeklyStarsEarned'] as int? ?? 0;
      _soundEnabled = json['soundEnabled'] as bool? ?? true;
      _reducedMotion = json['reducedMotion'] as bool? ?? false;
      _highContrast = json['highContrast'] as bool? ?? false;
      _largeText = json['largeText'] as bool? ?? false;
      _untimedTraining = json['untimedTraining'] as bool? ?? false;

      _ownedItemIds
        ..clear()
        ..addAll(
          ((json['ownedItemIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
      _ownedItemIds.add(defaultAvatarId);
      _ownedItemIds.add(defaultThemeId);
      _ownedItemIds.add(defaultFrameId);
      _ownedItemIds.add(defaultEffectId);
      _ownedItemIds.add(defaultMascotId);

      _boosterInventory
        ..clear()
        ..addAll(
          (json['boosterInventory'] as Map<String, dynamic>? ?? const <String, dynamic>{})
              .map((key, value) => MapEntry(key, value as int)),
        );

      _topicCorrectAnswers
        ..clear()
        ..addAll(
          (json['topicCorrectAnswers'] as Map<String, dynamic>? ?? const <String, dynamic>{})
              .map((key, value) => MapEntry(key, value as int)),
        );
      _topicWrongAnswers
        ..clear()
        ..addAll(
          (json['topicWrongAnswers'] as Map<String, dynamic>? ?? const <String, dynamic>{})
              .map((key, value) => MapEntry(key, value as int)),
        );
      _recentMistakes
        ..clear()
        ..addAll(
          ((json['recentMistakes'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<Map>()
              .map((entry) => MistakeReviewEntry.fromJson(Map<String, dynamic>.from(entry)))
              .whereType<MistakeReviewEntry>(),
        );
      _recentReplays
        ..clear()
        ..addAll(
          ((json['recentReplays'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<Map>()
              .map((entry) => MatchReplayView.fromJson(Map<String, dynamic>.from(entry)))
              .whereType<MatchReplayView>(),
        );

      _dailyClaimedMissionIds
        ..clear()
        ..addAll(
          ((json['dailyClaimedMissionIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
      _weeklyClaimedMissionIds
        ..clear()
        ..addAll(
          ((json['weeklyClaimedMissionIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
      _claimedLevelMilestones
        ..clear()
        ..addAll(
          ((json['claimedLevelMilestones'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<int>(),
        );
      _claimedSeasonMissionIds
        ..clear()
        ..addAll(
          ((json['claimedSeasonMissionIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
      _claimedSeasonRewardIds
        ..clear()
        ..addAll(
          ((json['claimedSeasonRewardIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
      _completedEventChallengeIds
        ..clear()
        ..addAll(
          ((json['completedEventChallengeIds'] as List<dynamic>? ?? const <dynamic>[]))
              .whereType<String>(),
        );
    }

    _ensureSeasonWindow();
    _ensureMissionWindows();
    _normalizeActiveTitle();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _completedOnboarding = true;
    notifyListeners();
    await _persist();
  }

  Future<void> signInAsGuest({String? displayName}) async {
    _signedIn = true;
    _provider = 'visitante';
    _displayName = (displayName == null || displayName.trim().isEmpty)
        ? 'Jogador Visitante'
        : displayName.trim();
    refreshSessionPresence();
    notifyListeners();
    await _persist();
  }

  Future<void> signInWithGoogleMock() async {
    _signedIn = true;
    _provider = 'google';
    if (_displayName == 'Jogador' || _displayName == 'Jogador Visitante') {
      _displayName = 'Jogador Google';
    }
    refreshSessionPresence();
    notifyListeners();
    await _persist();
  }

  Future<void> signOut() async {
    _signedIn = false;
    _provider = 'guest';
    notifyListeners();
    await _persist();
  }

  Future<void> claimDailyReward() async {
    final today = _dayKey(DateTime.now());
    if (_dailyRewardDate == today) {
      return;
    }

    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    _dailyStreak = _dailyRewardDate == yesterday ? _dailyStreak + 1 : 1;
    _dailyRewardDate = today;
    _coins += 60 + ((_dailyStreak - 1) * 10);
    notifyListeners();
    await _persist();
  }

  Future<void> claimVictoryChest() async {
    if (!victoryChestAvailable) {
      return;
    }

    final currentMilestone = _currentVictoryStreak ~/ 3;
    _claimedVictoryChestMilestone = currentMilestone;
    _coins += 110 + (currentMilestone * 25);
    _boosterInventory['booster_freeze'] = (_boosterInventory['booster_freeze'] ?? 0) + 1;
    _boosterInventory['booster_focus'] = (_boosterInventory['booster_focus'] ?? 0) + 1;
    notifyListeners();
    await _persist();
  }

  Future<void> claimTrainingChest() async {
    if (!trainingChestAvailable) {
      return;
    }

    _lastChestClaimDate = _dayKey(DateTime.now());
    _coins += 90;
    _boosterInventory['booster_freeze'] = (_boosterInventory['booster_freeze'] ?? 0) + 1;
    _boosterInventory['booster_focus'] = (_boosterInventory['booster_focus'] ?? 0) + 1;
    notifyListeners();
    await _persist();
  }

  Future<void> refreshSessionPresence() async {
    final today = _dayKey(DateTime.now());
    if (_lastSessionDate == today) {
      return;
    }

    if (_lastSessionDate == null) {
      _sessionWelcomeMessage = 'Bem-vindo ao Matetic. Sua rotina diaria comeca hoje.';
    } else {
      final lastDate = DateTime.tryParse(_lastSessionDate!);
      if (lastDate != null) {
        final daysAway = DateTime.now()
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (daysAway <= 1) {
          _sessionWelcomeMessage =
              'Bom retorno. Seu streak diario esta vivo e a campanha esta pronta.';
        } else {
          _sessionWelcomeMessage =
              'Voce voltou depois de $daysAway dias. Bora retomar o ritmo e recuperar o streak.';
        }
      }
    }

    _lastSessionDate = today;
    notifyListeners();
    await _persist();
  }

  Future<void> registerGameResult({
    required int score,
    required int starsEarned,
    required int correctAnswers,
    required int wrongAnswers,
    required int bestCombo,
    required int objectivesCompleted,
    required GameModeId modeId,
    required String sessionLabel,
    required String modeLabel,
    required List<String> topicLabels,
    String? sessionTrackingId,
  }) async {
    final rewards = previewRewardForRun(
      starsEarned: starsEarned,
      objectivesCompleted: objectivesCompleted,
    );

    _xp += rewards.xp;
    _coins += rewards.coins;
    _totalMatches++;
    _totalCorrectAnswers += correctAnswers;
    _totalWrongAnswers += wrongAnswers;
    if (bestCombo > _bestCombo) {
      _bestCombo = bestCombo;
    }
    if (score > _bestScore) {
      _bestScore = score;
    }
    if (starsEarned > _highestStarsEarned) {
      _highestStarsEarned = starsEarned;
    }
    if (wrongAnswers == 0 && starsEarned == 3) {
      _totalPerfectRuns++;
    }
    if (modeId == GameModeId.training) {
      _totalTrainingRuns++;
    }
    if (modeId == GameModeId.event) {
      _seasonEventRuns++;
      if (starsEarned > 0) {
        _seasonEventWins++;
        if (sessionTrackingId != null) {
          _completedEventChallengeIds.add(sessionTrackingId);
          final challenge = eventChallengeById(sessionTrackingId);
          if (challenge != null && challenge.isBoss) {
            _seasonEventBossWins++;
          }
        }
      }
    }
    _recentReplays.insert(
      0,
      MatchReplayView(
        sessionLabel: sessionLabel,
        modeLabel: modeLabel,
        score: score,
        starsEarned: starsEarned,
        bestCombo: bestCombo,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        createdAt: DateTime.now(),
        topicLabels: topicLabels,
      ),
    );
    if (_recentReplays.length > 18) {
      _recentReplays.removeRange(18, _recentReplays.length);
    }

    _ensureMissionWindows();
    _dailyLevelsPlayed++;
    _dailyStarsEarned += starsEarned;
    if (bestCombo > _dailyBestCombo) {
      _dailyBestCombo = bestCombo;
    }
    if (wrongAnswers == 0 && starsEarned > 0) {
      _dailyPerfectRuns++;
    }
    if (starsEarned > 0) {
      _dailyWinningRuns++;
      _currentVictoryStreak++;
    } else {
      _currentVictoryStreak = 0;
      _claimedVictoryChestMilestone = 0;
    }
    if (modeId == GameModeId.training) {
      _dailyTrainingRuns++;
    }
    _weeklyLevelsPlayed++;
    _weeklyStarsEarned += starsEarned;
    _normalizeActiveTitle();

    notifyListeners();
    await _persist();
  }

  void registerQuestionAttempt({
    required MathTopic topic,
    required bool isCorrect,
    required String prompt,
    required String explanation,
    required int correctAnswer,
    required int? selectedAnswer,
    required String difficultyLabel,
  }) {
    final bucket = isCorrect ? _topicCorrectAnswers : _topicWrongAnswers;
    bucket[topic.name] = (bucket[topic.name] ?? 0) + 1;

    if (!isCorrect) {
      _recentMistakes.insert(
        0,
        MistakeReviewEntry(
          topic: topic,
          prompt: prompt,
          explanation: explanation,
          correctAnswer: correctAnswer,
          selectedAnswer: selectedAnswer,
          difficultyLabel: difficultyLabel,
          createdAt: DateTime.now(),
        ),
      );
      if (_recentMistakes.length > 24) {
        _recentMistakes.removeRange(24, _recentMistakes.length);
      }
      notifyListeners();
    }

    unawaited(_persist());
  }

  Future<bool> consumeBooster(String itemId) async {
    final current = _boosterInventory[itemId] ?? 0;
    if (current <= 0) {
      return false;
    }

    _boosterInventory[itemId] = current - 1;
    notifyListeners();
    await _persist();
    return true;
  }

  List<MissionView> get dailyMissions {
    _ensureMissionWindows();
    return <MissionView>[
      MissionView(
        id: 'daily_levels',
        title: 'Completar 3 fases',
        description: 'Feche tres fases hoje para manter o ritmo da campanha.',
        progress: _dailyLevelsPlayed,
        target: 3,
        rewardCoins: 120,
        claimed: _dailyClaimedMissionIds.contains('daily_levels'),
        cadence: 'Diaria',
      ),
      MissionView(
        id: 'daily_stars',
        title: 'Ganhar 5 estrelas',
        description: 'Busque uma rodada forte e acumule 5 estrelas no dia.',
        progress: _dailyStarsEarned,
        target: 5,
        rewardCoins: 140,
        claimed: _dailyClaimedMissionIds.contains('daily_stars'),
        cadence: 'Diaria',
      ),
      MissionView(
        id: 'daily_combo',
        title: 'Combo x6',
        description: 'Atinga um combo de 6 em qualquer fase de hoje.',
        progress: _dailyBestCombo,
        target: 6,
        rewardCoins: 160,
        claimed: _dailyClaimedMissionIds.contains('daily_combo'),
        cadence: 'Diaria',
      ),
    ];
  }

  MissionView get specialDailyMission {
    _ensureMissionWindows();
    final dayIndex = DateTime.now().weekday % 3;
    if (dayIndex == 0) {
      return MissionView(
        id: 'daily_special_perfect',
        title: 'Especial do dia: rodada perfeita',
        description: 'Conclua 1 rodada sem erros para ativar o bonus extra do dia.',
        progress: _dailyPerfectRuns,
        target: 1,
        rewardCoins: 180,
        claimed: _dailyClaimedMissionIds.contains('daily_special_perfect'),
        cadence: 'Especial',
      );
    }
    if (dayIndex == 1) {
      return MissionView(
        id: 'daily_special_wins',
        title: 'Especial do dia: 3 vitorias',
        description: 'Vença 3 rodadas hoje para ganhar um reforco de moedas.',
        progress: _dailyWinningRuns,
        target: 3,
        rewardCoins: 200,
        claimed: _dailyClaimedMissionIds.contains('daily_special_wins'),
        cadence: 'Especial',
      );
    }
    return MissionView(
      id: 'daily_special_training',
      title: 'Especial do dia: treino focado',
      description: 'Complete 1 treino guiado para consolidar o aprendizado do dia.',
      progress: _dailyTrainingRuns,
      target: 1,
      rewardCoins: 170,
      claimed: _dailyClaimedMissionIds.contains('daily_special_training'),
      cadence: 'Especial',
    );
  }

  List<MissionView> get weeklyMissions {
    _ensureMissionWindows();
    return <MissionView>[
      MissionView(
        id: 'weekly_levels',
        title: 'Jogar 10 fases',
        description: 'Mantenha volume de treino ao longo da semana.',
        progress: _weeklyLevelsPlayed,
        target: 10,
        rewardCoins: 280,
        claimed: _weeklyClaimedMissionIds.contains('weekly_levels'),
        cadence: 'Semanal',
      ),
      MissionView(
        id: 'weekly_stars',
        title: 'Ganhar 18 estrelas',
        description: 'Suba o nivel da campanha com execucao consistente.',
        progress: _weeklyStarsEarned,
        target: 18,
        rewardCoins: 320,
        claimed: _weeklyClaimedMissionIds.contains('weekly_stars'),
        cadence: 'Semanal',
      ),
    ];
  }

  Future<void> claimMission(String missionId) async {
    for (final mission in dailyMissions) {
      if (mission.id == missionId && mission.completed && !mission.claimed) {
        _dailyClaimedMissionIds.add(missionId);
        _coins += mission.rewardCoins;
        notifyListeners();
        await _persist();
        return;
      }
    }

    for (final mission in weeklyMissions) {
      if (mission.id == missionId && mission.completed && !mission.claimed) {
        _weeklyClaimedMissionIds.add(missionId);
        _coins += mission.rewardCoins;
        notifyListeners();
        await _persist();
        return;
      }
    }
  }

  Future<void> equipTitle(String titleId) async {
    final title = titles.firstWhere(
      (entry) => entry.id == titleId,
      orElse: () => titles.first,
    );
    if (!title.unlocked) {
      return;
    }
    _activeTitleId = title.id;
    notifyListeners();
    await _persist();
  }

  Future<void> claimLevelMilestoneReward(int milestoneLevel) async {
    final reward = levelMilestoneRewards.firstWhere(
      (entry) => entry.level == milestoneLevel,
      orElse: () => const LevelMilestoneRewardView(
        level: 0,
        coins: 0,
        focusBoosters: 0,
        freezeBoosters: 0,
        claimed: true,
        available: false,
      ),
    );
    if (reward.level == 0 || !reward.available || reward.claimed) {
      return;
    }

    _claimedLevelMilestones.add(milestoneLevel);
    _coins += reward.coins;
    if (reward.focusBoosters > 0) {
      _boosterInventory['booster_focus'] =
          (_boosterInventory['booster_focus'] ?? 0) + reward.focusBoosters;
    }
    if (reward.freezeBoosters > 0) {
      _boosterInventory['booster_freeze'] =
          (_boosterInventory['booster_freeze'] ?? 0) + reward.freezeBoosters;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> claimSeasonMission(String missionId) async {
    for (final mission in seasonMissions) {
      if (mission.id == missionId && mission.completed && !mission.claimed) {
        _claimedSeasonMissionIds.add(missionId);
        _coins += mission.rewardCoins;
        notifyListeners();
        await _persist();
        return;
      }
    }
  }

  Future<void> claimSeasonReward(String rewardId) async {
    final reward = currentSeason.rewards.firstWhere(
      (entry) => entry.id == rewardId,
      orElse: () => const SeasonRewardDefinition(
        id: '',
        title: '',
        description: '',
        requiredWins: 999,
        coins: 0,
      ),
    );
    if (reward.id.isEmpty ||
        _claimedSeasonRewardIds.contains(reward.id) ||
        _seasonEventWins < reward.requiredWins) {
      return;
    }

    _claimedSeasonRewardIds.add(reward.id);
    _coins += reward.coins;
    if (reward.unlockItemId != null) {
      _ownedItemIds.add(reward.unlockItemId!);
    }
    notifyListeners();
    await _persist();
  }

  bool ownsItem(String itemId) => _ownedItemIds.contains(itemId);

  int boosterCount(String itemId) => _boosterInventory[itemId] ?? 0;

  Future<bool> buyItem(String itemId) async {
    final item = itemById(itemId);
    if (item.type != ShopItemType.booster && _ownedItemIds.contains(itemId)) {
      return false;
    }
    if (_coins < item.cost) {
      return false;
    }

    _coins -= item.cost;
    if (item.type == ShopItemType.booster) {
      _boosterInventory[itemId] = (_boosterInventory[itemId] ?? 0) + 1;
    } else {
      _ownedItemIds.add(itemId);
    }

    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> equipItem(String itemId) async {
    final item = itemById(itemId);
    if (!_ownedItemIds.contains(itemId) && item.type != ShopItemType.booster) {
      return;
    }

    if (item.type == ShopItemType.avatar) {
      _avatarId = itemId;
    }
    if (item.type == ShopItemType.theme) {
      _themeId = itemId;
    }
    if (item.type == ShopItemType.frame) {
      _frameId = itemId;
    }
    if (item.type == ShopItemType.effect) {
      _effectId = itemId;
    }
    if (item.type == ShopItemType.mascot) {
      _mascotId = itemId;
    }

    notifyListeners();
    await _persist();
  }

  Future<void> updateDisplayName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _displayName = trimmed;
    notifyListeners();
    await _persist();
  }

  Future<void> updateSettings({
    bool? soundEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largeText,
    bool? untimedTraining,
  }) async {
    _soundEnabled = soundEnabled ?? _soundEnabled;
    _reducedMotion = reducedMotion ?? _reducedMotion;
    _highContrast = highContrast ?? _highContrast;
    _largeText = largeText ?? _largeText;
    _untimedTraining = untimedTraining ?? _untimedTraining;
    notifyListeners();
    await _persist();
  }

  List<RankingEntryView> buildGlobalRanking() {
    final entries = <RankingEntryView>[
      const RankingEntryView(
        name: 'Ana Flash',
        score: 5850,
        subtitle: 'Liga Ouro',
        isPlayer: false,
      ),
      const RankingEntryView(
        name: 'Rafa Delta',
        score: 5410,
        subtitle: 'Liga Ouro',
        isPlayer: false,
      ),
      RankingEntryView(
        name: _displayName,
        score: _xp + (_bestScore ~/ 2) + (_coins * 2),
        subtitle: 'Seu perfil',
        isPlayer: true,
      ),
      const RankingEntryView(
        name: 'Leo Sprint',
        score: 3960,
        subtitle: 'Liga Prata',
        isPlayer: false,
      ),
    ];

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  List<RankingEntryView> buildWeeklyRanking() {
    final weeklyScore = (_weeklyStarsEarned * 120) + (_weeklyLevelsPlayed * 70);
    final entries = <RankingEntryView>[
      const RankingEntryView(
        name: 'Mila Orbit',
        score: 1980,
        subtitle: 'Semana atual',
        isPlayer: false,
      ),
      RankingEntryView(
        name: _displayName,
        score: weeklyScore,
        subtitle: 'Semana atual',
        isPlayer: true,
      ),
      const RankingEntryView(
        name: 'Caio Logic',
        score: 1420,
        subtitle: 'Semana atual',
        isPlayer: false,
      ),
    ];
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  List<RankingEntryView> buildFriendsRanking() {
    final entries = <RankingEntryView>[
      RankingEntryView(
        name: _displayName,
        score: _bestScore,
        subtitle: 'Seu melhor score',
        isPlayer: true,
      ),
      const RankingEntryView(
        name: 'Bia Vector',
        score: 2140,
        subtitle: 'Amiga',
        isPlayer: false,
      ),
      const RankingEntryView(
        name: 'Noah Prime',
        score: 1880,
        subtitle: 'Amigo',
        isPlayer: false,
      ),
    ];
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries;
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'completedOnboarding': _completedOnboarding,
      'signedIn': _signedIn,
      'provider': _provider,
      'displayName': _displayName,
      'coins': _coins,
      'xp': _xp,
      'avatarId': _avatarId,
      'themeId': _themeId,
      'frameId': _frameId,
      'effectId': _effectId,
      'mascotId': _mascotId,
      'ownedItemIds': _ownedItemIds.toList(),
      'boosterInventory': _boosterInventory,
      'totalMatches': _totalMatches,
      'totalCorrectAnswers': _totalCorrectAnswers,
      'totalWrongAnswers': _totalWrongAnswers,
      'bestCombo': _bestCombo,
      'bestScore': _bestScore,
      'highestStarsEarned': _highestStarsEarned,
      'totalPerfectRuns': _totalPerfectRuns,
      'totalTrainingRuns': _totalTrainingRuns,
      'activeTitleId': _activeTitleId,
      'seasonEventId': _seasonEventId,
      'seasonEventRuns': _seasonEventRuns,
      'seasonEventWins': _seasonEventWins,
      'seasonEventBossWins': _seasonEventBossWins,
      'topicCorrectAnswers': _topicCorrectAnswers,
      'topicWrongAnswers': _topicWrongAnswers,
      'recentMistakes': _recentMistakes.map((entry) => entry.toJson()).toList(),
      'recentReplays': _recentReplays.map((entry) => entry.toJson()).toList(),
      'dailyRewardDate': _dailyRewardDate,
      'lastSessionDate': _lastSessionDate,
      'lastChestClaimDate': _lastChestClaimDate,
      'dailyStreak': _dailyStreak,
      'currentVictoryStreak': _currentVictoryStreak,
      'claimedVictoryChestMilestone': _claimedVictoryChestMilestone,
      'dailyPerfectRuns': _dailyPerfectRuns,
      'dailyWinningRuns': _dailyWinningRuns,
      'dailyTrainingRuns': _dailyTrainingRuns,
      'sessionWelcomeMessage': _sessionWelcomeMessage,
      'dailyMissionDate': _dailyMissionDate,
      'dailyLevelsPlayed': _dailyLevelsPlayed,
      'dailyStarsEarned': _dailyStarsEarned,
      'dailyBestCombo': _dailyBestCombo,
      'dailyClaimedMissionIds': _dailyClaimedMissionIds.toList(),
      'weeklyMissionDate': _weeklyMissionDate,
      'weeklyLevelsPlayed': _weeklyLevelsPlayed,
      'weeklyStarsEarned': _weeklyStarsEarned,
      'weeklyClaimedMissionIds': _weeklyClaimedMissionIds.toList(),
      'claimedLevelMilestones': _claimedLevelMilestones.toList(),
      'claimedSeasonMissionIds': _claimedSeasonMissionIds.toList(),
      'claimedSeasonRewardIds': _claimedSeasonRewardIds.toList(),
      'completedEventChallengeIds': _completedEventChallengeIds.toList(),
      'soundEnabled': _soundEnabled,
      'reducedMotion': _reducedMotion,
      'highContrast': _highContrast,
      'largeText': _largeText,
      'untimedTraining': _untimedTraining,
    };
    await preferences.setString(_storageKey, jsonEncode(payload));
  }

  void _ensureMissionWindows() {
    final now = DateTime.now();
    final today = _dayKey(now);
    if (_dailyMissionDate != today) {
      _dailyMissionDate = today;
      _dailyLevelsPlayed = 0;
      _dailyStarsEarned = 0;
      _dailyBestCombo = 0;
      _dailyPerfectRuns = 0;
      _dailyWinningRuns = 0;
      _dailyTrainingRuns = 0;
      _dailyClaimedMissionIds.clear();
    }

    final weekKey = _weekKey(now);
    if (_weeklyMissionDate != weekKey) {
      _weeklyMissionDate = weekKey;
      _weeklyLevelsPlayed = 0;
      _weeklyStarsEarned = 0;
      _weeklyClaimedMissionIds.clear();
    }
  }

  void _ensureSeasonWindow() {
    if (_seasonEventId == currentSeasonEvent.id) {
      return;
    }
    _seasonEventId = currentSeasonEvent.id;
    _seasonEventRuns = 0;
    _seasonEventWins = 0;
    _seasonEventBossWins = 0;
    _claimedSeasonMissionIds.clear();
    _claimedSeasonRewardIds.clear();
    _completedEventChallengeIds.clear();
  }

  void _normalizeActiveTitle() {
    final unlockedTitleIds = titles.where((title) => title.unlocked).map((title) => title.id);
    if (!unlockedTitleIds.contains(_activeTitleId)) {
      _activeTitleId = 'rookie';
    }
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return _dayKey(monday);
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
}
