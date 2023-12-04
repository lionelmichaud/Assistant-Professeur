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

    @State
    private var userContextIsValid = false

    @State
    private var timeOut = false

    var body: some View {
        let userIsAuthenticatedOrAuthorized =
            authentication.userIsAuthenticatedByApple ||
            authentication.isAuthorizedUser

        VStack {
            if !userIsAuthenticatedOrAuthorized {
                // User pas encore authentifié ou autorisé
                SignInView(showAlert: false)

            } else if userContextIsValid {
                // User authentifié ou autorisé ET
                // User context valide
                ContentView()

            } else if !timeOut {
                // User authentifié ou autorisé ET
                // User context NON valide
                // Timeout de synchronisation NON échu
                ProgressView(label: { Text("Synchronisation iCloud en cours...\nCela peut prendre plusieurs minutes.") })
                    .font(.title2)

            } else {
                // User authentifié ou autorisé ET
                // User context NON valide
                // Timeout de synchronisation échu
                Text("Erreur de synchronisation.\nEssayer plus tard.")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif

        .task {
            // Vérifier si l'utilisateur est déjà autorisé.
            // Si oui, mettre à jour les context utilisateur.
            await authentication.checkUserAppleIdCredentials(
                userContext: userContext
            )
            userContextIsValid = userContext.isValid

            // Attendre que iCloud ait synchronisé les données utilisateur
            let period = 15 // seconds
            var counter = 0
            while !userContext.isValid {
                try? await Task.sleep(for: .seconds(period))
                if let userIdentifier = authentication.userCredentials?.userIdentifier,
                   let owner = OwnerEntity.byUserIdentifier(userIdentifier: userIdentifier) {
                    userContext.setOwner(to: owner)
                }
                counter += period
                if counter > 5 * 60 {
                    timeOut = true
                    break
                }
            }
            userContextIsValid = userContext.isValid
        }
    }
}

#Preview {
    HomeScreen()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environment(Authentication())
}
