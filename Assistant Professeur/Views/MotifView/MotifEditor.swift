//
//  MotifEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 25/04/2022.
//

import SwiftUI
import HelpersView

struct MotifEditor: View {
    @Binding
    var motif: MotifEnum

    @Binding
    var description: String

    var body: some View {
            VStack(alignment: .leading) {
                CasePicker(pickedCase: $motif.animation(),
                           label: "Motif")
                .pickerStyle(.menu)

                if motif == .autre {
                    TextEditor(text: $description)
                        .lineLimit(1...)
                        .multilineTextAlignment(.leading)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                        .frame(minHeight: 20)
                }
            }
    }
}

//struct MotifEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        MotifEditor(motif: .constant(Motif(nature: .autre, descriptionMotif: "Une description")))
//    }
//}
