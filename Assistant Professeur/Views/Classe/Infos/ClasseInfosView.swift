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

    @ObservedObject
    private var pref = UserPrefEntity.shared

    /// Conseils de classe
    @State
    private var conseils = [EKEvent]()

    @State
    private var arretsNotes = [EKEvent]()

    @State
    private var popOverConseilIsPresented: Bool = false

    @State
    private var popOverArretIsPresented: Bool = false

    @State
    private var eventStore = EKEventStore()

    @State
    private var calendar: EKCalendar?

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    private var arretNotesList: some View {
        ForEach(arretsNotes, id: \.eventIdentifier) { arretNotes in
            VStack {
                Text("Date: ").foregroundColor(.secondary) +
                    Text(arretNotes.startDate.formatted(date: .complete, time: .standard))
            }
        }
        .emptyListPlaceHolder(arretsNotes) {
            Text("Aucune date d'arrêt des notes prévue pour cette classe")
        }
    }

    private var conseilList: some View {
        ForEach(conseils, id: \.eventIdentifier) { conseil in
            VStack {
                Text("Date: ").foregroundColor(.secondary) +
                    Text(conseil.startDate.formatted(date: .complete, time: .standard))
                if let location = conseil.location {
                    Text("Lieu: ").foregroundColor(.secondary) +
                        Text(location)
                }
            }
        }
        .emptyListPlaceHolder(conseils) {
            Text("Aucun conseil prévu pour cette classe")
        }
    }

    private var roomView: some View {
        NavigationLink(value: ClasseNavigationRoute.room(classe)) {
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

    var body: some View {
        List {
            Section {
                // appréciation sur la classe
                if pref.viewClasseAppreciationEnabled {
                    AppreciationView(appreciation: $classe.viewAppreciation)
                }
                // annotation sur la classe
                if pref.viewClasseAnnotationEnabled {
                    AnnotationEditView(annotation: $classe.viewAnnotation)
                }
            }

            // Section arrêt des notes avant conseil de classe
            Section {
                arretNotesList
                    .popover(isPresented: $popOverArretIsPresented) {
                        Text("Nom requis pour l'événement du calendrier: \"**Arrêt notes - Niveau**\"")
                            .foregroundColor(.primary)
                            .padding()
                    }
            } header: {
                HStack {
                    Text("Arrêt des notes")
                        .style(.sectionHeader)
                    // Afficher le PopOver d'information sur le format à utiliser
                    Button {
                        popOverArretIsPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }

            // Section Conseils de classe
            Section {
                conseilList
                    .popover(isPresented: $popOverConseilIsPresented) {
                        Text("Nom requis pour l'événement du calendrier: \"**Conseil - Classe**\"")
                            .foregroundColor(.primary)
                            .padding()
                    }
            } header: {
                HStack {
                    Text("Conseils de classe")
                        .style(.sectionHeader)
                    // Afficher le PopOver d'information sur le format à utiliser
                    Button {
                        popOverConseilIsPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }

            // Section liste des documents utiles
            ClasseDocumentListSection(classe: classe)

            // Section Salle de classe utilisée
            Section {
                roomView
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Informations sur \(classe.displayString)")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task(id: classe.objectID) {
            if let school = classe.school {
                // Demander les droits d'accès aux calendriers de l'utilisateur
                (
                    calendar,
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = await EventManager.shared
                    .requestCalendarAccess(
                        eventStore: eventStore,
                        calendarName: school.viewName
                    )
                if let calendar {
                    // Récupérer les dates d'arrêt des notes avant conseils de classe
                    arretsNotes = EventManager.getAllArretsNotes(
                        forClasseLevel: classe.levelEnum,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: pref.viewSchoolYearPref.interval
                    )
                    // Récupérer les dates de conseils de classe
                    conseils = EventManager.getAllConseils(
                        forClasseName: classe.displayString,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        during: pref.viewSchoolYearPref.interval
                    )
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
