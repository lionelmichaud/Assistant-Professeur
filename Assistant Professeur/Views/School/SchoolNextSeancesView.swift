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
    private var period: PeriodEnum = .today

    @State
    private var popOverIsPresented: Bool = false

    // MARK: - Subviews

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("Exemple: pour la discipline de \(Discipline.technologie.pickerString),")
            Text("et la classe de 4ième 2: \"**\(Discipline.technologie.pickerString) - 4E2)**\"")
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
                dateInterval: period.dateInterval,
                showOnlyOngoingSeance: false,
                showToDoListButton: true
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
