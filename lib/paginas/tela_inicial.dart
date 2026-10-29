import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';
import 'package:jogo1/paginas/lista_paises.dart';
import 'package:jogo1/paginas/pagina_quiz.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _EstadoTelaInicial();
}

class _EstadoTelaInicial extends State<TelaInicial> {
  late Future<List<Pais>> _futuroPaises;
  IdiomaApp _idioma = IdiomaApp.portugues;

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

          return _MenuInicial(paises: paises, idioma: _idioma);
        },
      ),
    );
  }
}

class _MenuInicial extends StatelessWidget {
  const _MenuInicial({required this.paises, required this.idioma});

  final List<Pais> paises;
  final IdiomaApp idioma;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = TextosApp(idioma);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
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
                const SizedBox(height: 28),
                Text(
                  textos.introducao,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(textos.comecarQuiz),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              PaginaQuiz(paises: paises, idioma: idioma),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
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
