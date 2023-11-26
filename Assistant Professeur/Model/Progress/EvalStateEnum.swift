//
//  EvalStatusEnum.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/11/2023.
//

import Foundation
import AppFoundation

enum EvalStateEnum: String, PickableIdentifiableEnumP, Codable {
    case toBeCorrected
    case beingCorrected
    case corrected
    case givenBack

    var id: String {
        rawValue
    }

    var pickerString: String {
        switch self {
            case .toBeCorrected:
                "A corriger"
            case .beingCorrected:
                "En cours"
            case .corrected:
                "Corrigée"
            case .givenBack:
                "Rendue"
        }
    }
}
