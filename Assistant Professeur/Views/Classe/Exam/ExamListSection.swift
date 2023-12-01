//
//  ExamList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct ExamListSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @State
    private var isAddingNewExam = false

    var body: some View {
        Section {
            // ajouter une évaluation
            Button {
                isAddingNewExam = true
            } label: {
                Label("Ajouter une évaluation", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
            .customizedListItemStyle(
                isSelected: false
            )
            .sheet(isPresented: $isAddingNewExam) {
                NavigationStack {
                    ExamCreatorModal(classe: classe)
                        .presentationDetents([.medium])
                }
            }

            // édition de la liste des examen
            ForEach(classe.examsSortedByDate) { exam in
                NavigationLink(value: ClasseNavigationRoute.exam(classe.id, exam.id)) {
                    ClasseExamRow(exam: exam)
                }
                .customizedListItemStyle(
                    isSelected: false
                )
            }
            .onDelete(perform: deleteItems)
        } header: {
            Text("Evaluations (\(classe.nbOfExams))")
                .style(.sectionHeader)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { classe.examsSortedByDate[$0] }
                .forEach(managedObjectContext.delete)

            try? ExamEntity.saveIfContextHasChanged()
        }
    }
}

// struct ExamList_Previews: PreviewProvider {
//    static var previews: some View {
//        ExamList()
//    }
// }
