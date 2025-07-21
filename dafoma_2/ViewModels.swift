import SwiftUI
import Combine

// MARK: - Main App ViewModel
class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .home
    @Published var selectedCipher: CipherType = .caesar
    @Published var showingCipherTool = false
    @Published var showingDarkOps = false
    @Published var operations: [CipherOperation] = []
    
    private let cipherService = CipherService.shared
    
    func selectCipher(_ cipher: CipherType) {
        selectedCipher = cipher
        showingCipherTool = true
    }
    
    func addOperation(_ operation: CipherOperation) {
        operations.insert(operation, at: 0) // Add to beginning for recency
        if operations.count > 50 { // Keep only recent 50 operations
            operations = Array(operations.prefix(50))
        }
    }
    
    func clearHistory() {
        operations.removeAll()
    }
}

// MARK: - Cipher Tool ViewModel
class CipherToolViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var isEncoding = true
    @Published var isProcessing = false
    @Published var lastResult: CipherResult?
    @Published var showingError = false
    @Published var errorMessage = ""
    
    // Cipher-specific parameters
    @Published var caesarShift = 3
    @Published var substitutionKey = "ZYXWVUTSRQPONMLKJIHGFEDCBA"
    
    private let cipherService = CipherService.shared
    private var cancellables = Set<AnyCancellable>()
    
    let cipher: CipherType
    
    init(cipher: CipherType) {
        self.cipher = cipher
        setupBindings()
    }
    
    private func setupBindings() {
        // Auto-process text when input changes (with debounce)
        $inputText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.processText()
            }
            .store(in: &cancellables)
        
        // Clear output when switching encode/decode mode
        $isEncoding
            .sink { [weak self] _ in
                self?.processText()
            }
            .store(in: &cancellables)
    }
    
    func processText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            outputText = ""
            lastResult = nil
            return
        }
        
        isProcessing = true
        
        // Simulate brief processing delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            var parameters: [String: Any] = [:]
            
            switch self.cipher {
            case .caesar:
                parameters["shift"] = self.caesarShift
            case .substitution:
                parameters["key"] = self.substitutionKey
            default:
                break
            }
            
            let result = self.cipherService.processText(
                self.inputText,
                using: self.cipher,
                isEncoding: self.isEncoding,
                parameters: parameters
            )
            
            self.lastResult = result
            
            if result.success {
                self.outputText = result.output
                self.showingError = false
            } else {
                self.outputText = ""
                self.errorMessage = result.error ?? "Unknown error"
                self.showingError = true
            }
            
            self.isProcessing = false
        }
    }
    
    func swapInputOutput() {
        let temp = inputText
        inputText = outputText
        outputText = temp
        isEncoding.toggle()
    }
    
    func clearAll() {
        inputText = ""
        outputText = ""
        lastResult = nil
        showingError = false
    }
    
    func copyOutput() {
        UIPasteboard.general.string = outputText
    }
    
    func pasteInput() {
        if let clipboardText = UIPasteboard.general.string {
            inputText = clipboardText
        }
    }
}

// MARK: - Export ViewModel
class ExportViewModel: ObservableObject {
    @Published var selectedFormat: ExportFormat = .plainText
    @Published var includeMetadata = true
    @Published var showingShareSheet = false
    @Published var shareItems: [Any] = []
    
    func prepareExport(operation: CipherOperation) {
        switch selectedFormat {
        case .plainText:
            shareItems = [generatePlainText(operation)]
        case .json:
            shareItems = [generateJSON(operation)]
        case .image:
            if let image = generateImage(operation) {
                shareItems = [image]
            }
        }
        showingShareSheet = true
    }
    
    private func generatePlainText(_ operation: CipherOperation) -> String {
        var text = """
        CodeCipher Export
        =================
        
        Cipher: \(operation.type.rawValue)
        Operation: \(operation.isEncoding ? "Encode" : "Decode")
        
        Input:
        \(operation.input)
        
        Output:
        \(operation.output)
        """
        
        if includeMetadata {
            text += """
            
            
            Timestamp: \(DateFormatter.exportFormatter.string(from: operation.timestamp))
            """
        }
        
        return text
    }
    
    private func generateJSON(_ operation: CipherOperation) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let exportData: [String: Any] = [
            "cipher": operation.type.rawValue,
            "operation": operation.isEncoding ? "encode" : "decode",
            "input": operation.input,
            "output": operation.output,
            "timestamp": ISO8601DateFormatter().string(from: operation.timestamp),
            "app": "CodeCipher Utility"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "Error generating JSON: \(error.localizedDescription)"
        }
    }
    
    private func generateImage(_ operation: CipherOperation) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
        
        return renderer.image { context in
            // Background
            AppColors.background.uiColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 600))
            
            // Draw text content
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 4
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: AppColors.primaryGreen.uiColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .medium),
                .foregroundColor: AppColors.textPrimary.uiColor,
                .paragraphStyle: paragraphStyle
            ]
            
            var yOffset: CGFloat = 30
            
            // Title
            "CodeCipher".draw(at: CGPoint(x: 20, y: yOffset), withAttributes: titleAttributes)
            yOffset += 40
            
            // Content
            let content = """
            \(operation.type.rawValue)
            \(operation.isEncoding ? "ENCODE" : "DECODE")
            
            INPUT:
            \(operation.input)
            
            OUTPUT:
            \(operation.output)
            """
            
            content.draw(in: CGRect(x: 20, y: yOffset, width: 360, height: 500), withAttributes: bodyAttributes)
        }
    }
}

// MARK: - Dark Ops ViewModel
class DarkOpsViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var selectedCipher: CipherType = .caesar
    @Published var isEncoding = true
    @Published var isFullScreen = false
    
    private let cipherService = CipherService.shared
    
    func processText() {
        guard !inputText.isEmpty else {
            outputText = ""
            return
        }
        
        let result = cipherService.processText(inputText, using: selectedCipher, isEncoding: isEncoding)
        outputText = result.success ? result.output : "ERROR: \(result.error ?? "Unknown")"
    }
    
    func toggleMode() {
        isEncoding.toggle()
        processText()
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let exportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter
    }()
}

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
} 