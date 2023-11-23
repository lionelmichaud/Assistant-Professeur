//
//  SchoolCurrentSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/10/2023.
//

import HelpersView
import SwiftUI

struct SchoolCurrentSeanceView: View {
    @ObservedObject
    var school: SchoolEntity

    // MARK: - Computed Properties

    /// Période de recherche
    private var fullDay: DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = 24.hours.from(startOfDay)!
        return DateInterval(
            start: startOfDay,
            end: endOfDay
        )
    }

    var body: some View {
        // Afficher le resultat de la recherche
        SchoolSeancesList(
            school: school,
            dateInterval: fullDay,
            showOnlyOngoingSeance: true, 
            showToDoListButton: false
        )
        .padding(.horizontal)
        .verticallyAligned(.top)
        #if os(iOS)
            .navigationTitle("Cours actuel")
        #endif
            .navigationBarTitleDisplayModeInline()
    }
}

// #Preview {
//    SchoolCurrentSeancesView()
// }
