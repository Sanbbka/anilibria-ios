import SwiftUI
import Shimmer

public struct PosterSectionShimmer: View {
    public var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<5) { _ in
                    VStack(spacing: 4) {
                        Rectangle()
                            .frame(width: 400, height: 225)
                            .clipped()
                            .background(.gray)
                            .shimmering()
                        
                        Rectangle()
                            .frame(width: 400, height: 75)
                            .background(.red)
                            .shimmering()
                        
                        Text("Some text asdsa sa das dad asd")
                            .frame(width: 400, height: 75)
                            .foregroundStyle(.gray)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                }
            }.padding(40)
        }
    }
    
    public init() {}
}

public struct CardSection<Content: View>: View {
    public let content: Content
    public let focusable: Bool
    @FocusState var isFocused: Bool
    
    public init(focusable: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.focusable = focusable
    }
    
    public var body: some View {
        VStack {
            VStack {
                content
            }
            .padding(22)
        }
        .focusable(focusable)
        .focused($isFocused)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.systemGrayDarker)
        )
        .scaleEffect(isFocused ? 1 : 0.98)
    }
}
