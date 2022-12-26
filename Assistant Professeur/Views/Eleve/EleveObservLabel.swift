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
                Image(systemName: "magnifyingglass")
                    .imageScale(scale)
                    .foregroundColor(.red)
            }
        }
    }
}

//struct EleveObservLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            EleveObservLabel(eleve: TestEnvir.eleveStore.items.first!,
//                             scale: .large)
//            .previewLayout(.sizeThatFits)
//            .environmentObject(TestEnvir.observStore)
//
//            EleveObservLabel(eleve: TestEnvir.eleveStore.items.first!,
//                             scale: .medium)
//            .previewLayout(.sizeThatFits)
//            .environmentObject(TestEnvir.observStore)
//
//            EleveObservLabel(eleve: TestEnvir.eleveStore.items.first!,
//                             scale: .small)
//            .previewLayout(.sizeThatFits)
//            .environmentObject(TestEnvir.observStore)
//        }
//    }
//}
