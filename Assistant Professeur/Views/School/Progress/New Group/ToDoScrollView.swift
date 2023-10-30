//
//  ToDoList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 29/10/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

/// Liste des choses à faire pour préparer les cours du mois à venir
/// dans un certain nombre d'exemplaires avant une certaine date
struct ToDoScrollView: View {
    let seances: [Seance]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ToBePrintedDisclosureGroup(seances: seances)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("A faire...")
        #endif
    }
}
