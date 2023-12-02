//
//  WCompetencyTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/12/2023.
//

import Foundation
import TipKit

struct WCompEditItemTip: Tip {
    var title: Text {
        Text("Modifier une Compétence")
    }

    var message: Text? {
        Text("Glisser une compétence vers la droite.") +
        Text("\(Image(systemName: "arrowshape.right"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "square.and.pencil")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
