//
//  EleveDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/04/2022.
//

import SwiftUI

struct EleveDetail: View {
    @ObservedObject
    var eleve: EleveEntity

    @EnvironmentObject
    private var navigationModel: NavigationModel

    /// true si le mode édition est engagé
    @State
    private var isEditing = false

    @State
    private var isAddingNewObserv = false

    @State
    private var isAddingNewColle = false

    @State
    private var bonusIsExpanded = false

    @EnvironmentObject
    private var pref: UserPrefEntity

    // MARK: - Computed properties

    private var filterObservation: Bool {
        navigationModel.filterObservation
    }

    private var filterColle: Bool {
        navigationModel.filterColle
    }

    private var bonusView: some View {
        Stepper(
            value: $eleve.viewBonus,
            in: -pref.viewElevePref.maxBonusMalus ... pref.viewElevePref.maxBonusMalus,
            step: pref.viewElevePref.maxBonusIncrement
        ) {
            HStack {
                Label(
                    eleve.bonus >= 0 ? "Bonus" : "Malus",
                    systemImage: "plusminus"
                )
                Spacer()
                Text("\(eleve.bonus.formatted(.number.precision(.fractionLength(2))))")
                    .foregroundColor(.secondary)
            }
        }
        .listRowSeparator(.hidden)
    }

    private var observationsView: some View {
        Section {
            Button {
                isAddingNewObserv = true
            } label: {
                Label("Ajouter une observation", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des observations
            ForEach(eleve.sortedObservations(
                isConsignee: filterObservation ? false : nil,
                isVerified: filterObservation ? false : nil
            )) { observ in
                EleveObservRow(observ: observ)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .warning
                        navigationModel.selectedWarningType = .observation
                        navigationModel.selectedObservMngObjId = observ.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // supprimer un élève
                        Button(role: .destructive) {
                            withAnimation {
                                try? observ.delete()
                                if navigationModel.selectedObservMngObjId == observ.objectID {
                                    navigationModel.selectedObservMngObjId = nil
                                }
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text("Observations (\(eleve.nbOfObservs))")
                .style(.sectionHeader)
        }
//        .headerProminence(.increased)
    }

    private var collesView: some View {
        Section {
            Button {
                isAddingNewColle = true
            } label: {
                Label("Ajouter une colle", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des colles
            ForEach(eleve.sortedColles(isConsignee: filterColle ? false : nil)) { colle in
                EleveColleRow(colle: colle)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab = .warning
                        navigationModel.selectedWarningType = .colle
                        navigationModel.selectedColleMngObjId = colle.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // supprimer un élève
                        Button(role: .destructive) {
                            withAnimation {
                                try? colle.delete()
                                if navigationModel.selectedColleMngObjId == colle.objectID {
                                    navigationModel.selectedColleMngObjId = nil
                                }
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text("Colles (\(eleve.nbOfColles))")
                .style(.sectionHeader)
        }
    }

    var body: some View {
        VStack {
            // nom
            EleveNameGroupBox(
                eleve: eleve,
                isEditing: isEditing
            )

            List {
                // appréciation sur l'élève
                if pref.viewElevePref.appreciationEnabled {
                    AppreciationView(appreciation: $eleve.viewAppreciation)
                }
                // annotation sur l'élève
                if pref.viewElevePref.annotationEnabled {
                    AnnotationEditView(annotation: $eleve.viewAnnotation)
                }
                // bonus/malus de l'élève
                if pref.viewElevePref.bonusEnabled {
                    bonusView
                }
                // observations sur l'élève
                observationsView
                // colles de l'élève
                collesView
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    // Appliquer les modifications faites à l'élève
                    if isEditing {
                        // supprimer les caractères blancs au début et à la fin
                        eleve.viewFamilyName = eleve.viewFamilyName.trimmed.uppercased()
                        eleve.viewGivenName.trim()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Ok" : "Modifier")
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Élève")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            bonusIsExpanded = (eleve.bonus != 0)
        }
        .sheet(isPresented: $isAddingNewObserv) {
            NavigationStack {
                ObservCreatorModal(eleve: eleve)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $isAddingNewColle) {
            NavigationStack {
                ColleCreatorModal(eleve: eleve)
                    .presentationDetents([.medium])
            }
        }
    }
}

 struct EleveDetail_Previews: PreviewProvider {
     static func initialize() {
         DataBaseManager.populateWithMockData(storeType: .inMemory)
     }

     static var previews: some View {
         initialize()
         return Group {
             EleveDetail(eleve: EleveEntity.all().first!)
                 .previewDevice("iPad mini (6th generation)")

             EleveDetail(eleve: EleveEntity.all().first!)
                 .previewDevice("iPhone 13")
         }
         .environmentObject(NavigationModel(selectedEleveMngObjId: EleveEntity.all().first!.objectID))
         .environment(\.managedObjectContext, CoreDataManager.shared.context)
     }
 }
