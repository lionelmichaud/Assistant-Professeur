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
    private var navigationModel : NavigationModel

    // true si le mode édition est engagé
    @State
    private var isEditing = false

    @State
    private var isAddingNewObserv = false

    @State
    private var isAddingNewColle  = false

    @State
    private var bonusIsExpanded = false

    @Preference(\.eleveAppreciationEnabled)
    private var eleveAppreciationEnabled

    @Preference(\.eleveAnnotationEnabled)
    private var eleveAnnotationEnabled

    @Preference(\.eleveBonusEnabled)
    private var eleveBonusEnabled

    @Preference(\.maxBonusMalus)
    private var maxBonusMalus

    @Preference(\.maxBonusIncrement)
    private var maxBonusIncrement

    @Preference(\.eleveTrombineEnabled)
    private var eleveTrombineEnabled

    // MARK: - Computed properties

    private var filterObservation : Bool {
        navigationModel.filterObservation
    }
    private var filterColle : Bool {
        navigationModel.filterColle
    }

    private var bonusView: some View {
        Stepper(value : $eleve.viewBonus,
                in    : -maxBonusMalus ... maxBonusMalus,
                step  : maxBonusIncrement) {
            HStack {
                Label(eleve.bonus >= 0 ? "Bonus" : "Malus",
                      systemImage: "plusminus")
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
            ForEach(eleve.sortedObservations(isConsignee: filterObservation ? false : nil,
                                             isVerified: filterObservation ? false : nil)) { observ in
                EleveObservRow(observ: observ)

                    .onTapGesture {
                        // Programatic Navigation
                        navigationModel.selectedTab      = .observation
                        navigationModel.selectedObservId = observ.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // supprimer un élève
                        Button(role: .destructive) {
                            withAnimation {
                                try? observ.delete()
                                if navigationModel.selectedObservId == observ.objectID {
                                    navigationModel.selectedObservId = nil
                                }
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text("Observations (\(eleve.nbOfObservs))")
                .font(.headline)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
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
                        navigationModel.selectedTab     = .colle
                        navigationModel.selectedColleId = colle.objectID
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // supprimer un élève
                        Button(role: .destructive) {
                            withAnimation {
                                try? colle.delete()
                                if navigationModel.selectedColleId == colle.objectID {
                                    navigationModel.selectedColleId = nil
                                }
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text("Colles (\(eleve.nbOfColles))")
                .font(.headline)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
    }

    var body: some View {
        VStack {
            /// nom
            EleveNameGroupBox(eleve    : eleve,
                              isEditing: isEditing)

            List {
                /// appréciation sur l'élève
                if eleveAppreciationEnabled {
                    AppreciationView(appreciation: $eleve.viewAppreciation)
                }
                /// annotation sur l'élève
                if eleveAnnotationEnabled {
                    AnnotationView(annotation: $eleve.viewAnnotation)
                }
                /// bonus/malus de l'élève
                if eleveBonusEnabled {
                    bonusView
                }
                /// observations sur l'élève
                observationsView
                /// colles de l'élève
                collesView
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddingNewColle) {
            NavigationStack {
                ColleCreatorModal(eleve: eleve)
            }
            .presentationDetents([.medium])
        }
    }
}

//struct EleveDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                EleveDetail(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                EleveDetail(eleve: .constant(TestEnvir.eleveStore.items.first!))
//                    .environmentObject(NavigationModel(selectedEleveId: TestEnvir.eleveStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
