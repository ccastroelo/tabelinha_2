# Concorrentes e posicionamento

Levantamento de 23/10/2026 dos apps de ciclo menstrual e período fértil, para situar o
Tabelinha e decidir o que vale (e o que não vale) desenvolver a seguir. Alimenta os textos de
`descricoes.md` e a lista de pendências do `README.md`.

**Como foi feito:** pesquisa na web (listas de recomendação, páginas das lojas, imprensa e o
processo da FTC), sem instalar nem usar os apps. Número de usuários, preço e política de
privacidade mudam depressa e boa parte do que as lojas dizem é texto de marketing do próprio
desenvolvedor — confira na fonte antes de usar qualquer número destes numa decisão.

## As quatro camadas do mercado

**1. Os grandes, de conteúdo e assinatura.** [Flo](https://flo.health) e
[Clue](https://helloclue.com) são as referências. Conta obrigatória, dados na nuvem, previsão
com histórico longo, registro de dezenas de sintomas, artigos, comunidade e camada paga. A Flo
declarou 80 milhões de usuários ativos por mês em agosto de 2026; a assinatura da Clue (Clue
Plus) aparece em parceiros a US$ 39,99/ano. É aqui que mora o dinheiro do nicho — e também o
histórico ruim de privacidade: em 2021 a Flo fechou acordo com a FTC por ter enviado dados de
saúde (inclusive gravidez) para Facebook, Google, AppsFlyer e Flurry enquanto prometia
privacidade.

**2. Os populares genéricos.** "Meu Calendário", "Period Calendar", "Period Tracker" e dezenas
de clones. Grátis, com anúncios e compra interna, muito bem colocados nas lojas em português —
a Mozilla, no *Privacy Not Included*, registrou mais de 10 milhões de instalações só num deles
e reprovou suas práticas de dados. São o concorrente real do Tabelinha em visibilidade: é o que
a pessoa encontra ao buscar "calendário menstrual" na loja.

**3. Os de privacidade.** Camada pequena, crescente e ideologicamente próxima do Tabelinha:

- **[drip](https://dripapp.org)** — código aberto, dados só no aparelho, sem servidor, senha,
  método sintotérmico, importadores de Flo e Clue. É o mais citado como "o certo".
- **[Euki](https://eukiapp.org)** — sem conta, sem e-mail, dados só no aparelho, código aberto,
  PIN e **PIN de coação** (abre uma tela falsa se alguém obrigar a pessoa a destrancar).
- **[Mooneva](https://f-droid.org/en/packages/com.mooneva.app/)** — GPL-3, no F-Droid **sem
  permissão de internet** (dá para verificar, não é só promessa), PIN, modo discreto que
  disfarça o ícone e exportação de relatório clínico.
- **Nira, Cicla, PrivaCycle, Vela** — mesmo discurso, com menos verificação pública.

**4. O embutido, que ninguém lembra de contar.** O **Apple Saúde** tem Controle do Ciclo nativo:
grátis, já instalado, dados criptografados com o aparelho bloqueado, e a mesma previsão de
calendário (menstruação mais janela fértil). O Samsung Health faz o equivalente no Android. Para
quem só quer saber a data provável, esse é o concorrente mais difícil de bater — custo zero e
nenhum download. A estimativa retrospectiva de ovulação por temperatura do pulso exige Apple
Watch Series 8 ou mais novo.

## Comparação de funcionalidades

`✓` tem · `—` não tem · `pago` só na assinatura · `?` não achei fonte confiável. Colunas:
**Tab** Tabelinha · **Flo** · **Clue** · **Clones** a família "Period Calendar / Meu Calendário" ·
**drip** · **Euki** · **Moon** Mooneva · **Apple** o Controle do Ciclo do Apple Saúde.

| | Tab | Flo | Clue | Clones | drip | Euki | Moon | Apple |
| --- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Previsão da menstruação** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Janela fértil e ovulação** | ✓ | ✓ | ✓ | ✓ | ✓ | ? | ✓ | ✓ |
| **Previsão pela média do histórico** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ? | ✓ |
| **Previsão além de 1 ciclo** | ✓ | ? | pago | ✓ | ? | ? | ? | ✓ |
| **Método sintotérmico (temperatura + muco)** | — | — | — | parcial | ✓ | — | — | parcial |
| **Registro de fluxo** | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Sintomas e humor** | — | ✓ | ✓ (200+) | ✓ (58) | ✓ | ✓ | ✓ | básico |
| **Anotação livre por ciclo** | ✓ | ? | ✓ | ? | ? | ✓ | ? | — |
| **Sexo e contracepção** | — | ✓ | ✓ | ✓ | ✓ | ✓ | ? | ✓ |
| **Lembrete de pílula** | — | ✓ | ? | ✓ | — | ✓ | ? | — |
| **Lembretes do ciclo** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ? | ✓ |
| **Modo gravidez** | — | ✓ | ✓ / pago | ✓ | — | ✓ | — | — |
| **Modo perimenopausa** | — | ✓ | pago | ? | — | ? | ? | — |
| **Estatísticas do ciclo** | — | ✓ | ✓ / pago | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Exportar dados / relatório** | só imagem | ? | pago | ? | ✓ | ? | ✓ | via Saúde |
| **Importar de outro app** | só do app antigo | ? | ? | ? | ✓ (CSV) | ? | ? | — |
| **Conteúdo educativo** | ajuda curta | ✓ | ✓ / pago | ? | — | ✓ | — | — |
| **Comunidade / fórum** | — | ✓ | — | — | — | — | — | — |
| **Apple Watch / wearable** | — | ✓ | ✓ / pago | Wear OS | — | — | — | ✓ |
| **Widget na tela inicial** | — | ? | ? | ? | ? | ? | ? | ✓ |
| **Bloqueio do app** | ✓ (aparelho) | ✓ (PIN) | ? | ✓ (PIN) | ✓ (senha) | ✓ (PIN) | ✓ (PIN) | ✓ (aparelho) |
| **PIN de coação / tela falsa** | — | — | — | — | — | ✓ | — | — |
| **Ícone disfarçado** | — | — | — | — | — | — | ✓ | — |
| **Notificação discreta** | ✓ | ? | ? | ✓ | ? | ✓ | ? | ? |
| **Funciona sem internet** | ✓ | — | — | — | ✓ | ✓ | ✓ | ✓ |
| **Sem conta** | ✓ | anônimo | — | ✓ | ✓ | ✓ | ✓ | conta Apple |
| **Dados só no aparelho** | ✓ | — | — | — | ✓ | ✓ | ✓ | + iCloud |
| **Código aberto** | — | — | — | — | ✓ | ✓ | ✓ | — |
| **Sem anúncio** | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ |
| **Tudo de graça** | ✓ | — | — | — | ✓ | ✓ | ✓ | ✓ |
| **Português, inglês e espanhol** | ✓ | ✓ | ✓ | ✓ | ? | ? | ? | ✓ |

Lendo a tabela por coluna: o Tabelinha ganha no bloco de baixo (privacidade, custo, offline) e perde
no bloco do meio (registro de sintomas, estatística, exportação). Nenhum concorrente ganha os dois
blocos — os de privacidade também são pobres de função, e os completos vivem de conta e nuvem. É
esse vão que o Tabelinha ocupa.

### O que os grandes cobram

Serve para saber o que é "de graça no mercado" e o que é isca de assinatura.

- **Clue Plus:** previsão de menstruação de 6 meses, análise de sintomas recorrentes, modo
  perimenopausa, categorias de gravidez, 10 categorias extras de registro (sono, urina,
  suplementos), etiquetas personalizadas ilimitadas, resumo mensal por e-mail, acesso completo
  aos artigos e integração com wearables.
- **Flo Premium:** análises diárias personalizadas e ferramentas avançadas sobre o básico, que já
  inclui previsão, registro de sintomas, histórico e o Modo Anônimo (de 2022, resposta à crise de
  privacidade).
- **Stardust:** o histórico além de 6 meses é pago.
- **Natural Cycles:** não tem camada grátis, e é o único com liberação da FDA como contraceptivo
  (exige termômetro e medição diária).

### O que as pessoas reclamam

Uma análise de avaliações de 1 a 3 estrelas em seis apps do nicho distribuiu as queixas assim:
privacidade e compartilhamento de dados **28%**, precisão da previsão **19%**, assinatura
agressiva **16%**, interface de registro de sintomas **12%**, excesso de notificação e de conteúdo
"bem-estar" **10%**, travamento e erro de sincronização **8%**. É uma análise só, de um publisher
editorial, então vale como direção e não como medida.

Três dessas seis queixas — privacidade, assinatura e notificação — o Tabelinha já não tem por
construção. Uma (travamento de sincronização) não existe porque não há sincronização. Sobram
**precisão** e **interface de registro**, que são justamente as lacunas da tabela acima.

## Onde o Tabelinha está bem

- **Privacidade de verdade, não de texto.** Sem rede, sem conta, sem anúncio, sem analytics: as
  dependências do `pubspec.yaml` são só armazenamento local, notificações locais, fuso,
  autenticação do aparelho e a folha de compartilhar. Isso é verificável, e é exatamente a
  promessa que a Flo quebrou. No Brasil, dado de saúde é dado sensível na LGPD; o app que não
  coleta não tem o que vazar.
- **Bloqueio sem senha própria.** Usa a autenticação do aparelho, não guarda senha e não tem
  "esqueci o PIN" que apague dados. Nem Flo nem Clue fazem isso.
- **Honestidade no texto.** O app repete que é estimativa e que não serve como contraceptivo,
  inclusive na descrição da loja. Metade do nicho vende o contrário nas entrelinhas.
- **Herança.** Importa os dados do app Objective-C de 2013, com as anotações. Quem já era
  usuário não recomeça do zero.
- **Acessibilidade levada a sério** (contraste testado nos dois temas, alvo de 48 dp, fonte a
  2,0×, forma além da cor no calendário). Raro no nicho.

## Lacunas, em ordem de custo-benefício

1. **Exportar os dados.** Hoje só dá para compartilhar o calendário como imagem. Um CSV ou um
   relatório em PDF para levar ao médico é o pedido mais comum do nicho, cabe na arquitetura
   local (nada sai sem a pessoa mandar) e o Mooneva já mostra que é diferencial.
2. **Registrar o que a pessoa sente.** Fluxo, cólica, humor — todo concorrente tem; o Tabelinha
   guarda só datas e uma anotação livre. É a maior diferença funcional, e é o que transforma o
   app de calendário em diário. Custa telas novas e mexe no histórico.
3. **PIN de coação e modo discreto** (Euki, Mooneva). Barato de implementar sobre o `AppLock` que
   já existe, e fala direto com o público que escolhe app por privacidade.
4. **Widget na tela inicial.** "Faltam X dias" sem abrir o app. Barato, visível, nenhum
   concorrente de privacidade tem.
5. **Estatísticas do próprio ciclo** (variação, regularidade, duração média ao longo do tempo).
   O cálculo pelo histórico já tem os dados; falta mostrar.
6. **Apple Saúde / Health Connect.** Ler e escrever datas de menstruação integraria o app ao
   sistema. Atenção: é o único item desta lista que manda dado para fora do app, ainda que
   dentro do aparelho — exige rever a política de privacidade e o questionário da loja.

## O que não copiar

- **Conta, nuvem e sincronização.** É o pedido que mais aparece em avaliações e é justamente o
  que destruiria o diferencial. Troca de aparelho já está resolvida pelo backup do sistema.
- **Anúncios e analytics.** O app nasceu sem Parse, Flurry e Facebook SDK de propósito.
- **Assinatura agressiva.** As avaliações da Flo no Trustpilot em 2026 estão cheias de cobrança
  inesperada. Se um dia houver camada paga, que seja compra única e sem escurecer função que
  hoje é grátis.
- **Promessa de eficácia contraceptiva.** Além de falsa, é motivo de reprovação na loja.

## Posicionamento para a loja

O concorrente a atacar não é a Flo, é o clone genérico com anúncio que aparece na busca. A frase
que separa o Tabelinha dos dois é a mesma: **funciona sem internet, sem conta e sem anúncio, e
nada sai do seu aparelho.** Vale repetir isso no subtítulo, nas palavras-chave e na primeira
imagem da loja — hoje a descrição já diz, mas o subtítulo não é o lugar onde a pessoa lê primeiro.

## Fontes

- [FTC — Developer of Popular Women's Fertility-Tracking App Settles FTC Allegations](https://www.ftc.gov/news-events/news/press-releases/2021/01/developer-popular-womens-fertility-tracking-app-settles-ftc-allegations-it-misled-consumers-about)
- [TechCrunch — Flo gets FTC slap for sharing user data when it promised privacy](https://techcrunch.com/2021/01/13/flo-gets-ftc-slap-for-sharing-user-data-when-it-promised-privacy/)
- [Tuta — Best secure and private period tracking apps in 2026](https://tuta.com/blog/best-period-apps)
- [netzpolitik.org — Datenschutzfreundliche Perioden-Apps](https://netzpolitik.org/2025/datenschutzfreundliche-perioden-apps-zyklus-tracking-ohne-tracking/)
- [Mozilla *Privacy Not Included — Calendário do período](https://www.mozillafoundation.org/pt-BR/privacynotincluded/my-calendar-period-tracker/)
- [F-Droid — Mooneva](https://f-droid.org/en/packages/com.mooneva.app/)
- [Superrr — Drip, Feminist Tech Fellow](https://superrr.net/feministtech/fellow/drip/)
- [Apple — Track your period with Cycle Tracking](https://support.apple.com/120356)
- [Canaltech — Melhores aplicativos para acompanhar ciclo menstrual](https://canaltech.com.br/apps/melhores-aplicativos-para-acompanhar-ciclo-menstrual/)
- [Wikipédia — Flo (app)](https://en.wikipedia.org/wiki/Flo_(app)) (versão grátis, Modo Anônimo, processos)
- [Clue — What's included in Clue Plus](https://support.helloclue.com/hc/en-us/articles/15007279508637-What-s-included-in-Clue-Plus) e [Android Authority — Clue app](https://androidauthority.com/clue-app-3046459)
- [unstar.app — Period tracking apps ranked 2026](https://unstar.app/blog/flo-clue-stardust-apple-health-period-tracking-apps-ranked-2026) (a distribuição das queixas)
- [Mozilla — Privacy Review: Euki](https://www.mozillafoundation.org/pt-BR/nothing-personal/euki-privacy-review/)
- [drip — Perguntas frequentes](https://dripapp.org/faq.html) (método sintotérmico e importação por CSV)
- [AlternativeTo — Period Calendar](https://alternativeto.net/software/period-calendar/about) (a família de clones)
