//
//  DKnowTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/12/2023.
//

import Foundation
import TipKit

struct DKnowEditItemTip: Tip {
    var title: Text {
        Text("Modifier une Connaissance")
    }

    var message: Text? {
        Text("Glisser une Connaissance vers la droite.") +
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

struct WCompDisociationItemTip: Tip {
    var title: Text {
        Text("Dissocier d'une Connaissance Travaillée")
    }

    var message: Text? {
        Text("Glisser une Connaissance vers la gauche.") +
        Text("\(Image(systemName: "arrowshape.left"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "link")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct ActivityDisociationItemTip: Tip {
    var title: Text {
        Text("Dissocier d'une Activité")
    }

    var message: Text? {
        Text("Glisser une Activité vers la gauche.") +
        Text("\(Image(systemName: "arrowshape.left"))")
            .foregroundStyle(.primary)
    }

    var image: Image? {
        Image(systemName: "link")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
