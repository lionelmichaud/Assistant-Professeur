//
//  AppScreen.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/12/2023.
//

import SwiftUI

/// Onglets
@MainActor
enum AppScreen: String, Hashable, Identifiable, CaseIterable, Codable {
    case school = "Mes Etablissements"
    case classe = "Mes Classes"
    case eleve = "Mes Elèves"
    case warning = "Avertissements"
    case program = "Mes Progressions"
    case competence = "Compétences"

    nonisolated
    var id: AppScreen { self }

    var imageName: String {
        switch self {
            case .school: SchoolEntity.defaultImageName
            case .classe: ClasseEntity.defaultImageName
            case .eleve: EleveEntity.defaultImageName
            case .warning: "hand.raised"
            case .program: ProgramEntity.defaultImageName
            case .competence: WCompChapterEntity.defaultImageName
        }
    }

    var badgeValue: Int {
        switch self {
            case .school: SchoolEntity.cardinal()
            case .classe: ClasseEntity.cardinal()
            case .eleve: EleveEntity.cardinal()
            case .warning: ObservEntity.cardinal() + ColleEntity.cardinal()
            case .program: ProgramEntity.cardinal()
            case .competence: 0
        }
    }

    @ViewBuilder
    var label: some View {
        Label(
            self.rawValue,
            systemImage: self.imageName
        )
        .symbolVariant(.none)
    }

    @ViewBuilder
    var view: some View {
        switch self {
            case .school:
                SchoolSplitView()
                    .tag(self)
                    .badge(self.badgeValue)

            case .classe:
                ClasseSplitView()
                    .tag(self)
                    .badge(self.badgeValue)

            case .eleve:
                EleveSplitView()
                    .tag(self)
                    .badge(self.badgeValue)

            case .warning:
                WarningSplitView()
                    .tag(self)
                    .badge(self.badgeValue)

            case .program:
                ProgramSplitView()
                    .tag(self)
                    .badge(self.badgeValue)

            case .competence:
                CompetencySplitView()
                    .tag(self)
                    .badge(self.badgeValue)
        }
    }
}
