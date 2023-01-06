//
//  ExamCreator.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 22/06/2022.
//

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
            TextField("Sujet de l'évaluation",
                      text: $examVM.sujet)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .focused($isSujetFocused)
        }
    }

    var body: some View {
        Form {
            // nom
            nameView

            // date
            DatePicker("Date", selection: $examVM.dateExecuted)
                .labelsHidden()
                .listRowSeparator(.hidden)
                .environment(\.locale, Locale.init(identifier: "fr_FR"))

            // barême
            Stepper(value : $examVM.maxMark,
                    in    : 1 ... 100,
                    step  : 1) {
                HStack {
                    Text("Barême")
                    Spacer()
                    Text("\(examVM.maxMark) points")
                        .foregroundColor(.secondary)
                }
            }

            // coefficient
            Stepper(value : $examVM.coef,
                    in    : 0.0 ... 5.0,
                    step  : 0.25) {
                HStack {
                    Text("Coefficient")
                    Spacer()
                    Text("\(examVM.coef.formatted(.number.precision(.fractionLength(2))))")
                        .foregroundColor(.secondary)
                }
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

//struct ExamCreator_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            EmptyView()
//            ExamCreator(elevesId: [UUID()],
//                        addNewItem: { _ in })
//        }
//    }
//}
