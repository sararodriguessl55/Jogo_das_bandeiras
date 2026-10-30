import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo1/main.dart';
import 'package:jogo1/model.dart';
import 'package:jogo1/modelo_ranque.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('menu, idiomas, países e quiz com resultados', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    for (
      var tentativa = 0;
      tentativa < 20 && find.text('Começar quiz').evaluate().isEmpty;
      tentativa++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Começar quiz'), findsOneWidget);
    expect(find.text('Ver países'), findsOneWidget);
    expect(find.text('Escolha um continente'), findsOneWidget);
    expect(find.text('Todos os continentes'), findsOneWidget);
    expect(find.text('30 s'), findsWidgets);
    expect(find.text('60 s'), findsOneWidget);
    expect(find.text('120 s'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<Continente>));
    await tester.pumpAndSettle();
    for (final continente in [
      'África',
      'América',
      'Antártida',
      'Ásia',
      'Europa',
      'Oceania',
      'Todos os continentes',
    ]) {
      expect(find.text(continente), findsWidgets);
    }
    await tester.tap(find.text('América').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver países'));
    await tester.tap(find.text('Ver países'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Países ('), findsOneWidget);
    expect(find.text('Afeganistão'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Flags Quiz'), findsOneWidget);
    expect(find.text('Start quiz'), findsOneWidget);
    expect(find.text('View countries'), findsOneWidget);

    await tester.tap(find.text('PT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(DropdownButtonFormField<Continente>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos os continentes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('120 s'));
    await tester.pump();
    await tester.tap(find.text('30 s'));
    await tester.pump();
    await tester.tap(find.text('Começar quiz'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pergunta 1'), findsOneWidget);
    expect(find.text('30 s'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Pergunta 2'), findsOneWidget);

    await tester.tap(find.text('EN').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Which country does this flag belong to?'),
      findsOneWidget,
    );

    for (var segundo = 0; segundo < 30; segundo++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.textContaining('Time is up!'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.textContaining('Correct ('), findsOneWidget);
    expect(find.textContaining('Incorrect ('), findsOneWidget);
    expect(find.text('Not answered'), findsOneWidget);
    expect(find.text('Save to leaderboard'), findsOneWidget);
    expect(find.text('Do not save'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);

    await tester.ensureVisible(find.text('Save to leaderboard'));
    await tester.tap(find.text('Save to leaderboard'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tester');
    await tester.tap(find.text('Save result'));
    await tester.pumpAndSettle();
    expect(find.text('Result saved to leaderboard.'), findsNWidgets(2));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver ranque'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Continente>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos os continentes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 s').last);
    await tester.pumpAndSettle();
    expect(find.text('Tester'), findsOneWidget);
  });

  test('Antártida deve mapear para o continente correto', () {
    final pais = Pais(
      codigoContinente: 'AQ',
      id: 10,
      nome: 'Antarctica',
      codigoAlfa2: 'aq',
      codigoAlfa3: 'ata',
    );

    expect(pais.continente, Continente.antarctica);
  });

  test('ranque salva partidas repetidas e mantém todas persistidas', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioRanque();

    for (var partida = 1; partida <= 5; partida++) {
      await repositorio.salvar(
        ResultadoRanque(
          nome: 'Jogador $partida',
          pontos: partida,
          total: 10,
          duracaoSegundos: 60,
          continente: Continente.todos,
          data: DateTime(2026, 10, 29, 22, partida),
        ),
      );
    }

    final resultados = await RepositorioRanque().carregar();
    expect(resultados, hasLength(5));
    expect(
      resultados.map((resultado) => resultado.nome),
      containsAll([
        'Jogador 1',
        'Jogador 2',
        'Jogador 3',
        'Jogador 4',
        'Jogador 5',
      ]),
    );
  });
}
