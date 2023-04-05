//
//  EleveColleLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct EleveColleLabel : View {
    @ObservedObject
    var eleve: EleveEntity

    let scale: Image.Scale

    private var nbCollesNonNotifee: Int {
        eleve.nbOfColles(isConsignee: false)
    }

    var body: some View {
        HStack {
            let nb = nbCollesNonNotifee
            if nb > 0 {
                Text("\(nb)")
                Image(systemName: "lock.fill")
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

struct EleveColleLabel_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveColleLabel(eleve: EleveEntity.all().first!, scale: .large)
                .previewDevice("iPad mini (6th generation)")

            EleveColleLabel(eleve: EleveEntity.all().first!, scale: .large)
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
