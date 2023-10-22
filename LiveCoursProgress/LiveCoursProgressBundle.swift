//
//  LiveCoursProgressBundle.swift
//  LiveCoursProgress
//
//  Created by Lionel MICHAUD on 08/10/2023.
//

import SwiftUI
import WidgetKit

@main
struct LiveCoursProgressBundle: WidgetBundle {
    var body: some Widget {
        // LiveCoursProgress()
        #if canImport(ActivityKit)
            LiveCoursProgressLiveActivity()
        #endif
    }
}
