//
//  MotifView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 25/04/2022.
//

import SwiftUI

struct MotifView: View {
    let motif: Motif

    var body: some View {
        HStack(alignment: .center) {
            Text("Motif")
                .foregroundColor(.secondary)
                .padding(.trailing)

            Divider()

            if motif.nature == .autre {
                Text(motif.description.isEmpty ? "Autre motif" : motif.description)
            } else {
                VStack (alignment: .leading) {
                    Text(motif.nature.displayString)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct MotifView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MotifView(motif: Motif(nature: .autre, descriptionMotif: "Une description"))
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))

            MotifView(motif: Motif(nature: .leconNonApprise, descriptionMotif: "Une description suffisamment longue pour tenir sur plusieurs lignes"))
                .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))

        }
    }
}
