//
//  HomeScreen.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/11/2023.
//

import AuthenticationServices
import SwiftUI

struct HomeScreen: View {
    // MARK: - Netsed Types

    enum OwnerLoadingStateEnum {
        case idle
        case loading
        case available
        case failed
    }

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(Authentication.self)
    private var authentication

    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        let userIsAuthenticatedOrAuthorized =
            authentication.userIsAuthenticatedByApple ||
            authentication.isAuthorizedUser

        VStack {
            if !userIsAuthenticatedOrAuthorized {
                // User pas encore authentifié ou autorisé
                SignInView(showAlert: false)

            } else if userContext.isValid {
                // User authentifié ou autorisé ET
                // User context valide
                ContentView()
                #if os(macOS)
                    .frame(minWidth: 800, minHeight: 600)
                #endif

            } else {
                // User authentifié ou autorisé ET
                // User context NON valide
                SignInView(showAlert: true)
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
            }
        }
        .task {
            // Vérifier si l'utilisateur est déjà autorisé.
            // Si oui, mettre à jour les context utilisateur.
            await authentication.checkUserAppleIdCredentials(
                userContext: userContext
            )
        }
    }
}

#Preview {
    HomeScreen()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environment(Authentication())
}
