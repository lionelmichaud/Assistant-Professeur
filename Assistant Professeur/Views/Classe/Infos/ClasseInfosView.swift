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
    private var popOverIsPresented: Bool = false

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

            // Conseils de classe
            Section {
                conseilList
                    .popover(isPresented: $popOverIsPresented) {
                        Text("Nom requis pour l'événement du calendrier: \"**Conseil - Classe**\"")
                            .foregroundColor(.primary)
                            .padding()
                    }
            } header: {
                HStack {
                    Text("Conseils de classe")
                        .style(.sectionHeader)
                    // Afficher le PopOver d'information surle format à utiliser
                    Button {
                        popOverIsPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }

            // Salle de classe utilisée
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
        .task(id: classe.objectID) {
            if let school = classe.school {
                // Demander les droits d'accès aux calendriers de l'utilisateur
                (
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = await EventManager.requestCalendarAccess(eventStore: eventStore)

                if !alertIsPresented {
                    // Récupérer le calendrier
                    (
                        calendar,
                        alertIsPresented,
                        alertTitle,
                        alertMessage
                    ) = EventManager.getOrCreateCalendar(named: school.viewName,
                                                         inEventStore: eventStore)

                    if let calendar {
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
