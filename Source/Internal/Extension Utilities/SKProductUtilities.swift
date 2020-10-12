import StoreKit

// This utility exists to workaround an incorrect nullability annotation in the `SKProductDiscount` class declaration.
// Related bug report: rdar://39410422 (update: now closed)
// According to Apple engineering, this bug was fixed with iOS 12.0. As the project supports older OS versions, we can't remove this indirection quite yet.
@available(iOS 11.2, *)
extension SKProductDiscount {

    var locale: Locale {
        if let locale = self.value(forKey: "priceLocale") as? Locale {
            return locale
        }
        return Locale.current
    }

}
