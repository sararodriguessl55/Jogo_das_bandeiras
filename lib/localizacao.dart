import 'package:flutter/material.dart';

enum IdiomaApp { portugues, ingles }

class TextosApp {
  const TextosApp(this.idioma);

  final IdiomaApp idioma;

  bool get _portugues => idioma == IdiomaApp.portugues;

  String get tituloInicial => _portugues ? 'Quiz de Bandeiras' : 'Flags Quiz';
  String get erroCarregamento => _portugues
      ? 'Não foi possível carregar os países.'
      : 'Could not load the countries.';
  String get tentarNovamente => _portugues ? 'Tentar novamente' : 'Try again';
  String get introducao => _portugues
      ? 'Você conhece as bandeiras do mundo?'
      : 'Do you know the flags of the world?';
  String descricao(int quantidade) => _portugues
      ? 'Teste seus conhecimentos com $quantidade países.'
      : 'Test your knowledge with $quantidade countries.';
  String get comecarQuiz => _portugues ? 'Começar quiz' : 'Start quiz';
  String get verPaises => _portugues ? 'Ver países' : 'View countries';
  String get tituloQuiz => _portugues ? 'Quiz de bandeiras' : 'Flags quiz';
  String pergunta(int numero) =>
      _portugues ? 'Pergunta $numero' : 'Question $numero';
  String pontos(int quantidade) =>
      _portugues ? 'Pontos: $quantidade' : 'Score: $quantidade';
  String get perguntaBandeira => _portugues
      ? 'A qual país pertence esta bandeira?'
      : 'Which country does this flag belong to?';
  String get correto => _portugues ? 'Correto!' : 'Correct!';
  String respostaCorreta(String pais) => _portugues
      ? 'A resposta correta é $pais.'
      : 'The correct answer is $pais.';
  String get proximaPergunta =>
      _portugues ? 'Próxima pergunta' : 'Next question';
  String get tempoEsgotado => _portugues ? 'Tempo esgotado!' : 'Time is up!';
  String get resultadoFinal => _portugues ? 'Você fez' : 'Your score';
  String get jogarNovamente => _portugues ? 'Jogar novamente' : 'Play again';
  String tituloPaises(int quantidade) =>
      _portugues ? 'Países ($quantidade)' : 'Countries ($quantidade)';
  String codigosPais(String continente, String alfa2, String alfa3) =>
      '$continente · $alfa2 · $alfa3';
  String get seletorIdioma => _portugues ? 'Idioma' : 'Language';
}

class SeletorIdioma extends StatelessWidget {
  const SeletorIdioma({
    required this.idioma,
    required this.onChanged,
    super.key,
  });

  final IdiomaApp idioma;
  final ValueChanged<IdiomaApp> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<IdiomaApp>(
      segments: const [
        ButtonSegment(value: IdiomaApp.portugues, label: Text('PT')),
        ButtonSegment(value: IdiomaApp.ingles, label: Text('EN')),
      ],
      selected: {idioma},
      showSelectedIcon: false,
      onSelectionChanged: (selecionado) => onChanged(selecionado.first),
    );
  }
}
