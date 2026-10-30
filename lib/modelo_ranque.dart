import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

class ResultadoRanque {
  const ResultadoRanque({
    required this.nome,
    required this.pontos,
    required this.total,
    required this.duracaoSegundos,
    required this.continente,
    required this.data,
  });

  final String nome;
  final int pontos;
  final int total;
  final int duracaoSegundos;
  final Continente continente;
  final DateTime data;

  double get aproveitamento => total == 0 ? 0 : pontos / total;

  Map<String, Object> toJson() => {
    'nome': nome,
    'pontos': pontos,
    'total': total,
    'duracaoSegundos': duracaoSegundos,
    'continente': continente.name,
    'data': data.toIso8601String(),
  };

  factory ResultadoRanque.fromJson(Map<String, dynamic> json) {
    final continente = Continente.values.where(
      (valor) => valor.name == json['continente'],
    );
    if (continente.isEmpty) {
      throw const FormatException('Continente inválido no ranque salvo.');
    }

    return ResultadoRanque(
      nome: json['nome'] as String,
      pontos: json['pontos'] as int,
      total: json['total'] as int,
      duracaoSegundos: json['duracaoSegundos'] as int,
      continente: continente.first,
      data: DateTime.parse(json['data'] as String),
    );
  }
}

class RepositorioRanque {
  static const String _chave = 'jogo1_ranque_v1';

  Future<List<ResultadoRanque>> carregar() async {
    final preferencias = await SharedPreferences.getInstance();
    final jsonSalvo = preferencias.getString(_chave);
    if (jsonSalvo == null) return [];

    final decoded = jsonDecode(jsonSalvo);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Os dados do ranque salvo são inválidos.');
    }

    return decoded
        .map((item) => ResultadoRanque.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> salvar(ResultadoRanque resultado) async {
    final resultados = List<ResultadoRanque>.of(await carregar());
    resultados.add(resultado);
    resultados.sort(_comparar);

    final preferencias = await SharedPreferences.getInstance();
    final salvo = await preferencias.setString(
      _chave,
      jsonEncode(resultados.map((item) => item.toJson()).toList()),
    );
    if (!salvo) {
      throw StateError('Não foi possível salvar o ranque neste dispositivo.');
    }
  }

  static int comparar(ResultadoRanque a, ResultadoRanque b) => _comparar(a, b);

  static int _comparar(ResultadoRanque a, ResultadoRanque b) {
    final aproveitamento = b.aproveitamento.compareTo(a.aproveitamento);
    if (aproveitamento != 0) return aproveitamento;

    final pontos = b.pontos.compareTo(a.pontos);
    if (pontos != 0) return pontos;
    return a.data.compareTo(b.data);
  }
}
