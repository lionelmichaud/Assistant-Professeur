//
//  ClasseBrowserView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI
import HelpersView
import TipKit

struct ClasseSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @SectionedFetchRequest<String, ClasseEntity>(
        fetchRequest: ClasseEntity.requestAllSortedbySchoolThenClasseLevelNumber,
        sectionIdentifier: \.school!.displayString,
        animation: .default
    )
    private var classesSections: SectionedFetchResults<String, ClasseEntity>

    // Create an instance of your tip content.
    var flagListItem = FlagClasseItemTip()

    var body: some View {
        // Liste des classes par établissement
        TipView(flagListItem, arrowEdge: .bottom)
            .tint(.orange)
            .tipBackground(HierarchicalShapeStyle.tipBackgroundColor)
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
                                .style(.sectionHeader)
                            Spacer()
                            Text("\(section.count)")
                                .style(.sectionHeader)
                        }
                    }
                }
            }
            .emptyListPlaceHolder(classesSections) {
                ContentUnavailableView(
                    "Aucune classe actuellement...",
                    systemImage: ClasseEntity.defaultImageName,
                    description: Text("Les classes ajoutées apparaîtront ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Mes Classes")
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
            ClasseBrowserRow(classe: classe)

                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // Supprimer la classe et tous ses descendants
                    // dont les progressions d'activités pédagogiques associées
                    Button(role: .destructive) {
                        withAnimation {
                            if navigationModel.selectedClasseMngObjId == classe.objectID {
                                navigationModel.selectedClasseMngObjId = nil
                            }
                            // ATTENTION: à mettre en dernier
                            try? classe.delete()
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }

                .swipeActions(edge: .leading, allowsFullSwipe: true) {
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

//struct ClasseSidebarView_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseSidebarView()
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
//}

#Preview {
    func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }
    initialize()
    return ClasseSidebarView()
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
