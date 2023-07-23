//
//  ClassProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/02/2023.
//

import SwiftUI

struct ActivityClassProgressView: View {
    @ObservedObject
    var progress: ActivityProgressEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    private var isPrintedCheckBox: some View {
        // checkbox isPrinted
        Button {
            progress.toggleIsPrinted()
        } label: {
            Label(
                title: {
                    Text("Support de cours imprimés")
                }, icon: {
                    Image(systemName: progress.isPrinted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(progress.isPrinted ? .green : .gray)
                }
            )
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        LabeledContent {
            VStack(alignment: .leading) {
                ActivityProgressSlider(
                    progress: progress,
                    progressChanged: .constant(false)
                )

                TextField(
                    "",
                    text: $progress.annotation.bound,
                    prompt: Text("description"),
                    axis: .vertical
                )
                .onSubmit {
                    try? ActivityProgressEntity.saveIfContextHasChanged()
                }
                .multilineTextAlignment(.leading)
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)

                isPrintedCheckBox
            }
        } label: {
            Button {
                navig.selectedTab = .classe
                navig.selectedClasseMngObjId = progress.classe?.objectID
//                navig.classPath.append(ClasseNavigationRoute.progress(progress.classe!))
            } label: {
                Text(progress.classe?.displayString ?? "nil")
                    .bold()
                    .padding(4)
//                    .background {
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.primary)
//                            .foregroundColor(.gray)
//                    }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// struct ClassProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassProgressView()
//    }
// }
