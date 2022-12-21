//
//  EventList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 03/11/2022.
//

import SwiftUI

/// Vue de la liste des événements de l'établissement
struct EventList: View {
    @ObservedObject
    var school: SchoolEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    var body: some View {
        Section {
            // ajouter un événement
            Button {
                withAnimation {
                    let event = EventEntity.create()
                    event.school = school
                    try? EventEntity.saveIfContextHasChanged()
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un événement")
                }
            }
            .buttonStyle(.borderless)

            // édition de la liste des événements
            ForEach(school.eventsSortedByDate) { event in
                EventEditor(event: event)
            }
            .onDelete(perform: deleteItems)

        } header: {
            Text("Événements (\(school.nbOfEvents))")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
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

//struct EventList_Previews: PreviewProvider {
//    static var previews: some View {
//        EventList()
//    }
//}
