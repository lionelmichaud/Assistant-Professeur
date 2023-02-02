//
//  StepsValidationView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/02/2023.
//

import SwiftUI

struct StepsValidationView: View {
    @ObservedObject
    var exam: ExamEntity

    @State
    private var tog: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Étapes")
                .font(.headline)
            Text("Note totale: 10")
                .font(.body)
                .padding(.top, 8)
            List(exam.viewSteps) { step in
                HStack {
                    Image(systemName: "figure.stair.stepper")
                        .sfSymbolStyling()
                        .foregroundColor(.accentColor)
                    Toggle(isOn: $tog) {
                        Text(step.name)
                    }
                }
            }
        }
    }
}

// struct StepsValidationView_Previews: PreviewProvider {
//    static var previews: some View {
//        StepsValidationView()
//    }
// }
