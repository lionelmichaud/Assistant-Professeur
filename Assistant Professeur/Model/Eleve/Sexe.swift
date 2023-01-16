//
//  Sexe.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI
import AppFoundation

// MARK: - Sexe

public enum Sexe: String, PickableEnumP, Codable {
    case male
    case female

    public var displayString: String {
        switch self {
            case .male:
                return "G"
            case .female:
                return "F"
        }
    }

    public var pickerString: String {
        switch self {
            case .male:
                return "Garçon"
            case .female:
                return "Fille"
        }
    }

    public var color: Color {
        switch self {
            case .male:
                return .cyan
            case .female:
                return .pink
        }
    }
}
