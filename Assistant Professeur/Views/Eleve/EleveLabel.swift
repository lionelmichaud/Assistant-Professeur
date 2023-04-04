//
//  EleveLabel.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/05/2022.
//

import HelpersView
import SwiftUI

struct EleveLabel: View {
    @ObservedObject
    var eleve: EleveEntity

    var fontWeight: Font.Weight = .bold
    var imageSize: Image.Scale = .large
    var flagSize: Image.Scale = .large

    var body: some View {
        HStack {
            Image(systemName: "graduationcap")
                .imageScale(imageSize)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(eleve.sexEnum.color)

            EleveTextName(
                eleve: eleve,
                fontWeight: fontWeight
            )

            if eleve.isFlagged {
                Image(systemName: "flag.fill")
                    .imageScale(flagSize)
                    .foregroundColor(.orange)
            }
        }
    }
}

struct EleveLabel_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveLabel(eleve: EleveEntity.all().first!)
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewLayout(.sizeThatFits)

            EleveLabel(
                eleve: EleveEntity.all().first!,
                fontWeight: .regular,
                imageSize: .medium,
                flagSize: .medium
            )
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewLayout(.sizeThatFits)
        }
    }
}
