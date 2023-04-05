//
//  ClasseBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI

struct ClasseSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @SectionedFetchRequest<String, ClasseEntity>(
        fetchRequest: ClasseEntity.requestAllSortedbySchoolThenClasseLevelNumber,
        sectionIdentifier: \.school!.displayString,
        animation: .default
    )
    private var classesSections: SectionedFetchResults<String, ClasseEntity>

    var body: some View {
        List(selection: $navigationModel.selectedClasseMngObjId) {
            // pour chaque Etablissement
            ForEach(classesSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Classe
                        ClasseSidebarSchoolSubview(schoolSection: section)
                    } header: {
                        HStack {
                            Text(section.id)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(section.count)")
                        }
                    }
                }
            }
            .emptyListPlaceHolder(classesSections) {
                EmptyListMessage(
                    symbolName: "person.3.sequence.fill",
                    title: "Aucune classe actuellement.",
                    message: "Les classes ajoutées apparaîtront ici."
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Les Classes")
        #endif
    }
}

struct ClasseSidebarSchoolSubview: View {
    var schoolSection: SectionedFetchResults<String, ClasseEntity>.Element

    @EnvironmentObject
    private var navigationModel: NavigationModel

    var body: some View {
        // pour chaque Classe
        ForEach(schoolSection, id: \.objectID) { classe in
            ClassBrowserRow(classe: classe)

                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // supprimer la classe et tous ses descendants
                    Button(role: .destructive) {
                        withAnimation {
                            try? classe.delete()
                            if navigationModel.selectedClasseMngObjId == classe.objectID {
                                navigationModel.selectedClasseMngObjId = nil
                            }
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }

                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // modifier le flag de la classe
                    Button {
                        withAnimation {
                            classe.toggleFlag()
                        }
                    } label: {
                        if classe.isFlagged {
                            Label("Sans drapeau", systemImage: "flag.slash")
                        } else {
                            Label("Avec drapeau", systemImage: "flag.fill")
                        }
                    }.tint(.orange)
                }
        }
    }
}

 struct ClasseSidebarView_Previews: PreviewProvider {
     static func initialize() {
         DataBaseManager.populateWithMockData(storeType: .inMemory)
     }

    static var previews: some View {
        initialize()
        return Group {
            ClasseSidebarView()
                .environmentObject(NavigationModel(selectedClasseId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseSidebarView()
                .environmentObject(NavigationModel(selectedClasseId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
 }
