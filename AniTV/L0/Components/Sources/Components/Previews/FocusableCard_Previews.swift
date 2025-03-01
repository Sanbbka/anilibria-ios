//
//  FocusableCard.swift
//  Components
//
//  Created by Alexander Drovnyashin on 1/3/25.
//

import SwiftUI

struct FocusableCard_Previews: PreviewProvider {
    static var previews: some View {
        FocusableCard(
            title: "Sample Title",
            image: "https://example.com/sample-image.jpg",
            episodes: "10 Episodes"
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.tvBackground)
    }
}
