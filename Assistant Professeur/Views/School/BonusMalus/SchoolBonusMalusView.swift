//
//  SchoolBonusMalusView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/09/2023.
//

import HelpersView
import SwiftUI

struct SchoolBonusMalusView: View {
    @ObservedObject
    var school: SchoolEntity

    enum ViewMode: Int {
        case list
        case chart
    }

    @State
    private var presentation: ViewMode = .list

    var body: some View {
        List {
            // Statistqiues de l'établssement complet
            Section {
                BonusMalusGroupBox(
                    minBonus: school.minBonus,
                    maxBonus: school.maxBonus,
                    averageBonus: school.averageBonus,
                    showClasse: nil
                )
            } header: {
                Text("Etablissement \(school.viewName)")
                    .style(.sectionHeader)
            }

            // Liste des statistqiues des classes
            Section {
                switch presentation {
                    case .list:
                        SchoolBonusMalusList(school: school)
                    case .chart:
                        SchoolBonusMalusChart(school: school)
                }

            } header: {
                Text("Classes (\(school.nbOfClasses))")
                    .style(.sectionHeader)
            }
        }
        #if os(iOS)
        .navigationTitle("Bonus/Malus")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension SchoolBonusMalusView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Choix du style de présentation
        ToolbarItemGroup(placement: .automatic) {
            Picker("Présentation", selection: $presentation) {
                Image(systemName: "list.bullet").tag(ViewMode.list)
                Image(systemName: "chart.bar.fill").tag(ViewMode.chart)
            }
            .pickerStyle(.segmented)
        }
    }
}

// struct SchoolBonusMalusView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolBonusMalusView()
//    }
// }
