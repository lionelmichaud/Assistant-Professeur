//
//  RestoreButton.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 16/12/2023.
//

import SwiftUI
import StoreKit

struct RestorePurchasesButton: View {
    @State private var isRestoring = false

    var body: some View {
        Button("Restaurer les achats") {
            isRestoring = true
            Task.detached {
                defer { isRestoring = false }
                try await AppStore.sync()
            }
        }
        .disabled(isRestoring)
    }

}

#Preview {
    RestorePurchasesButton()
}
