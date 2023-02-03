//
//  Mark.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 24/05/2022.
//

import HelpersView
import SwiftUI

struct MarkView: View {
    @ObservedObject
    var mark: MarkEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isEditing: Bool = false

    private var examType: ExamTypeEnum {
        mark.examTypeEnum
    }

    var regularMarkView: some View {
        HStack {
            switch examType {
                case .global:
                    AmountEditView(
                        label: mark.eleve!.displayName,
                        amount: $mark.viewMark,
                        validity: .within(range: 0.0 ... Double(mark.exam!.viewMaxMark)),
                        currency: false
                    )
                    if examType == .global {
                        Stepper(
                            "",
                            onIncrement: {
                                mark.viewMark = (mark.viewMark + 0.5)
                                    .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                            },
                            onDecrement: {
                                mark.viewMark = (mark.viewMark - 0.5)
                                    .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                            }
                        )
                        .frame(maxWidth: 100)
                    }

                case .multiStep:
                    LabeledContent(
                        mark.eleve!.displayName,
                        value: mark.viewMark,
                        format: .number.precision(.fractionLength(1))
                    )
                    Text(" points")
                        .foregroundColor(.secondary)
                        .padding(.trailing)
                    Button("Modifier") {
                        isEditing.toggle()
                    }
            }
        }
    }

    var compactMarkView: some View {
        HStack {
            switch examType {
                case .global:
                    AmountEditView(
                        label: "Note",
                        amount: $mark.viewMark,
                        validity: .within(range: 0.0 ... Double(mark.exam!.viewMaxMark)),
                        currency: false
                    )
                case .multiStep:
                    LabeledContent(
                        "Note",
                        value: mark.viewMark,
                        format: .number.precision(.fractionLength(1))
                    )
                    Text(" points")
                        .foregroundColor(.secondary)
                    Button {
                        isEditing.toggle()
                    } label: {
                        Text("Modifier")
                    }
            }
            if examType == .global {
                Stepper(
                    "",
                    onIncrement: {
                        mark.viewMark = (mark.viewMark + 0.5)
                            .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                    },
                    onDecrement: {
                        mark.viewMark = (mark.viewMark - 0.5)
                            .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                    }
                )
            }
        }
    }

    var body: some View {
        Group {
            switch mark.markTypeEnum {
                case .note:
                    if hClass == .compact {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "graduationcap")
                                CasePicker(
                                    pickedCase: $mark.markTypeEnum,
                                    label: mark.eleve!.displayName
                                )
                                .pickerStyle(.menu)
                            }

                            compactMarkView
                        }
                    } else {
                        HStack {
                            Image(systemName: "graduationcap")

                            regularMarkView

                            CasePicker(
                                pickedCase: $mark.markTypeEnum,
                                label: ""
                            )
                            .pickerStyle(.menu)
                            .frame(maxWidth: 120)
                        }
                    }

                default:
                    HStack {
                        Image(systemName: "graduationcap")
                        if let eleve = mark.eleve {
                            CasePicker(
                                pickedCase: $mark.markTypeEnum,
                                label: eleve.displayName
                            )
                            .pickerStyle(.menu)
                        }
                    }
            }
        }
        // Modal Sheet de modification des notes échelonnées
        .sheet(
            isPresented: $isEditing,
            onDismiss: MarkEntity.rollback
        ) {
            NavigationStack {
                SteppedlMarkModal(mark: mark)
            }
            .presentationDetents([.medium])
        }
    }
}
