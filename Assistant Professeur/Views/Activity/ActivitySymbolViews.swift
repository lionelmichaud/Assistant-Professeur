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
        Group {
            if activity.viewIsEvalSommative {
                Label(
                    "Éval Sommative ",
                    systemImage: ActivityEntity.evalSommativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
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
                    "Éval Formative ",
                    systemImage: ActivityEntity.evalFormativeSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
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
                    "TP ",
                    systemImage: ActivityEntity.tpSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
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
                    "Projet ",
                    systemImage: ActivityEntity.projectSymbol
                )
                .if(showTitle) {
                    $0.labelStyle(.titleAndIcon)
                } else: {
                    $0.labelStyle(.iconOnly)
                }
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
            ActivitySymbolEvalFormmative(
                activity: activity,
                showTitle: showTitle
            )
            ActivitySymbolEvalSommative(
                activity: activity,
                showTitle: showTitle
            )
        }
    }
}

// struct ActivitySymbolViews_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivitySymbolViews()
//    }
// }
