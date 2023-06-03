//
//  NavigationModel+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import AppFoundation
import Foundation

extension NavigationModel {
    /// Onglets
    enum TabSelection: String, Hashable, Codable {
        case userSettings = "Réglages"
        case school = "Etablissement"
        case classe = "Classes"
        case eleve = "Elèves"
        case warning = "Avertissements"
        case program = "Programmes"
        case competence = "Compétences"

        var imageName: String {
            switch self {
                case .userSettings: return "gear"
                case .school: return SchoolEntity.defaultImageName
                case .classe: return ClasseEntity.defaultImageName
                case .eleve: return EleveEntity.defaultImageName
                case .warning: return "hand.raised"
                case .program: return ProgramEntity.defaultImageName
                case .competence: return "brain.head.profile"
            }
        }
    }

    /// Panneaux préférences
    enum PrefTabSelection: String, Hashable, Codable, PickableIdentifiableEnumP {
        case general
        case school
        case classe
        case eleve
        case program
        case sequence
        case activity
        case schoolYear

        // MARK: - Computed Properties

        var id: String { self.rawValue }

        var pickerString: String {
            switch self {
                case .general: return "Général"
                case .school: return "Établissements"
                case .classe: return "Classes"
                case .eleve: return "Élèves"
                case .program: return "Programmes"
                case .sequence: return "Séquences"
                case .activity: return "Activités"
                case .schoolYear: return "Scolarité"
            }
        }
    }

    /// Filtres
    enum WarningSelection: String, Hashable, Codable, CaseIterable {
        case observation = "Observations"
        case colle = "Colles"

        var imageName: String {
            switch self {
                case .observation:
                    return ObservEntity.defaultImageName
                case .colle:
                    return ColleEntity.defaultImageName
            }
        }
    }
}
