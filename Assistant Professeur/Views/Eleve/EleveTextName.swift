//
//  EleveTextName.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/04/2023.
//

import SwiftUI

struct EleveTextName: View {
    @ObservedObject
    var eleve: EleveEntity

    var fontSize: Font = .title2
    var fontWidth: Font.Width = .condensed
    var fontWeight: Font.Weight = .bold

    @ObservedObject
    private var pref = UserPrefEntity.shared

    var body: some View {
        Text(eleve.displayName(pref.nameDisplayOrderEnum))
            .font(fontSize)
            .fontWidth(fontWidth)
            .fontWeight(fontWeight)
            .elevNameStyling(
                hasTrouble: eleve.hasTrouble,
                hasAddTime: eleve.hasAddTime
            )
    }
}

struct EleveTextName_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            EleveTextName(eleve: EleveEntity.all().first!)

            EleveTextName(
                eleve: EleveEntity.all().first!,
                fontSize: .body,
                fontWidth: .standard,
                fontWeight: .regular
            )
        }
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
