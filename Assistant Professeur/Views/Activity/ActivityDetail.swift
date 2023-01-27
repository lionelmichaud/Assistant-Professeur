//
//  ActivityDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI
import CoreData

struct ActivityDetail: View {
    @EnvironmentObject
    private var navig : NavigationModel

    @State
    private var isEditing = false

    // MARK: - Computed Properties

    private var selectedActivityId: NSManagedObjectID? {
        navig.selectedActivityId
    }

    private var selectedActivity: ActivityEntity? {
        guard let selectedActivityId else { return nil }
        return ActivityEntity.byObjectId(id: selectedActivityId)
    }

    private var selectedActivityExists: Bool {
        selectedActivity != nil
    }

    var body: some View {
        VStack {
            if selectedActivityExists {
                ActivityDetailGroupBox(activity: selectedActivity!)
                Spacer()
            } else {
                VStack(alignment: .center) {
                    Text("Aucune Activité sélectionnée.")
                    Text("Sélectionner une Activité.")
                }
                .foregroundStyle(.secondary)
                .font(.title2)
            }
        }
        #if os(iOS)
        .navigationTitle("Activité")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        /// Modal Sheet de modification de l'activité
        .sheet(isPresented: $isEditing,
               onDismiss: { ActivityEntity.rollback() }) {
            if selectedActivityExists {
                NavigationStack {
                    ActivityEditorModal(activity: selectedActivity!)
                }
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: Toolbar Content

extension ActivityDetail {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        if selectedActivityExists {
            /// Editer l'activité
            ToolbarItemGroup(placement: .automatic) {
                Button("Modifier") {
                    isEditing.toggle()
                }
            }
        }
    }
}

//struct ActivityDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDetail()
//    }
//}
