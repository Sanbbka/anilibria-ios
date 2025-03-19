//
//  MediaInfoPanel.swift
//  Components
//
//  Created by Alexander Drovnyashin on 1/3/25.
//

import SwiftUI

public struct MediaInfoPanel_Previews: PreviewProvider {
    public static var previews: some View {
        MediaInfoPanel(
            title: "Sample Series",
            year: "2023",
            genres: ["Action", "Drama", "Sci-Fi"],
            description: "This is a sample description for the series."
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.tvBackground)
    }
}
