//
//  Palettes.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/03/2023.
//

import SwiftUI

extension Color {
    /// Palette de couleurs
    /// RENDU INUTILE PAR XCODE 15
//    static let blue0 = Color("Blue0")
//    static let blue1 = Color("Blue1")
//    static let blue2 = Color("Blue2")
//    static let blue3 = Color("Blue3")
//    static let blue4 = Color("Blue4")
//    static let blue5 = Color("Blue5")
//    static let blue6 = Color("Blue6")
//    static let blue7 = Color("Blue7")
//    static let blue8 = Color("Blue8")

    /// Ecran de lancement
    static let launchScreenBackground = Color("Launch-Screen-Color")

    /// Couleurs des textes
    static let title = Color.primary
    static let sectionHeader = Color.secondary
    static let rowTitle = Color.primary
    static let rowDescription = Color.primary

    /// Couleurs des tags
    static let groupTag = Color.blue5
    static let sequenceTag = Color.blue4
    static let activityTag = Color.blue6
    static let classeTag = Color.blue5
    static let disciplineCompTag = Color.blue6
    static let workedCompTag = Color.blue7
    static let activitySymbol = Color.blue3
    static let borderTag = Color.primary
    static let foregroundTag = Color.primary

    /// Couleurs de la TabBar
    static let tabBarColor = Color.blue6.opacity(0.2)

    /// Couleur de fond des list items
    static let listRowBackgroundUnselected = HierarchicalShapeStyle.quaternary
    static let listRowBackgroundSelected = HierarchicalShapeStyle.tertiary
}
