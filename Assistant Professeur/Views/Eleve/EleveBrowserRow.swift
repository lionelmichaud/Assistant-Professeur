//
//  EleveBrowserRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI

struct EleveBrowserRow: View {
    @ObservedObject
    var eleve: EleveEntity

    var body: some View {
        HStack {
            EleveLabel(eleve      : eleve,
                       fontWeight : .regular,
                       imageSize  : .medium,
                       flagSize   : .small)

            Spacer()
            
            EleveColleLabel(eleve: eleve, scale: .small)
            EleveObservLabel(eleve: eleve, scale: .small)
        }
    }
}

//struct EleveBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                DisclosureGroup("Group", isExpanded: .constant(true)) {
//                    EleveBrowserRow(eleve: Eleve.exemple)
//                        .environmentObject(NavigationModel())
//                        .environmentObject(TestEnvir.schoolStore)
//                        .environmentObject(TestEnvir.classeStore)
//                        .environmentObject(TestEnvir.eleveStore)
//                        .environmentObject(TestEnvir.colleStore)
//                        .environmentObject(TestEnvir.observStore)
//                }
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                DisclosureGroup("Group", isExpanded: .constant(true)) {
//                    EleveBrowserRow(eleve: Eleve.exemple)
//                        .environmentObject(NavigationModel())
//                        .environmentObject(TestEnvir.schoolStore)
//                        .environmentObject(TestEnvir.classeStore)
//                        .environmentObject(TestEnvir.eleveStore)
//                        .environmentObject(TestEnvir.colleStore)
//                        .environmentObject(TestEnvir.observStore)
//                }
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
