//
//  ClassRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 21/04/2022.
//

import SwiftUI
import HelpersView

struct ClassBrowserRow: View {
    @ObservedObject
    var classe: ClasseEntity

    private var regularRow: some View {
        HStack {
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(classe.levelEnum.color)

            Text(classe.displayString)
                .fontWeight(.bold)
            if classe.isFlagged {
                Image(systemName: "flag.fill")
                    .imageScale(.small)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "flag.fill")
                    .imageScale(.small)
                    .foregroundColor(.orange)
                    .hidden()
            }

            Text("\(classe.nbOfEleves) élèves")
                .foregroundStyle(.secondary)
                .padding(.leading)

            Image(systemName: "clock")
                .padding(.leading)
            Text("\(classe.heures.formatted(.number.precision(.fractionLength(1)))) heures")
                .foregroundStyle(.secondary)
            Spacer()

            ClasseColleLabel(classe: classe, scale: .medium)
            ClasseObservLabel(classe: classe, scale: .medium)
        }
    }

    private var compactRow: some View {
        HStack {
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(classe.levelEnum.color)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(classe.displayString)
                        .fontWeight(.bold)
                    if classe.isFlagged {
                        Image(systemName: "flag.fill")
                            .imageScale(.small)
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    ClasseColleLabel(classe: classe, scale: .medium)
                    ClasseObservLabel(classe: classe, scale: .medium)
                }

                HStack {
                    Text("\(classe.nbOfEleves) élèves")
                    Spacer()
                    Text("\(classe.heures.formatted(.number.precision(.fractionLength(1)))) heures")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        ViewThatFits {
            regularRow
            compactRow
        }
    }
}

//struct ClassRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            List {
//                ClassBrowserRow(classe: TestEnvir.classeStore.items.first!)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.observStore)
//                    .environmentObject(TestEnvir.colleStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            List {
//                ClassBrowserRow(classe: TestEnvir.classeStore.items.first!)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.observStore)
//                    .environmentObject(TestEnvir.colleStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
//}
