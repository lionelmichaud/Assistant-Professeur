//
//  ProgramTips.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/12/2023.
//

import Foundation
import TipKit

struct ProgramInfoTip: Tip {
    var title: Text {
        Text("Plus de Détails")
    }

    var message: Text? {
        Text("Taper ici pour afficher plus de détails sur la progression.")
    }

    var image: Image? {
        Image(systemName: "info.circle")
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}

struct ProgramPlanningTip: Tip {
    var title: Text {
        Text("Planning de la Progression")
    }

    var message: Text? {
        Text("Taper sur cette icône pour afficher le planning annuel de la progression.")
    }

    var image: Image? {
        ProgramTimeLine.ViewMode.planning.image
    }

    var options: [Option] {
        [Tips.MaxDisplayCount(5)]
    }
}
