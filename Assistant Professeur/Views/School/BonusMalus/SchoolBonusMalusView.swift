//
//  SchoolBonusMalusView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/09/2023.
//

import SwiftUI

struct SchoolBonusMalusView: View {
    @ObservedObject
    var school: SchoolEntity

    var body: some View {
        List {
            // Statistqiues de l'établssement complet
            Section {
                BonusMalusView(
                    minBonus: school.minBonus,
                    maxBonus: school.maxBonus,
                    averageBonus: school.averageBonus,
                    showClasse: nil
                )
            } header: {
                Text("Etablissement")
                    .style(.sectionHeader)
            }

            // Liste des statistqiues des classes
            Section {
                ForEach(school.classesSortedByLevelNumber) { classe in
                    BonusMalusView(
                        minBonus: classe.minBonus,
                        maxBonus: classe.maxBonus,
                        averageBonus: classe.averageBonus,
                        showClasse: classe
                    )
                }
            } header: {
                Text("Classes (\(school.nbOfClasses))")
                    .style(.sectionHeader)
            }

        }
        #if os(iOS)
        .navigationTitle("Bonus/Malus \(school.viewName)")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// struct SchoolBonusMalusView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolBonusMalusView()
//    }
// }
