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
                Image(systemName: "magnifyingglass")
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

//struct ClasseObservLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ClasseObservLabel(classe: TestEnvir.classeStore.items.first!,
//                              scale: .large)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//
//            ClasseObservLabel(classe: TestEnvir.classeStore.items.first!,
//                              scale: .medium)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//
//            ClasseObservLabel(classe: TestEnvir.classeStore.items.first!,
//                              scale: .small)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//        }
//    }
//}
