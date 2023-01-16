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

//struct EleveColleLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            EleveColleLabel(eleve: TestEnvir.eleveStore.items.first!,
//                            scale: .large)
//                .previewLayout(.sizeThatFits)
//                .environmentObject(TestEnvir.colleStore)
//
//            EleveColleLabel(eleve: TestEnvir.eleveStore.items.first!,
//                            scale: .medium)
//                .previewLayout(.sizeThatFits)
//                .environmentObject(TestEnvir.colleStore)
//
//            EleveColleLabel(eleve: TestEnvir.eleveStore.items.first!,
//                            scale: .small)
//            .previewLayout(.sizeThatFits)
//            .environmentObject(TestEnvir.colleStore)
//       }
//    }
//}
