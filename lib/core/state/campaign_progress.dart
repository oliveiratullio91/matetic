import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/math_topics.dart';
import '../data/sample_data.dart';

class LevelProgress {
  const LevelProgress({
    required this.levelId,
    required this.stars,
    required this.unlocked,
    required this.bestScore,
    required this.bestCombo,
    required this.timesPlayed,
    required this.totalCorrectAnswers,
    required this.completedObjectiveIds,
    required this.perfectClear,
  });

  final int levelId;
  final int stars;
  final bool unlocked;
  final int bestScore;
  final int bestCombo;
  final int timesPlayed;
  final int totalCorrectAnswers;
  final Set<String> completedObjectiveIds;
  final bool perfectClear;

  bool get completed => stars > 0;

  LevelProgress copyWith({
    int? stars,
    bool? unlocked,
    int? bestScore,
    int? bestCombo,
    int? timesPlayed,
    int? totalCorrectAnswers,
    Set<String>? completedObjectiveIds,
    bool? perfectClear,
  }) {
    return LevelProgress(
      levelId: levelId,
      stars: stars ?? this.stars,
      unlocked: unlocked ?? this.unlocked,
      bestScore: bestScore ?? this.bestScore,
      bestCombo: bestCombo ?? this.bestCombo,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      completedObjectiveIds:
          completedObjectiveIds ?? Set<String>.from(this.completedObjectiveIds),
      perfectClear: perfectClear ?? this.perfectClear,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'stars': stars,
      'unlocked': unlocked,
      'bestScore': bestScore,
      'bestCombo': bestCombo,
      'timesPlayed': timesPlayed,
      'totalCorrectAnswers': totalCorrectAnswers,
      'completedObjectiveIds': completedObjectiveIds.toList(),
      'perfectClear': perfectClear,
    };
  }
}

enum ChapterMedalTier {
  locked,
  bronze,
  silver,
  gold,
  platinum,
}

class ChapterMedalView {
  const ChapterMedalView({
    required this.chapter,
    required this.earnedStars,
    required this.maxStars,
    required this.completedLevels,
    required this.totalLevels,
    required this.perfectLevels,
    required this.tier,
  });

  final ChapterDefinition chapter;
  final int earnedStars;
  final int maxStars;
  final int completedLevels;
  final int totalLevels;
  final int perfectLevels;
  final ChapterMedalTier tier;

  double get completionRatio => totalLevels == 0 ? 0 : completedLevels / totalLevels;
  double get starRatio => maxStars == 0 ? 0 : earnedStars / maxStars;
  String get tierLabel {
    return switch (tier) {
      ChapterMedalTier.locked => 'Sem medalha',
      ChapterMedalTier.bronze => 'Bronze',
      ChapterMedalTier.silver => 'Prata',
      ChapterMedalTier.gold => 'Ouro',
      ChapterMedalTier.platinum => 'Platina',
    };
  }
}

class LevelProgressView {
  const LevelProgressView({
    required this.definition,
    required this.progress,
  });

  final LevelDefinition definition;
  final LevelProgress progress;

  int get id => definition.id;
  String get title => definition.title;
  String get description => definition.description;
  int get targetScore => definition.targetScore;
  int get durationInSeconds => definition.durationInSeconds;
  int get totalQuestions => definition.totalQuestions;
  int get chapterId => definition.chapterId;
  int get unlockStarsRequired => definition.unlockStarsRequired;
  int get difficultyTier => definition.difficultyTier;
  String get ruleSummary => definition.ruleSummary;
  List<MathTopic> get focusTopics => definition.focusTopics;
  List<SecondaryObjectiveDefinition> get secondaryObjectives => definition.secondaryObjectives;
  List<PhaseModifierDefinition> get modifiers => definition.modifiers;
  int get baseScorePerHit => definition.baseScorePerHit;
  int get scorePenaltyOnMiss => definition.scorePenaltyOnMiss;
  int get timePenaltyOnMiss => definition.timePenaltyOnMiss;
  int get speedBonusMultiplier => definition.speedBonusMultiplier;
  int get comboScoreMultiplier => definition.comboScoreMultiplier;
  int get extraSecondsOnCorrect => definition.extraSecondsOnCorrect;
  double get scoreGainMultiplier => definition.scoreGainMultiplier;
  int? get maxWrongAnswers => definition.maxWrongAnswers;
  bool get pauseEnabled => definition.pauseEnabled;
  bool get isBoss => definition.isBoss;
  int get stars => progress.stars;
  bool get unlocked => progress.unlocked;
  bool get completed => progress.completed;
  int get bestScore => progress.bestScore;
  int get bestCombo => progress.bestCombo;
  int get timesPlayed => progress.timesPlayed;
  int get totalCorrectAnswers => progress.totalCorrectAnswers;
  Set<String> get completedObjectiveIds => progress.completedObjectiveIds;
  bool get perfectClear => progress.perfectClear;
  int get completedObjectivesCount => progress.completedObjectiveIds.length;
  double get objectiveCompletionRatio {
    if (definition.secondaryObjectives.isEmpty) {
      return 0;
    }
    return progress.completedObjectiveIds.length / definition.secondaryObjectives.length;
  }
}

class CampaignProgressController extends ChangeNotifier {
  CampaignProgressController._() {
    _resetToDefaults();
  }

  static final CampaignProgressController instance = CampaignProgressController._();

  static const _storageKey = 'matetic_campaign_progress_v2';

  final Map<int, LevelProgress> _progressById = <int, LevelProgress>{};
  int? _selectedLevelId;

  List<LevelProgressView> get levels {
    return sampleLevelDefinitions
        .map(
          (definition) => LevelProgressView(
            definition: definition,
            progress: _progressById[definition.id]!,
          ),
        )
        .toList(growable: false);
  }

  LevelProgressView get nextPlayableLevel {
    return levels.firstWhere(
      (level) => level.unlocked && !level.completed,
      orElse: () => levels.first,
    );
  }

  LevelProgressView get selectedOrNextLevel {
    if (_selectedLevelId != null) {
      return levelById(_selectedLevelId!);
    }
    return nextPlayableLevel;
  }

  int get totalStars => levels.fold<int>(0, (sum, level) => sum + level.stars);
  int get completedLevels => levels.where((level) => level.completed).length;
  int get unlockedLevels => levels.where((level) => level.unlocked).length;
  int get perfectLevels => levels.where((level) => level.perfectClear).length;
  double get campaignProgress => totalStars / (levels.length * 3);
  List<ChapterDefinition> get chapters => sampleChapters;
  List<ChapterMedalView> get chapterMedals {
    return sampleChapters
        .map((chapter) {
          final chapterLevels = levelsForChapter(chapter.id);
          final earnedStars =
              chapterLevels.fold<int>(0, (sum, level) => sum + level.stars);
          final perfectLevels =
              chapterLevels.where((level) => level.perfectClear).length;
          final completedLevels =
              chapterLevels.where((level) => level.completed).length;
          final maxStars = chapterLevels.length * 3;
          final starRatio = maxStars == 0 ? 0 : earnedStars / maxStars;

          final ChapterMedalTier tier;
          if (perfectLevels == chapterLevels.length && chapterLevels.isNotEmpty) {
            tier = ChapterMedalTier.platinum;
          } else if (starRatio >= 0.84) {
            tier = ChapterMedalTier.gold;
          } else if (starRatio >= 0.62) {
            tier = ChapterMedalTier.silver;
          } else if (starRatio >= 0.34) {
            tier = ChapterMedalTier.bronze;
          } else {
            tier = ChapterMedalTier.locked;
          }

          return ChapterMedalView(
            chapter: chapter,
            earnedStars: earnedStars,
            maxStars: maxStars,
            completedLevels: completedLevels,
            totalLevels: chapterLevels.length,
            perfectLevels: perfectLevels,
            tier: tier,
          );
        })
        .toList(growable: false);
  }

  List<LevelProgressView> levelsForChapter(int chapterId) {
    return levels.where((level) => level.chapterId == chapterId).toList(growable: false);
  }

  ChapterMedalView medalForChapter(int chapterId) {
    return chapterMedals.firstWhere((medal) => medal.chapter.id == chapterId);
  }

  LevelProgressView levelById(int levelId) {
    return levels.firstWhere((level) => level.id == levelId);
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final storedSelectedLevelId = json['selectedLevelId'] as int?;
      final storedLevels = (json['levels'] as List<dynamic>? ?? <dynamic>[]);

      _resetToDefaults();

      for (final entry in storedLevels) {
        if (entry is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(entry);
        final levelId = map['levelId'];
        if (levelId is! int || !_progressById.containsKey(levelId)) {
          continue;
        }

        final current = _progressById[levelId]!;
        final storedStars = (map['stars'] as int?) ?? current.stars;
        _progressById[levelId] = current.copyWith(
          stars: storedStars.clamp(0, 3),
          unlocked: map['unlocked'] as bool? ?? current.unlocked,
          bestScore: map['bestScore'] as int? ?? current.bestScore,
          bestCombo: map['bestCombo'] as int? ?? current.bestCombo,
          timesPlayed: map['timesPlayed'] as int? ?? current.timesPlayed,
          totalCorrectAnswers:
              map['totalCorrectAnswers'] as int? ?? current.totalCorrectAnswers,
          completedObjectiveIds: ((map['completedObjectiveIds'] as List<dynamic>?) ??
                  const <dynamic>[])
              .whereType<String>()
              .toSet(),
          perfectClear: map['perfectClear'] as bool? ?? current.perfectClear,
        );
      }

      if (storedSelectedLevelId != null && _progressById.containsKey(storedSelectedLevelId)) {
        _selectedLevelId = storedSelectedLevelId;
      }
      _refreshUnlocks();
    } catch (_) {
      _resetToDefaults();
    }
  }

  void selectLevel(int levelId) {
    _selectedLevelId = levelId;
    notifyListeners();
    _persist();
  }

  void applyResult({
    required int levelId,
    required int starsEarned,
    required int score,
    required int bestCombo,
    required int correctAnswers,
    required Set<String> completedObjectiveIds,
    required bool perfectClear,
  }) {
    final current = _progressById[levelId];
    if (current == null) {
      return;
    }

    final updatedStars = starsEarned > current.stars ? starsEarned : current.stars;
    _progressById[levelId] = current.copyWith(stars: updatedStars);
    final mergedObjectiveIds = Set<String>.from(current.completedObjectiveIds)
      ..addAll(completedObjectiveIds);
    _progressById[levelId] = _progressById[levelId]!.copyWith(
      bestScore: score > current.bestScore ? score : current.bestScore,
      bestCombo: bestCombo > current.bestCombo ? bestCombo : current.bestCombo,
      totalCorrectAnswers: current.totalCorrectAnswers + correctAnswers,
      timesPlayed: current.timesPlayed + 1,
      completedObjectiveIds: mergedObjectiveIds,
      perfectClear: current.perfectClear || perfectClear,
    );
    _refreshUnlocks();

    notifyListeners();
    _persist();
  }

  void reset() {
    _resetToDefaults();
    notifyListeners();
    _persist();
  }

  void _resetToDefaults() {
    _progressById
      ..clear()
      ..addEntries(
        sampleLevelDefinitions.map(
          (definition) => MapEntry(
            definition.id,
            LevelProgress(
              levelId: definition.id,
              stars: 0,
              unlocked: definition.id == sampleLevelDefinitions.first.id,
              bestScore: 0,
              bestCombo: 0,
              timesPlayed: 0,
              totalCorrectAnswers: 0,
              completedObjectiveIds: <String>{},
              perfectClear: false,
            ),
          ),
        ),
      );
    _selectedLevelId = sampleLevelDefinitions.first.id;
    _refreshUnlocks();
  }

  void _refreshUnlocks() {
    final currentTotalStars = _progressById.values.fold<int>(
      0,
      (sum, level) => sum + level.stars,
    );

    for (var index = 0; index < sampleLevelDefinitions.length; index++) {
      final definition = sampleLevelDefinitions[index];
      final current = _progressById[definition.id]!;
      final bool unlocked;

      if (index == 0) {
        unlocked = true;
      } else {
        final previousDefinition = sampleLevelDefinitions[index - 1];
        final previousProgress = _progressById[previousDefinition.id]!;
        unlocked =
            previousProgress.completed && currentTotalStars >= definition.unlockStarsRequired;
      }

      _progressById[definition.id] = current.copyWith(unlocked: unlocked);
    }
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'selectedLevelId': _selectedLevelId,
      'levels': _progressById.values.map((progress) => progress.toJson()).toList(),
    };
    await preferences.setString(_storageKey, jsonEncode(payload));
  }
}
