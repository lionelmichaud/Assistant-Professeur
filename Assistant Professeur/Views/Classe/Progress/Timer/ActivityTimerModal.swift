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
    var test: Bool = false

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var warningRemainingMinutes: Int = 10

    @State
    private var alertRemainingMinutes: Int = 5

    var body: some View {
        SeanceTimerView(
            warningRemainingMinutes: $warningRemainingMinutes,
            alertRemainingMinutes: $alertRemainingMinutes,
            test: test
        )
        #if os(iOS)
        .navigationTitle("Chronomètre")
            // .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour") {
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
                ActivityTimerModal(activity: activity, test: true)
            }
            .previewDevice("iPad mini (6th generation)")
            NavigationStack {
                ActivityTimerModal(activity: activity, test: true)
            }
            .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
