import 'package:flutter/material.dart';

import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;
    final tabs = <String>['Global', 'Semanal', 'Amigos'];
    final entries = switch (_tabIndex) {
      0 => profile.buildGlobalRanking(),
      1 => profile.buildWeeklyRanking(),
      _ => profile.buildFriendsRanking(),
    };
    final comparison = profile.weeklyComparison;

    return Scaffold(
      body: ShellFrame(
        maxWidth: 980,
        child: ListView(
          children: [
            const _RankingHeader(),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List<Widget>.generate(tabs.length, (index) {
                final active = index == _tabIndex;
                return ChoiceChip(
                  selected: active,
                  label: Text(tabs[index]),
                  onSelected: (_) {
                    setState(() {
                      _tabIndex = index;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            _RankingSummaryCard(
              profile: profile,
              comparison: comparison,
              tabLabel: tabs[_tabIndex],
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                children: List<Widget>.generate(entries.length, (index) {
                  final entry = entries[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 12),
                    child: _RankingTile(
                      position: index + 1,
                      entry: entry,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingSummaryCard extends StatelessWidget {
  const _RankingSummaryCard({
    required this.profile,
    required this.comparison,
    required this.tabLabel,
  });

  final PlayerProfileController profile;
  final WeeklyComparisonView comparison;
  final String tabLabel;

  @override
  Widget build(BuildContext context) {
    final positive = comparison.delta >= 0;
    final accent = positive ? const Color(0xFF13C4A3) : const Color(0xFFFF7B54);

    return SectionCard(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel social',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Leitura pessoal do ranking de $tabLabel com base no seu ritmo recente.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comparison.trendLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  positive
                      ? '+${comparison.delta} pontos versus seu ritmo anterior'
                      : '${comparison.delta} pontos versus seu ritmo anterior',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil em destaque',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.displayName} • ${profile.activeTitleLabel}',
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

class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

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
                'Ranking',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Camada social leve do MVP: ranking global, semanal e entre amigos com dados locais.',
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

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.position,
    required this.entry,
  });

  final int position;
  final RankingEntryView entry;

  @override
  Widget build(BuildContext context) {
    final baseColor = entry.isPlayer ? const Color(0xFF2D55FF) : const Color(0xFFE5EAF7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isPlayer ? const Color(0xFFEEF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: entry.isPlayer ? baseColor.withValues(alpha: 0.2) : baseColor),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 10,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.isPlayer ? const Color(0xFF2D55FF) : const Color(0xFFF2F5FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: entry.isPlayer ? Colors.white : const Color(0xFF42506E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF55607B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
