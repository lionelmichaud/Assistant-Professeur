//
//  Mark.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 24/05/2022.
//

import SwiftUI
import HelpersView

struct MarkView: View {
    @ObservedObject
    var mark: MarkEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        Group {
            switch mark.markTypeEnum {
                case .note:
                    if hClass == .compact {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "graduationcap")
                                CasePicker(pickedCase : $mark.markTypeEnum,
                                           label      : mark.eleve!.displayName)
                                .pickerStyle(.menu)
                            }

                            HStack {
                                AmountEditView(label    : "Note",
                                               amount   : $mark.viewMark,
                                               validity : .within(range: 0.0 ... Double(mark.exam!.viewMaxMark)),
                                               currency : false)
                                Stepper(
                                    "",
                                    onIncrement: {
                                        mark.viewMark = (mark.viewMark + 0.5)
                                            .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                                    },
                                    onDecrement: {
                                        mark.viewMark = (mark.viewMark - 0.5)
                                            .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                                    })
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "graduationcap")
                            AmountEditView(label    : mark.eleve!.displayName,
                                           amount   : $mark.viewMark,
                                           validity : .within(range: 0.0 ... Double(mark.exam!.viewMaxMark)),
                                           currency : false)
                            Stepper(
                                "",
                                onIncrement: {
                                    mark.viewMark = (mark.viewMark + 0.5)
                                        .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                                },
                                onDecrement: {
                                    mark.viewMark = (mark.viewMark - 0.5)
                                        .clamp(low: 0.0, high: Double(mark.exam!.viewMaxMark))
                                })
                            .frame(maxWidth: 100)

                            CasePicker(pickedCase: $mark.markTypeEnum,
                                       label: "")
                            .pickerStyle(.menu)
                            .frame(maxWidth: 120)
                        }
                    }

                default:
                    HStack {
                        Image(systemName: "graduationcap")
                        CasePicker(pickedCase: $mark.markTypeEnum,
                                   label: mark.eleve!.displayName)
                        .pickerStyle(.menu)
                    }
            }
        }
    }
}
