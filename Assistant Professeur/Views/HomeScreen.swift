//
//  HomeScreen.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/11/2023.
//

import AuthenticationServices
import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "HomeScreen"
)

struct HomeScreen: View {
    // MARK: - Netsed Types

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
                Text("Echec de la synchronisation.\nRelancez l'application plus tard.")
                    .font(.title2)
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif

        .task {
            // Vérifier si l'utilisateur est déjà autorisé.
            // Si oui, mettre à jour les context utilisateur
            // avec les liens vers le Owner et ses Préférences.
            await authentication.checkUserAppleIdCredentials(
                userContext: userContext
            )

            if userContext.isValid {
                userContextIsValid = true
            } else {
                // Attendre que iCloud ait synchronisé les données utilisateur
                // Pas plus de 8 minutes
                await waitForiCloudSync()
            }
        }
    }

    @MainActor
    func waitForiCloudSync() async {
        // Attendre que iCloud ait synchronisé les données utilisateur
        // Pas plus de 8 minutes
        let period = 15 // seconds
        let timeOutSeconds = 8 * 60 // seconds
        var counter = 0
        while !userContext.isValid {
            try? await Task.sleep(for: .seconds(period))
            if let userIdentifier = authentication.userCredentials?.userIdentifier,
               let owner = OwnerEntity.byUserIdentifier(userIdentifier: userIdentifier) {
                userContext.setOwner(to: owner)
            }
            counter += period
            if counter > timeOutSeconds {
                timeOut = true
                customLog.info(
                    ">> Time-out (\(Int(timeOutSeconds.double() / 60.0)) min) de synchronisation iCloud !"
                )
                break
            }
        }
        userContextIsValid = userContext.isValid
    }
}

#Preview {
    HomeScreen()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environment(Authentication())
}
