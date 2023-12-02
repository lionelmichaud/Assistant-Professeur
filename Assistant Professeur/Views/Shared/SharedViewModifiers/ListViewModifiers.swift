//
//  ListViewModifiers.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/10/2023.
//

import SwiftUI

public extension View {
    /// Modifer le fond d'un item d'une liste en fonction de Sélectionné ou Pas sélectionné.
    ///
    /// Usage:
    ///
    ///      List(dataList, id: \.self) { data in
    ///         ItemView("\(data)")
    ///            .customizedListItemStyle(isSelected: data.isSelected)
    ///      }
    ///
    func customizedListItemStyle(isSelected: Bool) -> some View {
        return self.modifier(CustomizedListItemModifier(isSelected: isSelected))
    }
}

struct CustomizedListItemModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            // .listRowSeparatorTint(.secondary)
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: CGFloat(10))
                    .fill(isSelected ?
                          HierarchicalShapeStyle.listRowBackgroundSelected :
                            HierarchicalShapeStyle.listRowBackgroundUnselected
                    )
                    .padding(2)
            )
    }
}

#Preview {
    VStack(alignment: .leading) {
        Text("Customized List").padding()
        List {
            Label("Label Unselected", systemImage: "pencil.tip.crop.circle.fill")
                .modifier(CustomizedListItemModifier(isSelected: false))
            Label("Label Selected", systemImage: "pencil.tip.crop.circle.fill")
                .modifier(CustomizedListItemModifier(isSelected: true))
            Label(
                title: { Text("Label with Icon Unselected") },
                icon: { Image(systemName: "pencil.tip.crop.circle.fill") }
            )
            .modifier(CustomizedListItemModifier(isSelected: false))
            Label(
                title: { Text("Label with Icon Selected") },
                icon: { Image(systemName: "pencil.tip.crop.circle.fill") }
            )
            .modifier(CustomizedListItemModifier(isSelected: true))
        }
        Text("List without customization").padding()
        List {
            Label("Label Unselected", systemImage: "pencil.tip.crop.circle.fill")
            Label("Label Unselected", systemImage: "pencil.tip.crop.circle.fill")
        }
        Spacer()
    }
}

public extension View {
    /// Modifer le fond d'un item d'une liste en fonction de Sélectionné ou Pas sélectionné.
    ///
    /// Usage:
    ///
    ///     TipView(addDocumentTip, arrowEdge: .bottom)
    ///         .customizedTipKitStyle()
    ///
    func customizedTipKitStyle() -> some View {
        return self.modifier(CustomizedTipKitModifier())
    }
}

struct CustomizedTipKitModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // .listRowSeparatorTint(.secondary)
            .tint(Color.tipIconColor)
            .tipBackground(HierarchicalShapeStyle.tipBackgroundColor)
    }
}

// #Preview {
//    ListViewModifiers()
// }
