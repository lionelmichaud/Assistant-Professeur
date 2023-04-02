//
//  EmptyListMessage.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/04/2023.
//

import SwiftUI

struct EmptyListMessage: View {
    var symbolName: String?
    var title: String
    var message: String?
    var showAsGroupBox: Bool = false

    private var contentView: some View {
        VStack(alignment: .center) {
            if let symbolName {
                Image(systemName: symbolName)
                    .imageScale(.large)
                    .padding(.bottom)
            }
            Text(title)
                .bold()
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
        }
    }

    var body: some View {
        if showAsGroupBox {
            GroupBox {
                contentView
            }
        } else {
            contentView
                .horizontallyAligned(.center)
                .verticallyAligned(.top)
        }
    }
}

struct EmptyListMessage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyListMessage(
                symbolName: "books.vertical",
                title: "Titre",
                message: "Un message",
                showAsGroupBox: false
            )
            EmptyListMessage(
                symbolName: "books.vertical",
                title: "Titre",
                message: "Un message",
                showAsGroupBox: true
            )
        }
    }
}
