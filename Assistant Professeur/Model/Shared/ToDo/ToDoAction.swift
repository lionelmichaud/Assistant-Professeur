//
//  ToDoAction.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/11/2023.
//

import AppFoundation
import Foundation

/// Picker selectors
enum ToDoAction: String, PickableEnumP {
    case print = "A IMPRIMER"
    case load = "A PARTAGER"
    case correct = "A CORRIGER"

    var pickerString: String { self.rawValue }
    var imageName: String {
        switch self {
            case .print, .correct:
                DocumentEntity.forEleveImageName

            case .load:
                DocumentEntity.forEntImageName
        }
    }
}
