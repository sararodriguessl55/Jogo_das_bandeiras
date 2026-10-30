# Quiz de Bandeiras / Flags Quiz

Aplicativo Flutter para praticar o reconhecimento de bandeiras nacionais. O
menu permite escolher entre **30, 60 ou 120 segundos** para o quiz de múltipla
escolha e selecionar **todos os continentes** ou um dos seis continentes, ou consultar a lista de países e
bandeiras. Após cada resposta, a próxima bandeira aparece automaticamente. Ao
final, o resultado mostra as bandeiras acertadas e erradas, incluindo as
perguntas não respondidas, e permite salvar ou descartar a pontuação. O ranque é
armazenado localmente no aparelho e pode ser consultado por continente e duração.
A Antártida aparece na seleção, mas não possui bandeiras jogáveis nesta versão.
A interface está disponível em português e inglês; use o seletor `PT` / `EN` no
topo das telas.

## Como executar

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install) e
   configure um dispositivo ou emulador.
2. Abra um terminal na pasta deste projeto (`jogo1`).
3. Execute:

```sh
flutter pub get
flutter run
```

Para executar no navegador Chrome:

```sh
flutter run -d chrome
```

Para verificar o código e executar os testes:

```sh
flutter analyze
flutter test
```

## Arquitetura

- `lib/main.dart`: inicializa o aplicativo e define o tema.
- `lib/localizacao.dart`: contém as traduções da interface para português e
  inglês e o seletor de idioma.
- `lib/model.dart`: define `Pais`, carrega os dados JSON dos assets e usa
  `GeradorQuiz` para preparar as alternativas.
- `lib/paginas/tela_inicial.dart`: carrega os países e apresenta o menu.
- `lib/paginas/pagina_quiz.dart`: exibe as perguntas, contabiliza os pontos,
  avança automaticamente e apresenta os resultados quando o tempo selecionado
  termina.
- `lib/paginas/pagina_ranque.dart` e `lib/modelo_ranque.dart`: consultam e
  persistem localmente os melhores resultados.
- `lib/paginas/lista_paises.dart`: exibe a lista ordenada de países e bandeiras.
- `assets/data/en/` e `assets/flags/`: dados dos países e imagens das bandeiras.
- `test/widget_test.dart`: verifica o menu, a navegação, os idiomas e o tempo
  limite do quiz.

Os textos da interface são bilíngues. Os nomes dos países são exibidos em
português brasileiro ou inglês conforme o idioma selecionado.

## Créditos dos dados e imagens

A lista de países e as imagens das bandeiras foram reutilizadas do projeto
`flutter_flags_quiz`, que credita o conjunto
[world_countries](https://github.com/stefangabos/world_countries), de Stefan
Gabos.
