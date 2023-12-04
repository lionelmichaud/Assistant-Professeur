//
//  SignInView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/11/2023.
//

import AuthenticationServices
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SignInView"
)

struct SignInView: View {
    let showAlert: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(Authentication.self)
    private var authentication

    @Environment(UserContext.self)
    private var userContext

    var body: some View {
        VStack {
            Text("Veuillez vous authentifier")
                .padding()
                .font(.title2)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                    case let .success(authResult):
                        customLog.log(level: .info, "Auth success. Result: \(authResult)")

                        // Post-authentication updates on persistence and/or states.
                        //   Check if the User is authoriezd after sign-in.
                        //   Si oui, mettre à jour les context utilisateur avec le Owner.
                        withAnimation {
                            authentication.checkAuthorization(
                                authorization: authResult,
                                userContext: userContext
                            )
                        }

                    case let .failure(error):
                        customLog.log(level: .info, "Auth failed. Result: \(error.localizedDescription)")
                        // Handle auth failures
                }
            }
            .frame(width: 280, height: 40, alignment: .center)
            .signInWithAppleButtonStyle(colorScheme == .light ? .whiteOutline : .white)

            if showAlert {
                VStack {
                    Image(systemName: "hourglass")
                        .font(.largeTitle)
                        .padding(.top)
                    Text("Attendre que les données iCloud soient synchronisées.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding(.top)
                    Text("Essayer dans une minute.")
                        .foregroundStyle(.red)
                        .padding(.top)
                }
                .font(.title2)
                .padding()

            }
        }
    }
}

#Preview {
    SignInView(showAlert: true)
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environment(Authentication())
}
