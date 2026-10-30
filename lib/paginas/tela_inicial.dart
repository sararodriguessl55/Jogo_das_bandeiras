import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';
import 'package:jogo1/paginas/lista_paises.dart';
import 'package:jogo1/paginas/pagina_quiz.dart';
import 'package:jogo1/paginas/pagina_ranque.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _EstadoTelaInicial();
}

class _EstadoTelaInicial extends State<TelaInicial> {
  late Future<List<Pais>> _futuroPaises;
  IdiomaApp _idioma = IdiomaApp.portugues;
  int _duracaoQuizSegundos = 60;
  Continente _continenteSelecionado = Continente.todos;

  @override
  void initState() {
    super.initState();
    _futuroPaises = carregarPaises();
  }

  void _tentarCarregarNovamente() {
    setState(() {
      _futuroPaises = carregarPaises();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp(_idioma);

    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tituloInicial),
        actions: [
          SeletorIdioma(
            idioma: _idioma,
            onChanged: (idioma) => setState(() => _idioma = idioma),
          ),
        ],
      ),
      body: FutureBuilder<List<Pais>>(
        future: _futuroPaises,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(textos.erroCarregamento, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _tentarCarregarNovamente,
                      child: Text(textos.tentarNovamente),
                    ),
                  ],
                ),
              ),
            );
          }

          final paises = snapshot.data;
          if (paises == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _MenuInicial(
            paises: paises,
            idioma: _idioma,
            duracaoQuizSegundos: _duracaoQuizSegundos,
            continenteSelecionado: _continenteSelecionado,
            aoAlterarDuracao: (duracao) {
              setState(() => _duracaoQuizSegundos = duracao);
            },
            aoAlterarContinente: (continente) {
              setState(() => _continenteSelecionado = continente);
            },
          );
        },
      ),
    );
  }
}

class _MenuInicial extends StatelessWidget {
  const _MenuInicial({
    required this.paises,
    required this.idioma,
    required this.duracaoQuizSegundos,
    required this.continenteSelecionado,
    required this.aoAlterarDuracao,
    required this.aoAlterarContinente,
  });

  final List<Pais> paises;
  final IdiomaApp idioma;
  final int duracaoQuizSegundos;
  final Continente continenteSelecionado;
  final ValueChanged<int> aoAlterarDuracao;
  final ValueChanged<Continente> aoAlterarContinente;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = TextosApp(idioma);
    final paisesDoContinente = paises
        .where(
          (pais) =>
              continenteSelecionado == Continente.todos ||
              pais.continente == continenteSelecionado,
        )
        .toList(growable: false);
    final temPaises = paisesDoContinente.length >= GeradorQuiz.numeroAlternativas;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/home.png',
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: cores.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          textos.introducao,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cores.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          textos.descricao(paises.length),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Continente>(
                  initialValue: continenteSelecionado,
                  decoration: InputDecoration(
                    labelText: textos.selecionarContinente,
                    prefixIcon: const Icon(Icons.public),
                    border: const OutlineInputBorder(),
                  ),
                  items: Continente.values
                      .map(
                        (continente) => DropdownMenuItem<Continente>(
                          value: continente,
                          child: Text(textos.nomeContinente(continente)),
                        ),
                      )
                      .toList(),
                  onChanged: (continente) {
                    if (continente != null) aoAlterarContinente(continente);
                  },
                ),
                if (!temPaises) ...[
                  const SizedBox(height: 8),
                  Text(
                    textos.continenteSemPaises(
                      textos.nomeContinente(continenteSelecionado),
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 30, label: Text('30 s')),
                    ButtonSegment(value: 60, label: Text('60 s')),
                    ButtonSegment(value: 120, label: Text('120 s')),
                  ],
                  selected: {duracaoQuizSegundos},
                  showSelectedIcon: false,
                  onSelectionChanged: (duracao) =>
                      aoAlterarDuracao(duracao.first),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(textos.comecarQuiz),
                    onPressed: temPaises
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PaginaQuiz(
                                  paises: paisesDoContinente,
                                  idioma: idioma,
                                  duracaoSegundos: duracaoQuizSegundos,
                                  continente: continenteSelecionado,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: Text(textos.verRanque),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PaginaRanque(idioma: idioma),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.public),
                    label: Text(textos.verPaises),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ListaPaises(paises: paises, idioma: idioma),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
