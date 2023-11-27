//
//  HomeScreen.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/11/2023.
//

import AuthenticationServices
import SwiftUI

struct HomeScreen: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(Authentication.self)
    private var authentication

    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        VStack {
            if authentication.isValidated || authentication.isAuthorizedUser {
                ContentView()
                #if os(macOS)
                    .frame(minWidth: 800, minHeight: 600)
                #endif

            } else {
                SignInView()
            }
        }
        .task {
            // Vérifier si l'utilisateur est déjà autorisé.
            // Si oui, mettre à jour les context utilisateur.
            await authentication.checkUserCredentials(
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
