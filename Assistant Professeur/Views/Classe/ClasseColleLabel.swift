//
//  ClasseColleLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct ClasseColleLabel: View {
    var nbCollesNonNotifee: Int
    let imageScale: Image.Scale
    let withLabel: Bool

    // MARK: - Computed Properties
    var body: some View {
        if withLabel {
            ViewThatFits {
                template(
                    number: nbCollesNonNotifee,
                    large: true
                )
                template(
                    number: nbCollesNonNotifee,
                    large: false
                )
            }
        } else {
            template(
                number: nbCollesNonNotifee,
                large: false
            )
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private func template(
        number: Int,
        large: Bool
    ) -> some View {
        HStack {
            if number > 0 {
                Text("\(number)")
                if large {
                    Text("colle" + (number > 1 ? "s" : ""))
                }
                Image(systemName: "lock.fill")
                    .imageScale(imageScale)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview("With Label - Large") {
    ClasseColleLabel(
        nbCollesNonNotifee: 4,
        imageScale: .medium,
        withLabel: true
    )
    .frame(maxWidth: .infinity)
}

#Preview("With Label - Short") {
    ClasseColleLabel(
        nbCollesNonNotifee: 4,
        imageScale: .medium,
        withLabel: true
    )
    .frame(maxWidth: 75)
}

#Preview("No Label") {
    ClasseColleLabel(
        nbCollesNonNotifee: 4,
        imageScale: .medium,
        withLabel: false
    )
}

//struct ClasseColleLabel_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            ClasseColleLabel(classe: ClasseEntity.all().first!, scale: .large)
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseColleLabel(classe: ClasseEntity.all().first!, scale: .large)
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
