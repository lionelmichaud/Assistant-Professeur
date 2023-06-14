//
//  NiveauSchool.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import AppFoundation
import Foundation
import SwiftUI

enum LevelSchool: String, PickableIdentifiableEnumP, Codable, Equatable {
    case aecole
    case college
    case lycee

    // MARK: - Computed Properties

    var id: String { self.rawValue }

    var pickerString: String {
        switch self {
            case .aecole: return "École"
            case .college: return "Collège"
            case .lycee: return "Lycée"
        }
    }

    var next: Self {
        switch self {
            case .aecole: return .college
            case .college: return .lycee
            case .lycee: return .aecole
        }
    }

    var imageName: String {
        switch self {
            case .aecole: return "house.lodge"
            case .college: return "building"
            case .lycee: return "building.2"
        }
    }

    var imageColor: Color {
        switch self {
            case .aecole: return .yellow
            case .college: return .orange
            case .lycee: return .mint
        }
    }

    // MARK: - Methods

    /// Toggles from the current value to the next
    mutating func toggle() {
        self = self.next
    }
}
