//
//  Mark.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 24/05/2022.
//

import HelpersView
import SwiftUI

struct EleveMarkRow: View {
    @ObservedObject
    var mark: MarkEntity

    @EnvironmentObject
    private var pref: UserPreferences

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var showTrombine = false

    @State
    private var selectedEleve: EleveEntity?

    @State
    private var isEditing: Bool = false

    private let imageSize: Image.Scale = .large

    // MARK: - Computed Properties

    private var examType: ExamTypeEnum {
        mark.examTypeEnum
    }

    var body: some View {
        Group {
            switch mark.markTypeEnum {
                case .note:
                    if hClass == .compact {
                        VStack(alignment: .leading) {
                            HStack {
                                trombineButton

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
                            trombineButton

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
                        if let eleve = mark.eleve {
                            trombineButton
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
                IndividualSteppedlMarkModal(mark: mark)
            }
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Subviews

extension EleveMarkRow {
    private var regularMarkView: some View {
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
                    .buttonStyle(.bordered)
            }
        }
    }

    private var compactMarkView: some View {
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
                    .buttonStyle(.bordered)
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

    private var trombineButton: some View {
        // Trombine
        Button {
            withAnimation {
                selectedEleve = mark.eleve
            }
        } label: {
            Image(systemName: EleveEntity.defaultImageName)
                .imageScale(imageSize)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(mark.eleve!.sexEnum.color)
        }
        .buttonStyle(.borderless)
        .disabled(!pref.eleve.trombineEnabled)
        .popover(item: $selectedEleve) { eleve in
            TrombineView(eleve: eleve)
                .scaledToFit()
                .frame(minWidth: 200, minHeight: 250)
        }
    }
}
