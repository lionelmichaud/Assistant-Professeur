//
//  ListViewModifiers.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/10/2023.
//

import SwiftUI

extension View {
    /// Remplace une liste  de données`data`vide par un `placeHolderContent`
    ///
    /// Usage:
    ///
    ///      List(dataList, id: \.self) { data in
    ///         ItemView("\(data)")
    ///            .customizedListItemStyle(isSelected: data.isSelected)
    ///      }
    ///
    public func customizedListItemStyle(isSelected: Bool) -> some View {
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
                        Color.listRowBackgroundSelected :
                        Color.listRowBackgroundUnselected
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

// #Preview {
//    ListViewModifiers()
// }
