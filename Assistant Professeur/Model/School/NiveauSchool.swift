//
//  NiveauSchool.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import Foundation
import AppFoundation

enum NiveauSchool: String, PickableEnumP, Codable, Identifiable, Equatable {
    case college
    case lycee

    var id: String { self.rawValue }

    var pickerString: String {
        switch self {
            case .college:
                return "Collège"
            case .lycee:
                return "Lycée"
        }
    }
}
