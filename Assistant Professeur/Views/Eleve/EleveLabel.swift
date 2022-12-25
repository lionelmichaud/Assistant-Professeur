//
//  EleveLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import SwiftUI
import HelpersView

struct EleveLabel: View {
    @ObservedObject
    var eleve: EleveEntity

    var fontWeight : Font.Weight = .semibold
    var imageSize  : Image.Scale = .large
    var flagSize   : Image.Scale = .medium

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    var body: some View {
        HStack {
            Image(systemName: "graduationcap")
                .imageScale(imageSize)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(eleve.sexEnum.color)

            Text(eleve.displayName(nameDisplayOrder))
                .fontWeight(fontWeight)
                .padding(2)
                .background {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.primary, lineWidth: eleve.hasAddTime ? 2 : 0)
                            .foregroundColor(.gray)
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.gray)
                            .opacity(eleve.hasTrouble ? 1.0 : 0.0)
                    }
                }
            if eleve.isFlagged {
                Image(systemName: "flag.fill")
                    .imageScale(flagSize)
                    .foregroundColor(.orange)
            }
        }
    }
}

//struct EleveLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            EleveLabel(eleve      : Eleve.exemple,
//                       fontWeight : .regular,
//                       imageSize  : .large)
//            .previewLayout(.sizeThatFits)
//
//            EleveLabel(eleve: Eleve.exemple)
//                .previewLayout(.sizeThatFits)
//        }
//    }
//}
