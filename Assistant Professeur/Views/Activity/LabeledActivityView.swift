//
//  LabeledActivityView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

struct LabeledActivityView: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        Label {
            Text(activity.viewName)
                .textSelection(.enabled)
        } icon: {
            Image(systemName: "\(activity.viewNumber).circle")
                .imageScale(.large)
        }
    }
}

struct LabeledActivityView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let activity = ActivityEntity.all().first!
        return Group {
            LabeledActivityView(activity: activity)
                .previewDevice("iPad mini (6th generation)")
            LabeledActivityView(activity: activity)
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
