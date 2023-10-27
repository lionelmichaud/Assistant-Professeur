//
//  SchoolCurrentSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 24/10/2023.
//

import SwiftUI
import HelpersView

struct SchoolCurrentSeanceView: View {
    @ObservedObject
    var school: SchoolEntity

    // MARK: - Properties
    @State
    private var popOverIsPresented: Bool = false

    // MARK: - Computed Properties

    /// Période de recherche
    private var dateInterval: DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = 24.hours.from(startOfDay)!
        return DateInterval(
            start: startOfDay,
            end: endOfDay
        )
    }

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("Exemple: pour la discipline de \(Discipline.technologie.pickerString),")
            Text("et la classe de 4ième 2: \"**TECHNO - 4E2)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

    var body: some View {
        // Afficher le resultat de la recherche
        SchoolSeancesList(
            school: school,
            dateInterval: dateInterval,
            showOnlyOngoingSeance: true
        )
        .padding(.horizontal)
        .verticallyAligned(.top)
        #if os(iOS)
        .navigationTitle("Cours actuel")
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                // Afficher le PopOver d'information sur le format à utiliser
                Button {
                    popOverIsPresented = true
                } label: {
                    Image(systemName: "info.bubble")
                }
                .popover(isPresented: $popOverIsPresented) {
                    infoView
                }
            }
        }
        .navigationBarTitleDisplayModeInline()
    }
}

// #Preview {
//    SchoolCurrentSeancesView()
// }
