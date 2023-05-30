//
//  InfoPersoView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/05/2023.
//

import HelpersView
import SwiftUI

/// Infos perso de l'utilisateur de l'app
struct InfoPersoView: View {
    /// Initilisation des infos perso de l'utilisateur de l'app
    /// - Parameter cloudKitVM: Données  utilisateur fournies par CloudKit
    init(cloudKitVM: CloudKitViewModel) {
        // Créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore.
        OwnerEntity.initializeEntity(userName: cloudKitVM.userName)
        self._owner = StateObject(wrappedValue: OwnerEntity.all().first!)
    }

    @StateObject
    private var owner: OwnerEntity // = {
    // Créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore.
//        OwnerEntity.initializeEntity(userName: cloudKitVM.userName)
//        return OwnerEntity.all().first!
//    }()

    var body: some View {
        GroupBox {
            TextField("Votre nom", text: $owner.viewFamilyName)
            #if os(iOS) || os(tvOS)
                .autocapitalization(.allCharacters)
            #endif

            TextField("Votre prénom", text: $owner.viewGivenName)
            #if os(iOS) || os(tvOS)
                .autocapitalization(.words)
            #endif

            HStack {
                Text("NUMEN")
                TextField("Votre NUMEN", text: $owner.viewNumen)
                #if os(iOS) || os(tvOS)
                    .autocapitalization(.allCharacters)
                #endif
            }

            EmailEditView(
                title: "Mail académique",
                adress: $owner.viewEmailAdressAcademy,
                webmailURL: $owner.urlMailAcademy,
                id: $owner.viewIdMailAcademy,
                pwd: $owner.viewPwdMailAcademy
            )

            AnnotationEditView(annotation: $owner.viewAnnotation)
                .padding(.top)

        } label: {
            Text("Infos personnelles")
                .textCase(.uppercase)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue4))
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .padding()
        .verticallyAligned(.top)
    }
}

// struct InfoPersoView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            InfoPersoView()
//                .previewDevice("iPad mini (6th generation)")
//            InfoPersoView()
//                .previewDevice("iPhone 13")
//        }
//    }
// }
