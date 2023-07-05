//
//  MotifEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 25/04/2022.
//

import HelpersView
import SwiftUI

struct MotifEditor: View {
    @Binding
    var motif: MotifEnum

    @Binding
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            CasePicker(
                pickedCase: $motif.animation(),
                label: "Motif"
            )
            .pickerStyle(.menu)

            if motif == .autre {
                TextEditor(text: $description)
                    .lineLimit(1...)
                    .multilineTextAlignment(.leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8).stroke(.secondary)
                    )
                    .frame(minHeight: 20)
            }
        }
    }
}

struct MotifEditor_Previews: PreviewProvider {
    static var previews: some View {
        MotifEditor(
            motif: .constant(.autre),
            description: .constant("Une description")
        )
        .padding()
        .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))
    }
}
