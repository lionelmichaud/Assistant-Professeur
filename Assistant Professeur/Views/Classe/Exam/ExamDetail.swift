//
//  ExamDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 15/10/2022.
//

import SwiftUI

struct ExamDetail : View {
    @ObservedObject
    var exam : ExamEntity

    private var name: some View {
        HStack {
            Image(systemName: "doc.plaintext")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)

            // sujet
            TextField("Sujet de l'évaluation",
                      text: $exam.viewSujet)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
        }
        .listRowSeparator(.hidden)
    }

    var body: some View {
        // nom
        name

        // date
        DatePicker("Date",
                   selection: $exam.viewDateExecuted,
                   displayedComponents: [.date, .hourAndMinute])
        .environment(\.locale, Locale.init(identifier: "fr_FR"))
        .listRowSeparator(.hidden)

        // barême
        Stepper(value : $exam.maxMark,
                in    : 1 ... 100,
                step  : 1) {
            HStack {
                Text("Barême")
                Spacer()
                Text("\(exam.maxMark) points")
                    .foregroundColor(.secondary)
            }
        }
                .listRowSeparator(.hidden)

        // coefficient
        Stepper(value : $exam.coef,
                in    : 0.0 ... 5.0,
                step  : 0.25) {
            HStack {
                Text("Coefficient")
                Spacer()
                Text("\(exam.coef.formatted(.number.precision(.fractionLength(2))))")
                    .foregroundColor(.secondary)
            }
        }
    }
}

//struct ExamDetail_Previews: PreviewProvider {
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
//}
