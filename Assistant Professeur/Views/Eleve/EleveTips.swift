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
        Text("Ajouter un Élève à cette Classe")
    }

    var message: Text? {
        Text("En tapant ici ") +
        Text("\(Image(systemName: "plus.circle.fill"))")
            .foregroundStyle(.blue)
    }

    var image: Image? {
        Image(systemName: EleveEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct ActionsEleveTip: Tip {
    var title: Text {
        Text("Accéder à plus d'Options")
    }

    var message: Text? {
        Text("Sélectionner un ou plusieurs élèves pour avoir accès à des options complémentaires.")
    }

    var image: Image? {
        Image(systemName: EleveEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct FlagEleveItemTip: Tip {
    var title: Text {
        Text("Marquer un Élève")
    }

    var message: Text? {
        Text("Marquer un élève d'un drapeau en le glissant vers la droite.") +
        Text("\(Image(systemName: "arrowshape.right"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "flag.fill")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
