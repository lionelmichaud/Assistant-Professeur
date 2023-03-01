//
//  CompletionSymbol.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI
import StepperView

/// Symbol associé à un état d'avancement
struct CompletionSymbol: View {
    var status: ProgressState

    var body: some View {
        IndicatorImageView(
            name: status.imageName,
            size: 24
        )
    }
}

struct CompletionSymbol_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CompletionSymbol(status: .notStarted)
            CompletionSymbol(status: .inProgress)
            CompletionSymbol(status: .completed)
            CompletionSymbol(status: .invalid)
        }
    }
}
