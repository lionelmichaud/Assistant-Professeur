//
//  ExamCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/06/2022.
//

import HelpersView
import SwiftUI

struct ExamCreatorModal: View {
    @ObservedObject
    var classe: ClasseEntity

    @StateObject
    private var examVM = ExamViewModel()

    @FocusState
    private var isSujetFocused: Bool

    @Environment(\.dismiss)
    private var dismiss

    private var nameView: some View {
        HStack {
            Image(systemName: "doc.plaintext")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)

            // sujet
            TextField(
                "Sujet de l'évaluation",
                text: $examVM.sujet
            )
            .font(.title2)
            .textFieldStyle(.roundedBorder)
            .focused($isSujetFocused)
        }
    }

    private var dateView: some View {
        DatePicker("Date", selection: $examVM.dateExecuted)
            .labelsHidden()
            .listRowSeparator(.hidden)
            .environment(\.locale, Locale(identifier: "fr_FR"))
    }

    private var baremeView: some View {
        Stepper(
            value: $examVM.maxMark,
            in: 1 ... 100,
            step: 1
        ) {
            HStack {
                Text("Barême")
                Spacer()
                Text("\(examVM.maxMark) points")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var coefView: some View {
        Stepper(
            value: $examVM.coef,
            in: 0.0 ... 5.0,
            step: 0.25
        ) {
            HStack {
                Text("Coefficient")
                Spacer()
                Text("\(examVM.coef.formatted(.number.precision(.fractionLength(2))))")
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        Form {
            // nom
            nameView

            // date
            dateView

            // coefficient
            coefView

            CasePicker(
                pickedCase: $examVM.examTypeEnum,
                label: "Type d'évaluation"
            )
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)

            // barême
            if examVM.examTypeEnum == .global {
                baremeView
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem {
                Button("Ok") {
                    // Ajouter le nouvel établissement
                    withAnimation {
                        examVM.createAndSaveEntity(inClass: classe)
                    }
                    dismiss()
                }
            }
        }
        #if os(iOS)
        .navigationTitle("Nouvelle Évaluation")
        #endif
        .onAppear {
            isSujetFocused = true
        }
    }
}

// struct ExamCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            EmptyView()
//            ExamCreator(elevesId: [UUID()],
//                        addNewItem: { _ in })
//        }
//    }
// }
