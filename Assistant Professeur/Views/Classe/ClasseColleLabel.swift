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
        let number = nbCollesNonNotifee
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
                    Text("colle" + (number > 1 ? "s" : ""))
                }
                Image(systemName: "lock.fill")
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

//struct ClasseColleLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            ClasseColleLabel(classe : TestEnvir.classeStore.items.first!,
//                             scale  : .large)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//
//            ClasseColleLabel(classe : TestEnvir.classeStore.items.first!,
//                             scale  : .medium)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//
//            ClasseColleLabel(classe : TestEnvir.classeStore.items.first!,
//                             scale  : .small)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.observStore)
//            .previewLayout(.sizeThatFits)
//        }
//    }
//}
