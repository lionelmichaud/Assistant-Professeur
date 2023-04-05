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
                    _ = RessourceEntity.create(dans: school)
                }
            } label: {
                Label("Ajouter une ressource", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des examen
            ForEach(school.ressourcesSortedByName, id: \.objectID) { ressource in
                RessourceEditor(ressource: ressource)
            }
            .onDelete(perform: deleteItems)

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
                .map { school.ressourcesSortedByName[$0] }
                .forEach(managedObjectContext.delete)

            try? RessourceEntity.saveIfContextHasChanged()
        }
    }
}

struct RessourceList_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            List {
                RessourceList(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")
            
            List {
                RessourceList(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
