//
//  ExamDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 15/10/2022.
//

import SwiftUI

struct ExamDetail: View {
    @ObservedObject
    var exam: ExamEntity

    private var nameEditView: some View {
        HStack {
            Image(systemName: "doc.plaintext")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)

            // sujet
            TextField(
                "Sujet de l'évaluation",
                text: $exam.viewSujet
            )
            .font(.title2)
            .textFieldStyle(.roundedBorder)
        }
    }

    private var dateEditView: some View {
        DatePicker(
            "Date",
            selection: $exam.viewDateExecuted,
            displayedComponents: [.date, .hourAndMinute]
        )
        .environment(\.locale, Locale(identifier: "fr_FR"))
    }

    private var coefEditView: some View {
        Stepper(
            value: $exam.viewCoef,
            in: 0.0 ... 5.0,
            step: 0.25
        ) {
            HStack {
                Text("Coefficient")
                Spacer()
                Text("\(exam.viewCoef.formatted(.number.precision(.fractionLength(2))))")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var globalBaremeEditView: some View {
        Stepper(
            value: $exam.viewMaxMark,
            in: 1 ... 100,
            step: 1
        ) {
            HStack {
                Text("Barême")
                Spacer()
                Text("\(exam.viewMaxMark) points")
                    .foregroundColor(.secondary)
            }
        }
        .listRowSeparator(.hidden)
    }

    var body: some View {
        // nom
        nameEditView
            .listRowSeparator(.hidden)

        // date
        dateEditView
            .listRowSeparator(.hidden)

        // coefficient
        coefEditView

        // barême
        switch exam.examTypeEnum {
            case .global:
                globalBaremeEditView

            case .multiStep:
                StepsListView(exam: exam)
        }
    }
}

// struct ExamDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            List {
//                ExamDetail(exam: .constant(Exam.exemple))
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                ExamDetail(exam: .constant(Exam.exemple))
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
