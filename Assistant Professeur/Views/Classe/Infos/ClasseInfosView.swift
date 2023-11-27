//
//  ClasseInfosView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/05/2023.
//

import EventKit
import HelpersView
import os
import SwiftUI

struct ClasseInfosView: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(UserContext.self)
    private var userContext

    @State
    private var viewModel = ClasseEventsViewModel()

    @State
    private var popOverConseilIsPresented: Bool = false
    @State
    private var popOverArretIsPresented: Bool = false
    @State
    private var popOverBrevetIsPresented: Bool = false
    @State
    private var popOverBacIsPresented: Bool = false

    @State
    private var alert = AlertInfo()

    private var classeCalendarName: String {
        classe.school?.viewName ?? "de cet établissement"
    }

    var body: some View {
        List {
            Section {
                // appréciation sur la classe
                if userContext.prefs.viewClasseAppreciationEnabled {
                    AppreciationView(appreciation: $classe.viewAppreciation)
                }
                // annotation sur la classe
                if userContext.prefs.viewClasseAnnotationEnabled {
                    AnnotationEditView(annotation: $classe.viewAnnotation)
                }
                // statistiques des bonus / malus de la classe
                BonusMalusGroupBox(
                    minBonus: classe.minBonus,
                    maxBonus: classe.maxBonus,
                    averageBonus: classe.averageBonus,
                    showClasse: nil
                )
            }

            // Section Salle de classe utilisée
            Section {
                roomView
            }

            // Section arrêt des notes avant conseil de classe
            Section {
                if viewModel.state == .finished {
                    arretNotesList
                        .popover(isPresented: $popOverArretIsPresented) {
                            Text("Le nom requis pour l'événement du calendrier \(classeCalendarName) est \"*Arrêt notes - Niveau*\". Exemple: \"*Arrêt notes - 5E*\"")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                        }
                } else {
                    viewModel.state.view
                }
            } header: {
                HStack {
                    Text("Arrêt des notes")
                        .style(.sectionHeader)
                    // Afficher le PopOver d'information sur le format à utiliser
                    Button {
                        popOverArretIsPresented = true
                    } label: {
                        Image(systemName: "info.bubble")
                    }
                }
            } footer: {
                Text("Les événements nommés \"**Arrêt notes - Niveau**\" dans le calendrier \(classeCalendarName) apparaissent ici.")
            }

            // Section Conseils de classe
            Section {
                if viewModel.state == .finished {
                    conseilList
                        .popover(isPresented: $popOverConseilIsPresented) {
                            Text("Le nom requis pour l'événement du calendrier \(classeCalendarName) est \"*Conseil - Classe*\". Exemple: \"*Conseil - 5E2*\".")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                        }
                } else {
                    viewModel.state.view
                }
            } header: {
                HStack {
                    Text("Conseils de classe")
                        .style(.sectionHeader)
                    // Afficher le PopOver d'information sur le format à utiliser
                    Button {
                        popOverConseilIsPresented = true
                    } label: {
                        Image(systemName: "info.bubble")
                    }
                }
            } footer: {
                Text("Les événements nommés \"**Conseil - Classe**\" dans le calendrier \(classeCalendarName) apparaissent ici.")
            }

            // Section Brevet des collèges
            if let brevet = viewModel.brevet {
                Section {
                    if viewModel.state == .finished {
                        HStack {
                            Text("Du ").foregroundColor(.secondary) +
                                Text(brevet.startDate.formatted(date: .complete, time: .omitted)) +
                                Text(" au ").foregroundColor(.secondary) +
                                Text(brevet.endDate.formatted(date: .complete, time: .omitted))
                        }
                        .popover(isPresented: $popOverBrevetIsPresented) {
                            Text("Le nom requis pour l'événement dans le calendrier \"*\(userContext.prefs.viewSchoolYearPref.calName)*\" est \"*Brevet*\".")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                        }
                    } else {
                        viewModel.state.view
                    }
                } header: {
                    HStack {
                        Text("Brevet des collèges")
                            .style(.sectionHeader)
                        // Afficher le PopOver d'information sur le format à utiliser
                        Button {
                            popOverBrevetIsPresented = true
                        } label: {
                            Image(systemName: "info.bubble")
                        }
                    }
                } footer: {
                    Text("L'événement nommé \"*Brevet*\" dans le calendrier \"*\(userContext.prefs.viewSchoolYearPref.calName)*\" apparaît ici.")
                }
            }

            // Section Baccalauréat
            if let bac = viewModel.bac {
                Section {
                    if viewModel.state == .finished {
                        HStack {
                            Text("Du ").foregroundColor(.secondary) +
                                Text(bac.startDate.formatted(date: .complete, time: .omitted)) +
                                Text(" au ").foregroundColor(.secondary) +
                                Text(bac.endDate.formatted(date: .complete, time: .omitted))
                        }
                        .popover(isPresented: $popOverBacIsPresented) {
                            Text("Le nom requis pour l'événement dans le calendrier \"*\(userContext.prefs.viewSchoolYearPref.calName)*\" est \"*Bac*\".")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                        }
                    } else {
                        viewModel.state.view
                    }
                } header: {
                    HStack {
                        Text("Baccalauréat")
                            .style(.sectionHeader)
                        // Afficher le PopOver d'information sur le format à utiliser
                        Button {
                            popOverBacIsPresented = true
                        } label: {
                            Image(systemName: "info.bubble")
                        }
                    }
                } footer: {
                    Text("L'événement nommé \"*Bac*\" dans le calendrier \"*\(userContext.prefs.viewSchoolYearPref.calName)*\" apparaît ici.")
                }
            }

            // Section liste des documents utiles
            ClasseDocumentListSection(classe: classe)
        }
        .alert(
            alert.title,
            isPresented: $alert.isPresented,
            actions: {},
            message: { Text(alert.message) }
        )
        #if os(iOS)
        .navigationTitle("Informations sur \(classe.displayString)")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            let alert = await viewModel.getAllEvents(
                forClasse: classe,
                during: userContext.prefs.viewSchoolYearPref,
                after: .now
            )
            self.alert = alert
        }
    }
}

// MARK: - Subviews

extension ClasseInfosView {
    private var arretNotesList: some View {
        ForEach(viewModel.arretsNotes, id: \.eventIdentifier) { arretNotes in
            VStack {
                Text("Date: ").foregroundColor(.secondary) +
                    Text(arretNotes.startDate.formatted(date: .complete, time: .standard))
            }
        }
        .emptyListPlaceHolder(viewModel.arretsNotes) {
            Text("Aucune date future d'arrêt des notes plannifiée pour cette classe.")
        }
    }

    private var conseilList: some View {
        ForEach(viewModel.conseils, id: \.eventIdentifier) { conseil in
            VStack {
                Text("Date: ").foregroundColor(.secondary) +
                    Text(conseil.startDate.formatted(date: .complete, time: .standard))
                if let location = conseil.location {
                    Text("Lieu: ").foregroundColor(.secondary) +
                        Text(location)
                }
            }
        }
        .emptyListPlaceHolder(viewModel.conseils) {
            Text("Aucun conseil de classe futur plannifié pour cette classe.")
        }
    }

    private var roomView: some View {
        NavigationLink(value: ClasseNavigationRoute.room(classe.id)) {
            HStack {
                Label("Salle de classe", systemImage: "door.left.hand.open")
                    .fontWeight(.bold)
                if classe.hasAssociatedRoom {
                    Spacer()
                    Text(classe.room!.viewName)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ClasseInfosView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                ClasseInfosView(classe: ClasseEntity.all().first!)
                    .environmentObject(NavigationModel())
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                ClasseInfosView(classe: ClasseEntity.all().first!)
                    .environmentObject(NavigationModel())
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            }
            .previewDevice("iPhone 13")
        }
    }
}
