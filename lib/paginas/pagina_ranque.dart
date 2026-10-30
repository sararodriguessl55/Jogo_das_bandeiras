import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';
import 'package:jogo1/modelo_ranque.dart';

class PaginaRanque extends StatefulWidget {
  const PaginaRanque({required this.idioma, super.key});

  final IdiomaApp idioma;

  @override
  State<PaginaRanque> createState() => _EstadoPaginaRanque();
}

class _EstadoPaginaRanque extends State<PaginaRanque> {
  final RepositorioRanque _repositorio = RepositorioRanque();
  late Future<List<ResultadoRanque>> _resultados;
  Continente _continenteSelecionado = Continente.todos;
  int _duracaoSelecionada = 60;

  @override
  void initState() {
    super.initState();
    _resultados = _repositorio.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp(widget.idioma);
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(textos.tituloRanque)),
      body: FutureBuilder<List<ResultadoRanque>>(
        future: _resultados,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${textos.erroSalvarRanque}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final resultados =
              snapshot.data!
                  .where(
                    (resultado) =>
                        (_continenteSelecionado == Continente.todos ||
                            resultado.continente == _continenteSelecionado) &&
                        resultado.duracaoSegundos == _duracaoSelecionada,
                  )
                  .toList()
                ..sort(RepositorioRanque.comparar);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Continente>(
                              initialValue: _continenteSelecionado,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: textos.selecionarContinente,
                                border: const OutlineInputBorder(),
                              ),
                              items: Continente.values
                                  .map(
                                    (continente) =>
                                        DropdownMenuItem<Continente>(
                                          value: continente,
                                          child: Text(
                                            textos.nomeContinente(continente),
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (continente) {
                                if (continente != null) {
                                  setState(
                                    () => _continenteSelecionado = continente,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _duracaoSelecionada,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: textos.filtroTempoRanque,
                                border: const OutlineInputBorder(),
                              ),
                              items: const [30, 60, 120]
                                  .map(
                                    (segundos) => DropdownMenuItem<int>(
                                      value: segundos,
                                      child: Text('$segundos s'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (duracao) {
                                if (duracao != null) {
                                  setState(() => _duracaoSelecionada = duracao);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: resultados.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_outlined,
                                      size: 64,
                                      color: cores.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      textos.ranqueVazio,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: resultados.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final resultado = resultados[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: index < 3
                                          ? cores.primaryContainer
                                          : cores.surfaceContainerHighest,
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(
                                      resultado.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      textos.resumoRanque(resultado),
                                    ),
                                    trailing: index == 0
                                        ? Icon(
                                            Icons.emoji_events,
                                            color: cores.primary,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
