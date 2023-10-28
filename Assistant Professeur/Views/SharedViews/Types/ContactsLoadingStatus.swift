//
//  ContactsLoadingStatus.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/10/2023.
//

import Contacts
import HelpersView
import SwiftUI

enum ContactsLoadingStatus {
    case pending
    case loading
    case finished(contacts: [CNContact])
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

                case let .finished(contacts):
                    ForEach(contacts, id: \.identifier) { contact in
                        ContactView(contact: contact)
                    }
                    .emptyListPlaceHolder(contacts) {
                        ContentUnavailableView(
                            "Aucun contact trouvé dans votre appli **Contacts** pour cet établissement...",
                            systemImage: "person.crop.circle.badge.questionmark",
                            description: Text("Les contacts ajoutés dans votre appli **Contacts** pour cet établissement apparaîtront ici.")
                        )
                    }

                case .failed:
                    ContentUnavailableView(
                        "Echec de la recherche...",
                        systemImage: "person.crop.circle.badge.questionmark",
                        description: Text("L'accès à votre application **Contacts** n'est pas autorisé.")
                    )
            }
        }
    }
}
