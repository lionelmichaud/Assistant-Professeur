//
//  CalendarEventLoadingStatus.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import Foundation
import EventKit
import SwiftUI

enum LoadingStatus {
    case pending
    case loading
    case finished
    case failed

    var view: some View {
        Group {
            switch self {
                case .pending:
                    EmptyView()

                case .loading:
                    ProgressView(label: {
                        Text("Chargement à partir de l'application Calendrier")
                    })
                    .progressViewStyle(.automatic)

                case .finished:
                    Text("Chargement terminé")

                case .failed:
                    ContentUnavailableView(
                        "Echec de la recherche...",
                        systemImage: "calendar",
                        description: Text("L'accès à votre application **Calendrier** n'est pas autorisé.")
                    )
            }
        }
    }
}
