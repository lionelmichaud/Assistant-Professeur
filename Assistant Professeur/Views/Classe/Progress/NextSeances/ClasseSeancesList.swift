//
//  ClasseSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/11/2023.
//

import SwiftUI

struct ClasseSeancesList: View {
    @ObservedObject
    var classe: ClasseEntity
    let dateInterval: DateInterval
    let showToDoListButton: Bool

    @EnvironmentObject
    private var userContext: UserContext

    @State
    private var viewModel = ClasseSeancesViewModel()

    @State
    private var alert = AlertInfo()

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            // viewModel.toDoListButton

            // Afficher toutes les séances trouvées
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
            let alert = await viewModel.updateItems(
                forClasse: classe,
                inDateInterval: dateInterval,
                showToDoListButton: showToDoListButton,
                schoolYear: userContext.prefs.viewSchoolYearPref
            )
            self.alert = alert
        }
    }
}

//#Preview {
//    ClasseSeancesList()
//}
