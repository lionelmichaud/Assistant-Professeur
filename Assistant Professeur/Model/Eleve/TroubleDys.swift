//
//  TroubleDys.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 26/09/2022.
//

import Foundation
import AppFoundation

enum TroubleDys: Int16, PickableEnumP, Codable {
    case none = 0
    case begaiement
    case deficience
    case deficienceAd
    case dyscalculie
    case dyschromatopsie
    case dysgraphie
    case dyslexie
    case dysorthographie
    case dysorthophonie
    case dysphasie
    case dyspraxie
    case epilepsie
    case migraines
    case tsa
    case tda
    case autre
    case autreAd
    case undefined

    var pickerString: String {
        displayString
    }

    var displayString: String {
        switch self {
            case .begaiement:
                return "Bégaiement"
            case .deficience:
                return "Déficience physique"
            case .deficienceAd:
                return "Déficience physique (tps +)"
            case .dyscalculie:
                return "Dyscalculie"
            case .dyschromatopsie:
                return "Dyschromatopsie"
            case .dysgraphie:
                return "Dysgraphie"
            case .dyslexie:
                return "Dyslexie"
            case .dysorthographie:
                return "Dysorthographie"
            case .dysorthophonie:
                return "Dysorthophonie"
            case .dysphasie:
                return "Dysphasie"
            case .dyspraxie:
                return "Dyspraxie"
            case .epilepsie:
                return "Epilepsie"
            case .migraines:
                return "Migraines"
            case .tsa:
                return "TSA (autisme)"
            case .tda:
                return "Trouble de l'attention"
            case .autre:
                return "Autre"
            case .autreAd:
                return "Autre (tps +)"
            case .undefined:
                return "Indéfini"
            case .none:
                return "Aucun"
        }
    }

    var additionalTime: Bool {
        switch self {
            case .dyslexie, .dyspraxie, .dysorthographie,
                    .dysgraphie, .dyscalculie, .tsa, .tda,
                    .epilepsie, .migraines, .deficienceAd,
                    .dysphasie, .autreAd:
                return true

            case .none, .dysorthophonie, .dyschromatopsie,
                    .begaiement, .deficience, .undefined,
                    .autre:
                return false
        }
    }
}

extension Optional where Wrapped == TroubleDys {
    private var _bound: TroubleDys? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    var bound: TroubleDys {
        get {
            return _bound ?? .undefined
        }
        set {
            _bound = newValue
        }
    }
}
