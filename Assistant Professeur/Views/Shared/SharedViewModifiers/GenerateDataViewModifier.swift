//
//  GenerateDataViewModifier.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/12/2023.
//

import SwiftUI

struct GenerateDataViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                DataBaseManager.populateWithMockData(storeType: .inMemory)
            }
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}

extension View {
    func generateData() -> some View {
        modifier(GenerateDataViewModifier())
    }
}
