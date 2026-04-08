import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/state/campaign_progress.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import '../game/level_preview_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  static const double _estimatedChapterHeight = 2660;
  static const double _estimatedNodeGap = 112;

  final ScrollController _scrollController = ScrollController();
  late final AnimationController _pulseController;
  int? _lastAutoScrolledLevelId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scheduleAutoScroll(LevelProgressView level) {
    if (_lastAutoScrolledLevelId == level.id) {
      return;
    }
    _lastAutoScrolledLevelId = level.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final chapterIndex = level.chapterId - 1;
      final levelInChapter = (level.id - 1) % 20;
      final rawOffset =
          (chapterIndex * _estimatedChapterHeight) + (levelInChapter * _estimatedNodeGap);
      final target = rawOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final campaign = CampaignProgressController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([campaign, _pulseController]),
      builder: (context, _) {
        final viewport = MediaQuery.sizeOf(context);
        final compact = viewport.width < 860;
        final nextLevel = campaign.nextPlayableLevel;
        _scheduleAutoScroll(nextLevel);

        return Scaffold(
          body: ShellFrame(
            maxWidth: 1360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MapHeader(
                  compact: compact,
                  totalLevels: campaign.levels.length,
                  completedLevels: campaign.completedLevels,
                  unlockedLevels: campaign.unlockedLevels,
                  totalStars: campaign.totalStars,
                  currentLevelId: nextLevel.id,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _CampaignOverview(
                          compact: compact,
                          nextLevel: nextLevel,
                          progress: campaign.campaignProgress,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 20, bottom: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final chapter = campaign.chapters[index];
                              final chapterLevels = campaign.levelsForChapter(chapter.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: _ChapterPathSection(
                                  chapterTitle: chapter.title,
                                  chapterSubtitle: chapter.subtitle,
                                  chapterColor: chapter.themeColor,
                                  chapterUnlockStarsRequired: chapter.unlockStarsRequired,
                                  levels: chapterLevels,
                                  medal: campaign.medalForChapter(chapter.id),
                                  highlightedLevelId: nextLevel.id,
                                  pulseValue: _pulseController.value,
                                ),
                              );
                            },
                            childCount: campaign.chapters.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: _MoreLevelsTeaser(),
                      ),
                    ],
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

class _MoreLevelsTeaser extends StatelessWidget {
  const _MoreLevelsTeaser();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SectionCard(
        child: Column(
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8E5CFF),
                    Color(0xFF2D55FF),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D55FF).withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Mais fases em breve',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'A jornada atual vai ate a fase 500. Novos mundos, desafios e chefes extras vao expandir o mapa nas proximas atualizacoes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF55607B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.compact,
    required this.totalLevels,
    required this.completedLevels,
    required this.unlockedLevels,
    required this.totalStars,
    required this.currentLevelId,
  });

  final bool compact;
  final int totalLevels;
  final int completedLevels;
  final int unlockedLevels;
  final int totalStars;
  final int currentLevelId;

  @override
  Widget build(BuildContext context) {
    final description = compact
        ? 'Mapa em trilha com 500 fases conectadas por capitulos.'
        : 'Mapa em trilha com 500 fases conectadas, progressao crescente e visual de saga para navegar a campanha inteira.';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        SizedBox(
          width: compact ? MediaQuery.sizeOf(context).width - 120 : 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mapa de niveis',
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
        _HeaderChip(label: 'Fases', value: '$completedLevels / $totalLevels'),
        _HeaderChip(label: 'Abertas', value: '$unlockedLevels'),
        _HeaderChip(label: 'Estrelas', value: '$totalStars'),
        _HeaderChip(label: 'Atual', value: 'Fase $currentLevelId'),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _CampaignOverview extends StatelessWidget {
  const _CampaignOverview({
    required this.compact,
    required this.nextLevel,
    required this.progress,
  });

  final bool compact;
  final LevelProgressView nextLevel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 980 : 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campanha longa em formato de saga',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Cada capitulo vira um caminho com linhas e nos conectados. O jogador acompanha a trilha, ve os chefes e sente melhor a progressao da jornada.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(100),
                ),
                const SizedBox(height: 8),
                Text('${(progress * 100).round()}% da campanha concluida'),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 980 : 360),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E9F7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proxima fase sugerida',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fase ${nextLevel.id}: ${nextLevel.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextLevel.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF55607B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: nextLevel.focusTopics
                        .take(4)
                        .map((topic) => Chip(label: Text(topic.label)))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterPathSection extends StatelessWidget {
  const _ChapterPathSection({
    required this.chapterTitle,
    required this.chapterSubtitle,
    required this.chapterColor,
    required this.chapterUnlockStarsRequired,
    required this.levels,
    required this.medal,
    required this.highlightedLevelId,
    required this.pulseValue,
  });

  final String chapterTitle;
  final String chapterSubtitle;
  final Color chapterColor;
  final int chapterUnlockStarsRequired;
  final List<LevelProgressView> levels;
  final ChapterMedalView medal;
  final int highlightedLevelId;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final chapterUnlocked = levels.any((level) => level.unlocked);
    final chapterStars = levels.fold<int>(0, (sum, level) => sum + level.stars);

    return SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: chapterColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  chapterUnlocked ? Icons.auto_awesome_rounded : Icons.lock_rounded,
                  color: chapterColor,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapterSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF55607B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: chapterUnlocked
                      ? chapterColor.withValues(alpha: 0.12)
                      : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  chapterUnlocked
                      ? '$chapterStars estrelas neste capitulo'
                      : 'Abre com $chapterUnlockStarsRequired estrelas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: chapterUnlocked ? chapterColor : const Color(0xFF67728E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: chapterColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Medalha ${medal.tierLabel} • ${medal.perfectLevels} perfeitas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: chapterColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ChapterPathBoard(
            levels: levels,
            accent: chapterColor,
            highlightedLevelId: highlightedLevelId,
            pulseValue: pulseValue,
          ),
        ],
      ),
    );
  }
}

class _ChapterPathBoard extends StatelessWidget {
  const _ChapterPathBoard({
    required this.levels,
    required this.accent,
    required this.highlightedLevelId,
    required this.pulseValue,
  });

  final List<LevelProgressView> levels;
  final Color accent;
  final int highlightedLevelId;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(320.0, constraints.maxWidth);
        final points = _buildPathPoints(width, levels.length);
        final boardHeight = points.isEmpty ? 320.0 : points.last.dy + 170;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF9FBFF),
                Color(0xFFF1F5FF),
                Color(0xFFFFFAF0),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: SizedBox(
            height: boardHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      points: points,
                      accent: accent,
                    ),
                  ),
                ),
                ...List<Widget>.generate(levels.length, (index) {
                  final point = points[index];
                  final level = levels[index];

                  return Positioned(
                    left: point.dx - 72,
                    top: point.dy - 38,
                    child: _PathNode(
                      level: level,
                      accent: accent,
                      highlighted: level.id == highlightedLevelId,
                      pulseValue: pulseValue,
                      localLevelNumber: index + 1,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.level,
    required this.accent,
    required this.highlighted,
    required this.pulseValue,
    required this.localLevelNumber,
  });

  final LevelProgressView level;
  final Color accent;
  final bool highlighted;
  final double pulseValue;
  final int localLevelNumber;

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final nodeColor = locked
        ? const Color(0xFFE2E8F7)
        : level.isBoss
            ? const Color(0xFFFFB703)
            : accent;
    final textColor = locked ? const Color(0xFF67728E) : Colors.white;
    final scale = highlighted ? 1 + (pulseValue * 0.08) : 1.0;
    final showCheckpoint = localLevelNumber % 5 == 0;

    return SizedBox(
      width: 144,
      child: Column(
        children: [
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Fase atual',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (highlighted)
                Transform.scale(
                  scale: 1.12 + (pulseValue * 0.10),
                  child: Container(
                    width: level.isBoss ? 102 : 92,
                    height: level.isBoss ? 102 : 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: locked
                    ? null
                    : () {
                        CampaignProgressController.instance.selectLevel(level.id);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LevelPreviewScreen(levelId: level.id),
                          ),
                        );
                      },
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: level.isBoss ? 82 : 72,
                    height: level.isBoss ? 82 : 72,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: nodeColor.withValues(
                            alpha: locked ? 0.08 : highlighted ? 0.28 : 0.20,
                          ),
                          blurRadius: highlighted ? 30 : 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: locked ? 0.36 : 0.78),
                        width: highlighted ? 4 : 3,
                      ),
                    ),
                    child: Center(
                      child: level.isBoss && !locked
                          ? Icon(
                              Icons.whatshot_rounded,
                              color: textColor,
                              size: 30,
                            )
                          : Text(
                              '${level.id}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              if (level.isBoss)
                Positioned(
                  top: -10,
                  right: 20,
                  child: _NodeBadge(
                    label: 'Boss',
                    color: const Color(0xFFFFB703),
                  ),
                )
              else if (showCheckpoint)
                Positioned(
                  top: -10,
                  right: 20,
                  child: _NodeBadge(
                    label: 'CP',
                    color: accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            level.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            locked ? 'Bloqueada' : '${level.stars}/3 estrelas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF66718F),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.points,
    required this.accent,
  });

  final List<Offset> points;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final midY = (previous.dy + current.dy) / 2;

      path.cubicTo(
        previous.dx,
        midY,
        current.dx,
        midY,
        current.dx,
        current.dy,
      );
    }

    final outerPaint = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.accent != accent;
  }
}

List<Offset> _buildPathPoints(double width, int count) {
  const xPattern = <double>[0.16, 0.42, 0.78, 0.60, 0.24];
  const startY = 70.0;
  const verticalGap = 112.0;

  return List<Offset>.generate(count, (index) {
    final xFactor = xPattern[index % xPattern.length];
    final waveOffset = ((index ~/ xPattern.length) % 2 == 0) ? 0.0 : 0.06;
    final x = width * (xFactor + waveOffset).clamp(0.14, 0.86);
    final y = startY + (index * verticalGap);

    return Offset(x, y);
  }, growable: false);
}
