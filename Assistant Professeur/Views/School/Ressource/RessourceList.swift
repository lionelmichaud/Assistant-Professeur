//
//  RessourceList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 03/11/2022.
//

import SwiftUI

/// Vue de la liste des ressources de l'établissement
struct RessourceList: View {
    @ObservedObject
    var school: SchoolEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    var body: some View {
        Section {
            // ajouter une évaluation
            Button {
                withAnimation {
                    let ressource = RessourceEntity.create()
                    ressource.school = school
                    try? RessourceEntity.saveIfContextHasChanged()
                }
            } label: {
                Label("Ajouter une ressource", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des examen
            ForEach(school.allRessources) { ressource in
                RessourceEditor(ressource: ressource)
            }
            .onDelete(perform: deleteItems)
//            .onMove { fromOffsets, toOffset in
//                school.ressources.move(fromOffsets: fromOffsets, toOffset: toOffset)
//            }

        } header: {
            Text("Ressources (\(school.nbOfRessourceTypes))")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { school.allRessources[$0] }
                .forEach(managedObjectContext.delete)

            try? EventEntity.saveIfContextHasChanged()
        }
    }
}

//struct RessourceList_Previews: PreviewProvider {
//    static var previews: some View {
//        RessourceList()
//    }
//}
