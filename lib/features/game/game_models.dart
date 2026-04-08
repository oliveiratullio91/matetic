import 'dart:math';

import '../../core/data/math_topics.dart';
import '../../core/data/sample_data.dart';

class MathQuestion {
  const MathQuestion({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.topic,
    required this.difficultyLabel,
    required this.explanation,
  });

  final String prompt;
  final List<int> options;
  final int correctAnswer;
  final MathTopic topic;
  final String difficultyLabel;
  final String explanation;
}

class GameSessionConfig {
  const GameSessionConfig({
    required this.totalQuestions,
    required this.durationInSeconds,
    required this.targetScore,
    required this.phaseTitle,
    required this.ruleSummary,
    required this.focusTopics,
    required this.modifiers,
    required this.baseScorePerHit,
    required this.scorePenaltyOnMiss,
    required this.timePenaltyOnMiss,
    required this.speedBonusMultiplier,
    required this.comboScoreMultiplier,
    required this.extraSecondsOnCorrect,
    required this.scoreGainMultiplier,
    required this.maxWrongAnswers,
    required this.pauseEnabled,
    required this.difficultyTier,
  });

  final int totalQuestions;
  final int durationInSeconds;
  final int targetScore;
  final String phaseTitle;
  final String ruleSummary;
  final List<MathTopic> focusTopics;
  final List<PhaseModifierDefinition> modifiers;
  final int baseScorePerHit;
  final int scorePenaltyOnMiss;
  final int timePenaltyOnMiss;
  final int speedBonusMultiplier;
  final int comboScoreMultiplier;
  final int extraSecondsOnCorrect;
  final double scoreGainMultiplier;
  final int? maxWrongAnswers;
  final bool pauseEnabled;
  final int difficultyTier;
}

class MathQuestionFactory {
  MathQuestionFactory({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<MathQuestion> buildSessionQuestions(GameSessionConfig config) {
    return List<MathQuestion>.generate(
      config.totalQuestions,
      (index) => _buildQuestion(index, config),
    );
  }

  MathQuestion _buildQuestion(int index, GameSessionConfig config) {
    final difficultyLevel = config.difficultyTier + (index ~/ 3);
    final topic = config.focusTopics[(index + config.difficultyTier) % config.focusTopics.length];

    return switch (topic) {
      MathTopic.addition => _buildAdditionQuestion(difficultyLevel),
      MathTopic.subtraction => _buildSubtractionQuestion(difficultyLevel),
      MathTopic.multiplication => _buildMultiplicationQuestion(difficultyLevel),
      MathTopic.division => _buildDivisionQuestion(difficultyLevel),
      MathTopic.mixedOperations => _buildMixedOperationQuestion(difficultyLevel),
      MathTopic.fractions => _buildFractionQuestion(difficultyLevel),
      MathTopic.percentages => _buildPercentageQuestion(difficultyLevel),
      MathTopic.powers => _buildPowerQuestion(difficultyLevel),
      MathTopic.equations => _buildEquationQuestion(difficultyLevel),
      MathTopic.sequences => _buildSequenceQuestion(difficultyLevel),
    };
  }

  MathQuestion _buildAdditionQuestion(int difficultyLevel) {
    final maxA = 10 + (difficultyLevel * 7);
    final maxB = 8 + (difficultyLevel * 6);
    final a = 6 + _random.nextInt(maxA);
    final b = 4 + _random.nextInt(maxB);
    final correct = a + b;

    return MathQuestion(
      prompt: 'Quanto e $a + $b?',
      options: _buildOptions(correct, spread: 3 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.addition,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: 'Somar $a com $b resulta em $correct.',
    );
  }

  MathQuestion _buildSubtractionQuestion(int difficultyLevel) {
    final b = 5 + _random.nextInt(10 + difficultyLevel * 3);
    final correct = 12 + _random.nextInt(16 + difficultyLevel * 5);
    final a = correct + b;

    return MathQuestion(
      prompt: 'Quanto e $a - $b?',
      options: _buildOptions(correct, spread: 4 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.subtraction,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: 'Na subtracao, tiramos $b de $a e sobramos com $correct.',
    );
  }

  MathQuestion _buildMultiplicationQuestion(int difficultyLevel) {
    final clampedDifficulty = _clampInt(difficultyLevel, 1, 10);
    final a = 3 + _random.nextInt(4 + clampedDifficulty);
    final b = 4 + _random.nextInt(5 + clampedDifficulty);
    final correct = a * b;

    return MathQuestion(
      prompt: 'Quanto e $a x $b?',
      options: _buildOptions(correct, spread: 5 + difficultyLevel * 2),
      correctAnswer: correct,
      topic: MathTopic.multiplication,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: '$a vezes $b forma $correct porque estamos somando $a, $b vezes.',
    );
  }

  MathQuestion _buildDivisionQuestion(int difficultyLevel) {
    final clampedDifficulty = _clampInt(difficultyLevel, 1, 10);
    final divisor = 2 + _random.nextInt(4 + clampedDifficulty);
    final correct = 3 + _random.nextInt(5 + clampedDifficulty);
    final dividend = divisor * correct;

    return MathQuestion(
      prompt: 'Quanto e $dividend / $divisor?',
      options: _buildOptions(correct, spread: 2 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.division,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: '$dividend dividido por $divisor e $correct porque $correct x $divisor = $dividend.',
    );
  }

  MathQuestion _buildMixedOperationQuestion(int difficultyLevel) {
    final a = 2 + _random.nextInt(6 + difficultyLevel);
    final b = 2 + _random.nextInt(5 + difficultyLevel);
    final c = 2 + _random.nextInt(4 + (difficultyLevel ~/ 2));
    final useMultiplierFirst = _random.nextBool();
    final prompt = useMultiplierFirst
        ? 'Quanto e $a + ($b x $c)?'
        : 'Quanto e ($a + $b) x $c?';
    final correct = useMultiplierFirst ? a + (b * c) : (a + b) * c;

    return MathQuestion(
      prompt: prompt,
      options: _buildOptions(correct, spread: 6 + difficultyLevel * 2),
      correctAnswer: correct,
      topic: MathTopic.mixedOperations,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: useMultiplierFirst
          ? 'Primeiro fazemos $b x $c e depois somamos $a, chegando a $correct.'
          : 'Primeiro somamos $a + $b e depois multiplicamos por $c, totalizando $correct.',
    );
  }

  MathQuestion _buildFractionQuestion(int difficultyLevel) {
    final allowedDenominators = <int>[2, 3, 4, 5, 6, 8, 10];
    final denominator = allowedDenominators[_random.nextInt(
      mathMin(allowedDenominators.length, 3 + (difficultyLevel ~/ 2)),
    )];
    final numerator = 1 + _random.nextInt(denominator - 1);
    final unit = 4 + _random.nextInt(4 + difficultyLevel);
    final baseValue = denominator * unit;
    final correct = (baseValue * numerator) ~/ denominator;

    return MathQuestion(
      prompt: 'Quanto e $numerator/$denominator de $baseValue?',
      options: _buildOptions(correct, spread: 3 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.fractions,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: '$numerator/$denominator de $baseValue equivale a dividir por $denominator e pegar $numerator partes: $correct.',
    );
  }

  MathQuestion _buildPercentageQuestion(int difficultyLevel) {
    const easyRates = <int>[10, 20, 25, 50];
    const mediumRates = <int>[5, 10, 12, 15, 20, 25, 30, 40, 50];
    const hardRates = <int>[5, 8, 12, 15, 18, 20, 25, 30, 35, 40, 60, 75];
    final pool = difficultyLevel <= 5
        ? easyRates
        : difficultyLevel <= 10
            ? mediumRates
            : hardRates;
    final rate = pool[_random.nextInt(pool.length)];
    final multiplier = 2 + _random.nextInt(4 + difficultyLevel);
    final baseValue = (100 ~/ _greatestCommonDivisor(100, rate)) * multiplier;
    final correct = (baseValue * rate) ~/ 100;

    return MathQuestion(
      prompt: 'Quanto e $rate% de $baseValue?',
      options: _buildOptions(correct, spread: 4 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.percentages,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: '$rate% de $baseValue corresponde a ($rate/100) x $baseValue = $correct.',
    );
  }

  MathQuestion _buildPowerQuestion(int difficultyLevel) {
    final base = 2 + _random.nextInt(difficultyLevel >= 10 ? 4 : 3);
    final exponent = difficultyLevel >= 9 ? 3 + _random.nextInt(2) : 2 + _random.nextInt(2);
    final correct = pow(base, exponent).toInt();

    return MathQuestion(
      prompt: 'Quanto e $base^$exponent?',
      options: _buildOptions(correct, spread: 5 + difficultyLevel * 3),
      correctAnswer: correct,
      topic: MathTopic.powers,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: '$base^$exponent significa multiplicar $base por ele mesmo $exponent vezes, resultando em $correct.',
    );
  }

  MathQuestion _buildEquationQuestion(int difficultyLevel) {
    final x = 3 + _random.nextInt(8 + difficultyLevel);
    final offset = 4 + _random.nextInt(6 + difficultyLevel);
    final multiplier = difficultyLevel >= 9 ? 2 + _random.nextInt(3) : 1;
    final total = (x * multiplier) + offset;
    final prompt = multiplier == 1
        ? 'Resolva: x + $offset = $total'
        : 'Resolva: ${multiplier}x + $offset = $total';

    return MathQuestion(
      prompt: prompt,
      options: _buildOptions(x, spread: 3 + difficultyLevel),
      correctAnswer: x,
      topic: MathTopic.equations,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: multiplier == 1
          ? 'Basta isolar x: $total - $offset = $x.'
          : 'Primeiro tiramos $offset de $total e depois dividimos por $multiplier, chegando a x = $x.',
    );
  }

  MathQuestion _buildSequenceQuestion(int difficultyLevel) {
    final useGeometric = difficultyLevel >= 10 && _random.nextBool();
    if (useGeometric) {
      final ratio = 2 + _random.nextInt(2);
      final start = 2 + _random.nextInt(4 + (difficultyLevel ~/ 3));
      final second = start * ratio;
      final third = second * ratio;
      final correct = third * ratio;

      return MathQuestion(
        prompt: 'Qual e o proximo termo da sequencia $start, $second, $third, ...?',
        options: _buildOptions(correct, spread: ratio * (2 + difficultyLevel)),
        correctAnswer: correct,
        topic: MathTopic.sequences,
        difficultyLabel: _difficultyLabel(difficultyLevel),
        explanation: 'A sequencia e geometrica, multiplicando sempre por $ratio. O proximo termo e $correct.',
      );
    }

    final step = 2 + _random.nextInt(4 + difficultyLevel);
    final start = 4 + _random.nextInt(8 + difficultyLevel);
    final second = start + step;
    final third = second + step;
    final correct = third + step;

    return MathQuestion(
      prompt: 'Qual e o proximo termo da sequencia $start, $second, $third, ...?',
      options: _buildOptions(correct, spread: 3 + difficultyLevel),
      correctAnswer: correct,
      topic: MathTopic.sequences,
      difficultyLabel: _difficultyLabel(difficultyLevel),
      explanation: 'A sequencia cresce sempre em $step. Depois de $third, o proximo termo e $correct.',
    );
  }

  List<int> _buildOptions(int correctAnswer, {required int spread}) {
    final values = <int>{correctAnswer};

    while (values.length < 4) {
      final signal = _random.nextBool() ? 1 : -1;
      final offset = signal * (1 + _random.nextInt(spread + 1));
      final candidate = max(0, correctAnswer + offset);
      values.add(candidate);
    }

    final shuffled = values.toList()..shuffle(_random);
    return shuffled;
  }

  String _difficultyLabel(int difficultyLevel) {
    if (difficultyLevel <= 3) {
      return 'Leve';
    }
    if (difficultyLevel <= 7) {
      return 'Media';
    }
    if (difficultyLevel <= 11) {
      return 'Forte';
    }
    return 'Elite';
  }

  int _greatestCommonDivisor(int a, int b) {
    var x = a.abs();
    var y = b.abs();

    while (y != 0) {
      final rest = x % y;
      x = y;
      y = rest;
    }

    return x;
  }

  int mathMin(int a, int b) => a < b ? a : b;

  int _clampInt(int value, int lower, int upper) {
    if (value < lower) {
      return lower;
    }
    if (value > upper) {
      return upper;
    }
    return value;
  }
}
