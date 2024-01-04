//
//  ClasseSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import SwiftUI
import TipKit

struct ClasseSeancesList: View {
    @ObservedObject
    var classe: ClasseEntity
    let dateInterval: DateInterval

    @Environment(UserContext.self)
    private var userContext

    @State
    private var viewModel = ClasseSeancesViewModel()

    @State
    private var alert = AlertInfo()

    /// Create an instance of your tip content.
    var nextSeancesTip = NextSeancesTip()

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            // viewModel.toDoListButton

            // Afficher toutes les séances trouvées
            TipView(nextSeancesTip, arrowEdge: .bottom)
                .customizedTipKitStyle()

            viewModel.seancesListView
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: classe.id!.uuidString + dateInterval.description) {
            // Recherche des séances dans la tranche de temps `dateInterval`
            let alert = await viewModel.updateItems(
                forClasse: classe,
                inDateInterval: dateInterval,
                schoolYear: userContext.prefs.viewSchoolYearPref
            )
            self.alert = alert
        }
    }
}

// #Preview {
//    ClasseSeancesList()
// }
