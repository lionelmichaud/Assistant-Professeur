//
//  ObservBrowserRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 26/04/2022.
//

import SwiftUI
import HelpersView

struct ObservBrowserRow: View {
    @ObservedObject
    var observ: ObservEntity

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: ObservEntity.defaultImageName)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(observ.color)
                Text("\(observ.viewDate.stringShortDate) à \(observ.viewDate.stringTime)")
                    .font(.callout)

                Spacer()

                ObservNotifIcon(observ: observ)
                ObservSignIcon(observ: observ)
            }

            if let eleve = observ.eleve {
                EleveLabel(eleve: eleve)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                Text("<Elève indéfini>")
            }

            MotifLabel(motif: observ.motifEnum,
                       description: observ.viewDescriptionMotif)
                .font(.callout)
        }
    }
}

//struct ObservBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                DisclosureGroup("Group", isExpanded: .constant(true)) {
//                    ObservBrowserRow(eleve  : TestEnvir.eleveStore.items.first!,
//                                     observ : TestEnvir.observStore.items.first!)
//                    .environmentObject(NavigationModel())
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//                }
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                DisclosureGroup("Group", isExpanded: .constant(true)) {
//                    ObservBrowserRow(eleve  : TestEnvir.eleveStore.items.first!,
//                                     observ : TestEnvir.observStore.items.first!)
//                    .environmentObject(NavigationModel())
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//                }
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
