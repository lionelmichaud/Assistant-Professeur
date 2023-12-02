//
//  EleveTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 01/12/2023.
//

import Foundation
import TipKit

struct AddEleveTip: Tip {
    var title: Text {
        Text("Ajouter un élève à cette classe")
    }

    var message: Text? {
        Text("En tapant ici ") +
        Text("\(Image(systemName: "plus.circle.fill"))")
            .foregroundStyle(.blue)
    }

    var image: Image? {
        Image(systemName: EleveEntity.defaultImageName)
    }
}

struct ActionsEleveTip: Tip {
    var title: Text {
        Text("Plus d'options ici")
    }

    var message: Text? {
        Text("Sélectionner un ou plusieurs élèves pour avoir accès à des options complémentaires.")
    }

    var image: Image? {
        Image(systemName: EleveEntity.defaultImageName)
    }
}

struct FlagEleveItemTip: Tip {
    var title: Text {
        Text("Marquer un élève")
    }

    var message: Text? {
        Text("Marquer un élève d'un drapeau en le glissant vers la droite.") +
        Text("\(Image(systemName: "arrowshape.right"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "flag.fill")
    }
}
