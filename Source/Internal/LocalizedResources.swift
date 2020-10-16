import Foundation

internal class LocalizedStringSource {
    private var provider: LocalizedStringProvider!
    
    private var _cachedResourceDicts = [String : [String : Any]]()
    
    init(for locale: Locale) {
        self.provider = FoundationLocalizedStringProvider(locale: locale, bundle: self.bundle(for: locale))
    }
    
    func name(for unit: SubscriptionPeriod.Unit) -> String {
        return self.pluralizedName(for: unit, count: 1) // prolly a better way to do this
    }
    
    func pluralizedName(for unit: SubscriptionPeriod.Unit, count: Int) -> String {
        let identifier: Key.StringIdentifier
        
        switch unit {
            case .day:
                identifier = .day
            case .week:
                identifier = .week
            case .month:
                identifier = .month
            case .year:
                identifier = .year
        }
        
        return self.provider.localizedString(for: .periodUnits(identifier), formatting: [count])
    }
    
    func joinedPhrase(forUnitName unitName: String, formattedUnitCount unitCount: String) -> String {
        return self.provider.localizedString(for: .periodUnits(.unitCountJoiner), formatting: [unitCount, unitName])
    }
    
    func subscriptionPricePhrase(with configuration: SubscriptionPricePhraseConfiguration, formattedPrice: String, formattedUnitCount: String) -> String {
        return self.provider.localizedString(for: .subscriptionPricePhrases(configuration), formatting: [configuration.duration.period.unitCount, formattedPrice, formattedUnitCount])
    }
    
    internal struct SubscriptionPricePhraseConfiguration {
        let duration: SubscriptionDuration
        let isFormal: Bool
    }
}

extension LocalizedStringSource {
    private func bundle(for locale: Locale) -> Bundle {
        let frameworkBundle = Bundle.module
        
        // shockingly, this is the best way to specify a language for the localizedString(forKey:value:table:) Foundation API
        let bundleForLocalePath = locale.languageCode.flatMap { frameworkBundle.path(forResource: $0, ofType: "lproj") }
        
        let appropriateBundle: Bundle
        
        if let bundleForLocalePath = bundleForLocalePath, let bundleForLocale = Bundle(path: bundleForLocalePath) {
            appropriateBundle = bundleForLocale
        } else {
            appropriateBundle = frameworkBundle
        }
        
        return appropriateBundle
    }
    
    fileprivate enum Key {
        case periodUnits(StringIdentifier)
        case subscriptionPricePhrases(SubscriptionPricePhraseConfiguration)
        
        enum StringIdentifier : String {
            case unitCountJoiner = "UnitCountJoiner"
            
            case day = "Day"
            case week = "Week"
            case month = "Month"
            case year = "Year"
        }
        
        fileprivate var stringValue: String {
            switch self {
                case .periodUnits(let identifier):
                    return identifier.rawValue
                case .subscriptionPricePhrases(let configuration):
                    let unitIdentifier: String
                    
                    switch configuration.duration.period.unit {
                        case .day: unitIdentifier = "Day"
                        case .week: unitIdentifier = "Week"
                        case .month: unitIdentifier = "Month"
                        case .year: unitIdentifier = "Year"
                    }
                    
                    let formalIdentifier = configuration.isFormal ? "Formal" : "Informal"
                    let fixedDurationIdentifier = configuration.duration.isRecurring ? "NotFixedDuration" : "FixedDuration"
                    
                    let value = "\(unitIdentifier)\(formalIdentifier)\(fixedDurationIdentifier)"
                
                    return value
            }
        }
        
        fileprivate var tableName: String {
            switch self {
                case .periodUnits(_):
                    return "LocalizedPeriodUnits"
                case .subscriptionPricePhrases(_):
                    return "LocalizedSubscriptionPricePhrases"
            }
        }
    }
}

fileprivate protocol LocalizedStringProvider {
    init(locale: Locale, bundle: Bundle)
    
    func localizedString(for key: LocalizedStringSource.Key, formatting arguments: [CVarArg]) -> String
}

/// This handles localized string replacement. Unfortunately, it is kind of a black box and sometimes unreliable. For now, we include this implementation as a backup — with a view to select a single concrete provider down the road.
fileprivate final class FoundationLocalizedStringProvider : LocalizedStringProvider {
    private let locale: Locale
    private let bundle: Bundle

    init(locale: Locale, bundle: Bundle) {
        self.locale = locale
        self.bundle = bundle
    }

    func localizedString(for key: LocalizedStringSource.Key, formatting arguments: [CVarArg]) -> String {
        let format = self.bundle.localizedString(forKey: key.stringValue, value: "", table: "MerchantKitResources\(key.tableName)")

        let result = String(format: format, locale: self.locale, arguments: arguments)
        
        return result
    }
}
