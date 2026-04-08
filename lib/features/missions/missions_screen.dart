import 'package:flutter/material.dart';

import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return Scaffold(
          body: ShellFrame(
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  title: 'Missoes e rotina',
                  subtitle:
                      'Aqui fica a camada de retencao do Matetic: diaria, semanal e recompensa de volta.',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 860;

                      final dailyCard = _DailyRewardCard(profile: profile);
                      final missionLists = _MissionLists(profile: profile);

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: SingleChildScrollView(child: dailyCard),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(child: missionLists),
                            ),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            dailyCard,
                            const SizedBox(height: 20),
                            missionLists,
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

class _DailyRewardCard extends StatelessWidget {
  const _DailyRewardCard({required this.profile});

  final PlayerProfileController profile;

  @override
  Widget build(BuildContext context) {
    final specialMission = profile.specialDailyMission;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recompensa diaria',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Streak atual: ${profile.dailyStreak} dia(s). Entrar todo dia ajuda a sustentar moedas para loja e boosters.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          if (profile.sessionWelcomeMessage.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(profile.sessionWelcomeMessage),
            ),
          ],
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D55FF), Color(0xFF13C4A3)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premio de hoje',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${profile.dailyRewardPreviewCoins} moedas na coleta atual',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _LoginCalendarRow(entries: profile.loginCalendar),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: profile.dailyRewardAvailable ? () => profile.claimDailyReward() : null,
            icon: const Icon(Icons.card_giftcard_rounded),
            label: Text(
              profile.dailyRewardAvailable ? 'Coletar recompensa' : 'Recompensa coletada',
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Bau de treino',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Jogue 3 fases no dia para abrir um bau com moedas e boosters.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: profile.trainingChestAvailable ? () => profile.claimTrainingChest() : null,
            icon: const Icon(Icons.inventory_2_rounded),
            label: Text(
              profile.trainingChestAvailable ? 'Abrir bau' : 'Bau indisponivel',
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Bau de vitorias',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'A cada 3 vitorias seguidas voce libera um bau extra. Streak atual: ${profile.currentVictoryStreak}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4A5572),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: profile.victoryChestAvailable ? () => profile.claimVictoryChest() : null,
            icon: const Icon(Icons.emoji_events_rounded),
            label: Text(
              profile.victoryChestAvailable ? 'Abrir bau de vitorias' : 'Continue vencendo',
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Missao especial do dia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _MissionRow(
            mission: specialMission,
            onClaim: () => profile.claimMission(specialMission.id),
          ),
        ],
      ),
    );
  }
}

class _MissionLists extends StatelessWidget {
  const _MissionLists({required this.profile});

  final PlayerProfileController profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Passe da temporada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Tier ${profile.seasonPassTier} | ${profile.seasonPassProgress}/300 XP para o proximo marco.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5572),
                ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: profile.seasonPassProgressRatio,
                minHeight: 10,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: 12),
              Text(
                'O passe simples do MVP usa o seu XP total para liberar ritmo de recompensa.',
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
                'Missoes diarias',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...profile.dailyMissions.map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MissionRow(
                    mission: mission,
                    onClaim: () => profile.claimMission(mission.id),
                  ),
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
                'Missoes semanais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...profile.weeklyMissions.map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MissionRow(
                    mission: mission,
                    onClaim: () => profile.claimMission(mission.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginCalendarRow extends StatelessWidget {
  const _LoginCalendarRow({required this.entries});

  final List<LoginCalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: entries
          .map(
            (entry) => _LoginCalendarTile(entry: entry),
          )
          .toList(growable: false),
    );
  }
}

class _LoginCalendarTile extends StatelessWidget {
  const _LoginCalendarTile({required this.entry});

  final LoginCalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final activeColor = switch (entry.state) {
      CalendarEntryState.claimed => const Color(0xFF13C4A3),
      CalendarEntryState.current => const Color(0xFF2D55FF),
      CalendarEntryState.locked => const Color(0xFFB8C2DA),
    };

    return Container(
      width: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: activeColor.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Text(
            'Dia ${entry.dayNumber}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Icon(
            entry.state == CalendarEntryState.claimed
                ? Icons.check_circle_rounded
                : entry.state == CalendarEntryState.current
                    ? Icons.star_rounded
                    : Icons.lock_outline_rounded,
            color: activeColor,
          ),
          const SizedBox(height: 6),
          Text(
            '+${entry.rewardCoins}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: activeColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.mission,
    required this.onClaim,
  });

  final MissionView mission;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 280,
                child: Text(
                  mission.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Chip(label: Text(mission.cadence)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mission.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: mission.progressRatio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text('${mission.progress}/${mission.target}'),
              Text('+${mission.rewardCoins} moedas'),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: mission.completed && !mission.claimed ? onClaim : null,
            child: Text(mission.claimed ? 'Coletada' : 'Coletar'),
          ),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

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
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
