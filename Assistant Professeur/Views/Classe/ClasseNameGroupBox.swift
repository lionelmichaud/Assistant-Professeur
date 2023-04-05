//
//  ClasseNameGroupBox.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 09/10/2022.
//

import SwiftUI
import HelpersView

struct ClasseNameGroupBox: View {
    @ObservedObject
    var classe: ClasseEntity

    private var classeView: some View {
        HStack {
            ClasseAcronym(classe: classe)

            /// Flag de la classe
            Button {
                withAnimation {
                    classe.toggleFlag()
                }
            } label: {
                if classe.isFlagged {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "flag")
                        .foregroundColor(.orange)
                }
            }

            /// SEGPA ou pas
            if classe.school!.levelEnum == .college {
                Toggle(isOn: $classe.viewSegpa.animation()) {
                    Text("SEGPA")
                }
                .toggleStyle(.button)
                .controlSize(.small)
            }
        }
    }

    private var regularDisciplineView: some View {
        HStack {
            // Discipline enseignée
            CasePicker(pickedCase: $classe.disciplineEnum,
                       label: "Discipline")
            .pickerStyle(.menu)

            // Nombre d'heures d'enseignement pour cette classe
            AmountEditView(label: "Heures",
                           amount: $classe.viewHeures,
                           validity: .poz,
                           currency: false)
            .frame(maxWidth: 150)
        }
    }

    private var compactDisciplineView: some View {
        VStack {
            // Discipline enseignée
            CasePicker(pickedCase: $classe.disciplineEnum,
                       label: "Discipline")
            .pickerStyle(.menu)

            /// Nombre d'heures d'enseignement pour cette classe
            AmountEditView(label: "Heures",
                           amount: $classe.viewHeures,
                           validity: .poz,
                           currency: false)
            .frame(maxWidth: 150)
        }
    }

    var body: some View {
        GroupBox {
            ViewThatFits {
                HStack {
                    classeView

                    /// Nombre d'heures d'enseignement pour cette classe
                    regularDisciplineView
                }
                VStack {
                    classeView

                    /// Nombre d'heures d'enseignement pour cette classe
                    compactDisciplineView
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ClasseNameGroupBox_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseNameGroupBox(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseNameGroupBox(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
