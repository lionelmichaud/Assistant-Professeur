//
//  ClassCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/06/2022.
//

import HelpersView
import SwiftUI

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

    var body: some View {
        Form {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                HStack {
                    // niveau de cette classe
                    niveauView
                        .frame(width: 200)

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
            actions: {},
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
                    // Ajouter une nouvelle classe
                    if inSchool.exists(
                        classeLevel: classeVM.levelEnum,
                        classeNumero: classeVM.numero,
                        classeIsSegpa: classeVM.segpa
                    ) {
                        // doublon
                        alertTitle = "Ajout impossible"
                        alertMessage = "Cette classe existe déjà dans cet établissement"
                        alertIsPresented.toggle()

                    } else if !isCompatible(
                        classeLevel: classeVM.levelEnum,
                        withSchool: inSchool
                    ) {
                        // niveau de classe incompatble avec l'école
                        alertTitle = "Ajout impossible"
                        alertMessage = "Ce niveau de classe n'existe pas dans ce type d'établissement"
                        alertIsPresented.toggle()

                    } else {
                        // Ajouter la nouvelle classe
                        withAnimation {
                            classeVM.createAndSaveEntity(inSchool)
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
        classeLevel: LevelClasse,
        withSchool: SchoolEntity
    ) -> Bool {
        switch classeLevel {
            case .n6ieme, .n5ieme, .n4ieme, .n3ieme:
                return withSchool.levelEnum == .college

            case .n2nd, .n1ere, .n0terminale:
                return withSchool.levelEnum == .lycee
        }
    }
}

// MARK: - Subviews

extension ClassCreatorModal {
    var niveauView: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(classeVM.levelEnum.color)

            CasePicker(
                pickedCase: $classeVM.levelEnum,
                label: ""
            )
            .pickerStyle(.menu)
        }
    }

    var numeroView: some View {
        Picker("", selection: $classeVM.numero) {
            ForEach(1 ... 10, id: \.self) { num in
                Text(String(num))
            }
        }
        .pickerStyle(.menu)
    }

    var segpaView: some View {
        Group {
            if inSchool.levelEnum == .college {
                Toggle(isOn: $classeVM.segpa.animation()) {
                    Text("SEGPA")
                }
                .toggleStyle(.button)
                .controlSize(.small)
            } else {
                EmptyView()
            }
        }
    }

    var disciplineView: some View {
        CasePicker(
            pickedCase: $classeVM.disciplineEnum,
            label: "Discipline"
        )
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
}

struct ClassCreator_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                ClassCreatorModal(inSchool: SchoolEntity.all().first!)
            }
            .previewDevice("iPad mini (6th generation)")
            NavigationStack {
                EmptyView()
                ClassCreatorModal(inSchool: SchoolEntity.all().first!)
            }
            .previewDevice("iPhone 13)")
        }
        .padding()
        .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
}
