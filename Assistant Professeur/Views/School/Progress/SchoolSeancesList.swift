//
//  NextSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import SwiftUI

struct SchoolSeancesList: View {
    @ObservedObject
    var school: SchoolEntity
    let dateInterval: DateInterval
    let showOnlyOngoingSeance: Bool
    let showToDoListButton: Bool

    @EnvironmentObject
    private var userContext: UserContext

    @StateObject
    private var viewModel = SchoolSeancesViewModel()

    @State
    private var alert = AlertInfo()

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            if showToDoListButton {
                // Bouton de navigation vers la liste des ToDo
                switch viewModel.seancesLoadingState {
                    case .pending, .loading, .failed:
                        EmptyView()

                    case let .finished(seancesInInterval):
                        if seancesInInterval.seances.isNotEmpty {
                            // Afficher le bouton de navigation
                            NavigationLink(
                                value: SchoolNavigationRoute.toDoList(seancesInInterval.seances)
                            ) {
                                Label(
                                    "A faire avant ces cours...",
                                    systemImage: "checklist"
                                )
                                .imageScale(.large)
                                .font(.headline)
                                .fontWeight(.bold)
                            }
                            .padding(.bottom)
                        } else {
                            EmptyView()
                        }
                }
            }

            // Afficher toutes les séances trouvées
            viewModel.seancesLoadingState.view
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            let alert = await viewModel.updateItems(
                forSchool: school,
                inDateInterval: dateInterval,
                showOnlyOngoingSeance: showOnlyOngoingSeance,
                schoolYear: userContext.prefs.viewSchoolYearPref
            )
            self.alert = alert
        }
    }
}

// #Preview {
//    NextSeancesList()
// }
