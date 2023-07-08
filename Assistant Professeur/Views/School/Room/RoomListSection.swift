//
//  RoomList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 03/11/2022.
//

import SwiftUI
import HelpersView

/// Vue de la liste des salles de classe de l'établissement
struct RoomListSection: View {
    @ObservedObject
    var school: SchoolEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var indexSet: IndexSet = []

    var body: some View {
        Section {
            /// Ajouter une nouvelle salle de classe
            Button {
                withAnimation {
                    _ = RoomEntity.create(dans: school)
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter une salle de classe")
                }
            }
            .buttonStyle(.borderless)

            /// Editer la liste des salles de classe
            ForEach(school.roomsSortedByName, id: \.objectID) { room in
                RoomEditor(room: room)
            }
            .onDelete { indexSet in
                alertTitle = "Supprimer cette salle de classe?"
                alertMessage =
                    """
                    Cette action supprimera le plan de la salle de classe ainsi que toutes les places associées.
                    Cette action supprimera aussi la salle de classe elle-même.
                    Cette action ne peut pas être annulée.
                    """
                self.indexSet = indexSet
                alertIsPresented.toggle()
            }
            .alert(
                alertTitle,
                isPresented : $alertIsPresented,
                actions     : {
                    Button("Supprimer", role: .destructive, action: deleteItems)
                }
            )
        } header: {
            Text("Salles de classe (\(school.nbOfRooms))")
                .style(.sectionHeader)
        }
    }

    private func deleteItems() {
        withAnimation {
            indexSet
                .map { school.roomsSortedByName[$0] }
                .forEach(managedObjectContext.delete)

            try? RoomEntity.saveIfContextHasChanged()
        }
    }
}

//struct RoomList_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomList()
//    }
//}
