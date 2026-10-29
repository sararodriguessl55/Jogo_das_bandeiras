import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo1/main.dart';

void main() {
  testWidgets('menu, idiomas, países e quiz com resultados', (tester) async {
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
    await tester.tap(find.text('Começar quiz'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pergunta 1'), findsOneWidget);
    expect(find.text('60 s'), findsOneWidget);
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

    for (var segundo = 0; segundo < 60; segundo++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.textContaining('Time is up!'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.textContaining('Correct ('), findsOneWidget);
    expect(find.textContaining('Incorrect ('), findsOneWidget);
    expect(find.text('Not answered'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });
}
