# Tabelinha

Calendário do ciclo menstrual e do período fértil. O app Flutter fica em `app-flutter/`
(rode os comandos de lá); `codemagic.yaml` fica na raiz. O app original (Objective-C) só
existe no histórico do Git: `git restore --source=8af622c -- tabelinha`. Detalhes de
estrutura, importação de dados, backup e CI estão em `app-flutter/README.md`.

## Comandos

```bash
flutter analyze --no-pub
flutter test --no-pub
```

- `flutter build` / `flutter run` (qualquer coisa que chame o Gradle) só funciona no painel
  de Terminal do app (`run_in_terminal`, com `cwd` absoluto em `app-flutter`). No shell do
  agente o Gradle falha com "Unable to establish loopback connection".
- Depois de rodar `flutter pub get`/build, `pubspec.lock` muda por causa de pacotes presos ao
  SDK. Não commite essa mudança: `git checkout -- app-flutter/pubspec.lock`.
- Depois de rodar `flutter_launcher_icons` ou `flutter_native_splash`, reverta
  `ios/Runner.xcodeproj/project.pbxproj` e `ios/Runner/Info.plist`.

## Git

Só commite ou faça push quando a pessoa pedir, e respeite o que ela pediu ("só commit
local" ou "faça o push"). Nunca force-push.

## Cálculo do ciclo

`lib/core/cycle_calculator.dart` é Dart puro, sem Flutter. Duas regras que não se quebram:

- **Janela fértil de 9 dias** (`fertileHalfWindow = 4`): o texto de ajuda dos ARBs cita os mesmos
  números, e `test/help_text_test.dart` confere. Mudou um, mude o outro.
- **Sem histórico, o cálculo é idêntico ao do app original** (`test/cycle_calculator_test.dart`
  compara todas as combinações). A previsão pelo histórico (`knownPeriods`,
  `estimateCycleLength`, `CycleCalculator.known`) só entra por cima disso, e
  `test/history_prediction_test.dart` prova que, com ciclos regulares, dá o mesmo calendário.

## Lembretes

Notificações locais, opcionais e desligadas por padrão, sem servidor. Quais avisos e quando é
`planReminders` (`lib/core/reminders.dart`, puro); o plugin fica atrás de `ReminderService`
(`lib/data/`), então testes usam `test/fake_reminder_service.dart` e nunca o plugin. Se o app
passar a mandar qualquer dado para fora, a política de privacidade (`store/privacy-policy.html`)
e o questionário de privacidade da loja precisam mudar junto.

## Visual: direção "Acolhedor"

Cantos bem arredondados, sombra suave, fonte redonda e a identidade coral do ícone.

- **Tokens** em `lib/ui/theme.dart`: `buildTheme(Brightness)` e a extensão `CycleColors`
  (menstruação, fértil, ovulação, tonal, destaque, sombra). Nenhuma tela usa cor fixa;
  tudo vem do tema, claro e escuro.
- **Fonte**: Nunito estática (400/600/700/800) em `assets/fonts/`, embutida de propósito
  (sem baixar em tempo de execução). A licença OFL está registrada em `main.dart`.
- **Peças**: `SoftCard` (cartão branco, raio 28, sombra suave) e `HeroBanner` (destaque coral
  em degradê, com grade de pontos decorativa) em `lib/ui/widgets/`. Telas novas reaproveitam
  essas duas peças em vez de criar cartões próprios.
- **Contraste**: o branco sobre o coral só passa de 3:1, então o `HeroBanner` leva apenas
  texto grande (título ≥ 24 px, subtítulo ≥ 18,66 px em negrito). Texto menor vai em cartão
  branco. `test/contrast_test.dart` confere os pares nos dois temas (4,5:1 para texto normal,
  3:1 para texto grande); ao mudar uma cor, rode esse teste.
- **Dia fértil não depende só da cor**: o calendário põe um ponto sob o número, e a legenda
  repete as mesmas formas (quadrado, quadrado com ponto, círculo, anel).
- **Acessibilidade**: alvo de toque ≥ 48 dp, botões de ícone com `tooltip`, células do
  calendário com `Semantics.label`, layout testado com fonte ampliada (até 2,0×) e em 360 dp.
