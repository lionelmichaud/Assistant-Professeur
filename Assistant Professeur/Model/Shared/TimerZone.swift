//
//  TimerZone.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/10/2023.
//

import SwiftUI

enum TimerZone: Codable, CaseIterable {
    case normal, warning, alert, undefined
    var color: Color {
        switch self {
            case .normal: return .green
            case .warning: return .orange
            case .alert: return .red
            case .undefined: return .gray
        }
    }
}
