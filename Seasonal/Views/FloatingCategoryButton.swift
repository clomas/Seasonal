//
//  FloatingCategoryButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct FloatingCategoryButton: View {

    @Binding var selectedCategory: ProduceCategory

    var body: some View {
        Menu {
            ForEach(ProduceCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Label(category.title, systemImage: category.image)
//                    Label(category.title, image: "fruit")
                }
            }
        } label: {
            Image(systemName: selectedCategory.image)
//            Image(uiImage: UIImage(named: "fruit")!)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(18)
                .glassEffect(.regular.interactive(), in: Circle())

        }
        .tint(.primary)
        .accessibilityLabel("Filter by category")
        .controlSize(.large)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ZStack {
            Colour.background
            FloatingCategoryButton(selectedCategory: .constant(.all))
        }
            
    }
}
