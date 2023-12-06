//
//  ActivityDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import CoreData
import SwiftUI

struct ActivityDetail: View {
    @ObservedObject
    var activity: ActivityEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isEditing = false

    @State
    private var isDuplicating = false

    // MARK: - Computed Properties

    private var selectedActivityId: NSManagedObjectID? {
        navig.selectedActivityMngObjId
    }

    private var selectedActivityNumber: String {
        activity.viewNumber.formatted()
    }

    private var selectedSequenceNumber: String {
        activity.sequence?.viewNumber.formatted() ?? ""
    }

    var body: some View {
        Group {
            List {
                ActivityDetailGroupBox(activity: activity)

                Section {
                    ActivityProgressesView(activity: activity)
                } header: {
                    Text("Progression des Classes")
                        .style(.sectionHeader)
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Séquence \(selectedSequenceNumber) - Activité " + selectedActivityNumber)
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Modal Sheet de modification de l'activité
        .sheet(
            isPresented: $isEditing,
            onDismiss: ActivityEntity.rollback
        ) {
            NavigationStack {
                ActivityEditorModal(activity: activity)
            }
            .presentationDetents([.large])
        }

        // Modal Sheet de sélection de l'activité associée
        .sheet(
            isPresented: $isDuplicating
        ) {
            NavigationStack {
                DuplicateActivityModal(activity: activity)
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: Toolbar Content

extension ActivityDetail {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Editer l'activité
        ToolbarItemGroup(placement: .automatic) {
            // Modifier l'activité
            Button {
                isEditing.toggle()
            } label: {
                Label("Modifier", systemImage: "square.and.pencil")
            }

            // Dupliquer l'activité
            Button {
                isDuplicating.toggle()
            } label: {
                Label(
                    "Dupliquer l'activité dans une autre séquence",
                    systemImage: "doc.on.doc.fill"
                )
            }
        }
    }
}

// struct ActivityDetail_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            ActivityDetail()
//                .environmentObject(NavigationModel(selectedActivityMngObjId: ActivityEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//            ActivityDetail()
//                .environmentObject(NavigationModel(selectedActivityMngObjId: ActivityEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
// }
