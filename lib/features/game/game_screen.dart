import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/data/math_topics.dart';
import '../../core/data/sample_data.dart';
import '../../core/state/campaign_progress.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import 'game_models.dart';

Duration _motionDuration(int milliseconds) {
  return PlayerProfileController.instance.reducedMotion
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
}

class _ObjectiveResult {
  const _ObjectiveResult({
    required this.title,
    required this.description,
    required this.completed,
  });

  final String title;
  final String description;
  final bool completed;
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.levelId,
    this.quickMode,
    this.sessionTrackingId,
  });

  final int? levelId;
  final GameModeDefinition? quickMode;
  final String? sessionTrackingId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final MathQuestionFactory _questionFactory = MathQuestionFactory();
  final CampaignProgressController _campaign = CampaignProgressController.instance;
  final PlayerProfileController _profile = PlayerProfileController.instance;

  late List<MathQuestion> _questions;
  late LevelProgressView _level;
  late GameSessionConfig _sessionConfig;
  GameModeDefinition? _quickMode;
  Timer? _ticker;
  int _timeLeft = 0;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _questionElapsed = 0;
  int _freezeSeconds = 0;
  int _xpEarned = 0;
  int _coinsEarned = 0;
  bool _paused = false;
  bool _finished = false;
  bool _resultApplied = false;
  bool? _lastAnswerCorrect;
  int? _selectedAnswer;
  int? _lastScoreGain;
  String? _feedbackMessage;
  final Set<int> _suppressedOptions = <int>{};

  MathQuestion get _currentQuestion => _questions[_questionIndex];
  List<SecondaryObjectiveDefinition> get _activeObjectives =>
      _quickMode?.secondaryObjectives ?? _level.secondaryObjectives;
  int? get _maxWrongAnswers => _sessionConfig.maxWrongAnswers;
  bool get _isQuickMode => _quickMode != null;
  bool get _timerDisabled =>
      (_quickMode?.id == GameModeId.training) && _profile.untimedTraining;
  String get _phaseTitleLabel => _isQuickMode
      ? 'Modo: ${_sessionConfig.phaseTitle}'
      : '${_level.isBoss ? 'Chefe' : 'Fase'} ${_level.id}: ${_sessionConfig.phaseTitle}';
  String get _phaseDescription =>
      _quickMode?.description ?? _level.description;

  @override
  void initState() {
    super.initState();
    _configureLevel();
    _startSession();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _configureLevel() {
    _quickMode = widget.quickMode;
    _level = widget.levelId != null
        ? _campaign.levelById(widget.levelId!)
        : _campaign.selectedOrNextLevel;

    if (_quickMode != null) {
      final mode = _quickMode!;
      _sessionConfig = GameSessionConfig(
        totalQuestions: mode.totalQuestions,
        durationInSeconds: mode.durationInSeconds,
        targetScore: mode.targetScore,
        phaseTitle: mode.title,
        ruleSummary: mode.ruleSummary,
        focusTopics: mode.focusTopics,
        modifiers: mode.modifiers,
        baseScorePerHit: mode.baseScorePerHit,
        scorePenaltyOnMiss: mode.scorePenaltyOnMiss,
        timePenaltyOnMiss: mode.timePenaltyOnMiss,
        speedBonusMultiplier: mode.speedBonusMultiplier,
        comboScoreMultiplier: mode.comboScoreMultiplier,
        extraSecondsOnCorrect: mode.extraSecondsOnCorrect,
        scoreGainMultiplier: mode.scoreGainMultiplier,
        maxWrongAnswers: mode.maxWrongAnswers,
        pauseEnabled: mode.pauseEnabled,
        difficultyTier: mode.difficultyTier,
      );
      return;
    }

    _sessionConfig = GameSessionConfig(
      totalQuestions: _level.totalQuestions,
      durationInSeconds: _level.durationInSeconds,
      targetScore: _level.targetScore,
      phaseTitle: _level.title,
      ruleSummary: _level.ruleSummary,
      focusTopics: _level.focusTopics,
      modifiers: _level.modifiers,
      baseScorePerHit: _level.baseScorePerHit,
      scorePenaltyOnMiss: _level.scorePenaltyOnMiss,
      timePenaltyOnMiss: _level.timePenaltyOnMiss,
      speedBonusMultiplier: _level.speedBonusMultiplier,
      comboScoreMultiplier: _level.comboScoreMultiplier,
      extraSecondsOnCorrect: _level.extraSecondsOnCorrect,
      scoreGainMultiplier: _level.scoreGainMultiplier,
      maxWrongAnswers: _level.maxWrongAnswers,
      pauseEnabled: _level.pauseEnabled,
      difficultyTier: _level.difficultyTier,
    );
  }

  void _startSession() {
    _ticker?.cancel();
    _configureLevel();
    _questions = _questionFactory.buildSessionQuestions(_sessionConfig);
    _timeLeft = _sessionConfig.durationInSeconds;
    _score = 0;
    _combo = 0;
    _bestCombo = 0;
    _questionIndex = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _questionElapsed = 0;
    _freezeSeconds = 0;
    _xpEarned = 0;
    _coinsEarned = 0;
    _paused = false;
    _finished = false;
    _resultApplied = false;
    _lastAnswerCorrect = null;
    _selectedAnswer = null;
    _lastScoreGain = null;
    _suppressedOptions.clear();
    _feedbackMessage = _level.ruleSummary;
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused || _finished) {
        return;
      }

      setState(() {
        if (_timerDisabled) {
          if (_selectedAnswer == null) {
            _questionElapsed++;
          }
          return;
        }
        if (_freezeSeconds > 0) {
          _freezeSeconds--;
        } else {
          _timeLeft--;
        }
        if (_selectedAnswer == null) {
          _questionElapsed++;
        }

        if (_timeLeft <= 0) {
          _timeLeft = 0;
          _finishSession('O tempo acabou. Vamos revisar sua corrida.');
        }
      });
    });
  }

  Future<void> _togglePause() async {
    if (_finished || !_sessionConfig.pauseEnabled) {
      return;
    }
    setState(() {
      _paused = true;
      _feedbackMessage = 'Partida pausada. Escolha como quer continuar.';
    });

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Partida pausada'),
          content: const Text(
            'Voce pode retomar, reiniciar a fase ou voltar ao mapa sem perder o controle da sessao.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('exit'),
              child: const Text('Sair'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('restart'),
              child: const Text('Reiniciar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('resume'),
              child: const Text('Retomar'),
            ),
          ],
        );
      },
    );

    if (!mounted || _finished) {
      return;
    }

    switch (action) {
      case 'restart':
        setState(_startSession);
        return;
      case 'exit':
        Navigator.of(context).pop();
        return;
      case 'resume':
      default:
        setState(() {
          _paused = false;
          _feedbackMessage = 'Partida retomada. O cronometro voltou a correr.';
        });
        return;
    }
  }

  void _submitAnswer(int answer) {
    if (_finished || _paused || _selectedAnswer != null) {
      return;
    }

    final isCorrect = answer == _currentQuestion.correctAnswer;
    final speedBonus = (18 - (_questionElapsed * 2)).clamp(0, 18);

    setState(() {
      _selectedAnswer = answer;
      _lastAnswerCorrect = isCorrect;

      if (isCorrect) {
        _correctAnswers++;
        _combo++;
        if (_combo > _bestCombo) {
          _bestCombo = _combo;
        }
        final gain = _sessionConfig.baseScorePerHit +
            (_combo * _sessionConfig.comboScoreMultiplier) +
            (speedBonus * _sessionConfig.speedBonusMultiplier);
        final adjustedGain = (gain * _sessionConfig.scoreGainMultiplier).round();
        _lastScoreGain = adjustedGain;
        _score += adjustedGain;
        if (_sessionConfig.extraSecondsOnCorrect > 0) {
          _timeLeft = (_timeLeft + _sessionConfig.extraSecondsOnCorrect)
              .clamp(0, _sessionConfig.durationInSeconds);
        }
        _feedbackMessage =
            'Acertou. ${_currentQuestion.explanation} Bonus de velocidade: $speedBonus.';
      } else {
        _wrongAnswers++;
        _combo = 0;
        _timeLeft = (_timeLeft - _sessionConfig.timePenaltyOnMiss)
            .clamp(0, _sessionConfig.durationInSeconds);
        _lastScoreGain = -_sessionConfig.scorePenaltyOnMiss;
        _score = (_score - _sessionConfig.scorePenaltyOnMiss).clamp(0, 999999);
        _feedbackMessage =
            'Nao foi dessa vez. ${_currentQuestion.explanation} Voce perdeu ${_sessionConfig.timePenaltyOnMiss} segundos.';
      }
    });

    _profile.registerQuestionAttempt(
      topic: _currentQuestion.topic,
      isCorrect: isCorrect,
      prompt: _currentQuestion.prompt,
      explanation: _currentQuestion.explanation,
      correctAnswer: _currentQuestion.correctAnswer,
      selectedAnswer: answer,
      difficultyLabel: _currentQuestion.difficultyLabel,
    );

    if (_maxWrongAnswers != null && _wrongAnswers >= _maxWrongAnswers!) {
      setState(() {
        _finishSession('A rodada acabou porque o limite de erros foi atingido.');
      });
      return;
    }

    if (_timeLeft <= 0) {
      setState(() {
        _finishSession('O tempo acabou logo depois desta resposta.');
      });
    }
  }

  void _goToNextQuestion() {
    if (_finished || _selectedAnswer == null) {
      return;
    }

    if (_questionIndex >= _questions.length - 1) {
      setState(() {
        _finishSession('Voce concluiu todas as perguntas da fase.');
      });
      return;
    }

    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
      _lastAnswerCorrect = null;
      _lastScoreGain = null;
      _questionElapsed = 0;
      _suppressedOptions.clear();
      _feedbackMessage = 'Nova questao pronta. Mantenha o ritmo.';
    });
  }

  void _finishSession(String message) {
    _finished = true;
    _paused = false;
    _ticker?.cancel();
    _feedbackMessage = message;
    if (!_resultApplied) {
      final completedObjectiveIds = _completedObjectiveIds;
      final rewards = _profile.previewRewardForRun(
        starsEarned: _starsEarned,
        objectivesCompleted: completedObjectiveIds.length,
      );
      _xpEarned = rewards.xp;
      _coinsEarned = rewards.coins;
      if (!_isQuickMode) {
        _campaign.applyResult(
          levelId: _level.id,
          starsEarned: _starsEarned,
          score: _score,
          bestCombo: _bestCombo,
          correctAnswers: _correctAnswers,
          completedObjectiveIds: completedObjectiveIds,
          perfectClear: _isPerfectRun,
        );
      }
      unawaited(
        _profile.registerGameResult(
          score: _score,
          starsEarned: _starsEarned,
          correctAnswers: _correctAnswers,
          wrongAnswers: _wrongAnswers,
          bestCombo: _bestCombo,
          objectivesCompleted: completedObjectiveIds.length,
          modeId: _quickMode?.id ?? GameModeId.campaign,
          sessionLabel: _phaseTitleLabel,
          modeLabel: _isQuickMode ? _quickMode!.title : 'Campanha',
          topicLabels: _sessionConfig.focusTopics.map((topic) => topic.label).toList(growable: false),
          sessionTrackingId: widget.sessionTrackingId,
        ),
      );
      _resultApplied = true;
    }
  }

  String get _resultTitle {
    if (_maxWrongAnswers != null &&
        _wrongAnswers >= _maxWrongAnswers! &&
        _score < _sessionConfig.targetScore) {
      return 'Modo encerrado';
    }
    if (_score >= _sessionConfig.targetScore) {
      return 'Fase vencida';
    }
    return 'Fase incompleta';
  }

  String get _resultSummary {
    if (_score >= _sessionConfig.targetScore) {
      return _isQuickMode
          ? 'Voce bateu a meta do modo e saiu com uma rodada forte para subir no ranking local.'
          : 'Voce bateu a meta de score e ja tem base para destravar a proxima fase.';
    }
    if (_maxWrongAnswers != null && _wrongAnswers >= _maxWrongAnswers!) {
      return 'O modo terminou por limite de erros. Vale voltar com mais controle para bater a meta.';
    }
    return 'A corrida ja esta divertida, mas ainda falta ritmo para bater a meta da fase.';
  }

  List<_ObjectiveResult> get _objectiveResults {
    return _activeObjectives.map((objective) {
      final completed = switch (objective.type) {
        SecondaryObjectiveType.noMistakes => _wrongAnswers == 0,
        SecondaryObjectiveType.reachCombo => _bestCombo >= objective.targetValue,
        SecondaryObjectiveType.finishWithTimeLeft => _timeLeft >= objective.targetValue,
        SecondaryObjectiveType.correctAnswersAtLeast =>
          _correctAnswers >= objective.targetValue,
      };

      return _ObjectiveResult(
        title: objective.title,
        description: objective.description,
        completed: completed,
      );
    }).toList(growable: false);
  }

  Set<String> get _completedObjectiveIds {
    final completed = <String>{};
    for (final objective in _activeObjectives) {
      final objectiveCompleted = switch (objective.type) {
        SecondaryObjectiveType.noMistakes => _wrongAnswers == 0,
        SecondaryObjectiveType.reachCombo => _bestCombo >= objective.targetValue,
        SecondaryObjectiveType.finishWithTimeLeft => _timeLeft >= objective.targetValue,
        SecondaryObjectiveType.correctAnswersAtLeast =>
          _correctAnswers >= objective.targetValue,
      };
      if (objectiveCompleted) {
        completed.add(objective.id);
      }
    }
    return completed;
  }

  Future<void> _useFreezeBooster() async {
    if (_finished || _paused || _selectedAnswer != null || _freezeSeconds > 0) {
      return;
    }
    final consumed = await _profile.consumeBooster('booster_freeze');
    if (!consumed || !mounted) {
      return;
    }
    setState(() {
      _freezeSeconds = 6;
      _feedbackMessage = 'Booster congelar tempo ativado por 6 segundos.';
    });
  }

  Future<void> _useFocusBooster() async {
    if (_finished || _paused || _selectedAnswer != null) {
      return;
    }
    final availableWrongOptions = _currentQuestion.options
        .where((option) => option != _currentQuestion.correctAnswer)
        .where((option) => !_suppressedOptions.contains(option))
        .toList(growable: false);
    if (availableWrongOptions.isEmpty) {
      return;
    }
    final consumed = await _profile.consumeBooster('booster_focus');
    if (!consumed || !mounted) {
      return;
    }
    setState(() {
      _suppressedOptions.add(availableWrongOptions.first);
      _feedbackMessage =
          'Booster foco ativado. Uma alternativa incorreta foi removida desta questao.';
    });
  }

  int get _starsEarned {
    final allObjectivesCompleted = _objectiveResults.every((objective) => objective.completed);
    if (_score >= _sessionConfig.targetScore) {
      if (allObjectivesCompleted) {
        return 3;
      }
      return 2;
    }
    if (_score >= _sessionConfig.targetScore * 0.65) {
      return 1;
    }
    return 0;
  }

  bool get _isPerfectRun => _starsEarned == 3 && _wrongAnswers == 0;

  int? get _nextCampaignLevelId {
    if (_isQuickMode) {
      return null;
    }
    final currentIndex = sampleLevelDefinitions.indexWhere((level) => level.id == _level.id);
    if (currentIndex < 0 || currentIndex >= sampleLevelDefinitions.length - 1) {
      return null;
    }
    final candidateId = sampleLevelDefinitions[currentIndex + 1].id;
    final candidate = _campaign.levelById(candidateId);
    return candidate.unlocked ? candidate.id : null;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      body: ShellFrame(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GameHeader(
                  phaseTitle: _phaseTitleLabel,
                  description: _phaseDescription,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _StatusPanel(
                                score: _score,
                                timeLeft: _timeLeft,
                                combo: _combo,
                                bestCombo: _bestCombo,
                                progress:
                                    (_score / _sessionConfig.targetScore).clamp(0.0, 1.0),
                                correctAnswers: _correctAnswers,
                                wrongAnswers: _wrongAnswers,
                                feedbackMessage: _feedbackMessage ?? '',
                                timerDisabled: _timerDisabled,
                                targetScore: _sessionConfig.targetScore,
                                ruleSummary: _sessionConfig.ruleSummary,
                                focusTopics: _sessionConfig.focusTopics,
                                modifiers: _sessionConfig.modifiers,
                                timePenaltyOnMiss: _sessionConfig.timePenaltyOnMiss,
                                extraSecondsOnCorrect: _sessionConfig.extraSecondsOnCorrect,
                                maxWrongAnswers: _maxWrongAnswers,
                                freezeSeconds: _freezeSeconds,
                                freezeBoosters: _profile.boosterCount('booster_freeze'),
                                focusBoosters: _profile.boosterCount('booster_focus'),
                                onUseFreezeBooster: _useFreezeBooster,
                                onUseFocusBooster: _useFocusBooster,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 7,
                              child: _QuestionBoard(
                                question: _currentQuestion,
                                questionIndex: _questionIndex + 1,
                                totalQuestions: _questions.length,
                                selectedAnswer: _selectedAnswer,
                                lastAnswerCorrect: _lastAnswerCorrect,
                                lastScoreGain: _lastScoreGain,
                                finished: _finished,
                                paused: _paused,
                                pauseEnabled: _sessionConfig.pauseEnabled,
                                suppressedOptions: _suppressedOptions,
                                onAnswerSelected: _submitAnswer,
                                onNextQuestion: _goToNextQuestion,
                                onTogglePause: _togglePause,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _StatusPanel(
                                score: _score,
                                timeLeft: _timeLeft,
                                combo: _combo,
                                bestCombo: _bestCombo,
                                progress:
                                    (_score / _sessionConfig.targetScore).clamp(0.0, 1.0),
                                correctAnswers: _correctAnswers,
                                wrongAnswers: _wrongAnswers,
                                feedbackMessage: _feedbackMessage ?? '',
                                timerDisabled: _timerDisabled,
                                targetScore: _sessionConfig.targetScore,
                                ruleSummary: _sessionConfig.ruleSummary,
                                focusTopics: _sessionConfig.focusTopics,
                                modifiers: _sessionConfig.modifiers,
                                timePenaltyOnMiss: _sessionConfig.timePenaltyOnMiss,
                                extraSecondsOnCorrect: _sessionConfig.extraSecondsOnCorrect,
                                maxWrongAnswers: _maxWrongAnswers,
                                freezeSeconds: _freezeSeconds,
                                freezeBoosters: _profile.boosterCount('booster_freeze'),
                                focusBoosters: _profile.boosterCount('booster_focus'),
                                onUseFreezeBooster: _useFreezeBooster,
                                onUseFocusBooster: _useFocusBooster,
                              ),
                              const SizedBox(height: 20),
                              _QuestionBoard(
                                question: _currentQuestion,
                                questionIndex: _questionIndex + 1,
                                totalQuestions: _questions.length,
                                selectedAnswer: _selectedAnswer,
                                lastAnswerCorrect: _lastAnswerCorrect,
                                lastScoreGain: _lastScoreGain,
                                finished: _finished,
                                paused: _paused,
                                pauseEnabled: _sessionConfig.pauseEnabled,
                                suppressedOptions: _suppressedOptions,
                                onAnswerSelected: _submitAnswer,
                                onNextQuestion: _goToNextQuestion,
                                onTogglePause: _togglePause,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            if (_finished)
              Positioned.fill(
                child: _ResultOverlay(
                  title: _resultTitle,
                  summary: _resultSummary,
                  starsEarned: _starsEarned,
                  perfectRun: _isPerfectRun,
                  score: _score,
                  targetScore: _sessionConfig.targetScore,
                  correctAnswers: _correctAnswers,
                  bestCombo: _bestCombo,
                  objectiveResults: _objectiveResults,
                  coinsEarned: _coinsEarned,
                  xpEarned: _xpEarned,
                  nextLevelId: _nextCampaignLevelId,
                  onRestart: () => setState(_startSession),
                  onNextLevel: _nextCampaignLevelId == null
                      ? null
                      : () {
                          final nextId = _nextCampaignLevelId!;
                          _campaign.selectLevel(nextId);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => GameScreen(levelId: nextId),
                            ),
                          );
                        },
                  onExit: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.phaseTitle,
    required this.description,
    required this.onBack,
  });

  final String phaseTitle;
  final String description;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phaseTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.score,
    required this.timeLeft,
    required this.combo,
    required this.bestCombo,
    required this.progress,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.feedbackMessage,
    required this.timerDisabled,
    required this.targetScore,
    required this.ruleSummary,
    required this.focusTopics,
    required this.modifiers,
    required this.timePenaltyOnMiss,
    required this.extraSecondsOnCorrect,
    required this.maxWrongAnswers,
    required this.freezeSeconds,
    required this.freezeBoosters,
    required this.focusBoosters,
    required this.onUseFreezeBooster,
    required this.onUseFocusBooster,
  });

  final int score;
  final int timeLeft;
  final int combo;
  final int bestCombo;
  final double progress;
  final int correctAnswers;
  final int wrongAnswers;
  final String feedbackMessage;
  final bool timerDisabled;
  final int targetScore;
  final String ruleSummary;
  final List<MathTopic> focusTopics;
  final List<PhaseModifierDefinition> modifiers;
  final int timePenaltyOnMiss;
  final int extraSecondsOnCorrect;
  final int? maxWrongAnswers;
  final int freezeSeconds;
  final int freezeBoosters;
  final int focusBoosters;
  final Future<void> Function() onUseFreezeBooster;
  final Future<void> Function() onUseFocusBooster;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          child: Column(
            children: [
              _ScoreStat(label: 'Score', value: '$score'),
              const SizedBox(height: 14),
              _ScoreStat(
                label: 'Tempo',
                value: timerDisabled ? 'Sem tempo' : _formatTime(timeLeft),
              ),
              const SizedBox(height: 14),
              _ScoreStat(label: 'Combo', value: 'x$combo'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _MomentumBanner(
          combo: combo,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meta da fase',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Atingir $targetScore pontos antes do cronometro zerar.'
                '${timerDisabled ? ' Modo treino sem tempo ativo.' : ''}'
                '${maxWrongAnswers != null ? ' Limite de erros: $maxWrongAnswers.' : ''}'
                ' Cada erro custa $timePenaltyOnMiss segundos.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
              if (extraSecondsOnCorrect > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Acertos devolvem +$extraSecondsOnCorrect s nesta fase.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF13C4A3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: 12),
              Text('${(progress * 100).round()}% da meta concluida'),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5D9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(ruleSummary),
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
                'Leitura da rodada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _MiniStatRow(label: 'Acertos', value: '$correctAnswers'),
              _MiniStatRow(label: 'Erros', value: '$wrongAnswers'),
              _MiniStatRow(label: 'Melhor combo', value: '$bestCombo'),
              if (freezeSeconds > 0)
                _MiniStatRow(label: 'Tempo congelado', value: '${freezeSeconds}s'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: focusTopics
                    .map((topic) => Chip(label: Text(topic.label)))
                    .toList(growable: false),
              ),
              if (modifiers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Modificadores ativos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: modifiers
                      .map(
                        (modifier) => Chip(
                          avatar: Icon(modifier.icon, size: 16, color: modifier.color),
                          label: Text(modifier.title),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  feedbackMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Boosters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: freezeBoosters > 0 ? () => onUseFreezeBooster() : null,
                      icon: const Icon(Icons.ac_unit_rounded),
                      label: Text('Congelar ($freezeBoosters)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: focusBoosters > 0 ? () => onUseFocusBooster() : null,
                      icon: const Icon(Icons.flash_on_rounded),
                      label: Text('Foco ($focusBoosters)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }
}

class _QuestionBoard extends StatelessWidget {
  const _QuestionBoard({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.lastAnswerCorrect,
    required this.lastScoreGain,
    required this.finished,
    required this.paused,
    required this.pauseEnabled,
    required this.suppressedOptions,
    required this.onAnswerSelected,
    required this.onNextQuestion,
    required this.onTogglePause,
  });

  final MathQuestion question;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;
  final int? lastScoreGain;
  final bool finished;
  final bool paused;
  final bool pauseEnabled;
  final Set<int> suppressedOptions;
  final ValueChanged<int> onAnswerSelected;
  final VoidCallback onNextQuestion;
  final Future<void> Function() onTogglePause;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final questionProgress = (questionIndex / totalQuestions).clamp(0.0, 1.0);
        final feedbackTint = lastAnswerCorrect == null
            ? Colors.transparent
            : lastAnswerCorrect!
                ? const Color(0xFF13C4A3).withValues(alpha: 0.08)
                : const Color(0xFFD1495B).withValues(alpha: 0.08);
        final feedbackBorder = lastAnswerCorrect == null
            ? const Color(0xFFE4E9F7)
            : lastAnswerCorrect!
                ? const Color(0xFF13C4A3).withValues(alpha: 0.24)
                : const Color(0xFFD1495B).withValues(alpha: 0.24);

        return SectionCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Chip(label: Text('Pergunta $questionIndex de $totalQuestions')),
                  Chip(label: Text(question.difficultyLabel)),
                  Chip(label: Text(question.topic.label)),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: questionProgress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE9EEF9),
                ),
              ),
              const SizedBox(height: 24),
              if (hasBoundedHeight)
                Expanded(
                  child: AnimatedContainer(
                    duration: _motionDuration(220),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: feedbackTint,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: feedbackBorder),
                    ),
                    child: AnimatedSwitcher(
                      duration: _motionDuration(280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _QuestionStage(
                        key: ValueKey<int>(questionIndex),
                        question: question,
                        selectedAnswer: selectedAnswer,
                        lastScoreGain: lastScoreGain,
                        paused: paused,
                        finished: finished,
                        suppressedOptions: suppressedOptions,
                        onAnswerSelected: onAnswerSelected,
                      ),
                    ),
                  ),
                )
              else
                AnimatedContainer(
                  duration: _motionDuration(220),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: feedbackTint,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: feedbackBorder),
                  ),
                  child: SizedBox(
                    height: 430,
                    child: AnimatedSwitcher(
                      duration: _motionDuration(280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _QuestionStage(
                        key: ValueKey<int>(questionIndex),
                        question: question,
                        selectedAnswer: selectedAnswer,
                        lastScoreGain: lastScoreGain,
                        paused: paused,
                        finished: finished,
                        suppressedOptions: suppressedOptions,
                        onAnswerSelected: onAnswerSelected,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: _motionDuration(220),
                child: lastAnswerCorrect == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey<bool?>(lastAnswerCorrect),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerFeedbackBanner(
                          correct: lastAnswerCorrect!,
                          correctAnswer: question.correctAnswer,
                          scoreDelta: lastScoreGain ?? 0,
                        ),
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: finished || !pauseEnabled ? null : () => onTogglePause(),
                      icon: Icon(
                        paused
                            ? Icons.play_circle_outline_rounded
                            : Icons.pause_circle_outline_rounded,
                      ),
                      label: Text(
                        !pauseEnabled
                            ? 'Sem pausa'
                            : paused
                                ? 'Retomar'
                                : 'Pausar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: selectedAnswer == null || finished ? null : onNextQuestion,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        questionIndex >= totalQuestions ? 'Finalizar fase' : 'Proxima questao',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionStage extends StatelessWidget {
  const _QuestionStage({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.lastScoreGain,
    required this.paused,
    required this.finished,
    required this.suppressedOptions,
    required this.onAnswerSelected,
  });

  final MathQuestion question;
  final int? selectedAnswer;
  final int? lastScoreGain;
  final bool paused;
  final bool finished;
  final Set<int> suppressedOptions;
  final ValueChanged<int> onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 14),
        Text(
          selectedAnswer == null
              ? 'Escolha a melhor resposta antes do cronometro apertar mais.'
              : question.explanation,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4A5572),
          ),
        ),
        if (lastScoreGain != null) ...[
          const SizedBox(height: 14),
          Text(
            lastScoreGain! >= 0
                ? '+$lastScoreGain pontos nesta resposta'
                : '$lastScoreGain pontos nesta resposta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: lastScoreGain! >= 0
                  ? const Color(0xFF13C4A3)
                  : const Color(0xFFD1495B),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Expanded(
          child: _AnswersGrid(
            question: question,
            selectedAnswer: selectedAnswer,
            paused: paused,
            finished: finished,
            suppressedOptions: suppressedOptions,
            onAnswerSelected: onAnswerSelected,
          ),
        ),
      ],
    );
  }
}

class _AnswersGrid extends StatelessWidget {
  const _AnswersGrid({
    required this.question,
    required this.selectedAnswer,
    required this.paused,
    required this.finished,
    required this.suppressedOptions,
    required this.onAnswerSelected,
  });

  final MathQuestion question;
  final int? selectedAnswer;
  final bool paused;
  final bool finished;
  final Set<int> suppressedOptions;
  final ValueChanged<int> onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;

        return GridView.count(
          crossAxisCount: wide ? 2 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: wide ? 2.8 : 4.2,
          physics: const NeverScrollableScrollPhysics(),
          children: question.options
              .map(
                (option) => _AnswerCard(
                  value: option,
                  selectedAnswer: selectedAnswer,
                  correctAnswer: question.correctAnswer,
                  hidden: suppressedOptions.contains(option),
                  locked:
                      suppressedOptions.contains(option) ||
                      selectedAnswer != null ||
                      paused ||
                      finished,
                  onTap: () => onAnswerSelected(option),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.value,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.hidden,
    required this.locked,
    required this.onTap,
  });

  final int value;
  final int? selectedAnswer;
  final int correctAnswer;
  final bool hidden;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = value == correctAnswer;
    final isSelected = value == selectedAnswer;

    Color borderColor = const Color(0xFFE0E6F5);
    Color background = Colors.white;

    if (hidden) {
      borderColor = const Color(0xFFDCE3F4);
      background = const Color(0xFFF6F8FD);
    }

    if (selectedAnswer != null && isCorrect) {
      borderColor = const Color(0xFF13C4A3);
      background = const Color(0xFFEAFBF7);
    } else if (selectedAnswer != null && isSelected && !isCorrect) {
      borderColor = const Color(0xFFD1495B);
      background = const Color(0xFFFFEEF1);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: selectedAnswer != null ? 2 : 1),
        boxShadow: [
          if (selectedAnswer != null && isCorrect)
            BoxShadow(
              color: const Color(0xFF13C4A3).withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: locked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hidden ? 'Alternativa removida' : '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: hidden ? const Color(0xFF94A1BD) : null,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: _motionDuration(180),
                  child: selectedAnswer == null
                      ? (hidden
                          ? const Icon(
                              Icons.visibility_off_rounded,
                              key: ValueKey<String>('hidden'),
                              color: Color(0xFF94A1BD),
                            )
                          : const SizedBox.shrink())
                      : Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : isSelected
                                  ? Icons.cancel_rounded
                                  : Icons.circle_outlined,
                          key: ValueKey<String>('${selectedAnswer}_$value'),
                          color: isCorrect
                              ? const Color(0xFF13C4A3)
                              : isSelected
                                  ? const Color(0xFFD1495B)
                                  : const Color(0xFFB0B9D1),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AnimatedSwitcher(
          duration: _motionDuration(220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class _MomentumBanner extends StatelessWidget {
  const _MomentumBanner({
    required this.combo,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  final int combo;
  final int correctAnswers;
  final int wrongAnswers;

  @override
  Widget build(BuildContext context) {
    final bool hotStreak = combo >= 4;
    final Color baseColor = hotStreak ? const Color(0xFFFFB703) : const Color(0xFF2D55FF);
    final String title = hotStreak ? 'Ritmo quente' : 'Ritmo em construcao';
    final String subtitle = hotStreak
        ? 'Combo x$combo ativo. Essa e a hora de empilhar pontos.'
        : 'Acertos: $correctAnswers | Erros: $wrongAnswers';

    return AnimatedContainer(
      duration: _motionDuration(240),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.18),
            baseColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: baseColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            hotStreak ? Icons.local_fire_department_rounded : Icons.bolt_rounded,
            color: baseColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
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

class _AnswerFeedbackBanner extends StatelessWidget {
  const _AnswerFeedbackBanner({
    required this.correct,
    required this.correctAnswer,
    required this.scoreDelta,
  });

  final bool correct;
  final int correctAnswer;
  final int scoreDelta;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = correct ? const Color(0xFF13C4A3) : const Color(0xFFD1495B);
    final String title = correct ? 'Resposta certa' : 'Resposta errada';
    final String subtitle = correct
        ? 'Boa. +$scoreDelta pontos para manter o ritmo.'
        : 'A correta era $correctAnswer. Ajuste rapido e siga em frente.';

    return AnimatedContainer(
      duration: _motionDuration(220),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.16),
            baseColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: baseColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: baseColor,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              correct ? '+$scoreDelta' : '$scoreDelta',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
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

class _MiniStatRow extends StatelessWidget {
  const _MiniStatRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.title,
    required this.summary,
    required this.starsEarned,
    required this.perfectRun,
    required this.score,
    required this.targetScore,
    required this.correctAnswers,
    required this.bestCombo,
    required this.objectiveResults,
    required this.coinsEarned,
    required this.xpEarned,
    required this.nextLevelId,
    required this.onRestart,
    required this.onNextLevel,
    required this.onExit,
  });

  final String title;
  final String summary;
  final int starsEarned;
  final bool perfectRun;
  final int score;
  final int targetScore;
  final int correctAnswers;
  final int bestCombo;
  final List<_ObjectiveResult> objectiveResults;
  final int coinsEarned;
  final int xpEarned;
  final int? nextLevelId;
  final VoidCallback onRestart;
  final VoidCallback? onNextLevel;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF09101F).withValues(alpha: 0.66),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4A5572),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: List<Widget>.generate(3, (index) {
                    final active = index < starsEarned;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.star_rounded,
                        size: 34,
                        color: active ? const Color(0xFFFFB703) : const Color(0xFFD6DBEA),
                      ),
                    );
                  }),
                ),
                if (perfectRun) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD166),
                          Color(0xFFFFB703),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Selo de fase perfeita',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _MiniStatRow(label: 'Score final', value: '$score / $targetScore'),
                _MiniStatRow(label: 'Acertos', value: '$correctAnswers'),
                _MiniStatRow(label: 'Melhor combo', value: '$bestCombo'),
                _MiniStatRow(label: 'Moedas ganhas', value: '+$coinsEarned'),
                _MiniStatRow(label: 'XP ganho', value: '+$xpEarned'),
                const SizedBox(height: 18),
                Text(
                  'Objetivos secundarios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...objectiveResults.map(
                  (objective) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ObjectiveResultTile(objective: objective),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onExit,
                        child: const Text('Voltar ao mapa'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton(
                        onPressed: onRestart,
                        child: const Text('Jogar novamente'),
                      ),
                    ),
                  ],
                ),
                if (nextLevelId != null) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: Text('Ir para fase $nextLevelId'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ObjectiveResultTile extends StatelessWidget {
  const _ObjectiveResultTile({required this.objective});

  final _ObjectiveResult objective;

  @override
  Widget build(BuildContext context) {
    final baseColor =
        objective.completed ? const Color(0xFF13C4A3) : const Color(0xFFD6DBEA);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: objective.completed
            ? baseColor.withValues(alpha: 0.10)
            : const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: objective.completed
              ? baseColor.withValues(alpha: 0.24)
              : const Color(0xFFE1E6F4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            objective.completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: objective.completed ? baseColor : const Color(0xFF97A3BF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  objective.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  objective.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
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
