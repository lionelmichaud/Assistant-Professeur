//
//  NextSeancesList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import SwiftUI
import TipKit

struct SchoolSeancesList: View {
    @ObservedObject
    var school: SchoolEntity
    let dateInterval: DateInterval
    let showOnlyOngoingSeance: Bool
    let showToDoListButton: Bool

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @State
    private var viewModel = SchoolSeancesViewModel()

    @State
    private var alert = AlertInfo()

    @State
    private var ongoingSeance = false

    @State
    private var popOverIsPresented = false

    @State
    private var isShowingClasseTimer = false

    /// Create an instance of your tip content.
    var nextSeancesTip = NextSeancesTip()

    // MARK: - Subviews

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement dans votre")
            Text("application **Calendrier** doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n.")
            Text("*Exemple*: pour la discipline de **\(Discipline.technologie.pickerString)**,")
            Text("et la classe de **4ième 2** de cet établissement:")
            Text("un événement contenant:\"**\(Discipline.technologie.pickerString) - 4E2**\"")
            Text("doit être créé dans le caldendrier nommé:")
            Text("\"**\(school.viewName)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

    var body: some View {
        // Afficher la ToDo liste
        VStack(alignment: .leading) {
            // Bouton de navigation vers la liste des ToDo
            if showToDoListButton {
                switch viewModel.state {
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
            TipView(nextSeancesTip, arrowEdge: .bottom)
                .customizedTipKitStyle()

            viewModel.state.view
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
        .toolbar(content: myToolBarContent)

        // Chargement des données recherchées depuis l'application Calendrier
        .task(id: school.id!.uuidString + dateInterval.description) {
            // Recherche des séances dans la tranche de temps `dateInterval`
            let alert = await viewModel.updateItems(
                forSchool: school,
                inDateInterval: dateInterval,
                showOnlyOngoingSeance: showOnlyOngoingSeance,
                schoolYear: userContext.prefs.viewSchoolYearPref
            )

            if showOnlyOngoingSeance,
               case let SeancesLoadingStatus.finished(seancesInInterval) = viewModel.state,
               seancesInInterval.seances.isNotEmpty {
                self.ongoingSeance = true
            } else {
                self.ongoingSeance = false
            }

            self.alert = alert
        }
    }
}

// MARK: SchoolSidebarView Toolbar Content

extension SchoolSeancesList {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        if ongoingSeance {
            // Chronomètre de classe
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingClasseTimer.toggle()
                } label: {
                    Label("Chrono.", systemImage: "stopwatch")
                }
                .fullScreenCover(
                    isPresented: $isShowingClasseTimer,
                    onDismiss: {
                        if let seance = TodaySeances.shared.seanceOngoing(inSchool: school),
                           let classe = SchoolEntity.school(withName: seance.schoolName!)?.classe(withAcronym: seance.name!) {
                            DeepLinkManager.handleLink(
                                navigateTo: .classeProgressUpdate(classe: classe),
                                using: navig
                            )
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

        // Afficher le PopOver d'information sur le format à utiliser
        ToolbarItem(placement: .automatic) {
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
}

// #Preview {
//    NextSeancesList()
// }
