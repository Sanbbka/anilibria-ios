import Foundation
import SwiftUI

public struct ConfigurationView: View {
    @State var degreesRotating = 0.0
    
    public var body: some View {
        Image(systemName: "arrow.clockwise")
            .foregroundColor(.blue)
            .rotationEffect(.degrees(degreesRotating), anchor: .center)
            .onAppear {
                withAnimation(.linear(duration: 1)
                    .speed(2)
                    .repeatForever(autoreverses: false)) {
                        degreesRotating = 360.0
                    }
            }
    }
    
    public init() {}
}
