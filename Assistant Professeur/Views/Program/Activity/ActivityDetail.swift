//
//  ActivityDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import CoreData
import SwiftUI

struct ActivityDetail: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var isEditing = false

    // MARK: - Computed Properties

    private var selectedActivityId: NSManagedObjectID? {
        navig.selectedActivityMngObjId
    }

    private var selectedActivity: ActivityEntity? {
        guard let selectedActivityId else {
            return nil
        }
        return ActivityEntity.byObjectId(MngObjID: selectedActivityId)
    }

    private var selectedActivityExists: Bool {
        selectedActivity != nil
    }

    private var selectedActivityNumber: String {
        selectedActivity?.viewNumber.formatted() ?? ""
    }

    private var selectedSequenceNumber: String {
        selectedActivity?.sequence?.viewNumber.formatted() ?? ""
    }

    var body: some View {
        Group {
            if selectedActivityExists {
                List {
                    ActivityDetailGroupBox(activity: selectedActivity!)
                    
                    Section {
                        ActivityProgressesView(activity: selectedActivity!)
                    } header: {
                        Text("Progression des Classes")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                }
            } else {
                EmptyListMessage(
                    title: "Aucune activité sélectionnée.",
                    message: "Sélectionner une activité pour en visualiser le détail ici.",
                    showAsGroupBox: true
                )
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
            if selectedActivityExists {
                NavigationStack {
                    ActivityEditorModal(activity: selectedActivity!)
                }
                .presentationDetents([.large])
            } else {
                Text("Activité introuvable.")
            }
        }
    }
}

// MARK: Toolbar Content

extension ActivityDetail {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if selectedActivityExists {
            // Editer l'activité
            ToolbarItemGroup(placement: .automatic) {
                Button("Modifier") {
                    isEditing.toggle()
                }
            }
        }
    }
}

struct ActivityDetail_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ActivityDetail()
                .environmentObject(NavigationModel(selectedActivityMngObjId: ActivityEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ActivityDetail()
                .environmentObject(NavigationModel(selectedActivityMngObjId: ActivityEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
