//
//  ClasseTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/12/2023.
//

import Foundation
import TipKit

struct FlagClasseItemTip: Tip {
    var title: Text {
        Text("Marquer une classe")
    }

    var message: Text? {
        Text("Marquer une classe d'un drapeau en la glissant vers la droite.") +
            Text("\(Image(systemName: "arrowshape.right"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "flag.fill")
    }
}
