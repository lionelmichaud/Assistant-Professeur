//
//  ClasseObservLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct ClasseObservLabel: View {
    var nbObservNonNotifee: Int
    let imageScale: Image.Scale
    let withLabel: Bool

    var body: some View {
        if withLabel {
            ViewThatFits {
                template(
                    number: nbObservNonNotifee,
                    large: true
                )
                template(
                    number: nbObservNonNotifee,
                    large: false
                )
            }
        } else {
            template(
                number: nbObservNonNotifee,
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
                    Text("observation" + (number > 1 ? "s" : ""))
                }
                Image(systemName: ObservEntity.defaultImageName)
                    .imageScale(imageScale)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview("With Label - Large") {
    ClasseObservLabel(
        nbObservNonNotifee: 4,
        imageScale: .medium,
        withLabel: true
    )
    .frame(maxWidth: .infinity)
}

#Preview("With Label - Short") {
    ClasseObservLabel(
        nbObservNonNotifee: 4,
        imageScale: .medium,
        withLabel: true
    )
    .frame(maxWidth: 100)
}

#Preview("No Label") {
    ClasseObservLabel(
        nbObservNonNotifee: 4,
        imageScale: .medium,
        withLabel: false
    )
}

// struct ClasseObservLabel_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            ClasseObservLabel(classe: ClasseEntity.all().first!, imageScale: .large)
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//
//            ClasseObservLabel(classe: ClasseEntity.all().first!, imageScale: .large)
//                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
// }
