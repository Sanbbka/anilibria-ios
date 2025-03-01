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

#Preview {
    PosterSectionShimmer()
}
