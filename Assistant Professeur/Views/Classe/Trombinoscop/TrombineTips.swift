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
        Text("Ajouter aisément une photo")
    }
    var message: Text? {
        Text("En glissant une photo au format PNG ou JPEG sur la vignette d'un élève.")
    }
    var image: Image? {
        Image(systemName: "person.crop.square")
    }
}

struct ShowElevePhotoTip: Tip {
    var title: Text {
        Text("Afficher la photo de l'élève")
    }
    var message: Text? {
        Text("En tapant sur \(Image(systemName: EleveEntity.defaultImageName)).")
    }
    var image: Image? {
        Image(systemName: "person.crop.square")
    }
}
