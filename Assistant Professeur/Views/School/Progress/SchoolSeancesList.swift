//
//  NextSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import EventKit
import SwiftUI

struct SchoolSeancesList: View {
    @ObservedObject
    var school: SchoolEntity
    let dateInterval: DateInterval
    let showOnlyOngoingSeance: Bool
    let showToDoListButton: Bool

    @StateObject
    private var viewModel = SchoolSeancesViewModel()

    @State
    private var alert = AlertInfo()

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            viewModel.toDoListButton

            // Afficher toutes les séances trouvées
            viewModel.seancesListView
        }
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            let alert = await viewModel.updateItems(
                forSchool: school,
                inDateInterval: dateInterval,
                showOnlyOngoingSeance: showOnlyOngoingSeance,
                showToDoListButton: showToDoListButton
            )
            self.alert = alert
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
    }
}

// #Preview {
//    NextSeancesList()
// }
