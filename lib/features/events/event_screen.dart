import 'package:flutter/material.dart';

import '../../core/data/event_data.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';
import '../game/game_screen.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        final season = profile.currentSeason;

        return Scaffold(
          body: ShellFrame(
            maxWidth: 1080,
            child: ListView(
              children: [
                _EventHeader(profile: profile, season: season),
                const SizedBox(height: 24),
                _SeasonProgressCard(profile: profile, season: season),
                const SizedBox(height: 20),
                _SeasonMissionsCard(profile: profile),
                const SizedBox(height: 20),
                _SeasonRewardsCard(profile: profile, season: season),
                const SizedBox(height: 20),
                _BonusChapterCard(profile: profile, season: season),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventHeader extends StatelessWidget {
  const _EventHeader({
    required this.profile,
    required this.season,
  });

  final PlayerProfileController profile;
  final SeasonEventDefinition season;

  @override
  Widget build(BuildContext context) {
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
          width: 760,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                season.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                season.subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
            ],
          ),
        ),
        Chip(
          label: Text(profile.isWeekendEventWindow ? 'Fim de semana turbo' : season.bannerLabel),
        ),
      ],
    );
  }
}

class _SeasonProgressCard extends StatelessWidget {
  const _SeasonProgressCard({
    required this.profile,
    required this.season,
  });

  final PlayerProfileController profile;
  final SeasonEventDefinition season;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  season.color,
                  const Color(0xFF2D55FF),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temporada ativa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capitulo bonus, missao sazonal e cosmeticos exclusivos em um so fluxo.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: profile.seasonProgressRatio,
            minHeight: 12,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: 12),
          Text(
            '${profile.seasonEventWins}/${season.rewards.last.requiredWins} vitorias sazonais',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SeasonStat(label: 'Runs', value: '${profile.seasonEventRuns}'),
              _SeasonStat(label: 'Vitorias', value: '${profile.seasonEventWins}'),
              _SeasonStat(label: 'Chefes', value: '${profile.seasonEventBossWins}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonStat extends StatelessWidget {
  const _SeasonStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _SeasonMissionsCard extends StatelessWidget {
  const _SeasonMissionsCard({required this.profile});

  final PlayerProfileController profile;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missoes sazonais',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...profile.seasonMissions.map(
            (mission) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
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
                    Text(mission.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF55607B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: mission.progressRatio,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${mission.progress}/${mission.target} • +${mission.rewardCoins} moedas',
                          ),
                        ),
                        if (mission.claimed)
                          const Chip(label: Text('Resgatada'))
                        else if (mission.completed)
                          FilledButton(
                            onPressed: () => profile.claimSeasonMission(mission.id),
                            child: const Text('Resgatar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonRewardsCard extends StatelessWidget {
  const _SeasonRewardsCard({
    required this.profile,
    required this.season,
  });

  final PlayerProfileController profile;
  final SeasonEventDefinition season;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recompensas exclusivas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...season.rewards.map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFE1A8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFB703)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reward.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            reward.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF55607B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (profile.isSeasonRewardClaimed(reward.id))
                      const Chip(label: Text('Liberada'))
                    else if (profile.seasonEventWins >= reward.requiredWins)
                      FilledButton(
                        onPressed: () => profile.claimSeasonReward(reward.id),
                        child: const Text('Coletar'),
                      )
                    else
                      Text('${profile.seasonEventWins}/${reward.requiredWins}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BonusChapterCard extends StatelessWidget {
  const _BonusChapterCard({
    required this.profile,
    required this.season,
  });

  final PlayerProfileController profile;
  final SeasonEventDefinition season;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capitulo bonus da temporada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Cinco portais em sequencia, culminando no chefe sazonal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 14),
          ...season.bonusChapter.map(
            (challenge) {
              final completed = profile.isEventChallengeCompleted(challenge.id);
              final unlocked = profile.isEventChallengeUnlocked(challenge.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFFEAFBF7)
                        : unlocked
                            ? const Color(0xFFF8FAFF)
                            : const Color(0xFFF2F4F8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: completed
                          ? const Color(0xFF13C4A3)
                          : unlocked
                              ? const Color(0xFFE3E9F7)
                              : const Color(0xFFE0E5F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        challenge.isBoss
                            ? Icons.whatshot_rounded
                            : Icons.radio_button_checked_rounded,
                        color: challenge.isBoss
                            ? const Color(0xFFFFB703)
                            : challenge.mode.color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portal ${challenge.stageNumber}: ${challenge.title}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              challenge.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF55607B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (completed)
                        const Chip(label: Text('Concluido'))
                      else if (!unlocked)
                        const Chip(label: Text('Bloqueado'))
                      else
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  quickMode: challenge.mode,
                                  sessionTrackingId: challenge.id,
                                ),
                              ),
                            );
                          },
                          child: const Text('Jogar'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
