import Foundation

// MARK: - Cipher Operation Model
struct CipherOperation {
    let type: CipherType
    let input: String
    let output: String
    let isEncoding: Bool
    let timestamp: Date
    let parameters: [String: Any]?
    
    init(type: CipherType, input: String, output: String, isEncoding: Bool, parameters: [String: Any]? = nil) {
        self.type = type
        self.input = input
        self.output = output
        self.isEncoding = isEncoding
        self.timestamp = Date()
        self.parameters = parameters
    }
}

// MARK: - Cipher Result Model
struct CipherResult {
    let success: Bool
    let output: String
    let error: String?
    let metadata: [String: String]?
    
    static func success(_ output: String, metadata: [String: String]? = nil) -> CipherResult {
        return CipherResult(success: true, output: output, error: nil, metadata: metadata)
    }
    
    static func failure(_ error: String) -> CipherResult {
        return CipherResult(success: false, output: "", error: error, metadata: nil)
    }
}

// MARK: - Reference Entry Model
struct ReferenceEntry: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let description: String
    let content: String
    let cipherType: CipherType?
    
    static let entries: [ReferenceEntry] = [
        ReferenceEntry(
            title: "Caesar Cipher",
            category: "Classical Ciphers",
            description: "A substitution cipher where each letter is shifted by a fixed number of positions in the alphabet.",
            content: """
            The Caesar cipher is one of the earliest known encryption techniques, named after Julius Caesar who reportedly used it to communicate with his generals.

            How it works:
            • Each letter in the plaintext is shifted a certain number of places down the alphabet
            • The shift amount is the 'key' (traditionally 3 for Caesar)
            • When reaching the end of the alphabet, it wraps around to the beginning

            Example with shift of 3:
            A → D, B → E, C → F, ..., X → A, Y → B, Z → C

            Security:
            • Very weak by modern standards
            • Only 25 possible keys (shifts 1-25)
            • Easily broken by frequency analysis
            
            Historical significance:
            • Used by Roman military
            • Foundation for more complex substitution ciphers
            • Still used today for simple obfuscation (ROT13)
            """,
            cipherType: .caesar
        ),
        
        ReferenceEntry(
            title: "Base64 Encoding",
            category: "Modern Encoding",
            description: "A binary-to-text encoding scheme that represents binary data in ASCII string format.",
            content: """
            Base64 is not encryption but encoding - it's designed for data transmission and storage, not security.

            How it works:
            • Takes binary data and converts it to text
            • Uses 64 characters: A-Z, a-z, 0-9, +, /
            • Every 3 bytes of input become 4 characters of output
            • Padding with '=' characters when needed

            Common uses:
            • Email attachments (MIME)
            • Data URLs in web development
            • API data transmission
            • Configuration files

            Important notes:
            • NOT secure - easily reversible
            • Increases data size by ~33%
            • Safe for text transmission systems
            • Case-sensitive
            """,
            cipherType: .base64
        ),
        
        ReferenceEntry(
            title: "Morse Code",
            category: "Communication Systems",
            description: "A method of encoding text using dots and dashes to represent letters and numbers.",
            content: """
            Invented by Samuel Morse in the 1830s for telegraph communication.

            System:
            • Dots (·) represent short signals
            • Dashes (−) represent long signals
            • Letters separated by spaces
            • Words separated by larger spaces

            Key features:
            • Variable length encoding
            • More common letters have shorter codes
            • International standard (ITU)
            • Still used in radio communications

            Common patterns:
            • E: ·     (most common letter, shortest code)
            • T: −
            • A: ·−
            • SOS: ··· −−− ···

            Modern usage:
            • Amateur radio
            • Aviation navigation
            • Emergency signaling
            • Educational purposes
            """,
            cipherType: .morse
        ),
        
        ReferenceEntry(
            title: "Cryptography Fundamentals",
            category: "General Knowledge",
            description: "Basic concepts and terminology in cryptography and information security.",
            content: """
            Key Concepts:

            Encryption vs Encoding:
            • Encryption: Uses a key to transform data for security
            • Encoding: Transforms data for compatibility/transmission

            Cipher Types:
            • Substitution: Replace characters with others
            • Transposition: Rearrange character positions
            • Stream: Encrypt one character at a time
            • Block: Encrypt fixed-size groups

            Security Principles:
            • Confidentiality: Keep data secret
            • Integrity: Ensure data hasn't changed
            • Authentication: Verify identity
            • Non-repudiation: Prevent denial

            Historical Context:
            • Ancient: Scytale, Caesar cipher
            • Renaissance: Vigenère cipher
            • Modern: DES, AES, RSA
            • Quantum: Future-resistant algorithms

            Remember: The ciphers in this app are for educational purposes and should not be used for actual security needs.
            """,
            cipherType: nil
        )
    ]
}

// MARK: - Export Format Model
enum ExportFormat: String, CaseIterable {
    case plainText = "Plain Text"
    case json = "JSON"
    case image = "Image"
    
    var fileExtension: String {
        switch self {
        case .plainText: return "txt"
        case .json: return "json"
        case .image: return "png"
        }
    }
    
    var icon: String {
        switch self {
        case .plainText: return "doc.text"
        case .json: return "curlybraces"
        case .image: return "photo"
        }
    }
} 