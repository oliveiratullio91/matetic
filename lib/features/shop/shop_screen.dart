import 'package:flutter/material.dart';

import '../../core/data/shop_data.dart';
import '../../core/state/player_profile_controller.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/shell_frame.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopItemType _filter = ShopItemType.avatar;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfileController.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        final items = switch (_filter) {
          ShopItemType.avatar => avatarShopItems,
          ShopItemType.theme => themeShopItems,
          ShopItemType.frame => frameShopItems,
          ShopItemType.effect => effectShopItems,
          ShopItemType.mascot => mascotShopItems,
          ShopItemType.booster => boosterShopItems,
        };

        return Scaffold(
          body: ShellFrame(
            maxWidth: 1040,
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
                            'Loja e personalizacao',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Avatares, temas e boosters com compra local por moedas.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF4A5572),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(label: Text('${profile.coins} moedas')),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _filterChip(ShopItemType.avatar, 'Avatares'),
                    _filterChip(ShopItemType.theme, 'Temas'),
                    _filterChip(ShopItemType.frame, 'Molduras'),
                    _filterChip(ShopItemType.effect, 'Efeitos'),
                    _filterChip(ShopItemType.mascot, 'Mascotes'),
                    _filterChip(ShopItemType.booster, 'Boosters'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 920;
                      final previewCard = _LoadoutPreviewCard(profile: profile);
                      final list = ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _ShopItemCard(
                          item: items[index],
                          profile: profile,
                        ),
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: previewCard),
                            const SizedBox(width: 20),
                            Expanded(flex: 7, child: list),
                          ],
                        );
                      }

                      return ListView(
                        children: [
                          previewCard,
                          const SizedBox(height: 20),
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ShopItemCard(
                                item: item,
                                profile: profile,
                              ),
                            ),
                          ),
                        ],
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

  Widget _filterChip(ShopItemType type, String label) {
    return ChoiceChip(
      selected: _filter == type,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _filter = type;
        });
      },
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.profile,
  });

  final ShopItemDefinition item;
  final PlayerProfileController profile;

  @override
  Widget build(BuildContext context) {
    final owned = item.type == ShopItemType.booster
        ? profile.boosterCount(item.id) > 0
        : profile.ownsItem(item.id);
    final equipped = item.id == profile.avatarId ||
        item.id == profile.themeId ||
        item.id == profile.frameId ||
        item.id == profile.effectId ||
        item.id == profile.mascotId;

    return SectionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(item.icon, color: item.color, size: 34),
          ),
          const SizedBox(height: 18),
          Text(item.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 18),
          if (item.type == ShopItemType.booster)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Inventario: ${profile.boosterCount(item.id)}'),
            ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text(
                item.cost == 0 ? 'Gratis' : '${item.cost} moedas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (item.type == ShopItemType.booster)
                FilledButton(
                  onPressed: () => profile.buyItem(item.id),
                  child: const Text('Comprar'),
                )
              else if (!owned)
                FilledButton(
                  onPressed: () => profile.buyItem(item.id),
                  child: const Text('Comprar'),
                )
              else
                OutlinedButton(
                  onPressed: equipped ? null : () => profile.equipItem(item.id),
                  child: Text(equipped ? 'Em uso' : 'Equipar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadoutPreviewCard extends StatelessWidget {
  const _LoadoutPreviewCard({required this.profile});

  final PlayerProfileController profile;

  @override
  Widget build(BuildContext context) {
    final avatar = itemById(profile.avatarId);
    final theme = itemById(profile.themeId);
    final frame = itemById(profile.frameId);
    final effect = itemById(profile.effectId);
    final mascot = itemById(profile.mascotId);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loadout ativo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monte uma identidade propria para o Matetic com avatar, tema, moldura, efeito e mascote.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF55607B),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.color.withValues(alpha: 0.16),
                  frame.color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: frame.color.withValues(alpha: 0.22), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: avatar.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: frame.color, width: 3),
                  ),
                  child: Icon(avatar.icon, size: 42, color: avatar.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.activeTitleLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: theme.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tema ${theme.title} | Efeito ${effect.title}',
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
          const SizedBox(height: 16),
          _LoadoutLine(label: 'Avatar', item: avatar),
          _LoadoutLine(label: 'Tema', item: theme),
          _LoadoutLine(label: 'Moldura', item: frame),
          _LoadoutLine(label: 'Efeito', item: effect),
          _LoadoutLine(label: 'Mascote', item: mascot),
        ],
      ),
    );
  }
}

class _LoadoutLine extends StatelessWidget {
  const _LoadoutLine({
    required this.label,
    required this.item,
  });

  final String label;
  final ShopItemDefinition item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 20, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('$label: ${item.title}')),
        ],
      ),
    );
  }
}
