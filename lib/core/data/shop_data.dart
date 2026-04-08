import 'package:flutter/material.dart';

enum ShopItemType {
  avatar,
  theme,
  frame,
  effect,
  mascot,
  booster,
}

class ShopItemDefinition {
  const ShopItemDefinition({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.cost,
    required this.color,
    required this.icon,
  });

  final String id;
  final ShopItemType type;
  final String title;
  final String description;
  final int cost;
  final Color color;
  final IconData icon;
}

const defaultAvatarId = 'avatar_orbit';
const defaultThemeId = 'theme_blue';
const defaultFrameId = 'frame_core';
const defaultEffectId = 'effect_clean';
const defaultMascotId = 'mascot_nova';
const seasonThemeId = 'theme_comet';
const seasonFrameId = 'frame_comet';
const seasonEffectId = 'effect_comet';

const avatarShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: defaultAvatarId,
    type: ShopItemType.avatar,
    title: 'Orbit',
    description: 'Avatar padrao do Matetic, com energia de lancamento.',
    cost: 0,
    color: Color(0xFF2D55FF),
    icon: Icons.blur_circular_rounded,
  ),
  ShopItemDefinition(
    id: 'avatar_rocket',
    type: ShopItemType.avatar,
    title: 'Rocket',
    description: 'Para jogadores que gostam de velocidade e score alto.',
    cost: 180,
    color: Color(0xFFFF7B54),
    icon: Icons.rocket_launch_rounded,
  ),
  ShopItemDefinition(
    id: 'avatar_mint',
    type: ShopItemType.avatar,
    title: 'Mint',
    description: 'Avatar leve para quem joga com precisao e calma.',
    cost: 220,
    color: Color(0xFF13C4A3),
    icon: Icons.eco_rounded,
  ),
  ShopItemDefinition(
    id: 'avatar_crown',
    type: ShopItemType.avatar,
    title: 'Crown Spark',
    description: 'Avatar para runs de alto nivel e marcos de temporada.',
    cost: 320,
    color: Color(0xFFFFB703),
    icon: Icons.workspace_premium_rounded,
  ),
  ShopItemDefinition(
    id: 'avatar_quantum',
    type: ShopItemType.avatar,
    title: 'Quantum',
    description: 'Visual energico para quem joga no limite do cronometro.',
    cost: 340,
    color: Color(0xFF8E5CFF),
    icon: Icons.bolt_rounded,
  ),
];

const themeShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: defaultThemeId,
    type: ShopItemType.theme,
    title: 'Blue Pulse',
    description: 'Tema principal do Matetic, com azul vibrante e acento dourado.',
    cost: 0,
    color: Color(0xFF2D55FF),
    icon: Icons.palette_rounded,
  ),
  ShopItemDefinition(
    id: 'theme_sunset',
    type: ShopItemType.theme,
    title: 'Sunset Sprint',
    description: 'Laranja energetico com leitura forte para corrida de fases.',
    cost: 260,
    color: Color(0xFFFF7B54),
    icon: Icons.wb_sunny_rounded,
  ),
  ShopItemDefinition(
    id: 'theme_mint',
    type: ShopItemType.theme,
    title: 'Mint Logic',
    description: 'Visual calmo com verde e contraste suave.',
    cost: 260,
    color: Color(0xFF13C4A3),
    icon: Icons.auto_awesome_rounded,
  ),
  ShopItemDefinition(
    id: 'theme_cosmic',
    type: ShopItemType.theme,
    title: 'Cosmic Pulse',
    description: 'Tema violeta-azulado para capitulos finais e runs de elite.',
    cost: 320,
    color: Color(0xFF8E5CFF),
    icon: Icons.nights_stay_rounded,
  ),
  ShopItemDefinition(
    id: 'theme_lava',
    type: ShopItemType.theme,
    title: 'Lava Rush',
    description: 'Tema quente e vibrante inspirado em fases boss e combo rush.',
    cost: 340,
    color: Color(0xFFEF476F),
    icon: Icons.local_fire_department_rounded,
  ),
  ShopItemDefinition(
    id: seasonThemeId,
    type: ShopItemType.theme,
    title: 'Comet Festival',
    description: 'Tema sazonal desbloqueado durante eventos especiais da temporada.',
    cost: 0,
    color: Color(0xFF8E5CFF),
    icon: Icons.auto_awesome_rounded,
  ),
];

const frameShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: defaultFrameId,
    type: ShopItemType.frame,
    title: 'Core Frame',
    description: 'Moldura padrao com acabamento limpo para o perfil.',
    cost: 0,
    color: Color(0xFF64748B),
    icon: Icons.crop_square_rounded,
  ),
  ShopItemDefinition(
    id: 'frame_gold',
    type: ShopItemType.frame,
    title: 'Gold Pulse',
    description: 'Moldura dourada para perfis com cara de temporada forte.',
    cost: 210,
    color: Color(0xFFFFB703),
    icon: Icons.crop_rounded,
  ),
  ShopItemDefinition(
    id: 'frame_neon',
    type: ShopItemType.frame,
    title: 'Neon Loop',
    description: 'Moldura com pegada arcade para perfis de combo alto.',
    cost: 260,
    color: Color(0xFF2D55FF),
    icon: Icons.hexagon_rounded,
  ),
  ShopItemDefinition(
    id: 'frame_coral',
    type: ShopItemType.frame,
    title: 'Coral Arc',
    description: 'Acabamento marcante para perfis que gostam de impacto visual.',
    cost: 280,
    color: Color(0xFFFF7B54),
    icon: Icons.change_history_rounded,
  ),
  ShopItemDefinition(
    id: seasonFrameId,
    type: ShopItemType.frame,
    title: 'Comet Frame',
    description: 'Moldura exclusiva da temporada de evento.',
    cost: 0,
    color: Color(0xFF8E5CFF),
    icon: Icons.stars_rounded,
  ),
];

const effectShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: defaultEffectId,
    type: ShopItemType.effect,
    title: 'Clean Hit',
    description: 'Feedback visual direto e leve para respostas corretas.',
    cost: 0,
    color: Color(0xFF2D55FF),
    icon: Icons.auto_fix_normal_rounded,
  ),
  ShopItemDefinition(
    id: 'effect_fire',
    type: ShopItemType.effect,
    title: 'Fire Combo',
    description: 'Efeito mais agressivo para combos e resultados de rodada.',
    cost: 240,
    color: Color(0xFFFF7B54),
    icon: Icons.local_fire_department_rounded,
  ),
  ShopItemDefinition(
    id: 'effect_starlight',
    type: ShopItemType.effect,
    title: 'Star Echo',
    description: 'Trajeto brilhante para acertos perfeitos e marcos importantes.',
    cost: 300,
    color: Color(0xFFFFB703),
    icon: Icons.auto_awesome_rounded,
  ),
  ShopItemDefinition(
    id: 'effect_pulse',
    type: ShopItemType.effect,
    title: 'Pulse Wave',
    description: 'Feedback moderno com cara de saga viva e mapa premium.',
    cost: 320,
    color: Color(0xFF8E5CFF),
    icon: Icons.waves_rounded,
  ),
  ShopItemDefinition(
    id: seasonEffectId,
    type: ShopItemType.effect,
    title: 'Comet Trail',
    description: 'Efeito sazonal para acertos durante o festival do cometa.',
    cost: 0,
    color: Color(0xFFFFB703),
    icon: Icons.star_purple500_rounded,
  ),
];

const mascotShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: defaultMascotId,
    type: ShopItemType.mascot,
    title: 'Nova',
    description: 'Mascote padrao que acompanha a conta desde o comeco.',
    cost: 0,
    color: Color(0xFF2D55FF),
    icon: Icons.smart_toy_rounded,
  ),
  ShopItemDefinition(
    id: 'mascot_byte',
    type: ShopItemType.mascot,
    title: 'Byte',
    description: 'Mascote agil para runs de velocidade e treino diario.',
    cost: 280,
    color: Color(0xFF13C4A3),
    icon: Icons.flutter_dash_rounded,
  ),
  ShopItemDefinition(
    id: 'mascot_comet',
    type: ShopItemType.mascot,
    title: 'Comet',
    description: 'Companheiro brilhante para perfis que gostam de score alto.',
    cost: 340,
    color: Color(0xFFFFB703),
    icon: Icons.brightness_5_rounded,
  ),
];

const boosterShopItems = <ShopItemDefinition>[
  ShopItemDefinition(
    id: 'booster_freeze',
    type: ShopItemType.booster,
    title: 'Congelar tempo',
    description: 'Pausa o cronometro por alguns segundos em fases permitidas.',
    cost: 90,
    color: Color(0xFF6EC5FF),
    icon: Icons.ac_unit_rounded,
  ),
  ShopItemDefinition(
    id: 'booster_focus',
    type: ShopItemType.booster,
    title: 'Foco relampago',
    description: 'Remove pressao visual e ajuda a manter o combo.',
    cost: 110,
    color: Color(0xFFFFB703),
    icon: Icons.flash_on_rounded,
  ),
];

const allShopItems = <ShopItemDefinition>[
  ...avatarShopItems,
  ...themeShopItems,
  ...frameShopItems,
  ...effectShopItems,
  ...mascotShopItems,
  ...boosterShopItems,
];

ShopItemDefinition itemById(String id) {
  return allShopItems.firstWhere((item) => item.id == id);
}
