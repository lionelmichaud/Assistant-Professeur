//
//  EleveListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/06/2023.
//

import SwiftUI

struct EleveListSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @ObservedObject
    private var pref = UserPrefEntity.shared

    var body: some View {
        Section {
            // édition de la liste des élèves
            elevesListView

            // trombinoscope
            if pref.viewElevePref.trombineEnabled {
                trombinoscopeView
            }

            // gestion des groupes
            groupsView
        } header: {
            Text("Elèves (\(classe.nbOfEleves))")
                .style(.sectionHeader)
        }
    }
}

// MARK: - Subviews

extension EleveListSection {
    private var elevesListView: some View {
        NavigationLink(value: ClasseNavigationRoute.liste(classe.id)) {
            Label("Liste d'appel", systemImage: "list.bullet")
                .fontWeight(.bold)
        }
    }

    private var trombinoscopeView: some View {
        NavigationLink(value: ClasseNavigationRoute.trombinoscope(classe.id)) {
            Label("Trombinoscope", systemImage: "person.crop.square.fill")
                .fontWeight(.bold)
        }
    }

    private var groupsView: some View {
        NavigationLink(value: ClasseNavigationRoute.groups(classe.id)) {
            Label("Groupes", systemImage: "person.line.dotted.person.fill")
                .fontWeight(.bold)
        }
    }
}

struct EleveListSection_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveListSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            EleveListSection(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
