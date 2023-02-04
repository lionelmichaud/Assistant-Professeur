//
//  ActivitySymbolViews.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/02/2023.
//

import SwiftUI

struct ActivitySymbolEvalSommative: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        if activity.viewIsEvalSommative {
            Group {
                Label(
                    "Éval Sommative",
                    systemImage: ActivityEntity.evalSommativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct ActivitySymbolEvalFormmative: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        if activity.viewIsEvalFormative {
            Group {
                Label(
                    "Éval Formative",
                    systemImage: ActivityEntity.evalFormativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct ActivitySymbolTP: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        if activity.viewIsTP {
            Group {
                Label(
                    "TP",
                    systemImage: ActivityEntity.tpSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct ActivitySymbolProject: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        if activity.viewIsProject {
            Group {
                Label(
                    "Projet",
                    systemImage: ActivityEntity.projectSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct ActivityAllSymbols: View {
    @ObservedObject
    var activity: ActivityEntity
    var showTitle: Bool

    var body: some View {
        HStack {
            ActivitySymbolProject(
                activity: activity,
                showTitle: showTitle
            )
            ActivitySymbolTP(
                activity: activity,
                showTitle: showTitle
            )
            .padding(.leading)
            ActivitySymbolEvalFormmative(
                activity: activity,
                showTitle: showTitle
            )
            .padding(.leading)
            ActivitySymbolEvalSommative(
                activity: activity,
                showTitle: showTitle
            )
            .padding(.leading)
        }
    }
}

// struct ActivitySymbolViews_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySymbolViews()
//    }
// }
