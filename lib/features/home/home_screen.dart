import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/data/sample_data.dart';
import '../../core/data/shop_data.dart';
import '../../core/state/campaign_progress.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import '../game/level_preview_screen.dart';
import '../map/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final campaign = CampaignProgressController.instance;
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([campaign, profile]),
      builder: (context, _) {
        final nextLevel = campaign.nextPlayableLevel;
        final avatar = itemById(profile.avatarId);
        final dailyRewardReady = profile.dailyRewardAvailable;

        return Scaffold(
          body: ShellFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeTopBar(
                  profile: profile,
                  avatar: avatar,
                  nextLevelId: nextLevel.id,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: SingleChildScrollView(
                                child: _MainColumn(
                                  campaign: campaign,
                                  profile: profile,
                                  nextLevel: nextLevel,
                                  dailyRewardReady: dailyRewardReady,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(
                                child: _SideColumn(
                                  campaign: campaign,
                                  profile: profile,
                                  dailyRewardReady: dailyRewardReady,
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _MainColumn(
                                campaign: campaign,
                                profile: profile,
                                nextLevel: nextLevel,
                                dailyRewardReady: dailyRewardReady,
                              ),
                              const SizedBox(height: 20),
                              _SideColumn(
                                campaign: campaign,
                                profile: profile,
                                dailyRewardReady: dailyRewardReady,
                              ),
                            ],
                          ),
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

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.profile,
    required this.avatar,
    required this.nextLevelId,
  });

  final PlayerProfileController profile;
  final ShopItemDefinition avatar;
  final int nextLevelId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: avatar.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(avatar.icon, color: avatar.color),
        ),
        SizedBox(
          width: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ola, ${profile.displayName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Nivel ${profile.level} | ${profile.coins} moedas | ${profile.xpIntoCurrentLevel}/450 XP',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Titulo ativo: ${profile.activeTitleLabel}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF66718F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mascote ativo: ${itemById(profile.mascotId).title}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF7A86A5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 760)
          FilledButton.icon(
            onPressed: () => _openLevel(context, nextLevelId),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Continuar campanha'),
          ),
      ],
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.campaign,
    required this.profile,
    required this.nextLevel,
    required this.dailyRewardReady,
  });

  final CampaignProgressController campaign;
  final PlayerProfileController profile;
  final LevelProgressView nextLevel;
  final bool dailyRewardReady;

  @override
  Widget build(BuildContext context) {
    final startIndex = nextLevel.chapterId <= 3 ? 0 : nextLevel.chapterId - 3;
    final visibleChapters = sampleChapters.skip(startIndex).take(6).toList(growable: false);

    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temporada 1: Arranque Mental',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (profile.sessionWelcomeMessage.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(profile.sessionWelcomeMessage),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Campanha, missões, ranking, loja e perfil agora compartilham o mesmo progresso local.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: campaign.campaignProgress.clamp(0.0, 1.0),
                minHeight: 12,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(campaign.campaignProgress * 100).round()}% da campanha inicial'),
                  Text('${campaign.totalStars} / ${campaign.levels.length * 3} estrelas'),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(20),
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
                      nextLevel.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(nextLevel.description),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: nextLevel.focusTopics
                          .map((topic) => Chip(label: Text(topic.label)))
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    ),
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Abrir mapa'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openLevel(context, nextLevel.id),
                    icon: const Icon(Icons.sports_esports_rounded),
                    label: const Text('Jogar fase sugerida'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoute.profile),
                    icon: const Icon(Icons.person_rounded),
                    label: const Text('Abrir perfil'),
                  ),
                ],
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
                'Capitulos por perto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: visibleChapters
                    .map(
                      (chapter) => SizedBox(
                        width: 280,
                        child: _ChapterCard(
                          chapter: chapter,
                          totalStars: campaign.totalStars,
                          medal: campaign.medalForChapter(chapter.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              Text(
                'Modos e atalhos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final width = compact ? double.infinity : (constraints.maxWidth - 32) / 3;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        child: _ActionCard(
                          title: 'Campanha',
                          subtitle: 'Mapa por fases com estrelas, objetivos e chefes.',
                          actionLabel: 'Entrar',
                          icon: Icons.route_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MapScreen()),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ActionCard(
                          title: 'Modos',
                          subtitle:
                              'Campanha, contra o tempo, sobrevivencia, combo rush e evento.',
                          actionLabel: 'Abrir',
                          icon: Icons.videogame_asset_rounded,
                          onTap: () => Navigator.of(context).pushNamed(AppRoute.modes),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ActionCard(
                          title: 'Treino',
                          subtitle: 'Revise erros, veja topicos fracos e abra sessoes focadas.',
                          actionLabel: 'Treinar',
                          icon: Icons.school_rounded,
                          onTap: () => Navigator.of(context).pushNamed(AppRoute.training),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ActionCard(
                          title: 'Evento sazonal',
                          subtitle: 'Capitulo bonus, missoes exclusivas e cosmeticos temporarios.',
                          actionLabel: 'Abrir evento',
                          icon: Icons.auto_awesome_rounded,
                          onTap: () => Navigator.of(context).pushNamed(AppRoute.events),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ActionCard(
                          title: 'Missoes',
                          subtitle: dailyRewardReady
                              ? 'Recompensa diaria pronta para coleta.'
                              : 'Acompanhe rotina diaria e semanal.',
                          actionLabel: 'Abrir',
                          icon: Icons.task_alt_rounded,
                          onTap: () => Navigator.of(context).pushNamed(AppRoute.missions),
                        ),
                      ),
                    ],
                  );
                },
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
                'Progressao forte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _StatRow(label: 'Titulo ativo', value: profile.activeTitleLabel),
              _StatRow(
                label: 'Conquistas liberadas',
                value: '${profile.unlockedAchievementsCount}/${profile.achievements.length}',
              ),
              _StatRow(
                label: 'Fases perfeitas',
                value: '${campaign.perfectLevels}',
              ),
              _StatRow(
                label: 'Marcos de nivel prontos',
                value: '${profile.availableLevelMilestoneRewardsCount}',
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: profile.levelProgress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: 8),
              Text(
                'Nivel ${profile.level} em andamento: ${profile.xpIntoCurrentLevel}/450 XP',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55607B),
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
                'Capitulos em destaque',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 640;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: sampleSubjects
                        .map(
                          (subject) => SizedBox(
                            width: compact ? double.infinity : (constraints.maxWidth - 16) / 2,
                            child: _SubjectCard(subject: subject),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.campaign,
    required this.profile,
    required this.dailyRewardReady,
  });

  final CampaignProgressController campaign;
  final PlayerProfileController profile;
  final bool dailyRewardReady;

  @override
  Widget build(BuildContext context) {
    final dailyMissions = profile.dailyMissions;
    final weeklyComparison = profile.weeklyComparison;

    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rotina de hoje',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _MissionTile(
                title: dailyMissions[0].title,
                subtitle: '${dailyMissions[0].rewardCoins} moedas',
                progress: dailyMissions[0].progressRatio,
              ),
              const SizedBox(height: 12),
              _MissionTile(
                title: dailyMissions[1].title,
                subtitle: '${dailyMissions[1].rewardCoins} moedas',
                progress: dailyMissions[1].progressRatio,
              ),
              const SizedBox(height: 12),
              _MissionTile(
                title: dailyRewardReady ? 'Recompensa diaria pronta' : 'Recompensa diaria coletada',
                subtitle: dailyRewardReady
                    ? '+${profile.dailyRewardPreviewCoins} moedas no login'
                    : 'Volte amanha para continuar o streak',
                progress: dailyRewardReady ? 1 : 0,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoute.missions),
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Abrir missoes'),
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
                'Resumo rapido',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _StatRow(label: 'Fases concluidas', value: '${campaign.completedLevels}'),
              _StatRow(label: 'Fases abertas', value: '${campaign.unlockedLevels}'),
              _StatRow(label: 'Total de estrelas', value: '${campaign.totalStars}'),
              _StatRow(label: 'Melhor score geral', value: '${profile.bestScore}'),
              _StatRow(label: 'Melhor combo', value: 'x${profile.bestCombo}'),
              _StatRow(label: 'Streak diaria', value: '${profile.dailyStreak}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treino inteligente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Topico sugerido agora: ${profile.recommendedTrainingTopic.topic.label}.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55607B),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoute.training),
                icon: const Icon(Icons.auto_graph_rounded),
                label: const Text('Abrir treino e revisao'),
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
                'Camada social',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${weeklyComparison.trendLabel}: ${weeklyComparison.delta >= 0 ? '+' : ''}${weeklyComparison.delta} pontos no comparativo semanal.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ranking global, semanal e entre amigos ja esta pronto localmente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55607B),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoute.ranking),
                icon: const Icon(Icons.leaderboard_rounded),
                label: const Text('Ver ranking'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.totalStars,
    required this.medal,
  });

  final ChapterDefinition chapter;
  final int totalStars;
  final ChapterMedalView medal;

  @override
  Widget build(BuildContext context) {
    final unlocked = totalStars >= chapter.unlockStarsRequired;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: unlocked
              ? chapter.themeColor.withValues(alpha: 0.22)
              : const Color(0xFFE1E7F5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked ? Icons.auto_awesome_rounded : Icons.lock_rounded,
                color: unlocked ? chapter.themeColor : const Color(0xFF97A3BF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            chapter.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            unlocked
                ? 'Destravado com ${chapter.unlockStarsRequired} estrelas.'
                : 'Precisa de ${chapter.unlockStarsRequired} estrelas para abrir.',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: chapter.themeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Medalha ${medal.tierLabel} | ${medal.earnedStars}/${medal.maxStars} estrelas',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: chapter.themeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final SubjectSummary subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: subject.color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              subject.badge,
              style: TextStyle(
                color: subject.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subject.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: subject.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(100),
            color: subject.color,
          ),
          const SizedBox(height: 10),
          Text('${(subject.progress * 100).round()}% concluido'),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF66718F),
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(100),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

void _openLevel(BuildContext context, int levelId) {
  CampaignProgressController.instance.selectLevel(levelId);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LevelPreviewScreen(levelId: levelId),
    ),
  );
}
