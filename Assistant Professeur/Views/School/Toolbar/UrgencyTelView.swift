//
//  UrgencyTelView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/05/2023.
//

import SwiftUI
import HelpersView
import AppFoundation

struct UrgencyTelView: View {
    private let columns = [
        GridItem(
            .adaptive(minimum: 120, maximum: 200),
            alignment: .top
        )
    ]
    var body: some View {
        GroupBox {
            LazyVGrid(
                columns: columns,
                spacing: 4
            ) {
                telNumberPad(
                    tel: "112",
                    label: "NUMÉRO D’APPEL D’URGENCE EUROPÉEN"
                )
                telNumberPad(
                    tel: "114",
                    label: "NUMÉRO D’URGENCE POUR LES PERSONNES SOURDESET MALENTENDANTES"
                )
                telNumberPad(
                    tel: "15",
                    label: "SAMU"
                )
                telNumberPad(
                    tel: "17",
                    label: "POLICE SECOURS"
                )
                telNumberPad(
                    tel: "18",
                    label: "SAPEURS-POMPIERS"
                )
            }
        } label: {
            Text("Numéros d'urgence")
                .textCase(.uppercase)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue4))
        }
        .padding()
        .verticallyAligned(.top)
    }

    @ViewBuilder
    func telNumberPad(tel: String, label: String) -> some View {
        VStack(alignment: .center) {
            Text(tel)
                .font(.title)
                .fontWeight(.black)
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(4)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.secondary))
        .onLongPressGesture(minimumDuration: 1) {
            call(telNumber: tel)
        }
    }
}

struct UrgencyTelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UrgencyTelView()
                .previewDevice("iPad mini (6th generation)")
            UrgencyTelView()
                .previewDevice("iPhone 13")
        }
    }
}
