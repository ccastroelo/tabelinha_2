# Tabelinha

Calendário do ciclo menstrual e do período fértil. Port em Flutter do app iOS
original (Objective-C), que continua na pasta [`tabelinha/`](tabelinha/) só como
referência.

Bundle id / applicationId: `br.eti.claudiocastro.tabelinha` (o mesmo do app original).

## Rodar

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

Textos em `lib/l10n/*.arb` (pt, en, es); o código é gerado por `flutter gen-l10n`
a cada build.

## Estrutura

```
lib/
  core/    cálculo do ciclo e datas — Dart puro, sem Flutter
  data/    PeriodRecord + CycleRepository (shared_preferences)
  state/   AppController (ChangeNotifier) + AppScope (InheritedNotifier)
  l10n/    ARBs
  ui/      theme, home (resumo, calendário, ajustes), history, help, terms
```

## O que veio do app original

| Original (Obj-C)                         | Aqui                                              |
| ---------------------------------------- | ------------------------------------------------- |
| `tabViewController` — calendário + ajustes | `ui/home/*`                                       |
| `retornaStatusDaCelula:`                  | `CycleCalculator.kindOf` (testado contra o original) |
| `historicoTableViewController`            | `ui/history/history_page.dart`                    |
| `detailViewController` — anotações        | `ui/history/record_detail_page.dart`              |
| `ajudaViewController`                     | `ui/help/help_page.dart`                          |
| `acordoViewController` — termos           | `ui/terms/terms_page.dart`                        |
| `NSUserDefaults` + `periodos.bin`         | `CycleRepository`                                 |

## Decisões e diferenças

- **Fertilidade.** O calendário marca ovulação no dia `ciclo ÷ 2` e janela fértil de ±4
  dias (9 dias), exatamente como o app original. O texto de ajuda do original dizia
  "2 dias antes e depois" (5 dias); foi corrigido para 4 e 9. Se a janela mudar, altere
  `fertileHalfWindow` (`lib/core/cycle_calculator.dart`) e o `helpBody` dos ARBs juntos.
- **Projeção do ciclo.** O original só projetava um ciclo antes da data de início; aqui o
  ciclo é projetado para qualquer data.
- **Histórico.** Registrar o mesmo período duas vezes atualiza o registro em vez de duplicar
  (o original duplicava). A identidade do registro é a data de início.
- **Termos.** O original encerrava o app (`exit(0)`) se a pessoa não concordasse. A App Store
  não aceita isso; aqui o botão "Continuar" só habilita depois de marcar "Estou ciente".
- **Anotações.** Salvam sozinhas ao sair da tela (sem Cancelar/Gravar).
- **Removidos:** Parse, Flurry, Facebook SDK, iRate e as notificações push. Nada disso
  é necessário para o app funcionar.
- pt-PT usava exatamente os mesmos textos do pt-BR, então `pt` cobre os dois.

## Importação dos dados do app antigo (iOS)

Quem atualiza do app Objective-C para este mantém a pasta de dados (mesmo bundle id).
Na primeira abertura, antes da primeira tela, o app traz:

| No app antigo                                   | Vira                         |
| ----------------------------------------------- | ---------------------------- |
| `NSUserDefaults` `iniciociclo`                  | início do ciclo              |
| `duracaociclo`, `duracaoperiodo`                | duração do ciclo / menstruação |
| `Documents/periodos.bin` (`Periodo`: início, fim, anotação) | histórico com anotações |
| `acordado`                                      | termos já aceitos (não pergunta de novo) |

- **Nativo:** `LegacyDataReader` em `ios/Runner/AppDelegate.swift` lê tudo e devolve JSON
  pelo canal `br.eti.claudiocastro.tabelinha/data` (`getData`). Fica no `AppDelegate.swift`
  para não precisar mexer no `.pbxproj`.
- **Dart:** `lib/data/legacy_importer.dart` e `legacy_data.dart`; a regra de mesclagem está em
  `AppController.importLegacy`.
- **Não sobrescreve nada:** ajustes só entram se ainda não há data de início; registros com o
  mesmo início são mesclados (a anotação existente vence); duplicados do app antigo viram um só.
- **Roda uma vez.** Se a leitura falhar (ou o canal não existir), nada é marcado e tenta de
  novo na próxima abertura. Nunca derruba a inicialização.
- No Android o importador não faz nada: o app antigo só existia no iOS.

**O lado Dart é coberto por testes; o Swift ainda não foi compilado nem rodado** (o projeto
foi desenvolvido no Windows). Para validar num Mac:

1. Rodar o app antigo (`tabelinha/`) num simulador, definir início/duração e registrar um período com anotação.
2. Sem desinstalar, rodar este app no mesmo simulador (mesmo bundle id).
3. Conferir calendário, histórico e anotação. Para repetir, apague a chave `flutter.legacyImported`
   do `NSUserDefaults` (ou reinstale o app novo mantendo os dados antigos).

## Backup e troca de aparelho

Sem login e sem servidor: os dados ficam na conta Apple ou Google da própria pessoa,
pelo backup automático do sistema.

- **Android:** Auto Backup, com regras explícitas em
  `android/app/src/main/res/xml/backup_rules.xml` (Android 11 e anterior) e
  `data_extraction_rules.xml` (Android 12+), referenciadas no `AndroidManifest.xml`.
  Só entra `FlutterSharedPreferences.xml`, que guarda tudo que o app salva (início e
  durações do ciclo, histórico com anotações, aceite dos termos). Mantenha os dois XMLs iguais.
- **iOS:** nada a configurar. `shared_preferences` grava no `NSUserDefaults`, que o backup do
  iCloud (e do computador) já inclui, e nenhum arquivo do app é excluído do backup.

Validado no emulador Android com o transporte local do `bmgr`: o log mostra as regras
lidas e só esse arquivo no backup; depois de apagar os dados do app (`pm clear`) e
rodar `bmgr restore`, o app abre com início, durações, histórico, anotação e termos de volta.

Isso é **restauração ao trocar de aparelho, não sincronização**:

- Precisa do backup ligado nos ajustes do sistema (iCloud Backup / Backup do Google).
- No Android o backup roda cerca de uma vez por dia, com o aparelho parado, carregando e no
  Wi-Fi, e a restauração acontece ao instalar num aparelho novo (ou reinstalar pela Play Store).
- Não passa dados entre iOS e Android nem mantém dois aparelhos em sincronia.

Para testar de novo no Android (emulador com Google Play, sem conta):

```bash
adb shell bmgr enable true
adb shell bmgr transport com.android.localtransport/.LocalTransport
adb shell bmgr backupnow br.eti.claudiocastro.tabelinha   # app aberto, não parado
adb shell pm clear br.eti.claudiocastro.tabelinha
adb shell bmgr restore 1 br.eti.claudiocastro.tabelinha
```

## Pendências

- Validar a importação no iOS (passos acima).
- Confirmar no iOS que o backup do iCloud traz os dados de volta num aparelho novo.
- Ícone do app e tela de abertura (ainda os padrões do Flutter).
- Testar o restante no iOS (o projeto foi desenvolvido e validado no Android/Windows).
