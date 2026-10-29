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

class _EstadoPaginaQuiz extends State<PaginaQuiz> {
  static const int _duracaoQuiz = 30;

  late final GeradorQuiz _geradorQuiz;
  late IdiomaApp _idioma;
  Pais? _respostaSelecionada;
  Timer? _cronometro;
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
    super.dispose();
  }

  void _iniciarCronometro() {
    _cronometro?.cancel();
    _cronometro = Timer.periodic(const Duration(seconds: 1), (cronometro) {
      if (_segundosRestantes <= 1) {
        cronometro.cancel();
        setState(() {
          _segundosRestantes = 0;
          _quizEncerrado = true;
        });
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
      if (pais == _geradorQuiz.respostaCorreta) {
        _pontuacao++;
      }
    });
  }

  void _irParaProximaPergunta() {
    if (_quizEncerrado) return;

    setState(() {
      _numeroPergunta++;
      _respostaSelecionada = null;
      _geradorQuiz.prepararRodada();
    });
  }

  void _reiniciarQuiz() {
    setState(() {
      _pontuacao = 0;
      _numeroPergunta = 1;
      _segundosRestantes = _duracaoQuiz;
      _respostaSelecionada = null;
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
      body: SafeArea(
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
                              _respostaSelecionada == null && !_quizEncerrado
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
                          child: Text(pais.nome),
                        ),
                      ),
                    ),
                  if (_respostaSelecionada != null && !_quizEncerrado) ...[
                    const SizedBox(height: 8),
                    Text(
                      respostaCorreta
                          ? textos.correto
                          : textos.respostaCorreta(
                              _geradorQuiz.respostaCorreta.nome,
                            ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: respostaCorreta
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _irParaProximaPergunta,
                        child: Text(textos.proximaPergunta),
                      ),
                    ),
                  ],
                  if (_quizEncerrado) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${textos.tempoEsgotado} ${textos.resultadoFinal}: '
                      '$_pontuacao ${_idioma == IdiomaApp.portugues ? 'pontos' : 'points'}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _reiniciarQuiz,
                        child: Text(textos.jogarNovamente),
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
