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

    @EnvironmentObject 
    private var authentication: Authentication

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
            await authentication.checkUserCredentials()
        }
    }
}

#Preview {
    HomeScreen()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(Authentication())
}
