import SwiftUI

public struct LoadMoreButton: View {
    public var isLoading: Bool
    public var action: () -> Void
    
    @FocusState private var isFocused
    
    public init(isLoading: Bool, action: @escaping () -> Void) {
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Text("Next")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(isFocused ? .white : .gray)
            }
            .frame(width: 400, height: 250)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FF424E"),
                                Color(hex: "D31027")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
        }
        .buttonStyle(.card) // Специальный стиль для tvOS
        .onLongPressGesture(minimumDuration: 0.01) { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isFocused = pressing
            }
        } perform: {}
    }
}

// Вспомогательное расширение для работы с HEX-цветами
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xff00) >> 8) / 255.0
        let b = Double(rgbValue & 0xff) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
