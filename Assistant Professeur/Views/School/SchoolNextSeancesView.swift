//
//  SchoolNextSeancesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/07/2023.
//

import HelpersView
import SwiftUI

struct SchoolNextSeancesView: View {
    @ObservedObject
    var school: SchoolEntity

    // MARK: - Properties

    @State
    private var period: PeriodEnum = .nextWeek

    @State
    private var popOverIsPresented: Bool = false
    private let horizon = 3 // mois

    // MARK: - Computed Properties

    /// Période de recherche
    private var dateInterval: DateInterval {
        var endDate: Date?
        switch period {
            case .today: endDate = 1.days.from(Calendar.current.startOfDay(for: .now))
            case .nextWeek: endDate = 1.weeks.fromNow
            case .all: endDate = horizon.months.fromNow
        }
        return DateInterval(
            start: Date.now,
            end: endDate!
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
        VStack {
            // Sélecteur de période de recherche dans Calendrier
            CasePicker(
                pickedCase: $period,
                label: "Période"
            )
            .pickerStyle(.segmented)
            .padding(.vertical)

            // Afficher le resultat de la recherche
            SchoolSeancesList(
                school: school,
                dateInterval: dateInterval,
                showOnlyOngoingSeance: false
            )
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        #if os(iOS)
            .navigationTitle("Cours à venir")
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

// struct SchoolNextSeancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolNextSeancesView()
//    }
// }
