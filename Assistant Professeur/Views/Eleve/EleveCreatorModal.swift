//
//  EleveCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 07/10/2022.
//

import SwiftUI
import HelpersView

struct EleveCreatorModal: View {
    let inClasse: ClasseEntity

    @Environment(\.dismiss)
    private var dismiss

    /// Focused filed manager
    enum FocusableField: Hashable {
        case givenName
        case familyName
        case none

        mutating func moveToNext() {
            switch self {
                case .givenName:
                    self = .familyName
                case .familyName:
                    self = .none
                case .none:
                    self = .none
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @StateObject
    private var eleveVM = EleveViewModel()

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        Form {
            HStack {
                Image(systemName: "graduationcap")
                    .sfSymbolStyling()
                    .foregroundColor(eleveVM.sexEnum.color)
                // Sexe de cet eleve
                CasePicker(pickedCase: $eleveVM.sexEnum, label: "Sexe")
                    .pickerStyle(.menu)
            }

            TextField("Prénom", text: $eleveVM.givenName)
                .onSubmit {
                    eleveVM.givenName.trim()
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focus, equals: .givenName)

            TextField("Nom", text: $eleveVM.familyName)
                .onSubmit {
                    eleveVM.familyName.trim()
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($focus, equals: .familyName)
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .alert(
            alertTitle,
            isPresented : $alertIsPresented,
            actions     : { },
            message     : { Text(alertMessage) }
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Ajouter") {
                    // supprimer les caracctères blancs au début et à la fin
                    eleveVM.familyName = eleveVM.familyName.trimmed.uppercased()
                    eleveVM.givenName.trim()

                    // Ajouter un nouvel élève à la classe
                    if eleveVM.familyName.isEmpty {
                        alertTitle   = "Ajout impossible"
                        alertMessage = "Le nom de famille est obligatoire."
                        focus = .familyName
                        alertIsPresented.toggle()

                    } else if eleveVM.givenName.isEmpty {
                        alertTitle   = "Ajout impossible"
                        alertMessage = "Le prénom est obligatoire."
                        focus = .givenName
                        alertIsPresented.toggle()

                    } else if EleveEntity.byName(
                        familyName: eleveVM.familyName,
                        givenName:eleveVM.givenName
                    ) != nil {
                        alertTitle   = "Ajout impossible"
                        alertMessage = "Cet élève existe déjà"
                        alertIsPresented.toggle()

                    } else {
                        withAnimation {
                            eleveVM.save(inClasse)
                        }
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Nouvel élève")
        #endif
        .onAppear {
            focus = .givenName
        }
    }
}

//struct EleveCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                EleveCreatorModal(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel())
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                EleveCreatorModal(classe: .constant(TestEnvir.classeStore.items.first!))
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
