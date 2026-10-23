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
  ui/      theme, widgets (SoftCard, HeroBanner), home (resumo, calendário, ajustes),
           history, help, terms
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
- **Previsão pelo histórico.** Com 3 ou mais menstruações vividas (o início de referência e os
  registros que já começaram), o app usa a média dos últimos ciclos (até 6) no lugar da duração
  fixa, e os ciclos já vividos aparecem com as datas reais de cada um. Intervalos fora de 8 a 55
  dias são descartados: um buraco sem registro não é um ciclo de 90 dias. A janela fértil
  continua de 9 dias, com a ovulação na metade de cada ciclo. O interruptor "Calcular pelo
  histórico", em "Seu ciclo", desliga isso e volta ao cálculo de sempre; o teste
  `history_prediction_test.dart` garante que, com ciclos regulares, os dois dão o mesmo
  calendário. Código: `knownPeriods`, `estimateCycleLength` e `CycleCalculator.known` em
  `lib/core/cycle_calculator.dart`.
  - **Limite:** o histórico só reflete a realidade se a data de início for corrigida quando a
    menstruação vem em outro dia e o mês for registrado de novo. "Registrar menstruação do mês"
    grava as datas que o próprio app projetou; sem correção, a média sai igual à duração fixa.
- **Lembretes.** Opcionais e desligados até a pessoa ligar (o sistema pede a permissão de
  notificações nessa hora). Avisam a próxima menstruação (com 0 a 7 dias de antecedência), o
  início do período fértil e a ovulação, num horário escolhido. São agendados no próprio
  aparelho com `flutter_local_notifications`: nada passa por servidor nem por rede. O app agenda
  os próximos 130 dias (no máximo ~15 avisos; o iOS aceita 64) e reagenda a cada mudança nos
  dados e toda vez que abre; quem não abre o app por mais de uns 4 meses deixa de receber.
  - **Código:** `lib/core/reminders.dart` (quais avisos e quando, puro e testado),
    `lib/state/app_controller.dart` (liga/desliga, permissão e reagendamento),
    `lib/data/local_notifications_service.dart` (o plugin) e `lib/ui/home/reminders_card.dart`.
  - **Detalhes:** o texto não cita datas e diz que é só uma estimativa; no Android a
    notificação fica oculta com a tela bloqueada e protegida. Cada aviso é um instante
    absoluto (horário local do Dart convertido para UTC), então não há banco de fusos; ao viajar
    para outro fuso os avisos já agendados seguem o horário de antes até o app abrir de novo.
    Sem alarme exato, o aviso pode atrasar alguns minutos.
  - **Android:** exige `coreLibraryDesugaring` no `build.gradle.kts` e os receptores do plugin
    no `AndroidManifest.xml`; o ícone da barra de status é `res/drawable/ic_stat_tabelinha.xml`,
    e o `res/raw/keep.xml` o protege do encolhimento de recursos do release (o plugin o procura
    pelo nome; sem isso os lembretes falham no release com `invalid_icon`, e só lá).
    **iOS:** o `AppDelegate.swift` define o delegado das notificações. Não foi testado em
    aparelho (sem Mac): vale conferir no TestFlight que o pedido de permissão aparece e que
    os avisos chegam.
- **Bloqueio do app.** Opcional e desligado por padrão ("Bloqueio do app", na home). Usa a
  autenticação do próprio aparelho (digital, rosto ou código de tela, pelo `local_auth`): o app
  não guarda senha nem recebe biometria, só ouve "sim" ou "não" do sistema, e não existe
  "esqueci o PIN" que apague dados.
  - **Quando tranca:** ao abrir o app e depois de ficar mais de 30 s fora (`lockGracePeriod`); a
    carência evita pedir de novo ao voltar da folha de compartilhar ou de um diálogo de
    permissão. Enquanto a tela do sistema está aberta, o app não conta isso como "ter saído".
    Relógio que volta para trás tranca.
  - **Capa de privacidade:** com o bloqueio ligado, o app se cobre assim que sai da frente, para
    a prévia nos apps recentes não mostrar os dados (conferido no emulador).
  - **Ligar e desligar** exigem se identificar, para quem pegar o celular desbloqueado não
    desligar. Sem bloqueio de tela no aparelho o interruptor fica travado e explica o que fazer.
    Se o aparelho **perder** o bloqueio de tela com o bloqueio do app ligado, o app se desliga em
    vez de trancar a pessoa para fora (só quando o aparelho garante que não suporta; um erro do
    plugin mantém tudo trancado).
  - **Código:** `lib/state/app_lock.dart` (estado, carência e regras; atrás de `Authenticator`, que
    os testes trocam por `test/fake_authenticator.dart`), `lib/ui/lock/app_lock_gate.dart` (a tela
    de bloqueio e a capa, acima do `Navigator`) e `lib/ui/home/app_lock_card.dart`.
  - **Android:** `MainActivity` é `FlutterFragmentActivity`, a permissão `USE_BIOMETRIC` está no
    manifesto e os temas anteriores ao Android 12 têm pai AppCompat (sem isso o diálogo
    biométrico quebra no Android 8 ou anterior). **iOS:** `NSFaceIDUsageDescription` no
    `Info.plist`, em inglês (traduzir exige `InfoPlist.strings` no projeto Xcode). Não foi
    testado em aparelho iOS (sem Mac): vale conferir Face ID e Touch ID no TestFlight.
- **Histórico.** Registrar o mesmo período duas vezes atualiza o registro em vez de duplicar
  (o original duplicava). A identidade do registro é a data de início. Registrar uma data a menos
  de 8 dias de um registro corrige esse registro (e mantém a anotação) em vez de criar outro,
  que estragaria a média.
- **Termos.** O original encerrava o app (`exit(0)`) se a pessoa não concordasse. A App Store
  não aceita isso; aqui o botão "Continuar" só habilita depois de marcar "Estou ciente".
- **Anotações.** Salvam sozinhas ao sair da tela (sem Cancelar/Gravar).
- **Removidos:** Parse, Flurry, Facebook SDK, iRate e as notificações push. Nada disso
  é necessário para o app funcionar. (Os lembretes de hoje são outra coisa: notificações
  locais, agendadas no próprio aparelho, sem servidor.)
- pt-PT usava exatamente os mesmos textos do pt-BR, então `pt` cobre os dois.

## Visual

A direção visual é a "Acolhedor": fundo pêssego, cartões brancos de cantos bem
arredondados com sombra suave, destaque coral em degradê no topo e a fonte Nunito.
Mantém o coral do ícone. Vale para todas as telas, no tema claro e no escuro.

- **Tema.** `lib/ui/theme.dart` define `buildTheme(Brightness)` e a extensão `CycleColors`
  (menstruação, fértil, ovulação, tonal, destaque e sombra). As telas não usam cor fixa.
- **Peças.** `SoftCard` e `HeroBanner` (`lib/ui/widgets/`) são a base de qualquer tela nova.
- **Fonte.** Nunito (SIL OFL) vai embutida em `assets/fonts/`, sem baixar nada em execução.
  A licença aparece na tela de licenças do app.
- **Calendário.** Cada dia tem a própria forma: menstruação em quadrado cheio, período
  fértil em quadrado tintado com um ponto sob o número, ovulação em círculo âmbar e "hoje"
  com anel. O período fértil não depende só da cor.
- **Contraste.** `test/contrast_test.dart` confere todos os pares texto/fundo nos dois
  temas (4,5:1 para texto normal, 3:1 para texto grande). O branco sobre o coral só passa
  de 3:1, por isso o `HeroBanner` leva apenas texto grande.
- **Fonte ampliada.** `test/app_test.dart` percorre as telas em 360×640 dp com fonte a 2,0×
  e falha se algo estourar.

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

## Ícone e splash

O ícone é o do app iOS antigo: coral, setas e grade de pontos com o dia destacado. A versão
em alta resolução (2048 px, quadrado cheio) não está no histórico do Git do app antigo, onde
o maior arquivo é de 180 px; veio do `tabelinha_3` (`assets/icons/icon2048.png`).

- **Fonte:** `assets/icon/icon.png`, cópia do original. As camadas do Android e as imagens da
  splash (`assets/icon/adaptive_*.png`, `assets/splash/*.png`) saem dele por
  `tool/generate_brand_assets_test.dart`: o símbolo é extraído do próprio original, não redesenhado.
- **Configuração:** seções `flutter_launcher_icons` e `flutter_native_splash` do `pubspec.yaml`.
- **Android:** ícone adaptativo (fundo `#FF5A5A` e símbolo), ícone temático (Android 13+) e
  splash do Android 12+ (fundo coral com o símbolo).
- **iOS:** `AppIcon` completo, com o de 1024 px sem canal alfa (a App Store rejeita
  transparência), e `LaunchScreen` com fundo coral e o símbolo.
- **Splash:** só coral, igual no claro e no escuro. A do app antigo era a marca "iDeias MOB © 2013".

Para regenerar tudo:

```bash
flutter test tool/generate_brand_assets_test.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
git checkout -- ios/Runner.xcodeproj/project.pbxproj ios/Runner/Info.plist
```

O último comando desfaz estragos das ferramentas (só rode se não tiver outras mudanças nesses
dois arquivos): o `flutter_launcher_icons` troca o valor de
`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` por um inválido no `project.pbxproj`,
e o `flutter_native_splash` reformata o `Info.plist`.

Validado no emulador Android (ícone adaptativo e splash). O lado iOS (catálogo de ícones, 
`LaunchScreen.storyboard`) foi gerado e revisado, mas não rodado.

## Imagens da App Store

`flutter test tool/generate_store_screenshots_test.dart` gera 54 imagens em
`store/ios/screenshots/<idioma>/<aparelho>/`: 6 telas × 3 idiomas × 3 aparelhos. Leva uns 30 s.

| Pasta        | Tamanho   | Onde subir no App Store Connect                                         |
| ------------ | --------- | ----------------------------------------------------------------------- |
| `iphone-6.3` | 1206×2622 | iPhone 6,1" ou 6,3" (a loja aceita também 1179×2556, 2556×1179 e 2622×1206) |
| `iphone-6.9` | 1320×2868 | iPhone 6,9"                                                             |
| `ipad-13`    | 2064×2752 | iPad 13" (o app é universal, então a loja exige)                        |

Para um tamanho de iPhone novo, acrescente um `_Device` em `_devices` no gerador. As prévias
em vídeo (1920×886 ou 886×1920) não são geradas aqui: são vídeos, não telas.

Os textos da loja (nome, subtítulo, descrição, palavras-chave e novidades, nos mesmos três
idiomas) estão em `store/ios/descricoes.md`, com o limite de caracteres de cada campo.

| Pasta   | Localização na loja                                           |
| ------- | ------------------------------------------------------------- |
| `pt-BR` | Português (Brasil)                                            |
| `en-US` | Inglês (EUA)                                                  |
| `es-ES` | Espanhol (Espanha); serve também para o espanhol do México    |

As telas, na ordem: `01-today`, `02-calendar`, `03-settings`, `04-records`, `05-notes`, `06-dark`.

- **São o app de verdade.** Cada imagem é a tela renderizada pelo próprio app, com a Nunito, a
  plataforma iOS e dados de exemplo numa data fixa (17/10/2026), por isso saem iguais a cada
  execução. A barra de status (9:41) e o indicador de início são desenhados por cima.
- **Moldura e texto** ficam em `tool/generate_store_screenshots_test.dart`: os títulos e subtítulos
  de cada idioma em `_langs`, as telas em `_shots` e as anotações de exemplo em `_Lang.notes`.
- **iPad.** A tela é renderizada em 768×1024 pt (proporção 3:4 de qualquer iPad) para a coluna do
  app preencher a moldura; em 1032×1376 pt sobrava fundo vazio dos lados.
- **PNG de 24 bits, sem transparência.** O gerador codifica o PNG ele mesmo, porque o do `dart:ui`
  sai com canal alfa.
- Os textos de marketing não prometem eficácia contraceptiva, que o app também não oferece.

## Política de privacidade

`store/privacy-policy.html` é a política, em português, inglês e espanhol, num arquivo só e sem
nenhum recurso externo. Ela descreve o que o app faz de fato: nada sai do aparelho (sem rede,
conta, anúncios nem analytics). Se o app passar a enviar qualquer dado, a política precisa mudar
junto, e o questionário de privacidade da loja também.

- **Antes de publicar**, troque os três `[e-mail de contato]` (um por idioma); estão em amarelo.
- **Endereço por idioma**: o mesmo arquivo, com `#pt`, `#en` ou `#es` no fim, mostra só aquele
  idioma. Dá para usar um endereço diferente em cada localização do App Store Connect.
- **Hospedagem**: qualquer página estática serve (por exemplo, GitHub Pages). A loja exige uma URL
  pública da política.

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

1. **Repositório — feito.** `ccastroelo/tabelinha_2` foi adicionado na conta pessoal do
   Codemagic como *Flutter App*, com configuração por `codemagic.yaml`. O painel está apontado
   para a branch `feat/flutter-port`, a única que hoje contém o arquivo; depois do merge na
   `main`, troque o seletor de branch para `main`.
2. **iOS — feito, reaproveitando a chave existente.** O `ios-release` usa a chave de API do
   App Store Connect **`codemagic`** (Key ID `6PBVM27M7L`), que já estava na integração
   *Settings → Integrations → Developer Portal* da conta e é a mesma que assina o app atipico.
   Ela é da equipe dona do bundle `br.eti.claudiocastro.tabelinha` — confirmado porque a lista
   de bundle identifiers carregada com essa chave inclui o `tabelinha`. Como o certificado de
   distribuição é por equipe (e a Apple limita quantos existem), ele é reaproveitado; o perfil
   de provisionamento é por bundle id e o Codemagic cria o do Tabelinha no primeiro build.
   O `APP_STORE_APPLE_ID` (595717748) já foi conferido na App Store: é o "Tabelinha", mesmo
   bundle, versão publicada 3.0.
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

- A estrutura do `codemagic.yaml` (parse, campos obrigatórios, tipos de máquina) e a lógica do
  número de build, com stubs da CLI.
- **Erro encontrado no primeiro build real:** com o prefixo `app-flutter/` nos `artifacts`, o
  Codemagic respondeu "No artifacts were found" (o IPA existia). Os padrões agora começam com
  `**/`; o build imprime `pwd` e `CM_BUILD_DIR` e lista a pasta do IPA/AAB para o log mostrar
  onde o arquivo está se isso se repetir.
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
