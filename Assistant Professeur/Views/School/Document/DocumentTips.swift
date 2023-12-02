//
//  DocumentTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 01/12/2023.
//

import Foundation
import SwiftUI
import TipKit

struct AddDocumentTip: Tip {
    var title: Text {
        Text("Ajouter aisément un Document")
    }

    var message: Text? {
        Text("Ajouter un document en tapant sur le signe \(Image(systemName: "plus.circle.fill")) ou en glissant dessus un document PDF.")
    }

    var image: Image? {
        Image(systemName: DocumentEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct AddDocumentsTip: Tip {
    var title: Text {
        Text("Ajouter aisément des Documents")
    }

    var message: Text? {
        Text("Ajouter des documents en tapant sur le signe \(Image(systemName: "plus.circle.fill")) ou en glissant dessus un ou plusieurs documents PDF.")
    }

    var image: Image? {
        Image(systemName: DocumentEntity.defaultImageName)
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
