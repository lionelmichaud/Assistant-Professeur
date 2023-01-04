//
//  ExamEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 13/05/2022.
//

import SwiftUI
import CoreData

struct ExamEditor: View {
    @ObservedObject
    var classe : ClasseEntity

    @ObservedObject
    var exam : ExamEntity

    @State
    private var searchString: String = ""

    var body: some View {
        Group {
            List {
                if searchString.isEmpty {
                    ExamDetail(exam: exam)
                }
                // notes
//                MarkListView(classe       : classe,
//                             exam         : $exam,
//                             searchString : searchString)
            }
            .searchable(text      : $searchString,
                        placement : .navigationBarDrawer(displayMode : .automatic),
                        prompt    : "Nom, Prénom ou n° de groupe")
            .autocorrectionDisabled()
//            .onChange(of: exam) { _ in
//                if let idx = classe.exams.firstIndex(where: { $0.id == examId }) {
//                    classe.exams[idx] = exam
//                }
//            }
        }
        #if os(iOS)
        .navigationTitle("Évaluation")
        #endif
        .task {
//            if let exam = classe.exams.first(where: { $0.id == examId }) {
//                examFound = true
//                self.exam = exam
//            }
        }
    }
}

//struct ExamEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ExamEditor(classe: .constant(TestEnvir.classeStore.items.first!),
//                           examId: TestEnvir.classeStore.items.first!.exams.first?.id ?? UUID())
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ExamEditor(classe: .constant(TestEnvir.classeStore.items.first!),
//                           examId: TestEnvir.classeStore.items.first!.exams.first?.id ?? UUID())
//                .environmentObject(NavigationModel())
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
