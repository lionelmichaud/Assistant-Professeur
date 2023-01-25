//
//  ActivityEditor.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import SwiftUI
import CoreData

struct ActivityEditor: View {
    @EnvironmentObject
    private var navigationModel : NavigationModel

    // MARK: - Computed Properties

    private var selectedActivityId: NSManagedObjectID? {
        navigationModel.selectedActivityId
    }

    private var selectedActivity: ActivityEntity? {
        guard let selectedActivityId else { return nil }
        return ActivityEntity.byObjectId(id: selectedActivityId)
    }

    private var selectedActivityExists: Bool {
        selectedActivity != nil
    }

    var body: some View {
        if selectedActivityExists {
            ActivityEditorModal(activity: selectedActivity!)
        } else {
            VStack(alignment: .center) {
                Text("Aucune Activité sélectionnée.")
                Text("Sélectionner une Activité.")
            }
            .foregroundStyle(.secondary)
            .font(.title2)
        }
    }
}

struct ActivityEditor_Previews: PreviewProvider {
    static var previews: some View {
        ActivityEditor()
    }
}
