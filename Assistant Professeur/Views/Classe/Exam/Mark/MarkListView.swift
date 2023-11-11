//
//  MarkListView.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 15/10/2022.
//

import AppFoundation
import SwiftUI

/// Liste des notes éditables de chaque élève de la classe
struct MarkListView: View {
    @ObservedObject
    var exam: ExamEntity
    var searchString: String

    @EnvironmentObject
    private var userContext: UserContext

    @State
    private var isAddingGroupMark = false

    @State
    private var isShowingResetConfirmDialog = false

    // MARK: - Compute Properties

    var body: some View {
        Section {
            ForEach(
                exam.sortedMarksByEleveName(
                    searchString: searchString,
                    nameSortOrderEnum: userContext.prefs.nameSortOrderEnum
                )
            ) { mark in
                EleveMarkRow(mark: mark)
                    .listRowSeparatorTint(.secondary)
            }
        } header: {
            HStack {
                Text("Notes")
                Spacer()

                // Bouton reset de toutes les notes de la classe
                Button(role: .destructive) {
                    isShowingResetConfirmDialog = true
                } label: {
                    Image(systemName: "eraser.fill")
                }
                .buttonStyle(.borderedProminent)
                // Confirmation de Suppression de toutes vos données
                .confirmationDialog(
                    "Remettre toutes les notes à \"Non noté\" ?",
                    isPresented: $isShowingResetConfirmDialog,
                    titleVisibility: .visible
                ) {
                    Button("Poursuivre", role: .destructive) {
                        withAnimation {
                            self.resetAllMarks()
                        }
                    }
                } message: {
                    Text("Cette action ne peut pas être annulée.")
                }

                // Bouton affecter la même note à tous les membres d'un même groupe
                if let classe = exam.classe, classe.nbOfGroups > 1 {
                    Button {
                        isAddingGroupMark = true
                    } label: {
                        Image(systemName: "person.line.dotted.person.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $isAddingGroupMark) {
                        NavigationStack {
                            switch exam.examTypeEnum {
                                case .global:
                                    // Note globale
                                    GroupGlobalMarkModal(exam: exam)
                                        .presentationDetents([.medium])
                                case .multiStep:
                                    // Notes échelonnées
                                    GroupSteppedlMarkModal(exam: exam)
                                        .presentationDetents([.medium])
                            }
                        }
                    }
                }
            }
            .padding(.trailing)
        }
        .headerProminence(.increased)
    }

    // MARK: - Methods

    private func resetAllMarks() {
        withAnimation {
            exam.allMarks.forEach { mark in
                mark.markTypeEnum = .nonNote
            }
        }
    }
}

// struct MarkListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                MarkListView(classe       : TestEnvir.classeStore.items.first!,
//                             exam         : .constant(Exam.exemple),
//                             searchString : "")
//                .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                MarkListView(classe       : TestEnvir.classeStore.items.first!,
//                             exam         : .constant(Exam.exemple),
//                             searchString : "")
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
// }
