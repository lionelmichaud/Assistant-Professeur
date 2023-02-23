//
//  CompletionSymbol.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/02/2023.
//

import SwiftUI

/// Symbol associé à un état d'avancement
struct CompletionSymbol: View {
    var status: ProgressState

    var body: some View {
        switch status {
            case .inProgress:
                Image(systemName: "play.circle")
                    .symbolVariant(.circle)
                    .symbolRenderingMode(.palette)
                    //.foregroundStyle(.primary, .gray)
            case .completed:
                Image(systemName: "checkmark")
                    .symbolVariant(.circle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, .green)
            case .invalid:
                Image(systemName: "checkmark.circle.badge.xmark")
                    .symbolRenderingMode(.multicolor)

            case .notStarted:
                // Symbol caché (occupe de la place mais ne se voit pas)
                Image(systemName: "play.circle")
                    .symbolVariant(.circle)
                    .symbolRenderingMode(.palette)
                    .hidden()
        }
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
