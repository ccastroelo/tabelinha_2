# Tabelinha

Calendário do ciclo menstrual e do período fértil. Port em Flutter do app iOS
original (Objective-C). O código original foi removido da árvore e continua no histórico
do Git, no commit `8af622c` ("first commit"). Para trazê-lo de volta, na raiz do repositório:
`git restore --source=8af622c -- tabelinha`.

Este projeto Flutter fica em `app-flutter/`; rode os comandos abaixo de dentro dela.

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

1. Restaurar o app antigo (comando acima) e rodá-lo num simulador, definir início/duração e registrar um período com anotação.
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

## CI/CD (Codemagic)

O `codemagic.yaml` fica na **raiz do repositório** (`../codemagic.yaml`; o Codemagic só o
encontra ali) e define três workflows:

> **Escopo atual: só iOS/TestFlight.** O `android-release` está com o gatilho desligado no
> `codemagic.yaml` (só roda se iniciado à mão), para a tag `v*` não disparar um build Android
> que falharia por falta do keystore. Os passos 3 a 5 abaixo ficam para quando o Android voltar.

| Workflow          | Quando roda                              | O que faz                                                  |
| ----------------- | ---------------------------------------- | ---------------------------------------------------------- |
| `tests`           | PR para a `main` e push na `main`        | `flutter analyze` e `flutter test`                         |
| `android-release` | só início manual no painel (desligado)   | AAB assinado, disponível como artefato (sem publicar ainda) |
| `ios-release`     | tag `v*` ou início manual no painel      | IPA assinado → App Store Connect/TestFlight (não publica na loja) |

**Para lançar uma versão:** ajuste `version:` no `pubspec.yaml` (ex.: `4.0.1`), commite e
crie a tag: `git tag v4.0.1 && git push origin v4.0.1`. O número depois do `+` (build) é
definido pelo CI: o maior entre "último da loja + 1" e o contador do Codemagic.

### Configuração única no painel

1. **Repositório:** em codemagic.io, *Add application* → GitHub → `ccastroelo/tabelinha_2` →
   Flutter App → configuração por `codemagic.yaml`. Escolha uma branch que já contenha o arquivo.
2. **iOS:** em *Teams → Integrations → App Store Connect*, crie uma integração chamada
   **`tabelinha_asc`** com uma chave de API (App Store Connect → Usuários e Acesso →
   Integrações; permissão App Manager ou superior). O Codemagic cria o certificado e o perfil
   de distribuição para `br.eti.claudiocastro.tabelinha`. O `APP_STORE_APPLE_ID` (595717748) já
   foi conferido na App Store: é o "Tabelinha", mesmo bundle, versão publicada 3.0. A chave de API
   precisa ser do time dono do app (SYNAPSE SOLUCOES TECNOLOGICAS LTDA).
   O build sobe para o App Store Connect e aparece no TestFlight. **Testadores internos** recebem
   assim que o processamento termina, sem revisão da Apple. Para **grupo externo**, acrescente
   `submit_to_testflight: true` e `beta_groups:` no bloco `publishing` do `ios-release` — aí
   passa pela beta review.
3. **Android, assinatura:** em *Teams → Code signing identities → Android keystores*, gere um
   keystore com *reference name* **`tabelinha_keystore`**. Ele será a chave de envio: guarde uma
   cópia fora do Codemagic e use o Play App Signing, que permite redefinir essa chave.
4. **Android, primeira versão (o app ainda não existe no Google Play):** crie o app no Play
   Console (pacote `br.eti.claudiocastro.tabelinha`), rode `android-release`, baixe o `.aab`
   dos artefatos e envie **manualmente**, por exemplo na faixa de testes internos.
5. **Android, publicação automática (só depois do passo 4):** crie uma conta de serviço no
   Google Cloud, dê a ela acesso ao app no Play Console e baixe o JSON. No Codemagic, crie o grupo
   de variáveis **`google_play`** com a variável secreta `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`
   (conteúdo do JSON). Depois descomente `groups` e `publishing` em `android-release`.
6. Abra um PR para a `main` e confira se `tests` dispara (o gatilho depende do webhook que o
   Codemagic cria ao adicionar o repositório).

### O que foi validado

- A estrutura do `codemagic.yaml` (parse, campos obrigatórios, tipos de máquina, prefixo
  `app-flutter/` nos artefatos) e a lógica do número de build, com stubs da CLI.
- A assinatura de release do Android, com `jarsigner`: AAB gerado com um keystore descartável
  passado pelas variáveis `CM_*` saiu assinado por ele, e sem as variáveis (build local) saiu
  com a chave `Android Debug`, que o Google Play recusa.
- O `APP_STORE_APPLE_ID` e o bundle identifier, contra a ficha pública do app na App Store.
- **Não validado:** a execução no Codemagic em si, a assinatura/envio do iOS e a publicação nas lojas.
  Isso depende da sua conta e das credenciais; espere ajustes no primeiro build de cada workflow.

### Decisões

- **Máquina:** tudo em `mac_mini_m2`, coberta pelas 500 min/mês do plano gratuito. `linux_x2`
  é mais barato, mas exige cobrança ativada; se ativar, troque em `tests` e `android-release`.
  Por isso os releases só rodam por tag, não a cada push.
- **Publicação conservadora:** o Android só gera o AAB (quando a publicação for ligada, vai como
  rascunho na faixa interna) e o iOS só chega ao App Store Connect. Liberar para o público é
  sempre um passo manual seu.
- **Versão 4.0.0:** o app iOS original estava na 3.0 e a App Store só aceita versão maior que a
  publicada (confira a versão que está no ar).
- **Assinatura:** `android/app/build.gradle.kts` lê `CM_KEYSTORE_PATH` e relacionadas. Em build
  local cai na chave de debug, que o Google Play recusa.

## Pendências

- Validar a importação no iOS (passos acima).
- Confirmar no iOS que o backup do iCloud traz os dados de volta num aparelho novo.
- Ícone do app e tela de abertura (ainda os padrões do Flutter).
- Testar o restante no iOS (o projeto foi desenvolvido e validado no Android/Windows).
