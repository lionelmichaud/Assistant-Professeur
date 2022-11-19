//
//  UIPreferences.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 18/09/2022.
//

import Foundation
import AppFoundation

public enum NameOrdering: Int, PickableEnumP {
    case nomPrenom
    case prenomNom

    public var pickerString: String {
        switch self {
            case .nomPrenom:
                return "NOM Prénom"
            case .prenomNom:
                return "Prénom NOM"
        }
    }
}
