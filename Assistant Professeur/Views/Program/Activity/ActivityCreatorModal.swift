//
//  ActivityCreatorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI

/// A Bridge to ActivityEditorModal that creates the object to be edited
struct ActivityCreatorModal: View {
    @ObservedObject
    var sequence: SequenceEntity

    /// This will not show changes to the variables in this View
    @State
    var newActivity: ActivityEntity?

    var body: some View {
        Group {
            if let newActivity {
                ActivityEditorModal(activity: newActivity)
            } else {
                // Likely wont ever be visible but there has to be a fallback
                ProgressView()
                    .onAppear {
                        newActivity = ActivityEntity.createWithoutSaving(dans: sequence)
                    }
            }
        }
    }
}

// struct ActivityCreatorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityCreatorModal()
//    }
// }
