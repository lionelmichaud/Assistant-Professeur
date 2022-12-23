//
//  ClasseEleveRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/04/2022.
//

import SwiftUI

struct ClasseEleveRow: View {
    @ObservedObject
    var eleve: EleveEntity

    var body: some View {
        HStack {
            EleveLabel(eleve: eleve)

            Spacer()

//            EleveColleLabel(eleve: eleve, scale: .medium)
//            EleveObservLabel(eleve: eleve, scale: .medium)
        }
    }
}

//struct ClasseEleveRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                ClasseEleveRow(eleve: TestEnvir.eleveStore.items.first!)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                ClasseEleveRow(eleve: TestEnvir.eleveStore.items.first!)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
