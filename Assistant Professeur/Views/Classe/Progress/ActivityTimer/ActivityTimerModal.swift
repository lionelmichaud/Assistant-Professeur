//
//  ActivityTimerModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/04/2023.
//

import SwiftUI

struct ActivityTimerModal: View {
    @ObservedObject
    var activity: ActivityEntity

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ActivityTimerView(activity: activity)
        #if os(iOS)
            .navigationTitle("Chronomètre")
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ok") {
                        dismiss()
                    }
                }
            }
    }
}

struct ActivityTimerModal_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let activity = ActivityEntity.all().first!
        return Group {
            NavigationStack {
                ActivityTimerModal(activity: activity)
            }
            .previewDevice("iPad mini (6th generation)")
            NavigationStack {
                ActivityTimerModal(activity: activity)
            }
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
