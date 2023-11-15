//
//  ComputingStatus.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/11/2023.
//

import SwiftUI

enum ComputingStatus {
    case pending
    case computing(message: String)
    case finished(message: String)
    case failed(message: String)

    var view: some View {
        Group {
            switch self {
                case .pending:
                    EmptyView()

                case let .computing(message):
                    ProgressView(label: {
                        Text(message)
                    })
                    .progressViewStyle(.automatic)

                case let .finished(message):
                    Text(message)

                case let .failed(message):
                    ContentUnavailableView(label: {
                        Label(message, systemImage: "exclamationmark.triangle")
                    })
            }
        }
    }
}
