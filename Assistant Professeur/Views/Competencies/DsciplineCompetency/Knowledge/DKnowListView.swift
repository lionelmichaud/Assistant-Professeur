//
//  KnowledgeListView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

struct DKnowListView: View {
    @EnvironmentObject
    private var nav: NavigationModel

    // MARK: - Computed Properties

    private var selectedCompetencyId: NSManagedObjectID? {
        nav.selectedDiscCompMngObjId
    }

    private var selectedCompetency: DCompEntity? {
        guard let selectedCompetencyId else {
            return nil
        }
        return DCompEntity.byObjectId(MngObjID: selectedCompetencyId)
    }

    private var selectedCompetencyExists: Bool {
        selectedCompetency != nil
    }

    var body: some View {
        VStack {
            if selectedCompetencyExists {
                List {
                    // Compétence disciplinaire
//                    DCompBrowserRow(
//                        competency: selectedCompetency!,
//                        showIcon: false
//                    )

                    // Section des Connaissances disciplinaires associées
                    // à la compétence disciplinaire sélectionnée
                    KnowledgeListSection(
                        dCompetency: selectedCompetency!
                    )

                    // Section des Compétences travaillées associées
                    // à la compétence disciplinaire sélectionnée
                    if WCompEntity.cardinal() > 0 {
                        WCompListSection(
                            dCompetency: selectedCompetency!
                        )
                    }

                    // Section des Activités associées
                    // à la compétence disciplinaire sélectionnée
                    if ActivityEntity.cardinal() > 0 {
                        ActivityListSection(
                            dCompetency: selectedCompetency!
                        )
                    }
                }
            } else {
                ContentUnavailableView(
                    "Aucune compétence sélectionnée...",
                    systemImage: DKnowledgeEntity.defaultImageName,
                    description: Text("Sélectionner une compétence pour en visualiser le détail ici.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Relations")
        #endif
        .navigationBarTitleDisplayModeInline()
//        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

//extension DKnowListView {
//    @ToolbarContentBuilder
//    func myToolBarContent() -> some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            // Modifier une connaissance à la section
//            if let selectedDiscKnowMngObjId = nav.selectedDiscKnowMngObjId {
//                Button("Modifier") {
//                    editedKnowledge =
//                        DKnowledgeEntity
//                            .byObjectId(MngObjID: selectedDiscKnowMngObjId)
//                }
//            }
//        }
//    }
//}

// struct KnowledgeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        KnowledgeListView()
//    }
// }
