//
//  RoomTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2023.
//

import SwiftUI
import TipKit

struct RoomCreateTip: Tip {
    var title: Text {
        Text("Créer un plan de salle de classe")
    }

    var message: Text? {
        Text("Créer une salle de classe en touchant \(Image(systemName: "plus.circle.fill")) ") +
        Text("puis éditer son plan en touchant le bouton **Plan**.")
    }

    var image: Image? {
        Image(systemName: RoomEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct RoomPlanEditTip: Tip {
    var title: Text {
        Text("Editer le plan de classe")
    }

    var message: Text? {
        Text("Positionner des chaises pour les élèves en utilisant le menu ci-dessus.")
    }

    var image: Image? {
        Image(systemName: RoomEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
