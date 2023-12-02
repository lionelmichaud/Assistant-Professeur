//
//  TrombineTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 01/12/2023.
//

import Foundation
import TipKit

struct AddElevePhotoTip: Tip {
    var title: Text {
        Text("Ajouter ou modifier la Photo d'un Élève")
    }
    var message: Text? {
        Text("Glisser une photo au format PNG ou JPEG sur la vignette d'un élève.")
    }
    var image: Image? {
        Image(systemName: "person.crop.square")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct ShowElevePhotoTip: Tip {
    var title: Text {
        Text("Afficher la Photo de l'Élève")
    }
    var message: Text? {
        Text("Taper sur \(Image(systemName: EleveEntity.defaultImageName)).")
    }
    var image: Image? {
        Image(systemName: "person.crop.square")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
