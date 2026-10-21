import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Entrega ao Dart os dados gravados pelo app iOS original (Objective-C).
    // Lado Dart: lib/data/legacy_importer.dart.
    let channel = FlutterMethodChannel(
      name: "br.eti.claudiocastro.tabelinha/data",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "getData" {
        result(LegacyDataReader.readJSON())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

/// Lê o que o app original deixou no aparelho. O bundle id é o mesmo, então quem
/// atualiza para o app Flutter mantém a pasta de dados do app antigo.
///
/// - `NSUserDefaults`: `iniciociclo` (NSDate), `duracaociclo` e `duracaoperiodo`
///   (NSString), `acordado` (NSDate, quando aceitou os termos).
/// - `Documents/periodos.bin`: NSKeyedArchiver de um NSMutableArray de `Periodo`
///   (inicio, fim, obs, ...).
enum LegacyDataReader {
  /// JSON como o Dart espera, ou `nil` se não houver nada para importar.
  static func readJSON() -> String? {
    var out: [String: Any] = [:]
    let defaults = UserDefaults.standard

    if let start = defaults.object(forKey: "iniciociclo") as? Date {
      out["start"] = isoDay(start)
    }
    if let cycle = intValue(defaults.object(forKey: "duracaociclo")) {
      out["cycleLength"] = cycle
    }
    if let period = intValue(defaults.object(forKey: "duracaoperiodo")) {
      out["periodLength"] = period
    }
    if let agreed = defaults.object(forKey: "acordado") as? Date {
      out["termsAcceptedAt"] = ISO8601DateFormatter().string(from: agreed)
    }
    out["records"] = readPeriods()

    guard
      let data = try? JSONSerialization.data(withJSONObject: out),
      let json = String(data: data, encoding: .utf8)
    else { return nil }
    return json
  }

  private static func readPeriods() -> [[String: String]] {
    guard
      let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
      let data = try? Data(contentsOf: documents.appendingPathComponent("periodos.bin"))
    else { return [] }

    do {
      let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
      unarchiver.requiresSecureCoding = false
      // O arquivo guarda a classe pelo nome "Periodo"; aqui ela vira LegacyPeriodo.
      unarchiver.setClass(LegacyPeriodo.self, forClassName: "Periodo")
      defer { unarchiver.finishDecoding() }

      guard let items = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [Any] else {
        return []
      }
      return items.compactMap { ($0 as? LegacyPeriodo)?.json }
    } catch {
      return []
    }
  }

  private static func intValue(_ value: Any?) -> Int? {
    if let text = value as? String {
      return Int(text.trimmingCharacters(in: .whitespaces))
    }
    if let number = value as? NSNumber {
      return number.intValue
    }
    return nil
  }

  /// Dia de calendário no fuso do aparelho. O app original gravava as datas às 11h
  /// locais, então o dia sai certo mesmo com pequenas variações de fuso.
  fileprivate static func isoDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}

/// Espelho do `Periodo` do app Objective-C (só decodifica).
final class LegacyPeriodo: NSObject, NSCoding {
  let inicio: Date?
  let fim: Date?
  let obs: String?

  required init?(coder: NSCoder) {
    inicio = coder.decodeObject(forKey: "inicio") as? Date
    fim = coder.decodeObject(forKey: "fim") as? Date
    obs = coder.decodeObject(forKey: "obs") as? String
    super.init()
  }

  func encode(with coder: NSCoder) {}

  /// `nil` quando faltam as datas.
  var json: [String: String]? {
    guard let inicio = inicio, let fim = fim else { return nil }
    return [
      "start": LegacyDataReader.isoDay(inicio),
      "end": LegacyDataReader.isoDay(fim),
      "note": obs ?? "",
    ]
  }
}
