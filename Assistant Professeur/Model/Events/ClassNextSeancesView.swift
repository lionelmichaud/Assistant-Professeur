//
//  ClassNextSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import HelpersView
import SwiftUI

struct ClassNextSeancesView: View {
    @ObservedObject
    var classe: ClasseEntity

    private let horizon = 3 // mois

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            
        }
            .verticallyAligned(.top)
        #if os(iOS)
            .navigationTitle("Cours à venir")
        #endif
            .navigationBarTitleDisplayModeInline()
    }
}

struct ClassNextSeances_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first { classe in
            classe.levelEnum == .n5ieme
        }!
        print(classe)
        return Group {
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPad mini (6th generation)")
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPhone 13")
        }
    }
}
