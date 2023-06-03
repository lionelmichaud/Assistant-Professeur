//
//  NavigationModel+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

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
                case .userSettings:
                    return ""
                case .school:
                    return SchoolEntity.defaultImageName
                case .classe:
                    return ClasseEntity.defaultImageName
                case .eleve:
                    return EleveEntity.defaultImageName
                case .warning:
                    return "hand.raised"
                case .program:
                    return ProgramEntity.defaultImageName
                case .competence:
                    return ""
            }
        }
    }

    /// Panneaux préférences
    enum PrefTabSelection: String, Hashable, Codable {
        case general = "Général"
        case school = "Établissements"
        case classe = "Classes"
        case eleve = "Élèves"
        case program = "Programmes"
        case sequence = "Séquences"
        case activity = "Activités"
        case schoolYear = "Scolarité"
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
