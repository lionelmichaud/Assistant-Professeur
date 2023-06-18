//
//  ClassCapsule.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 31/03/2023.
//

import SwiftUI

struct ClasseCapsule: View {
    let classe: ClasseEntity

    var body: some View {
        Text("\(classe.displayString)")
            .filledCapsuleStyling(
                withBackground: true,
                withBorder: true,
                fillColor: .blue1
            )
    }
}

struct ClassCapsule_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseCapsule(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseCapsule(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
