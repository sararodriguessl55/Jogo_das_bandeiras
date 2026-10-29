import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';

class PaginaQuiz extends StatefulWidget {
  const PaginaQuiz({required this.paises, required this.idioma, super.key});

  final List<Pais> paises;
  final IdiomaApp idioma;

  @override
  State<PaginaQuiz> createState() => _EstadoPaginaQuiz();
}

class _ResultadoPergunta {
  const _ResultadoPergunta({required this.bandeira, this.resposta});

  final Pais bandeira;
  final Pais? resposta;

  bool get acertou => resposta == bandeira;
}

class _EstadoPaginaQuiz extends State<PaginaQuiz> {
  static const int _duracaoQuiz = 60;
  static const Duration _intervaloAvancoAutomatico = Duration(
    milliseconds: 700,
  );

  late final GeradorQuiz _geradorQuiz;
  late IdiomaApp _idioma;
  Pais? _respostaSelecionada;
  Timer? _cronometro;
  Timer? _avancoAutomatico;
  final List<_ResultadoPergunta> _resultados = [];
  int _pontuacao = 0;
  int _numeroPergunta = 1;
  int _segundosRestantes = _duracaoQuiz;
  bool _quizEncerrado = false;

  @override
  void initState() {
    super.initState();
    _idioma = widget.idioma;
    _geradorQuiz = GeradorQuiz(widget.paises)..prepararRodada();
    _iniciarCronometro();
  }

  @override
  void dispose() {
    _cronometro?.cancel();
    _avancoAutomatico?.cancel();
    super.dispose();
  }

  void _iniciarCronometro() {
    _cronometro?.cancel();
    _cronometro = Timer.periodic(const Duration(seconds: 1), (cronometro) {
      if (_segundosRestantes <= 1) {
        cronometro.cancel();
        _encerrarQuiz();
        return;
      }

      setState(() {
        _segundosRestantes--;
      });
    });
  }

  void _selecionarResposta(Pais pais) {
    if (_respostaSelecionada != null || _quizEncerrado) return;

    setState(() {
      _respostaSelecionada = pais;
      _resultados.add(
        _ResultadoPergunta(
          bandeira: _geradorQuiz.respostaCorreta,
          resposta: pais,
        ),
      );
      if (pais == _geradorQuiz.respostaCorreta) {
        _pontuacao++;
      }
    });
    _avancoAutomatico = Timer(
      _intervaloAvancoAutomatico,
      _irParaProximaPergunta,
    );
  }

  void _encerrarQuiz() {
    if (_quizEncerrado) return;

    _avancoAutomatico?.cancel();
    setState(() {
      if (_respostaSelecionada == null) {
        _resultados.add(
          _ResultadoPergunta(bandeira: _geradorQuiz.respostaCorreta),
        );
      }
      _segundosRestantes = 0;
      _quizEncerrado = true;
    });
  }

  void _irParaProximaPergunta() {
    if (_quizEncerrado) return;

    _avancoAutomatico?.cancel();
    setState(() {
      _numeroPergunta++;
      _respostaSelecionada = null;
      _geradorQuiz.prepararRodada();
    });
  }

  void _reiniciarQuiz() {
    _avancoAutomatico?.cancel();
    setState(() {
      _pontuacao = 0;
      _numeroPergunta = 1;
      _segundosRestantes = _duracaoQuiz;
      _respostaSelecionada = null;
      _resultados.clear();
      _quizEncerrado = false;
      _geradorQuiz.prepararRodada();
    });
    _iniciarCronometro();
  }

  Color _corResposta(Pais pais, ColorScheme cores) {
    if (_respostaSelecionada == null) return cores.surface;
    if (pais == _geradorQuiz.respostaCorreta) {
      return const Color(0xFFDDF4E4);
    }
    if (pais == _respostaSelecionada) return const Color(0xFFFFE2E0);
    return cores.surface;
  }

  Widget _imagemBandeira(Pais pais, {double tamanho = 44}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/flags/64x64/${pais.codigoAlfa2}.png',
        width: tamanho,
        height: tamanho * 0.75,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => SizedBox(
          width: tamanho,
          height: tamanho * 0.75,
          child: const Icon(Icons.flag_outlined),
        ),
      ),
    );
  }

  Widget _secaoResultado({
    required String titulo,
    required List<_ResultadoPergunta> resultados,
    required TextosApp textos,
    required Color cor,
    required bool mostrarResposta,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            '$titulo (${resultados.length})',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: cor, fontWeight: FontWeight.bold),
          ),
        ),
        if (resultados.isEmpty)
          Text(
            textos.idioma == IdiomaApp.portugues
                ? 'Nenhuma resposta nesta categoria.'
                : 'No answers in this category.',
          )
        else
          for (final resultado in resultados)
            Card(
              child: ListTile(
                leading: _imagemBandeira(resultado.bandeira),
                title: Text(textos.nomePais(resultado.bandeira)),
                subtitle: mostrarResposta
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textos.respostaEsperada(
                              textos.nomePais(resultado.bandeira),
                            ),
                          ),
                          Text(
                            resultado.resposta == null
                                ? textos.naoRespondida
                                : textos.respostaEscolhida(
                                    textos.nomePais(resultado.resposta!),
                                  ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
      ],
    );
  }

  Widget _telaResultados(TextosApp textos) {
    final acertos = _resultados
        .where((resultado) => resultado.acertou)
        .toList();
    final erros = _resultados.where((resultado) => !resultado.acertou).toList();
    final total = acertos.length + erros.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  textos.resultados,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  textos.tempoEsgotado,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  textos.pontuacaoFinal(_pontuacao, total),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _secaoResultado(
                  titulo: textos.acertos,
                  resultados: acertos,
                  textos: textos,
                  cor: Colors.green.shade800,
                  mostrarResposta: false,
                ),
                _secaoResultado(
                  titulo: textos.erros,
                  resultados: erros,
                  textos: textos,
                  cor: Colors.red.shade800,
                  mostrarResposta: true,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _reiniciarQuiz,
                  child: Text(textos.jogarNovamente),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = TextosApp(_idioma);
    final respostaCorreta =
        _respostaSelecionada == _geradorQuiz.respostaCorreta;

    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tituloQuiz),
        actions: [
          SeletorIdioma(
            idioma: _idioma,
            onChanged: (idioma) => setState(() => _idioma = idioma),
          ),
        ],
      ),
      body: _quizEncerrado
          ? _telaResultados(textos)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              textos.pergunta(_numeroPergunta),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Chip(
                              avatar: const Icon(Icons.star, size: 18),
                              label: Text(textos.pontos(_pontuacao)),
                            ),
                            Chip(
                              avatar: Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: _segundosRestantes <= 10
                                    ? Colors.red
                                    : cores.primary,
                              ),
                              label: Text('$_segundosRestantes s'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          textos.perguntaBandeira,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cores.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/flags/128x128/${_geradorQuiz.respostaCorreta.codigoAlfa2}.png',
                            width: 190,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 190,
                              height: 150,
                              child: Icon(Icons.flag_outlined, size: 64),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (final pais in _geradorQuiz.opcoes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed:
                                    _respostaSelecionada == null &&
                                        !_quizEncerrado
                                    ? () => _selecionarResposta(pais)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _corResposta(pais, cores),
                                  foregroundColor: cores.onSurface,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  side: BorderSide(
                                    color: _respostaSelecionada == null
                                        ? cores.outlineVariant
                                        : _corResposta(pais, cores),
                                  ),
                                ),
                                child: Text(textos.nomePais(pais)),
                              ),
                            ),
                          ),
                        if (_respostaSelecionada != null &&
                            !_quizEncerrado) ...[
                          const SizedBox(height: 8),
                          Text(
                            respostaCorreta
                                ? textos.correto
                                : textos.respostaCorreta(
                                    textos.nomePais(
                                      _geradorQuiz.respostaCorreta,
                                    ),
                                  ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: respostaCorreta
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
