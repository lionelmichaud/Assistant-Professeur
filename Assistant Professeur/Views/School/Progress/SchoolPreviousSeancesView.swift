//
//  SchoolPreviousSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/10/2023.
//

import HelpersView
import SwiftUI

struct SchoolPreviousSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

    // MARK: - Computed Properties

    /// Période de recherche
    private var dayUpToNow: DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        return DateInterval(
            start: startOfDay,
            end: .now
        )
    }

    var body: some View {
        // Afficher le resultat de la recherche
        SchoolSeancesList(
            school: school,
            dateInterval: dayUpToNow,
            showOnlyOngoingSeance: false,
            showToDoListButton: false
        )
        .padding(.horizontal)
        .verticallyAligned(.top)
        #if os(iOS)
            .navigationTitle("Cours précédents")
        #endif
            .navigationBarTitleDisplayModeInline()
    }
}

// #Preview {
//    SchoolPreviousSeancesView()
// }
