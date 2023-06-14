//
//  EleveObservLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct EleveObservLabel: View {
    @ObservedObject
    var eleve: EleveEntity

    let scale: Image.Scale

    private var nbObservWithActionToDo: Int {
        eleve.nbOfObservations(isConsignee: false,
                               isVerified: false)
    }

    var body: some View {
        HStack {
            let nb = nbObservWithActionToDo
            if nb > 0 {
                Text("\(nb)")
                Image(systemName: ObservEntity.defaultImageName)
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

struct EleveObservLabel_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveObservLabel(eleve: EleveEntity.all().first!, scale: .large)
                .previewDevice("iPad mini (6th generation)")

            EleveObservLabel(eleve: EleveEntity.all().first!, scale: .large)
                .previewDevice("iPhone 13")
        }
        .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
