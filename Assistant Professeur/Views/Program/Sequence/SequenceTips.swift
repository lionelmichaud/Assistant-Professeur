//
//  SequenceTip.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/12/2023.
//

import Foundation
import TipKit

struct SequenceInfoTip: Tip {
    var title: Text {
        Text("Plus de Détails")
    }

    var message: Text? {
        Text("Taper ici pour afficher plus de détails sur la séquence.")
    }

    var image: Image? {
        Image(systemName: "info.circle")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct SequencePresentationTip: Tip {
    var title: Text {
        Text("Document présentant la Séquence")
    }

    var message: Text? {
        Text("Taper sur cette icône pour afficher le document de présentation de la séquence.")
    }

    var image: Image? {
        SequenceTimeLine.ViewMode.presentationSheet.image
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
