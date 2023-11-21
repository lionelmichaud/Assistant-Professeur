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

//    @State
//    private var seanceIsOngoing: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @EnvironmentObject
    private var userContext: UserContext

    @StateObject
    private var viewModel = SchoolSeancesViewModel()

    @State
    private var alert = AlertInfo()

    @State
    private var ongoingSeance = false

    @State
    private var popOverIsPresented = false

    @State
    private var isShowingClasseTimer = false

    // MARK: - Subviews

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("Exemple: pour la discipline de \(Discipline.technologie.pickerString),")
            Text("et la classe de 4ième 2: \"**\(Discipline.technologie.pickerString) - 4E2)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

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
        .toolbar {
            if ongoingSeance {
                ToolbarItem(placement: .primaryAction) {
                    // Chronomètre de classe
                    Button {
                        isShowingClasseTimer.toggle()
                    } label: {
                        Label("Chrono.", systemImage: "stopwatch")
                    }
                    .fullScreenCover(
                        isPresented: $isShowingClasseTimer,
                        onDismiss: {
                            Task {
                                // Aller à la vue de mise à jour de l'vanacement de la progression de la classe
                                if let seance = TodaySeances.shared.seanceOngoing(inSchool: school),
                                   let classe = SchoolEntity.school(withName: seance.schoolName!)?.classe(withAcronym: seance.name!) {
                                    await navig.navigateToProgressOf(thisClasse: classe)
                                }
                            }
                        },
                        content: {
                            NavigationStack {
                                ClasseTimerModal(
                                    school: school
                                )
                            }
                        }
                    )
                }
            }
            ToolbarItem(placement: .automatic) {
                // Afficher le PopOver d'information sur le format à utiliser
                Button {
                    popOverIsPresented = true
                } label: {
                    Image(systemName: "info.bubble")
                }
                .popover(isPresented: $popOverIsPresented) {
                    infoView
                }
            }
        }
        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            let alert = await viewModel.updateItems(
                forSchool: school,
                inDateInterval: dateInterval,
                showOnlyOngoingSeance: showOnlyOngoingSeance,
                schoolYear: userContext.prefs.viewSchoolYearPref
            )

            if showOnlyOngoingSeance,
               case let SeancesLoadingStatus.finished(seancesInInterval) = viewModel.seancesLoadingState,
               seancesInInterval.seances.isNotEmpty {
                self.ongoingSeance = true
            } else {
                self.ongoingSeance = false
            }

            self.alert = alert
        }
    }
}

// #Preview {
//    NextSeancesList()
// }
