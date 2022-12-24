//
//  ClassCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/06/2022.
//

import SwiftUI
import HelpersView

struct ClassCreatorModal: View {
    let inSchool: SchoolEntity

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var classeVM = ClasseViewModel()

    @FocusState
    private var isHoursFocused: Bool

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var niveauView: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(classeVM.levelEnum.color)

            CasePicker(pickedCase: $classeVM.levelEnum,
                       label: "")
            .pickerStyle(.menu)
        }
    }

    var numeroView: some View {
        Picker("", selection: $classeVM.numero) {
            ForEach(1...10, id: \.self) { num in
                Text(String(num))
            }
        }
        .pickerStyle(.menu)
    }

    var segpaView: some View {
        Toggle(isOn: $classeVM.segpa.animation()) {
            Text("SEGPA")
        }
        .toggleStyle(.button)
        .controlSize(.small)
    }

    var disciplineView: some View {
        CasePicker(pickedCase: $classeVM.disciplineEnum,
                   label: "Discipline")
        .pickerStyle(.menu)
        .frame(width: 300)
    }

    var hoursView: some View {
        AmountEditView(
            label: "Nombre d'heures de cours par semaine",
            amount: $classeVM.heures,
            validity: .poz,
            currency: false
        )
        .submitLabel(.done)
        .focused($isHoursFocused)
        .frame(width: 300)

    }

    var body: some View {
        Form {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                HStack {
                    // niveau de cette classe
                    niveauView
                        .frame(width: 200)
                    //Spacer(minLength: 50)

                    // numéro de cette classe
                    numeroView
                        .frame(width: 80)

                    // SEGPA ou pas
                    segpaView
                        .layoutPriority(1)
                    Spacer()
                }

                // priorité 2
                VStack {
                    HStack {
                        // niveau de cette classe
                        niveauView
                            .frame(width: 200)

                        // numéro de cette classe
                        numeroView
                    }
                    // SEGPA ou pas
                    segpaView
                }
            }

            ViewThatFits(in: .horizontal) {
                // priorité 1
                HStack {
                    disciplineView
                    Spacer()
                    hoursView
                }

                // priorité 2
                VStack {
                    disciplineView
                    Spacer()
                    hoursView
                }
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: { },
            message: { Text(alertMessage) }
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter") {
                    /// Ajouter une nouvelle classe
                    if inSchool.exists(
                        classeLevel: classeVM.levelEnum,
                        classeNumero: classeVM.numero,
                        classeIsSegpa: classeVM.segpa
                    ) {
                        // doublon
                        alertTitle   = "Ajout impossible"
                        alertMessage = "Cette classe existe déjà dans cet établissement"
                        alertIsPresented.toggle()

                    } else if !isCompatible(
                        classeLevel: classeVM.levelEnum,
                        withSchool: inSchool
                    ) {
                        // niveau de classe incompatble avec l'école
                        alertTitle   = "Ajout impossible"
                        alertMessage = "Ce niveau de classe n'existe pas dans ce type d'établissement"
                        alertIsPresented.toggle()

                    } else {
                        // Ajouter la nouvelle classe
                        withAnimation {
                            classeVM.save(inSchool)
                        }
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Nouvelle Classe")
        #endif
        .onAppear {
            isHoursFocused = true
        }
    }

    private func isCompatible(
        classeLevel : LevelClasse,
        withSchool  : SchoolEntity
    ) -> Bool {
        switch classeLevel {
            case .n6ieme, .n5ieme, .n4ieme, .n3ieme:
                return withSchool.levelEnum == .college

            case .n2nd, .n1ere, .n0terminale:
                return withSchool.levelEnum == .lycee
        }
    }
}

//struct ClassCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ClassCreatorModal(inSchool: .constant(TestEnvir.schoolStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ClassCreatorModal(inSchool: .constant(TestEnvir.schoolStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
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
