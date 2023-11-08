//
//  SignInView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/11/2023.
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var authentication: Authentication

    var body: some View {
        VStack {
            Text("Veuillez vous authentifier")
                .padding()

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                    case let .success(authResult):
                        print("Auth success. Result: \(authResult)")
                        // Post-authentication updates on persistence and/or states.
                        // authResult.credential
                        withAnimation {
                            authentication.checkAuthorization(
                                authorization:authResult
                            )
                        }

                    case let .failure(error):
                        print("Auth failed. Result: \(error.localizedDescription)")
                        // TODO: - Présenter une alerte
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
        .environmentObject(Authentication())
}
