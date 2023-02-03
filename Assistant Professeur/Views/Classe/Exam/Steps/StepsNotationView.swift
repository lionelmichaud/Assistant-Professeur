//
//  StepsValidationView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct StepsNotationView: View {
    
    // MARK: - Initializer

    init(
        exam: ExamEntity,
        width: Int,
        stepsMarks: Binding<[Double]>
    ) {
        self.exam = exam
        self.width = width
        self._stepsMarks = stepsMarks
    }

    // MARK: - Properties

    @ObservedObject
    private var exam: ExamEntity

    private let width: Int

    @Binding
    private var stepsMarks: [Double]

    private var noteTotale: Double {
        stepsMarks.sum()
    }

    var body: some View {
        VStack {
            HStack {
                Text("Étapes")
                Spacer()
                Text("Note totale: \(valueString(value: noteTotale))")
                    .padding(.top, 8)
                    .foregroundColor(.accentColor)
            }
            .font(.headline)
            .padding(.horizontal)

            List(exam.viewSteps.indices, id: \.self) { idx in
                HStack {
                    Text(exam.viewSteps[idx].name)
                        .frame(width: CGFloat(width), alignment: .leading)
                    Slider(
                        value: $stepsMarks[idx],
                        in: 0 ... exam.viewSteps[idx].points.double(),
                        step: 0.5
                    ) {
                        Text("Label")
                    } minimumValueLabel: {
                        Text("")
                    } maximumValueLabel: {
                        Text("\(valueString(value: stepsMarks[idx]))").foregroundColor(.accentColor) +
                            Text(" / \(maxValue(value: Double(exam.viewSteps[idx].points)))")
                    } onEditingChanged: { _ in
                    }
                }
            }
        }
    }

    // MARK: - Methods

    private func maxValue(value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }

    private func valueString(value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

// struct StepsValidationView_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsValidationView()
//    }
// }
