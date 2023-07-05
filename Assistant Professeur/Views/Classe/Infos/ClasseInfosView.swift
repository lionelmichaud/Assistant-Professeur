//
//  ClasseInfosView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/05/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct ClasseInfosView: View {
    @ObservedObject
    var classe: ClasseEntity

    @EnvironmentObject
    private var pref: UserPreferences

    /// Conseils de classe
    @State
    private var conseils = [EKEvent]()

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
                if pref.classeAppreciationEnabled {
                    AppreciationView(appreciation: $classe.viewAppreciation)
                }
                // annotation sur la classe
                if pref.classeAnnotationEnabled {
                    AnnotationEditView(annotation: $classe.viewAnnotation)
                }
            }

            // Conseils de classe
            Section {
                conseilList
            } header: {
                Text("Conseils de classe")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            }

            // Salle de classe utilisée
            Section {
                roomView
            }
        }
        .task {
            if let school = classe.school {
                conseils = await EventManager.getAllConseils(
                    forClasseName: classe.displayString,
                    inCalendarNamed: school.viewName,
                    during: pref.schoolYear.interval
                )
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
