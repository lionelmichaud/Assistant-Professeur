//
//  ClassNextSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import HelpersView
import SwiftUI

struct ClassNextSeancesView: View {
    @ObservedObject
    var classe: ClasseEntity

    // MARK: - Properties

    @State
    private var period: PeriodEnum = .nextWeek

    @State
    private var popOverIsPresented: Bool = false

    // MARK: - Subviews

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement dans votre")
            Text("application **Calendrier** doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("*Exemple*: pour la discipline de **\(classe.disciplineEnum.pickerString)**,")
            Text("et la classe de **\(classe.displayString)**:")
            Text("un événement contenant:\"**\(classe.disciplineEnum.acronym) - \(classe.displayString)**\"")
            Text("doit être créé dans le caldendrier nommé:")
            Text("\"**\(classe.school?.viewName ?? "")**\"")
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
            ClasseSeancesList(
                classe: classe,
                dateInterval: period.dateInterval
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

struct ClassNextSeances_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        let classe = ClasseEntity.all().first { classe in
            classe.levelEnum == .n5ieme
        }!
        print(classe)
        return Group {
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPad mini (6th generation)")
            ClassNextSeancesView(classe: classe)
                .previewDevice("iPhone 13")
        }
    }
}
