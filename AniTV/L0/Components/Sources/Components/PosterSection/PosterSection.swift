//
//  File.swift
//  
//
//  Created by Alexander Drovnyashin on 19/2/24.
//

import SwiftUI

public struct PosterSection: View {
    public let rows: [PosterModel]
    public let selectedElement: ((PosterModel) -> Void)?
    public let isLoading: Bool
    public let loadMore: () -> Void
    
    @FocusState private var currentFocus: Int?
    
    public init(
        isLoading: Bool,
        rows: [PosterModel],
        selectedElement: @escaping ((PosterModel) -> Void),
        loadMore: @escaping (() -> Void)
    ) {
        self.rows = rows
        self.selectedElement = selectedElement
        self.loadMore = loadMore
        self.isLoading = isLoading
    }
    
    public var body: some View {
        VStack {
            SectionHeader(title: "Последние изменения")
            ScrollView (.vertical, showsIndicators: false) {
                VStack {
                    ForEach(rows) { row in
                        BookCardView(poster: row) {
                            selectedElement?(row)
                        }.focused($currentFocus, equals: row.id)
                    }
                    LoadMoreButton(isLoading: isLoading) {
                        currentFocus = rows.last?.id
                        loadMore()
                    }
                }
            }.onAppear() {
                currentFocus = rows.first?.id
            }
        }
    }
}
