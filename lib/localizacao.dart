import 'package:flutter/material.dart';
import 'package:jogo1/model.dart';

enum IdiomaApp { portugues, ingles }

class TextosApp {
  const TextosApp(this.idioma);

  final IdiomaApp idioma;

  bool get _portugues => idioma == IdiomaApp.portugues;

  static const Map<String, String> _nomesPaisesPtBr = {
    'af': 'Afeganistão',
    'al': 'Albânia',
    'dz': 'Argélia',
    'ad': 'Andorra',
    'ao': 'Angola',
    'ag': 'Antígua e Barbuda',
    'ar': 'Argentina',
    'am': 'Armênia',
    'au': 'Austrália',
    'at': 'Áustria',
    'az': 'Azerbaijão',
    'bs': 'Bahamas',
    'bh': 'Bahrein',
    'bd': 'Bangladesh',
    'bb': 'Barbados',
    'by': 'Belarus',
    'be': 'Bélgica',
    'bz': 'Belize',
    'bj': 'Benim',
    'bt': 'Butão',
    'bo': 'Bolívia',
    'ba': 'Bósnia e Herzegovina',
    'bw': 'Botsuana',
    'br': 'Brasil',
    'bn': 'Brunei',
    'bg': 'Bulgária',
    'bf': 'Burquina Faso',
    'bi': 'Burundi',
    'cv': 'Cabo Verde',
    'kh': 'Camboja',
    'cm': 'Camarões',
    'ca': 'Canadá',
    'cf': 'República Centro-Africana',
    'td': 'Chade',
    'cl': 'Chile',
    'cn': 'China',
    'co': 'Colômbia',
    'km': 'Comores',
    'cg': 'Congo',
    'cd': 'República Democrática do Congo',
    'cr': 'Costa Rica',
    'ci': 'Costa do Marfim',
    'hr': 'Croácia',
    'cu': 'Cuba',
    'cy': 'Chipre',
    'cz': 'Chéquia',
    'dk': 'Dinamarca',
    'dj': 'Djibuti',
    'dm': 'Dominica',
    'do': 'República Dominicana',
    'ec': 'Equador',
    'eg': 'Egito',
    'sv': 'El Salvador',
    'gq': 'Guiné Equatorial',
    'er': 'Eritreia',
    'ee': 'Estônia',
    'sz': 'Essuatíni',
    'et': 'Etiópia',
    'fj': 'Fiji',
    'fi': 'Finlândia',
    'fr': 'França',
    'ga': 'Gabão',
    'gm': 'Gâmbia',
    'ge': 'Geórgia',
    'de': 'Alemanha',
    'gh': 'Gana',
    'gr': 'Grécia',
    'gd': 'Granada',
    'gt': 'Guatemala',
    'gn': 'Guiné',
    'gw': 'Guiné-Bissau',
    'gy': 'Guiana',
    'ht': 'Haiti',
    'hn': 'Honduras',
    'hu': 'Hungria',
    'is': 'Islândia',
    'in': 'Índia',
    'id': 'Indonésia',
    'ir': 'Irã',
    'iq': 'Iraque',
    'ie': 'Irlanda',
    'il': 'Israel',
    'it': 'Itália',
    'jm': 'Jamaica',
    'jp': 'Japão',
    'jo': 'Jordânia',
    'kz': 'Cazaquistão',
    'ke': 'Quênia',
    'ki': 'Quiribati',
    'kp': 'Coreia do Norte',
    'kr': 'Coreia do Sul',
    'kw': 'Kuwait',
    'kg': 'Quirguistão',
    'la': 'Laos',
    'lv': 'Letônia',
    'lb': 'Líbano',
    'ls': 'Lesoto',
    'lr': 'Libéria',
    'ly': 'Líbia',
    'li': 'Liechtenstein',
    'lt': 'Lituânia',
    'lu': 'Luxemburgo',
    'mg': 'Madagascar',
    'mw': 'Malawi',
    'my': 'Malásia',
    'mv': 'Maldivas',
    'ml': 'Mali',
    'mt': 'Malta',
    'mh': 'Ilhas Marshall',
    'mr': 'Mauritânia',
    'mu': 'Maurício',
    'mx': 'México',
    'fm': 'Micronésia',
    'md': 'Moldávia',
    'mc': 'Mônaco',
    'mn': 'Mongólia',
    'me': 'Montenegro',
    'ma': 'Marrocos',
    'mz': 'Moçambique',
    'mm': 'Mianmar',
    'na': 'Namíbia',
    'nr': 'Nauru',
    'np': 'Nepal',
    'nl': 'Países Baixos',
    'nz': 'Nova Zelândia',
    'ni': 'Nicarágua',
    'ne': 'Níger',
    'ng': 'Nigéria',
    'mk': 'Macedônia do Norte',
    'no': 'Noruega',
    'om': 'Omã',
    'pk': 'Paquistão',
    'pw': 'Palau',
    'pa': 'Panamá',
    'pg': 'Papua-Nova Guiné',
    'py': 'Paraguai',
    'pe': 'Peru',
    'ph': 'Filipinas',
    'pl': 'Polônia',
    'pt': 'Portugal',
    'qa': 'Catar',
    'ro': 'Romênia',
    'ru': 'Rússia',
    'rw': 'Ruanda',
    'kn': 'São Cristóvão e Névis',
    'lc': 'Santa Lúcia',
    'vc': 'São Vicente e Granadinas',
    'ws': 'Samoa',
    'sm': 'San Marino',
    'st': 'São Tomé e Príncipe',
    'sa': 'Arábia Saudita',
    'sn': 'Senegal',
    'rs': 'Sérvia',
    'sc': 'Seicheles',
    'sl': 'Serra Leoa',
    'sg': 'Singapura',
    'sk': 'Eslováquia',
    'si': 'Eslovênia',
    'sb': 'Ilhas Salomão',
    'so': 'Somália',
    'za': 'África do Sul',
    'ss': 'Sudão do Sul',
    'es': 'Espanha',
    'lk': 'Sri Lanka',
    'sd': 'Sudão',
    'sr': 'Suriname',
    'se': 'Suécia',
    'ch': 'Suíça',
    'sy': 'Síria',
    'tj': 'Tadjiquistão',
    'tz': 'Tanzânia',
    'th': 'Tailândia',
    'tl': 'Timor-Leste',
    'tg': 'Togo',
    'to': 'Tonga',
    'tt': 'Trinidad e Tobago',
    'tn': 'Tunísia',
    'tr': 'Turquia',
    'tm': 'Turcomenistão',
    'tv': 'Tuvalu',
    'ug': 'Uganda',
    'ua': 'Ucrânia',
    'ae': 'Emirados Árabes Unidos',
    'gb': 'Reino Unido',
    'us': 'Estados Unidos',
    'uy': 'Uruguai',
    'uz': 'Uzbequistão',
    'vu': 'Vanuatu',
    've': 'Venezuela',
    'vn': 'Vietnã',
    'ye': 'Iêmen',
    'zm': 'Zâmbia',
    'zw': 'Zimbábue',
  };

  String nomePais(Pais pais) =>
      _portugues ? _nomesPaisesPtBr[pais.codigoAlfa2] ?? pais.nome : pais.nome;

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
  String get resultados => _portugues ? 'Resultados' : 'Results';
  String get acertos => _portugues ? 'Acertos' : 'Correct';
  String get erros => _portugues ? 'Erros' : 'Incorrect';
  String respostaEscolhida(String pais) =>
      _portugues ? 'Sua resposta: $pais' : 'Your answer: $pais';
  String get naoRespondida => _portugues ? 'Não respondida' : 'Not answered';
  String respostaEsperada(String pais) =>
      _portugues ? 'Resposta correta: $pais' : 'Correct answer: $pais';
  String pontuacaoFinal(int acertos, int total) => _portugues
      ? '$acertos de $total respostas corretas'
      : '$acertos of $total answers correct';
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
