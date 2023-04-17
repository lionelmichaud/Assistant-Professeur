//
//  ActivityTimerView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/04/2023.
//

import SwiftUI

struct ActivityTimerView: View {
    @ObservedObject
    var activity: ActivityEntity

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ActivityTimerView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let activity = ActivityEntity.all().first!
        return Group {
            ActivityTimerView(activity: activity)
                .previewDevice("iPad mini (6th generation)")
            ActivityTimerView(activity: activity)
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
