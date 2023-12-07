//
//  ExamEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 13/05/2022.
//

import CoreData
import SwiftUI

struct ExamEditor: View {
    @ObservedObject
    var classe: ClasseEntity

    @ObservedObject
    var exam: ExamEntity

    @State
    private var searchString: String = ""

    var body: some View {
        List {
            if searchString.isEmpty {
                ExamDetail(exam: exam)
            }

            // notes
            MarkListView(
                exam: exam,
                searchString: searchString
            )
        }
        .searchable(
            text: $searchString,
//                        placement : .navigationBarDrawer(displayMode : .automatic),
            placement: .toolbar,
            prompt: "Nom, Prénom ou n° de groupe"
        )
        .autocorrectionDisabled()
        .toolbar(content: myToolBarContent)
//            .onChange(of: exam) { _ in
//                if let idx = classe.exams.firstIndex(where: { $0.id == examId }) {
//                    classe.exams[idx] = exam
//                }
//            }
        #if os(iOS)
        .navigationTitle("Évaluation")
        #endif
    }
}

// MARK: - Toolbar

extension ExamEditor {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            // Dupliquer l'exam pour toutes les classes de même niveau
            Button {
                // récupérer la liste des classes de même niveau
                let otherClassesOfSameLevel = ClasseEntity
                    .all()
                    .filter { otherClasse in
                        otherClasse.viewSegpa == classe.viewSegpa &&
                            otherClasse.levelEnum == classe.levelEnum &&
                            otherClasse.objectID != classe.objectID
                    }

                // dupliquer l'exam pour chacune des autres classes
                otherClassesOfSameLevel.forEach { classe in
                    switch exam.examTypeEnum {
                        case .global:
                            ExamEntity.createGlobalExam(
                                sujet: exam.viewSujet,
                                coef: exam.viewCoef,
                                maxMark: exam.viewMaxMark,
                                dateExecuted: exam.viewDateExecuted,
                                pour: classe
                            )
                        case .multiStep:
                            ExamEntity.createSteppedExam(
                                sujet: exam.viewSujet,
                                coef: exam.viewCoef,
                                examSteps: exam.viewSteps,
                                dateExecuted: exam.viewDateExecuted,
                                pour: classe
                            )
                    }
                }
            } label: {
                Label(
                    "Dupliquer pour toutes les classes de ce niveau",
                    systemImage: "doc.on.doc"
                )
            }
        }
    }
}

// struct ExamEditor_Previews: PreviewProvider {
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
// }
