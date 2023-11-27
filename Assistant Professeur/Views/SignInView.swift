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
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(Authentication.self)
    private var authentication

    @EnvironmentObject
    private var userContext: UserContext

    var body: some View {
        VStack {
            Text("Veuillez vous authentifier")
                .padding()

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
        }
    }
}

#Preview {
    SignInView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environment(Authentication())
}
