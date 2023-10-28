//
//  ErrorAlertModifier.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/10/2023.
//

import SwiftUI

extension View {
    /// Somme de tous les éléméents d'un Array
    ///
    /// In this example, I’m using an ArticleView that allows us to publish an article.
    /// Publishing can result in an error, which we want to present in an alert accordingly:
    ///
    ///     struct ArticleView: View {
    ///         @StateObject var viewModel = ArticleViewModel()
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 TextField(text: $viewModel.title, prompt: Text("Article title")) {
    ///                     Text("Title")
    ///                 }
    ///                 Button {
    ///                     viewModel.publish()
    ///                 } label: {
    ///                     Text("Publish")
    ///                 }
    ///             }.errorAlert(error: $viewModel.error)
    ///         }
    ///     }
    ///
    /// L'erreur est conforme au protocole `LocalizedError` et ainsi définie:
    ///
    ///     enum Error: LocalizedError {
    ///         case titleEmpty
    ///
    ///         var errorDescription: String? {
    ///             switch self {
    ///             case .titleEmpty:
    ///                 return "Missing title"
    ///             }
    ///         }
    ///
    ///         var recoverySuggestion: String? {
    ///             switch self {
    ///             case .titleEmpty:
    ///                 return "Article publishing failed due to missing title"
    ///             }
    ///         }
    ///     }
    ///
    ///    @Published var error: Swift.Error?
    ///
    /// - Note: [Error alert presenting in SwiftUI simplified](https://www.avanderlee.com/swiftui/error-alert-presenting/)
    func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK"
    ) -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(
            isPresented: .constant(localizedAlertError != nil),
            error: localizedAlertError,
            actions: { _ in
                Button(buttonTitle) {
                    error.wrappedValue = nil
                }
            },
            message: { error in
                let failureReason = error.failureReason ?? "Raison inconnue."
                let recoverySuggestion = error.recoverySuggestion ?? ""
                let message = "\n" + failureReason + (recoverySuggestion == "" ? "" : "\n\n\(recoverySuggestion)")
                Text(message)
            }
        )
    }

    func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK",
        actions: @escaping (LocalizedError) -> Void
    ) -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(
            isPresented: .constant(localizedAlertError != nil),
            error: localizedAlertError,
            actions: { _ in
                Button(buttonTitle) {
                    if let localizedAlertError {
                        actions(localizedAlertError)
                    }
                    error.wrappedValue = nil
                }
            },
            message: { error in
                let failureReason = error.failureReason ?? "Raison inconnue."
                let recoverySuggestion = error.recoverySuggestion ?? ""
                let message = "\n" + failureReason + (recoverySuggestion == "" ? "" : "\n\n\(recoverySuggestion)")
                Text(message)
            }
        )
    }

    func errorAlert<A>(
        error: Binding<Error?>,
        @ViewBuilder actions: (LocalizedError) -> A
    ) -> some View where A: View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(
            isPresented: .constant(localizedAlertError != nil),
            error: localizedAlertError,
            actions: { error in
                actions(error)
            },
            message: { error in
                let failureReason = error.failureReason ?? "Raison inconnue."
                let recoverySuggestion = error.recoverySuggestion ?? ""
                let message = "\n" + failureReason + (recoverySuggestion == "" ? "" : "\n\n\(recoverySuggestion)")
                Text(message)
            }
        )
    }
}

/// This structure works as a facade.
///
/// We can return nil by using an optional initializer, allowing us not to present an alert if the thrown error isn’t localized.
///
/// - Note: [Error alert presenting in SwiftUI simplified](https://www.avanderlee.com/swiftui/error-alert-presenting/)
struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var failureReason: String? {
        underlyingError.failureReason
    }

    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else {
            return nil
        }
        underlyingError = localizedError
    }
}
