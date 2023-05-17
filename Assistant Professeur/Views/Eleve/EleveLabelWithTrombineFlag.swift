////
////  EleveLabelWithTrombineFlag.swift
////  Cahier du Professeur (iOS)
////
////  Created by Lionel MICHAUD on 17/06/2022.
////

import HelpersView
import SwiftUI

struct EleveLabelWithTrombineFlag: View {
    @ObservedObject
    var eleve: EleveEntity

    var isEditable: Bool = true
    var font: Font = .title3
    var fontWeight: Font.Weight = .semibold
    var imageSize: Image.Scale = .large
    var flagSize: Image.Scale = .medium

    @EnvironmentObject
    private var pref: UserPreferences

    @Environment(\.horizontalSizeClass)
    var hClass

    @State
    private var showTrombine = false

    // MARK: - Computed Properties

    private var classe: ClasseEntity? {
        eleve.classe
    }

    private var hasPAP: Binding<Bool> {
        Binding(
            get: {
                eleve.hasTrouble
            },
            set: { newValue in
                if newValue {
                    eleve.troubleEnum = .undefined
                } else {
                    eleve.troubleEnum = .none
                }
            }
        )
    }

    private var troubleEditView: some View {
        let layout = hClass == .compact ?
            AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
        return layout {
            HStack {
                Image(systemName: "figure.and.child.holdinghands")
                    .imageScale(imageSize)
                    .foregroundStyle(.tint)
                CasePicker(
                    pickedCase: $eleve.troubleEnum,
                    label: "Trouble"
                )
                .pickerStyle(.menu)
            }
            .padding(.trailing)

            HStack {
                Image(systemName: "hourglass.badge.plus")
                    .imageScale(imageSize)
                    .foregroundStyle(.green, .tint)
                Toggle(isOn: $eleve.viewHasAddTime.animation()) {
                    Text("1/3 de temps aditionnel")
                }
                .toggleStyle(.button)
                .controlSize(.small)
            }
        }
    }

    private var troubleDisplayView: some View {
        VStack {
            HStack {
                Image(systemName: "figure.and.child.holdinghands")
                    .imageScale(imageSize)
                    .foregroundStyle(.tint)
                Text(eleve.troubleEnum.displayString)
            }
            if eleve.viewHasAddTime {
                HStack {
                    Image(systemName: "hourglass.badge.plus")
                        .imageScale(imageSize)
                        .foregroundStyle(.green, .tint)
                    Text("1/3 de temps aditionnel")
                }
            }
        }
    }

    var body: some View {
        return VStack {
            HStack {
                // Classe
                if let classe {
                    Text(classe.displayString)
                        .font(font)
                        .fontWeight(.semibold)
                }
                // Trombine
                Button {
                    withAnimation {
                        showTrombine.toggle()
                    }
                } label: {
                    Image(systemName: "graduationcap")
                        .imageScale(imageSize)
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(eleve.sexEnum.color)
                }
                .disabled(!pref.eleve.trombineEnabled)

                // Nom
                if hClass == .compact {
                    EleveTextName(
                        eleve: eleve,
                        fontSize: font,
                        fontWidth: Font.Width.condensed,
                        fontWeight: fontWeight
                    )
                } else {
                    EleveTextName(
                        eleve: eleve,
                        fontSize: font,
                        fontWidth: Font.Width.standard,
                        fontWeight: fontWeight
                    )
                }

                // Flag
                Button {
                    eleve.toggleFlag()
                } label: {
                    if eleve.isFlagged {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: "flag")
                            .foregroundColor(.orange)
                    }
                }
                .disabled(!isEditable)

                // PAP
                if isEditable {
                    Toggle(isOn: hasPAP.animation()) {
                        Text("PAP")
                    }
                    .toggleStyle(.button)
                    .controlSize(.small)
                }
            }

            // Trouble dys
            if eleve.hasTrouble {
                if isEditable {
                    troubleEditView

                } else {
                    troubleDisplayView
                }
            }

            // Groupe
            if let group = eleve.group {
                GroupCapsule(group: group)
            }

            // Trombine
            if showTrombine && eleve.hasImageTrombine {
                // TODO: - Gérer ici la mise à jour de la photo par drag and drop
                Trombine(eleve: eleve)
                    .frame(height: 320)
            }
        }
        .onAppear {
            //            hasPAP = eleve.troubleDys != nil
        }
    }
}

 struct EleveLabelWithTrombineFlag_Previews: PreviewProvider {
     static func initialize() {
         DataBaseManager.populateWithMockData(storeType: .inMemory)
     }

    static var previews: some View {
        initialize()
        return Group {
            EleveLabelWithTrombineFlag(eleve      : EleveEntity.all().first!,
                                       isEditable : false)
            .previewDevice("iPhone 13")

            EleveLabelWithTrombineFlag(eleve      : EleveEntity.all().first!,
                                       isEditable : true)
            .previewDevice("iPad mini (6th generation)")
        }
        .environmentObject(NavigationModel())
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
    }
 }
