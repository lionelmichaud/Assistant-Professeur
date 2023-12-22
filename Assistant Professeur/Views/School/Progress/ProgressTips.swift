//
//  ProgressTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/12/2023.
//

import Foundation
import TipKit

struct NextSeancesTip: Tip {
    var title: Text {
        Text("Visualiser le contenu pédagogique de chaque cours")
    }

    var message: Text? {
        Text("Avec l'option **Progression pédagogique** ") +
            Text("vous pouvez voir, pour chaque cours, sont contenu pédagogique, ") +
            Text("**séquence & activité**, ainsi que les **documents pdf** nécessaires.")
    }

    var image: Image? {
        Image(systemName: ProgramEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct ToBePrintedTip: Tip {
    var title: Text {
        Text("Visualiser les documents à imprimer")
    }

    var message: Text? {
        Text("Avec l'option **Progression pédagogique** ") +
            Text("vous pouvez voir, pour les 4 semaines à venir, ") +
            Text("quels **documents pdf** restent à **imprimer**, ") +
            Text("en quelle **quantité**, avant quelle **date** et cocher la case **Fait**.")
    }

    var image: Image? {
        Image(systemName: DocumentEntity.forEleveImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(1)]
    }
}

struct ToBeLoadedTip: Tip {
    var title: Text {
        Text("Visualiser les documents à partager")
    }

    var message: Text? {
        Text("Avec l'option **Progression pédagogique** ") +
        Text("vous pouvez voir, pour les 4 semaines à venir, ") +
        Text("quels **documents pdf** restent à **partager** ") +
        Text("avec vos élèves, avant quelle **date** et cocher la case **Fait**.")
    }

    var image: Image? {
        Image(systemName: DocumentEntity.forEntImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(1)]
    }
}
