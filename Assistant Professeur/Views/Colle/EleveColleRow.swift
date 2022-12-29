//
//  EleveColleRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 23/04/2022.
//

import SwiftUI
import HelpersView

struct EleveColleRow: View {
    @ObservedObject
    var colle: ColleEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(colle.color)
            VStack(alignment: .leading) {
                Text(colle.date.stringShortDate)
                Text(colle.motifEnum.displayString)
                    .foregroundColor(.secondary)
            }
            .font(hClass == .compact ? .callout : .body)

            Spacer()

            Button {
                colle.toggleIsConsignee()
            } label: {
                Image(systemName: colle.isConsignee ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(colle.isConsignee ? .green : .gray)
                if hClass == .compact {
                    Text("Notifié")
                        .font(.callout)
                } else {
                    Text("Notifiée à la vie scolaire")
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)

            Button {
                colle.toggleIsVerified()
            } label: {
                Image(systemName: colle.isVerified ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(colle.isVerified ? .green : .gray)
                if hClass == .compact {
                    Text("Exéc.")
                        .font(.callout)
                } else {
                    Text("Exécutée par l'élève")
                }
            }
            .buttonStyle(.plain)
        }
    }
}

//struct EleveColleRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            EleveColleRow(colle: Colle.exemple)
//                .previewDevice("iPad mini (6th generation)")
//                .previewLayout(.sizeThatFits)
//            EleveColleRow(colle: Colle.exemple)
//                .previewDevice("iPhone Xs")
//                .previewLayout(.sizeThatFits)
//        }
//    }
//}
