//
//  Interoperability.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 18/09/2022.
//

import Foundation
import AppFoundation

public enum Interoperability: Int, PickableEnumP {
    case proNote
    case ecoleDirecte

    public var pickerString: String {
        switch self {
            case .proNote:
                return "ProNote"
            case .ecoleDirecte:
                return "EcoleDirecte"
        }
    }
}
