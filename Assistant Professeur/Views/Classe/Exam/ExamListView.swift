//
//  ExamList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct ExamListView: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @State
    private var isAddingNewExam = false

    var body: some View {
        Group {
            // ajouter une évaluation
            Button {
                isAddingNewExam = true
            } label: {
                Label("Ajouter une évaluation", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
            .sheet(isPresented: $isAddingNewExam) {
                NavigationStack {
                    ExamCreatorModal(classe: classe)
                        .presentationDetents([.medium])
                }
            }

            // édition de la liste des examen
            ForEach(classe.examsSortedByDate) { exam in
                NavigationLink(value: ClasseNavigationRoute.exam(classe, exam)) {
                    ClasseExamRow(exam: exam)
                }
            }
            .onDelete(perform: deleteItems)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { classe.allExams[$0] }
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
