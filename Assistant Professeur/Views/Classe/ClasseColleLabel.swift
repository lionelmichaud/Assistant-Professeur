//
//  ClasseColleLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct ClasseColleLabel: View {
    @ObservedObject
    var classe: ClasseEntity

    let scale: Image.Scale

    // MARK: - Computed Properties

    private var nbCollesNonNotifee: Int {
        classe.nbOfColles(isConsignee: false)
    }

    var body: some View {
//        let number = nbCollesNonNotifee
        ViewThatFits {
            template(number: classe.nbOfColles(isConsignee: false), large: true)
            template(number: classe.nbOfColles(isConsignee: false), large: false)
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private func template(number: Int, large: Bool) -> some View {
        HStack {
            if number > 0 {
                Text("\(number)")
                if large {
                    Text("colle" + (number > 1 ? "s" : ""))
                }
                Image(systemName: "lock.fill")
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

struct ClasseColleLabel_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseColleLabel(classe: ClasseEntity.all().first!, scale: .large)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseColleLabel(classe: ClasseEntity.all().first!, scale: .large)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
