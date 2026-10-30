import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

enum Continente { todos, africa, america, antarctica, asia, europa, oceania }

class Pais {
  const Pais({
    required this.codigoContinente,
    required this.id,
    required this.nome,
    required this.codigoAlfa2,
    required this.codigoAlfa3,
  });

  final String codigoContinente;
  final int id;
  final String nome;
  final String codigoAlfa2;
  final String codigoAlfa3;

  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      codigoContinente: json['cc'] as String,
      id: json['id'] as int,
      nome: json['name'] as String,
      codigoAlfa2: json['alpha2'] as String,
      codigoAlfa3: json['alpha3'] as String,
    );
  }

  @override
  String toString() => '$nome ($codigoAlfa2)';
}

extension ContinentePais on Pais {
  Continente get continente {
    switch (codigoContinente) {
      case 'AF':
        return Continente.africa;
      case 'NA':
      case 'SA':
        return Continente.america;
      case 'AQ':
        return Continente.antarctica;
      case 'AS':
        return Continente.asia;
      case 'EU':
        return Continente.europa;
      case 'OC':
        return Continente.oceania;
      default:
        throw FormatException(
          'Código de continente desconhecido: $codigoContinente',
        );
    }
  }
}

Future<List<Pais>> carregarPaises() async {
  final jsonText = await rootBundle.loadString('assets/data/en/countries.json');
  final decoded = jsonDecode(jsonText);
  if (decoded is! List<dynamic>) {
    throw const FormatException(
      'Os dados dos países devem ser uma lista JSON.',
    );
  }

  return decoded
      .map((entrada) => Pais.fromJson(entrada as Map<String, dynamic>))
      .toList(growable: false);
}

class GeradorQuiz {
  GeradorQuiz(List<Pais> paises, {Random? random})
    : _paises = List<Pais>.unmodifiable(paises),
      _random = random ?? Random() {
    if (_paises.length < numeroAlternativas) {
      throw ArgumentError.value(
        paises.length,
        'paises',
        'São necessários ao menos $numeroAlternativas países.',
      );
    }
  }

  static const int numeroAlternativas = 4;

  final List<Pais> _paises;
  final Random _random;

  List<Pais> opcoes = const [];
  late Pais respostaCorreta;

  void prepararRodada() {
    final paisesEmbaralhados = List<Pais>.of(_paises)..shuffle(_random);
    opcoes = paisesEmbaralhados.take(numeroAlternativas).toList(growable: false)
      ..shuffle(_random);
    respostaCorreta = opcoes[_random.nextInt(opcoes.length)];
  }
}
