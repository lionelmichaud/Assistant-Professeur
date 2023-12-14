//
//  PrefScreen.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/12/2023.
//

import AppFoundation
import SwiftUI

/// Panneaux préférences
enum PrefScreen: String, Hashable, Codable, PickableIdentifiableEnumP {
    case general
    case school
    case classe
    case eleve
    case program
    case sequence
    case activity
    case schoolYear

    var id: String { self.rawValue }

    var pickerString: String {
        switch self {
            case .general: "Général"
            case .school: "Établissements"
            case .classe: "Classes"
            case .eleve: "Élèves"
            case .program: "Progressions"
            case .sequence: "Séquences"
            case .activity: "Activités"
            case .schoolYear: "Année scolaire"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
            case .general:
                SettingsGeneral()
                    .tag(self)

            case .school:
                SettingsSchool()
                    .tag(self)

            case .classe:
                SettingsClasse()
                    .tag(self)

            case .eleve:
                SettingsEleve()
                    .tag(self)

            case .program:
                SettingsProgram()
                    .tag(self)

            case .sequence:
                SettingsSequence()
                    .tag(self)

            case .activity:
                SettingsActivity()
                    .tag(self)

            case .schoolYear:
                SettingsSchoolYear()
                    .tag(self)
        }
    }
}
