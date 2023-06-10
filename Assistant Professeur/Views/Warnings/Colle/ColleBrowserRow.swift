//
//  ColleBrowserRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI
import HelpersView

struct ColleBrowserRow: View {
    @ObservedObject
    var colle : ColleEntity

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: ColleEntity.defaultImageName)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(colle.color)
                Text("\(colle.viewDate.stringShortDate) à \(colle.viewDate.stringTime)")
                    .font(.callout)

                Spacer()

                ColleNotifIcon(colle: colle)
            }

            if let eleve = colle.eleve {
                EleveLabel(eleve: eleve)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                Text("<Elève indéfini>")
            }

            HStack {
                Image(systemName: "clock")
                LabeledContent("Durée (heure)",
                               value: colle.viewDuree,
                               format: .number)
            }

            MotifLabel(motif: colle.motifEnum,
                       description: colle.viewDescriptionMotif)
                .font(.callout)
        }
    }
}

//struct ColleBrowserRow_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            DisclosureGroup("Group", isExpanded: .constant(true)) {
//                ColleBrowserRow(eleve: Eleve.exemple,
//                                colle: Colle.exemple)
//            }
//            .previewLayout(.sizeThatFits)
//        }
//    }
//}
