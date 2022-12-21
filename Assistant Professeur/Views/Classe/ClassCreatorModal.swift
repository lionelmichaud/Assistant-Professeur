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

    @Environment(\.dismiss)
    private var dismiss

    var niveau: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(classeVM.levelEnum.color)

            CasePicker(pickedCase: $classeVM.levelEnum,
                       label: "Niveau")
            .pickerStyle(.menu)
        }
    }

    var numero: some View {
        Picker("Numéro", selection: $classeVM.numero) {
            ForEach(1...10, id: \.self) { num in
                Text(String(num))
            }
        }
        .pickerStyle(.menu)
    }

    var segpa: some View {
        Toggle(isOn: $classeVM.segpa.animation()) {
            Text("SEGPA")
                .font(.caption)
        }
        .toggleStyle(.button)
        .controlSize(.large)
    }

    var body: some View {
        Form {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                HStack {
                    // niveau de cette classe
                    niveau
                    Spacer(minLength: 50)

                    // numéro de cette classe
                    numero
                    Spacer(minLength: 50)
                        //.frame(maxWidth: 140)

                    // SEGPA ou pas
                    segpa
                }
                // priorité 2
                VStack {
                    // niveau de cette classe
                    niveau

                    // numéro de cette classe
                    numero

                    // SEGPA ou pas
                    segpa
                }
            }
            AmountEditView(
                label: "Nombre d'heures de cours par semaine",
                amount: $classeVM.heures,
                validity: .poz,
                currency: false
            )
            .submitLabel(.done)
            .focused($isHoursFocused)
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
            ToolbarItem {
                Button("Ok") {
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
