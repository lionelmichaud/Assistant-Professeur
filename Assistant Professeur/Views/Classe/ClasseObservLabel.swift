//
//  ClasseObservLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct ClasseObservLabel: View {
    @ObservedObject
    var classe: ClasseEntity

    let scale: Image.Scale

    // MARK: - Computed Properties

    private var nbObservNonNotifee: Int {
        classe.nbOfObservations(isConsignee: false,
                                isVerified: false)
    }

    var body: some View {
        let number = nbObservNonNotifee
        ViewThatFits {
            template(number: number, large: true)
            template(number: number, large: false)
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private func template(number: Int, large: Bool) -> some View {
        HStack {
            if number > 0 {
                Text("\(number)")
                if large {
                    Text("observation" + (number > 1 ? "s" : ""))
                }
                Image(systemName: ObservEntity.defaultImageName)
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

struct ClasseObservLabel_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseObservLabel(classe: ClasseEntity.all().first!, scale: .large)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseObservLabel(classe: ClasseEntity.all().first!, scale: .large)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
