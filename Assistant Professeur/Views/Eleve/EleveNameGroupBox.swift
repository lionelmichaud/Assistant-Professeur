//
//  EleveNameGroupBox.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 09/10/2022.
//

import SwiftUI
import HelpersView

struct EleveNameGroupBox: View {
    @ObservedObject
    var eleve: EleveEntity

    var isEditing: Bool

    @Preference(\.nameDisplayOrder)
    private var nameDisplayOrder

    // MARK: - Computed Properties

    private var sexEditView: some View {
        HStack {
//            Image(systemName: "graduationcap")
//                .sfSymbolStyling()
//                .foregroundColor(eleve.sexEnum.color)
            // Sexe de cet eleve
            CasePicker(pickedCase: $eleve.sexEnum, label: "Sexe")
                .pickerStyle(.menu)
        }
    }
    private var prenomEditView: some View {
        TextField("Prénom", text: $eleve.viewGivenName)
            .onSubmit {
                eleve.viewGivenName.trim()
            }
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
    }
    private var nomEditView: some View {
        TextField("Nom", text: $eleve.viewFamilyName)
            .onSubmit {
                eleve.viewFamilyName.trim()
            }
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
    }

    var body: some View {
        GroupBox {
            if isEditing {
                // mode édition des sex, prénom, nom
                ViewThatFits(in: .horizontal) {
                    // priorité 1
                    HStack {
                        sexEditView
                        if nameDisplayOrder == .nomPrenom {
                            nomEditView
                            prenomEditView
                        } else {
                            prenomEditView
                            nomEditView
                        }
                    }
                    // priorité 2
                    VStack {
                        sexEditView
                        if nameDisplayOrder == .nomPrenom {
                            nomEditView
                            prenomEditView
                        } else {
                            prenomEditView
                            nomEditView
                        }
                    }
                }

            } else {
                EleveLabelWithTrombineFlag(eleve: eleve)
            }
        }
    }
}

//struct EleveNameGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//                EleveNameGroupBox(eleve: .constant(TestEnvir.eleveStore.items.first!),
//                                  isEditing: true)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDisplayName("Editable")
//                .previewDevice("iPhone 13")
//
//                EleveNameGroupBox(eleve: .constant(TestEnvir.eleveStore.items.first!),
//                                  isEditing: false)
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDisplayName("Non Editable")
//                .previewDevice("iPhone 13")
//        }
//    }
//}
