import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/data/shop_data.dart';
import '../../core/state/campaign_progress.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: PlayerProfileController.instance.displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;
    final campaign = CampaignProgressController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([profile, campaign]),
      builder: (context, _) {
        final avatar = itemById(profile.avatarId);
        final theme = itemById(profile.themeId);
        final frame = itemById(profile.frameId);
        final effect = itemById(profile.effectId);
        final mascot = itemById(profile.mascotId);

        return Scaffold(
          body: ShellFrame(
            maxWidth: 1000,
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
                            'Perfil do jogador',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Conta local com estatisticas, configuracoes e personalizacao.',
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
                      final wide = constraints.maxWidth >= 860;
                      final mainCard = _ProfileSummaryCard(
                        profile: profile,
                        campaign: campaign,
                        avatar: avatar,
                        theme: theme,
                        frame: frame,
                        effect: effect,
                        mascot: mascot,
                        nameController: _nameController,
                      );
                      final sideCard = _SettingsCard(
                        profile: profile,
                        campaign: campaign,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(child: mainCard),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(child: sideCard),
                            ),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            mainCard,
                            const SizedBox(height: 20),
                            sideCard,
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
    required this.campaign,
    required this.avatar,
    required this.theme,
    required this.frame,
    required this.effect,
    required this.mascot,
    required this.nameController,
  });

  final PlayerProfileController profile;
  final CampaignProgressController campaign;
  final ShopItemDefinition avatar;
  final ShopItemDefinition theme;
  final ShopItemDefinition frame;
  final ShopItemDefinition effect;
  final ShopItemDefinition mascot;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: avatar.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: frame.color, width: 3),
                ),
                child: Icon(avatar.icon, color: avatar.color, size: 42),
              ),
              SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Nivel ${profile.level} | ${profile.coins} moedas | tema ${theme.title}',
                    ),
                    const SizedBox(height: 4),
                    Text('Titulo ativo: ${profile.activeTitleLabel}'),
                    const SizedBox(height: 4),
                    Text('Moldura ${frame.title} | efeito ${effect.title}'),
                    const SizedBox(height: 4),
                    Text('Mascote ${mascot.title} acompanha seu perfil'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nome exibido',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => profile.updateDisplayName(nameController.text),
            child: const Text('Salvar nome'),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: profile.levelProgress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: 10),
          Text('${profile.xpIntoCurrentLevel}/450 XP para o proximo nivel'),
          const SizedBox(height: 6),
          Text(
            profile.activeTitleDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 24),
          _StatLine(label: 'Partidas jogadas', value: '${profile.totalMatches}'),
          _StatLine(label: 'Melhor score', value: '${profile.bestScore}'),
          _StatLine(label: 'Melhor combo', value: 'x${profile.bestCombo}'),
          _StatLine(label: 'Maior estrela em fase', value: '${profile.highestStarsEarned}/3'),
          _StatLine(label: 'Fases perfeitas', value: '${campaign.perfectLevels}'),
          _StatLine(label: 'Conquistas liberadas', value: '${profile.unlockedAchievementsCount}'),
          _StatLine(label: 'Acertos totais', value: '${profile.totalCorrectAnswers}'),
          _StatLine(label: 'Erros totais', value: '${profile.totalWrongAnswers}'),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.color.withValues(alpha: 0.12),
                  mascot.color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: frame.color.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: mascot.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(mascot.icon, color: mascot.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mascote ativo: ${mascot.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mascot.description,
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
          const SizedBox(height: 24),
          Text(
            'Titulos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...profile.titles.map(
            (title) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TitleTile(
                title: title,
                onEquip: title.unlocked && !title.equipped
                    ? () => profile.equipTitle(title.id)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Conquistas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...profile.achievements.map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AchievementTile(achievement: achievement),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Evolucao por topico',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...profile.topicPerformance.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TopicProgressTile(topic: topic),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Replay das partidas recentes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (profile.recentReplays.isEmpty)
            Text(
              'Ainda nao ha partidas suficientes para montar o replay textual.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF55607B),
              ),
            )
          else
            ...profile.recentReplays.take(5).map(
              (replay) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReplayTile(replay: replay),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Topicos que mais pedem treino',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (profile.weakestTopics.isEmpty)
            Text(
              'Ainda nao ha dados suficientes. Jogue mais algumas fases para o jogo recomendar focos de estudo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF55607B),
              ),
            )
          else
            ...profile.weakestTopics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WeakTopicTile(topic: topic),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoute.training),
            icon: const Icon(Icons.school_rounded),
            label: const Text('Abrir treino e revisao'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.profile,
    required this.campaign,
  });

  final PlayerProfileController profile;
  final CampaignProgressController campaign;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuracoes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.soundEnabled,
            onChanged: (value) => profile.updateSettings(soundEnabled: value),
            title: const Text('Som ativo'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.reducedMotion,
            onChanged: (value) => profile.updateSettings(reducedMotion: value),
            title: const Text('Reduzir animacoes'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.highContrast,
            onChanged: (value) => profile.updateSettings(highContrast: value),
            title: const Text('Alto contraste'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.largeText,
            onChanged: (value) => profile.updateSettings(largeText: value),
            title: const Text('Texto maior'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.untimedTraining,
            onChanged: (value) => profile.updateSettings(untimedTraining: value),
            title: const Text('Treino sem cronometro'),
          ),
          const SizedBox(height: 16),
          Text(
            'Recompensas de marco',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...profile.levelMilestoneRewards.map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MilestoneRewardTile(
                reward: reward,
                onClaim: reward.available && !reward.claimed
                    ? () => profile.claimLevelMilestoneReward(reward.level)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Medalhas por capitulo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...campaign.chapterMedals.take(6).map(
            (medal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChapterMedalTile(medal: medal),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await profile.signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoute.login, (route) => false);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta local'),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
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
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TitleTile extends StatelessWidget {
  const _TitleTile({
    required this.title,
    required this.onEquip,
  });

  final PlayerTitleView title;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) {
    final accent = title.equipped
        ? const Color(0xFF2D55FF)
        : title.unlocked
            ? const Color(0xFF13C4A3)
            : const Color(0xFF94A1BD);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  title.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (title.equipped)
            const Chip(label: Text('Equipado'))
          else if (title.unlocked)
            OutlinedButton(
              onPressed: onEquip,
              child: const Text('Equipar'),
            )
          else
            const Chip(label: Text('Bloqueado')),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final AchievementView achievement;

  @override
  Widget build(BuildContext context) {
    final accent =
        achievement.unlocked ? const Color(0xFFFFB703) : const Color(0xFFB6C0D8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? const Color(0xFFFFF7E3)
            : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            achievement.unlocked
                ? Icons.emoji_events_rounded
                : Icons.lock_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.progressLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: achievement.unlocked
                        ? const Color(0xFFB67100)
                        : const Color(0xFF73809C),
                    fontWeight: FontWeight.w700,
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

class _MilestoneRewardTile extends StatelessWidget {
  const _MilestoneRewardTile({
    required this.reward,
    required this.onClaim,
  });

  final LevelMilestoneRewardView reward;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final accent = reward.claimed
        ? const Color(0xFF13C4A3)
        : reward.available
            ? const Color(0xFF2D55FF)
            : const Color(0xFF94A1BD);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nivel ${reward.level}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '+${reward.coins} moedas'
            '${reward.freezeBoosters > 0 ? ' | ${reward.freezeBoosters} freeze' : ''}'
            '${reward.focusBoosters > 0 ? ' | ${reward.focusBoosters} foco' : ''}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 10),
          if (reward.claimed)
            const Chip(label: Text('Resgatada'))
          else if (reward.available)
            FilledButton(
              onPressed: onClaim,
              child: const Text('Resgatar recompensa'),
            )
          else
            Text(
              'Disponivel ao chegar neste nivel.',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF73809C),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChapterMedalTile extends StatelessWidget {
  const _ChapterMedalTile({required this.medal});

  final ChapterMedalView medal;

  @override
  Widget build(BuildContext context) {
    final color = switch (medal.tier) {
      ChapterMedalTier.platinum => const Color(0xFF8E5CFF),
      ChapterMedalTier.gold => const Color(0xFFFFB703),
      ChapterMedalTier.silver => const Color(0xFF8F9DBA),
      ChapterMedalTier.bronze => const Color(0xFFC67B48),
      ChapterMedalTier.locked => const Color(0xFF94A1BD),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${medal.chapter.title} • ${medal.tierLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${medal.earnedStars}/${medal.maxStars} estrelas | ${medal.perfectLevels} fases perfeitas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicProgressTile extends StatelessWidget {
  const _TopicProgressTile({required this.topic});

  final TopicPerformanceView topic;

  @override
  Widget build(BuildContext context) {
    final ratio = topic.totalAttempts == 0 ? 0.0 : topic.accuracyRatio;
    final accent = ratio >= 0.7
        ? const Color(0xFF13C4A3)
        : ratio >= 0.45
            ? const Color(0xFFFFB703)
            : const Color(0xFFD1495B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
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
                '${(ratio * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(100),
            color: accent,
          ),
          const SizedBox(height: 8),
          Text(
            '${topic.correctAnswers} acertos | ${topic.wrongAnswers} erros | ${topic.recommendationLabel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayTile extends StatelessWidget {
  const _ReplayTile({required this.replay});

  final MatchReplayView replay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
                  replay.sessionLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                replay.modeLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF2D55FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Score ${replay.score} | ${replay.starsEarned}/3 estrelas | ${replay.replaySummary}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          if (replay.topicLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: replay.topicLabels
                  .take(4)
                  .map((topic) => Chip(label: Text(topic)))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeakTopicTile extends StatelessWidget {
  const _WeakTopicTile({required this.topic});

  final TopicPerformanceView topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9F7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.topic.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Aproveitamento ${_formatAccuracy(topic.accuracyRatio)} em ${topic.totalAttempts} tentativas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
              ],
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
    );
  }
}

String _formatAccuracy(double value) {
  return '${(value * 100).round()}%';
}
