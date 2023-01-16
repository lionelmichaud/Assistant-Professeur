//
//  MotifLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/05/2022.
//

import SwiftUI

struct MotifLabel: View {
    let motif       : MotifEnum
    var description : String
    var fontWeight  : Font.Weight = .semibold
    var imageSize   : Image.Scale = .large

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(imageSize)
                .symbolRenderingMode(.hierarchical)
                //.foregroundColor(eleve.sexe.color)
            Text(motif == .autre ? description : motif.displayString)
                .lineLimit(1)
                .fontWeight(fontWeight)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

struct MotifLabel_Previews: PreviewProvider {
    static var previews: some View {
        MotifLabel(motif: .bavardage,
                   description: "")
        .previewLayout(.sizeThatFits)
        MotifLabel(motif: .autre,
                   description: "La desciption du motif")
        .previewLayout(.sizeThatFits)
    }
}
