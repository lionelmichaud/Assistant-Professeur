//
//  CalendarSeancesLoadingStatus.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import SwiftUI

enum CalendarSeancesLoadingStatus {
    case pending
    case loading
    case finished(seancesInInterval: SeancesInDateInterval)
    case failed

    var view: some View {
        Group {
            switch self {
                case .pending:
                    EmptyView()

                case .loading:
                    ProgressView(label: {
                        Text("Chargement à partir de l'appliaction Calendrier")
                    })
                    .progressViewStyle(.automatic)

                case let .finished(seancesInInterval):
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(seancesInInterval.seances) { seance in
                            SeanceRow(seance: seance, showWatchButton: false)
                        }
                        .emptyListPlaceHolder(seancesInInterval.seances) {
                            ContentUnavailableView(
                                "Aucun cours trouvé dans votre agenda...",
                                systemImage: "clock",
                                description: Text("Les cours plannifiés dans votre agenda pour les classes de cet établissement apparaîtront ici.")
                            )
                        }
                    }

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
