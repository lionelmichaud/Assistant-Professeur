//
//  LiveCoursProgressAttributes.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Dynamic content of the Live Activity

/// Represents the dynamic content of the Live Activity
struct LiveCoursProgressState: Codable, Equatable, Hashable {
    // MARK: - Type properties

    enum TimerZone: Codable {
        case normal, warning, alert
        var color: Color {
            switch self {
                case .normal: return .green
                case .warning: return .orange
                case .alert: return .red
            }
        }
    }

    static let defaultEndState =
    LiveCoursProgressState(
        elapsedTime: nil,
        remainingTime: nil, 
        timerZone: .alert
    )

    // MARK: - Properties

    var elapsedTime: DateComponents?
    var remainingTime: DateComponents?
    var cursorValue: Double?
    var timerZone: TimerZone
}

// MARK: - Fixed non-changing properties of the Live Activity

struct LiveCoursProgressFixedAttributes: Codable {
    let seance: DateInterval
    let classeName: String
    let warningRemainingMinutes: Int
    let alertRemainingMinutes: Int
}

// MARK: - Content that appears in your Live Activity

/// Describes the content that appears in your Live Activity.
/// Its inner type ContentState represents the dynamic content of the Live Activity.
struct LiveCoursProgressAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Dynamic stateful properties about your activity go here!
        var dynamicAttributes: LiveCoursProgressState
    }

    /// Fixed non-changing properties about your activity go here!
    var fixedAttributes: LiveCoursProgressFixedAttributes
}
