//
//  EventList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 03/11/2022.
//

import SwiftUI

/// Vue de la liste des événements de l'établissement
struct EventListSection: View {
    @ObservedObject
    var school: SchoolEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    var body: some View {
        Section {
            // ajouter un événement
            Button {
                withAnimation {
                    _ = EventEntity.create(
                        dans: school,
                        withName: ""
                    )
                }
            } label: {
                Label("Ajouter un événement", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des événements
            ForEach(school.eventsSortedByDate) { event in
                EventEditor(event: event)
            }
            .onDelete(perform: deleteItems)

        } header: {
            Text("Événements (\(school.nbOfEvents))")
                .style(.sectionHeader)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { school.eventsSortedByDate[$0] }
                .forEach(managedObjectContext.delete)

            try? EventEntity.saveIfContextHasChanged()
        }
    }
}

struct EventList_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            List {
                EventListSection(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            List {
                EventListSection(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
