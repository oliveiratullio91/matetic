import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matetic/app/matetic_app.dart';
import 'package:matetic/core/data/sample_data.dart';
import 'package:matetic/core/state/player_profile_controller.dart';
import 'package:matetic/features/events/event_screen.dart';
import 'package:matetic/features/game/game_screen.dart';
import 'package:matetic/features/game/level_preview_screen.dart';
import 'package:matetic/features/map/map_screen.dart';
import 'package:matetic/features/missions/missions_screen.dart';
import 'package:matetic/features/modes/mode_select_screen.dart';
import 'package:matetic/features/profile/profile_screen.dart';
import 'package:matetic/features/ranking/ranking_screen.dart';
import 'package:matetic/features/shop/shop_screen.dart';
import 'package:matetic/features/training/training_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Campanha gera 500 fases', () {
    expect(sampleLevelDefinitions.length, 500);
    expect(sampleChapters.length, 25);
  });

  testWidgets('Matetic mostra tela inicial do fluxo', (tester) async {
    await tester.pumpWidget(const MateticApp());
    await tester.pump();

    expect(find.text('Matetic'), findsOneWidget);
    expect(find.textContaining('Treino matematico'), findsOneWidget);
  });

  testWidgets('GameScreen abre em layout estreito sem quebrar', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: GameScreen(levelId: 1),
      ),
    );
    await tester.pump();

    expect(find.text('Fase 1: Aquecimento'), findsOneWidget);
    expect(find.textContaining('Pergunta 1'), findsOneWidget);
  });

  test('PlayerProfileController permite ativar treino sem cronometro', () async {
    final profile = PlayerProfileController.instance;
    await profile.updateSettings(untimedTraining: true);
    expect(profile.untimedTraining, isTrue);
    await profile.updateSettings(untimedTraining: false);
    expect(profile.untimedTraining, isFalse);
  });

  testWidgets('LevelPreviewScreen mostra objetivos secundarios', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LevelPreviewScreen(levelId: 1),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Objetivos secundarios'), findsOneWidget);
    expect(find.textContaining('Combo x3'), findsOneWidget);
    expect(find.textContaining('Iniciar fase'), findsOneWidget);
  });

  testWidgets('LevelPreviewScreen mostra modificadores de fase quando existirem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LevelPreviewScreen(levelId: 5),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Modificadores da fase'), findsOneWidget);
    expect(find.textContaining('Fase relampago'), findsOneWidget);
  });

  testWidgets('MissionsScreen mostra rotina diaria e semanal', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MissionsScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Recompensa diaria'), findsOneWidget);
    expect(find.textContaining('Missoes diarias'), findsOneWidget);
    expect(find.textContaining('Missoes semanais'), findsOneWidget);
    expect(find.textContaining('Bau de vitorias'), findsOneWidget);
    expect(find.textContaining('Missao especial do dia'), findsOneWidget);
  });

  testWidgets('ShopScreen mostra categorias de personalizacao', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShopScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Loja e personalizacao'), findsOneWidget);
    expect(find.text('Avatares'), findsOneWidget);
    expect(find.text('Temas'), findsOneWidget);
    expect(find.text('Molduras'), findsOneWidget);
    expect(find.text('Efeitos'), findsOneWidget);
    expect(find.text('Mascotes'), findsOneWidget);
    expect(find.text('Boosters'), findsOneWidget);
    expect(find.textContaining('Loadout ativo'), findsOneWidget);
  });

  testWidgets('ModeSelectScreen mostra modos jogaveis', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModeSelectScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Selecao de modos'), findsOneWidget);
    expect(find.text('Campanha'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Contra o tempo'), 300);
    expect(find.text('Contra o tempo'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sobrevivencia'), 300);
    expect(find.text('Sobrevivencia'), findsOneWidget);
  });

  testWidgets('TrainingScreen mostra treino recomendado e revisao', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TrainingScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Treino e revisao'), findsOneWidget);
    expect(find.textContaining('Treino recomendado'), findsOneWidget);
    expect(find.textContaining('Revisao dos erros recentes'), findsOneWidget);
  });

  testWidgets('ProfileScreen mostra progressao forte da etapa 12', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Titulos'), findsOneWidget);
    expect(find.text('Conquistas'), findsOneWidget);
    expect(find.textContaining('Recompensas de marco'), findsOneWidget);
    expect(find.textContaining('Medalhas por capitulo'), findsOneWidget);
    expect(find.textContaining('Mascote ativo'), findsOneWidget);
    expect(find.textContaining('Evolucao por topico'), findsOneWidget);
    expect(find.textContaining('Replay das partidas recentes'), findsOneWidget);
    expect(find.textContaining('Texto maior'), findsOneWidget);
    expect(find.textContaining('Treino sem cronometro'), findsOneWidget);
  });

  testWidgets('RankingScreen mostra resumo social da etapa 15', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RankingScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Painel social'), findsOneWidget);
    expect(find.textContaining('Perfil em destaque'), findsOneWidget);
    expect(find.text('Global'), findsOneWidget);
  });

  testWidgets('EventScreen mostra temporada, recompensas e capitulo bonus', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EventScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Festival do Cometa'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Missoes sazonais'), 300);
    expect(find.textContaining('Missoes sazonais'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Recompensas exclusivas'), 300);
    expect(find.textContaining('Recompensas exclusivas'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Capitulo bonus da temporada'), 300);
    expect(find.textContaining('Capitulo bonus da temporada'), findsOneWidget);
  });

  testWidgets('MapScreen abre em tela estreita sem quebrar', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MapScreen(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Mapa de niveis'), findsOneWidget);
    expect(find.textContaining('Mapa em trilha com 500 fases'), findsOneWidget);
    expect(find.textContaining('Aquecimento'), findsOneWidget);
  });
}
