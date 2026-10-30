import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';
import 'package:jogo1/modelo_ranque.dart';

class PaginaQuiz extends StatefulWidget {
  const PaginaQuiz({
    required this.paises,
    required this.idioma,
    required this.duracaoSegundos,
    required this.continente,
    super.key,
  });

  final List<Pais> paises;
  final IdiomaApp idioma;
  final int duracaoSegundos;
  final Continente continente;

  @override
  State<PaginaQuiz> createState() => _EstadoPaginaQuiz();
}

class _ResultadoPergunta {
  const _ResultadoPergunta({required this.bandeira, this.resposta});

  final Pais bandeira;
  final Pais? resposta;

  bool get acertou => resposta == bandeira;
}

class _DialogSalvarRanque extends StatefulWidget {
  const _DialogSalvarRanque({required this.textos});

  final TextosApp textos;

  @override
  State<_DialogSalvarRanque> createState() => _EstadoDialogSalvarRanque();
}

class _EstadoDialogSalvarRanque extends State<_DialogSalvarRanque> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = widget.textos;
    return AlertDialog(
      title: Text(textos.salvarNoRanque),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: textos.nomeJogador,
            border: const OutlineInputBorder(),
          ),
          validator: (valor) => valor == null || valor.trim().isEmpty
              ? textos.nomeObrigatorio
              : null,
          onFieldSubmitted: (_) => _confirmar(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(textos.naoSalvarRanque),
        ),
        FilledButton(
          onPressed: () => _confirmar(context),
          child: Text(textos.confirmarSalvar),
        ),
      ],
    );
  }

  void _confirmar(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }
}

class _EstadoPaginaQuiz extends State<PaginaQuiz> {
  late final int _duracaoQuiz;
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
  late int _segundosRestantes;
  bool _quizEncerrado = false;
  bool _decidiuRanque = false;
  bool _resultadoSalvo = false;

  @override
  void initState() {
    super.initState();
    _idioma = widget.idioma;
    _duracaoQuiz = widget.duracaoSegundos;
    _segundosRestantes = _duracaoQuiz;
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
      _decidiuRanque = false;
      _resultadoSalvo = false;
      _geradorQuiz.prepararRodada();
    });
    _iniciarCronometro();
  }

  Future<void> _salvarNoRanque(TextosApp textos) async {
    final nome = await showDialog<String>(
      context: context,
      builder: (_) => _DialogSalvarRanque(textos: textos),
    );

    if (nome == null || !mounted) return;
    try {
      await RepositorioRanque().salvar(
        ResultadoRanque(
          nome: nome,
          pontos: _pontuacao,
          total: _resultados.length,
          duracaoSegundos: _duracaoQuiz,
          continente: widget.continente,
          data: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _decidiuRanque = true;
        _resultadoSalvo = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.resultadoSalvo)));
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${textos.erroSalvarRanque} $erro')),
      );
    }
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
                const SizedBox(height: 8),
                Text(
                  '${textos.nomeContinente(widget.continente)} · $_duracaoQuiz s',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (!_decidiuRanque)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            textos.tituloRanque,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            textos.idioma == IdiomaApp.portugues
                                ? 'Quer registrar sua pontuação no ranque deste aparelho?'
                                : 'Would you like to save your score to this device’s leaderboard?',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              FilledButton.icon(
                                onPressed: () => _salvarNoRanque(textos),
                                icon: const Icon(Icons.save_outlined),
                                label: Text(textos.salvarNoRanque),
                              ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _decidiuRanque = true),
                                child: Text(textos.naoSalvarRanque),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    _resultadoSalvo
                        ? textos.resultadoSalvo
                        : textos.resultadoNaoSalvo,
                    textAlign: TextAlign.center,
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
