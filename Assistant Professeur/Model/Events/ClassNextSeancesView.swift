//
//  ClassNextSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/07/2023.
//

import EventKit
import HelpersView
import SwiftUI

struct ClassNextSeancesView: View {
    @ObservedObject
    var classe: ClasseEntity

    @ObservedObject
    private var pref = UserPrefEntity.shared

    private let horizon = 3 // mois
    // TODO: - A mettre en préférence

    @State
    private var classeSeances: SeancesInDateInterval = .init()

    @State
    private var popOverIsPresented: Bool = false

    @State
    private var eventStore = EKEventStore()

    @State
    private var calendar: EKCalendar?

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    private var infoView: some View {
        VStack {
            Text("Pour apparaître ici les noms des événements")
            Text("du calendrier de cet établissement doivent contenir:")
            Text("\"**Acronyme Discipline - Classe**\"\n")
            Text("Exemple: pour la discipline de \(classe.disciplineEnum.pickerString),")
            Text("et la classe de \(classe.displayString): \"**\(classe.disciplineEnum.acronym) - \(classe.displayString)**\"")
        }
        .foregroundColor(.primary)
        .padding()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(classeSeances.seances) { seance in
                SeanceRow(seance: seance)
            }
            .emptyListPlaceHolder(classeSeances.seances) {
                ContentUnavailableView(
                    "Aucun événement trouvé dans le calendrier de cet établissement pour cette classe...",
                    systemImage: "clock",
                    description: Text("Les événements plannifiés dans votre agenda pour cet établissement et cette classe apparaîtront ici.")
                )
            }
        }
        .padding(.horizontal)
        .verticallyAligned(.top)
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .task(id: classe.objectID) {
            // Suite des Séances à venir pour cette classe sur un `horizon`
            if let schoolName = classe.school?.viewName {
                // Demander les droits d'accès aux calendriers de l'utilisateur
                (
                    calendar,
                    alertIsPresented,
                    alertTitle,
                    alertMessage
                ) = await EventManager.shared
                    .requestCalendarAccess(
                        eventStore: eventStore,
                        calendarName: schoolName
                    )
                if let calendar {
                    let dateInterval = DateInterval(
                        start: Date.now,
                        end: horizon.months.fromNow!
                    )

                    // `SeancesInDateInterval` contenant la liste des Séances à venir
                    // pour une classe d'un établissement avec le contenu pédagogique de chaque séance.
                    classeSeances = await SeancesInDateInterval.loadedNextSeancesForClasse(
                        schoolName: schoolName,
                        classe: classe,
                        inCalendar: calendar,
                        inEventStore: eventStore,
                        inDateInterval: dateInterval
                    )
                }
            }
        }
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
