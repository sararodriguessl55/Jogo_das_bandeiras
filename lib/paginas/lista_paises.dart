import 'package:flutter/material.dart';
import 'package:jogo1/localizacao.dart';
import 'package:jogo1/model.dart';

class ListaPaises extends StatefulWidget {
  const ListaPaises({required this.paises, required this.idioma, super.key});

  final List<Pais> paises;
  final IdiomaApp idioma;

  @override
  State<ListaPaises> createState() => _EstadoListaPaises();
}

class _EstadoListaPaises extends State<ListaPaises> {
  late IdiomaApp _idioma;

  @override
  void initState() {
    super.initState();
    _idioma = widget.idioma;
  }

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp(_idioma);
    final paisesOrdenados = List<Pais>.of(widget.paises)
      ..sort(
        (primeiro, segundo) => textos
            .nomePais(primeiro)
            .compareTo(textos.nomePais(segundo)),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tituloPaises(widget.paises.length)),
        actions: [
          SeletorIdioma(
            idioma: _idioma,
            onChanged: (idioma) => setState(() => _idioma = idioma),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: paisesOrdenados.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, indice) {
          final pais = paisesOrdenados[indice];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/flags/64x64/${pais.codigoAlfa2}.png',
                width: 48,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 48, child: Icon(Icons.flag_outlined)),
              ),
            ),
            title: Text(textos.nomePais(pais)),
            subtitle: Text(
              textos.codigosPais(
                pais.codigoContinente,
                pais.codigoAlfa2.toUpperCase(),
                pais.codigoAlfa3.toUpperCase(),
              ),
            ),
          );
        },
      ),
    );
  }
}
