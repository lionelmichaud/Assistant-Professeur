//
//  ActivitySymbolViews.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/02/2023.
//

import HelpersView
import SwiftUI

struct ActivitySymbolEvalSommative: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        Group {
            if activity.viewIsEvalSommative {
                Label(
                    "Éval Sommative",
                    systemImage: ActivityEntity.evalSommativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
                .filledCapsuleStyling(
                    withBackground: true,
                    withBorder: true,
                    fillColor: .activitySymbol
                )
            } else {
                EmptyView()
            }
        }
    }
}

struct ActivitySymbolEvalFormmative: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        Group {
            if activity.viewIsEvalFormative {
                Label(
                    "Éval Formative",
                    systemImage: ActivityEntity.evalFormativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
                .filledCapsuleStyling(
                    withBackground: true,
                    withBorder: true,
                    fillColor: .activitySymbol
                )
            } else {
                EmptyView()
            }
        }
    }
}

struct ActivitySymbolTP: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        Group {
            if activity.viewIsTP {
                Label(
                    "TP",
                    systemImage: ActivityEntity.tpSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
                .filledCapsuleStyling(
                    withBackground: true,
                    withBorder: true,
                    fillColor: .activitySymbol
                )
            } else {
                EmptyView()
            }
        }
    }
}

struct ActivitySymbolProject: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        Group {
            if activity.viewIsProject {
                Label(
                    "Projet",
                    systemImage: ActivityEntity.projectSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
                .filledCapsuleStyling(
                    withBackground: true,
                    withBorder: true,
                    fillColor: .activitySymbol
                )
            } else {
                EmptyView()
            }
        }
    }
}

struct ActivityAllSymbols: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool
    var axis: Axis = .horizontal

    var body: some View {
        if axis == .horizontal {
            HStack {
                ActivitySymbolProject(
                    activity: activity,
                    showTitle: showTitle
                )
                ActivitySymbolTP(
                    activity: activity,
                    showTitle: showTitle
                )
                ActivitySymbolEvalFormmative(
                    activity: activity,
                    showTitle: showTitle
                )
                ActivitySymbolEvalSommative(
                    activity: activity,
                    showTitle: showTitle
                )
            }
        } else {
            VStack {
                ActivitySymbolProject(
                    activity: activity,
                    showTitle: showTitle
                )
                .padding(activity.isProject ? 2 : 0)
                ActivitySymbolTP(
                    activity: activity,
                    showTitle: showTitle
                )
                .padding(activity.isTP ? 2 : 0)
                ActivitySymbolEvalFormmative(
                    activity: activity,
                    showTitle: showTitle
                )
                .padding(activity.isEvalFormative ? 2 : 0)
                ActivitySymbolEvalSommative(
                    activity: activity,
                    showTitle: showTitle
                )
            }
        }
    }
}

// struct ActivitySymbolViews_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySymbolViews()
//    }
// }
