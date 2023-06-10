//
//  EleveObservRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct EleveObservRow: View {
    @ObservedObject
    var observ: ObservEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var motifDisplayString: String {
        if observ.motifEnum == .autre {
            return observ.viewDescriptionMotif.truncate(to: 20, addEllipsis: true)
        } else {
            return observ.motifEnum.displayString
        }
    }

    var body: some View {
        HStack {
            Image(systemName: ObservEntity.defaultImageName)
                .foregroundColor(observ.color)
            if hClass == .compact {
                VStack(alignment: .leading) {
                    Text(observ.viewDate.stringShortDate)
                    Text(motifDisplayString)
                        .foregroundColor(.secondary)
                }
                .font(.callout)
            } else {
                VStack(alignment: .leading) {
                    Text(observ.viewDate.stringLongDateTime)
                    Text(motifDisplayString)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button {
                observ.toggleIsConsignee()
            } label: {
                Image(systemName: observ.isConsignee ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observ.isConsignee ? .green : .gray)
                if hClass == .compact {
                    Text("Notifié")
                        .font(.callout)
                } else {
                    Text("Notifiée aux parents")
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)

            Button {
                observ.toggleIsVerified()
            } label: {
                Image(systemName: observ.isVerified ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(observ.isVerified ? .green : .gray)
                if hClass == .compact {
                    Text("Vérifié")
                        .font(.callout)
                } else {
                    Text("Signature des parents vérifiée")
                }
            }
            .buttonStyle(.plain)
        }
    }
}

//struct EleveObservRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            EleveObservRow(observ: Observation.exemple)
//                .previewDevice("iPad mini (6th generation)")
//                .previewLayout(.sizeThatFits)
//            EleveObservRow(observ: Observation.exemple)
//                .previewDevice("iPhone Xs")
//                .previewLayout(.sizeThatFits)
//        }
//    }
//}
