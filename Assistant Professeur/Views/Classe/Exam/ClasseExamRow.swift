//
//  ClasseExamRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 12/05/2022.
//

import SwiftUI
import HelpersView

struct ClasseExamRow: View {
    @ObservedObject
    var exam: ExamEntity

    var body: some View {
        HStack {
            Image(systemName: "doc.plaintext")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 5) {
                Text(exam.viewSujet)
                HStack {
                    Text(exam.viewDateExecuted.stringLongDate)
                    Spacer()
                    Text("sur \(exam.maxMark) points")
                    Spacer()
                    Text("coef \(exam.coef.formatted(.number.precision(.fractionLength(2))))")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            //.fontWeight(.semibold)
        }
    }
}

//struct ClasseExamRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ClasseExamRow(exam: Exam(sujet: "Les automatismes en technologie"))
//    }
//}
