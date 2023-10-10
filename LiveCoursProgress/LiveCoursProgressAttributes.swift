//
//  LiveCoursProgressAttributes.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import WidgetKit

// MARK: - Dynamic content of the Live Activity

/// Represents the dynamic content of the Live Activity
struct LiveCoursProgressState: Codable, Equatable, Hashable {
    // MARK: - Type properties

    static let defaultEndState = LiveCoursProgressState(remaingMinutes: 0)

    // MARK: - Properties

    var remaingMinutes: Int
}

// MARK: - Fixed non-changing properties of the Live Activity

struct LiveCoursProgressFixedAttributes: Codable {
    let classeName: String
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
