/// O que a pessoa informou sobre contraceptivo num dia marcado com relação sexual.
///
/// [naoInformado] é o padrão e não é "sem": informar é opcional, e o app não supõe nada a
/// partir do silêncio. Nada aqui entra no cálculo do ciclo nem vira aviso de risco — o app
/// não calcula risco de gravidez, só guarda o que a pessoa escreveu.
enum Contraception {
  naoInformado,
  com,
  sem;

  String get id => name;

  static Contraception fromId(Object? id) => switch (id) {
        'com' => Contraception.com,
        'sem' => Contraception.sem,
        _ => Contraception.naoInformado,
      };
}
