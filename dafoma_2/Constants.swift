import SwiftUI

// MARK: - Color Constants
struct AppColors {
    static let background = Color(hex: "#0e0e0e")
    static let secondaryBackground = Color(hex: "#1a1c1e")
    static let primaryGreen = Color(hex: "#28a809")
    static let primaryRed = Color(hex: "#e6053a")
    static let accentOrange = Color(hex: "#d17305")
    
    // Additional derived colors for better UX
    static let cardBackground = Color(hex: "#1a1c1e").opacity(0.8)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let neonGlow = primaryGreen.opacity(0.3)
}

// MARK: - Typography
struct AppFonts {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .medium, design: .monospaced)
    static let caption = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let cipherResult = Font.system(size: 18, weight: .medium, design: .monospaced)
}

// MARK: - Layout Constants
struct AppLayout {
    static let cornerRadius: CGFloat = 12
    static let cardSpacing: CGFloat = 16
    static let padding: CGFloat = 20
    static let buttonHeight: CGFloat = 50
    static let animationDuration: Double = 0.3
    static let pulseAnimation: Animation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Cipher Types
enum CipherType: String, CaseIterable, Identifiable {
    case caesar = "Caesar Cipher"
    case base64 = "Base64"
    case morse = "Morse Code"
    case hex = "Hexadecimal"
    case binary = "Binary"
    case rot13 = "ROT13"
    case substitution = "Substitution"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .caesar: return "shield.lefthalf.filled"
        case .base64: return "doc.text"
        case .morse: return "dot.radiowaves.left.and.right"
        case .hex: return "number"
        case .binary: return "01.square"
        case .rot13: return "repeat"
        case .substitution: return "textformat.abc"
        }
    }
    
    var description: String {
        switch self {
        case .caesar: return "Classic shift cipher"
        case .base64: return "Text to Base64 encoding"
        case .morse: return "International Morse Code"
        case .hex: return "Hexadecimal encoding"
        case .binary: return "Binary representation"
        case .rot13: return "13-position shift cipher"
        case .substitution: return "Custom character mapping"
        }
    }
}

// MARK: - App Navigation
enum AppScreen: String, CaseIterable {
    case home = "Home"
    case reference = "Reference"
    case darkOps = "DarkOps"
    case export = "Export"
} 