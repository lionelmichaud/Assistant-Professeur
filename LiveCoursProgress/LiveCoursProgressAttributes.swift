//
//  LiveCoursProgressAttributes.swift
//  LiveCoursProgressExtension
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import ActivityKit
import WidgetKit
//import SwiftUI

struct LiveCoursProgressAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var remaingMinutes: Int
    }

    // Fixed non-changing properties about your activity go here!
    var classeName: String
}

