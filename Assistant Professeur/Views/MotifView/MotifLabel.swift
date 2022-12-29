//
//  MotifLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 17/05/2022.
//

import SwiftUI

struct MotifLabel: View {
    let motif      : Motif
    var fontWeight : Font.Weight = .semibold
    var imageSize  : Image.Scale = .large

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(imageSize)
                .symbolRenderingMode(.hierarchical)
                //.foregroundColor(eleve.sexe.color)
            Text(motif.nature == .autre ? motif.descriptionMotif : motif.nature.displayString)
                .fontWeight(fontWeight)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

struct MotifLabel_Previews: PreviewProvider {
    static var previews: some View {
        MotifLabel(motif: Motif())
            .previewLayout(.sizeThatFits)
        MotifLabel(motif: Motif(nature: .leconNonApprise, descriptionMotif: ""))
            .previewLayout(.sizeThatFits)
    }
}
