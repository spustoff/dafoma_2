import Foundation

// MARK: - Cipher Service
class CipherService: ObservableObject {
    static let shared = CipherService()
    
    private init() {}
    
    // MARK: - Main Encode/Decode Function
    func processText(_ text: String, using cipher: CipherType, isEncoding: Bool, parameters: [String: Any] = [:]) -> CipherResult {
        guard !text.isEmpty else {
            return .failure("Input text cannot be empty")
        }
        
        switch cipher {
        case .caesar:
            return processCaesar(text, isEncoding: isEncoding, parameters: parameters)
        case .base64:
            return processBase64(text, isEncoding: isEncoding)
        case .morse:
            return processMorse(text, isEncoding: isEncoding)
        case .hex:
            return processHex(text, isEncoding: isEncoding)
        case .binary:
            return processBinary(text, isEncoding: isEncoding)
        case .rot13:
            return processROT13(text)
        case .substitution:
            return processSubstitution(text, isEncoding: isEncoding, parameters: parameters)
        }
    }
    
    // MARK: - Caesar Cipher
    private func processCaesar(_ text: String, isEncoding: Bool, parameters: [String: Any]) -> CipherResult {
        let shift = parameters["shift"] as? Int ?? 3
        let actualShift = isEncoding ? shift : -shift
        
        let result = text.map { char -> Character in
            if char.isLetter {
                let base: UInt8 = char.isUppercase ? 65 : 97 // 'A' or 'a'
                let shifted = (Int(char.asciiValue! - base) + actualShift + 26) % 26
                return Character(UnicodeScalar(shifted + Int(base))!)
            }
            return char
        }
        
        let output = String(result)
        let metadata = ["shift": "\(shift)", "direction": isEncoding ? "encode" : "decode"]
        return .success(output, metadata: metadata)
    }
    
    // MARK: - Base64
    private func processBase64(_ text: String, isEncoding: Bool) -> CipherResult {
        if isEncoding {
            let encoded = Data(text.utf8).base64EncodedString()
            return .success(encoded, metadata: ["size_increase": "\(encoded.count - text.count) characters"])
        } else {
            guard let data = Data(base64Encoded: text) else {
                return .failure("Invalid Base64 string")
            }
            guard let decoded = String(data: data, encoding: .utf8) else {
                return .failure("Could not decode to valid UTF-8 string")
            }
            return .success(decoded)
        }
    }
    
    // MARK: - Morse Code
    private func processMorse(_ text: String, isEncoding: Bool) -> CipherResult {
        if isEncoding {
            let morse = text.uppercased().compactMap { char -> String? in
                return morseCodeMap[char]
            }.joined(separator: " ")
            
            guard !morse.isEmpty else {
                return .failure("Text contains unsupported characters for Morse code")
            }
            
            return .success(morse)
        } else {
            let reversedMap = Dictionary(uniqueKeysWithValues: morseCodeMap.map { ($1, $0) })
            let words = text.components(separatedBy: "  ") // Double space separates words
            
            let decoded = words.map { word in
                word.split(separator: " ").compactMap { code in
                    reversedMap[String(code)]
                }.map(String.init).joined()
            }.joined(separator: " ")
            
            guard !decoded.isEmpty else {
                return .failure("Invalid Morse code format")
            }
            
            return .success(decoded)
        }
    }
    
    // MARK: - Hexadecimal
    private func processHex(_ text: String, isEncoding: Bool) -> CipherResult {
        if isEncoding {
            let hex = text.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
            return .success(hex.uppercased())
        } else {
            // Remove spaces and ensure even length
            let cleanHex = text.replacingOccurrences(of: " ", with: "")
            guard cleanHex.count % 2 == 0 else {
                return .failure("Hex string must have even number of characters")
            }
            
            var data = Data()
            var index = cleanHex.startIndex
            
            while index < cleanHex.endIndex {
                let nextIndex = cleanHex.index(index, offsetBy: 2)
                let hexByte = String(cleanHex[index..<nextIndex])
                
                guard let byte = UInt8(hexByte, radix: 16) else {
                    return .failure("Invalid hexadecimal characters")
                }
                
                data.append(byte)
                index = nextIndex
            }
            
            guard let decoded = String(data: data, encoding: .utf8) else {
                return .failure("Could not decode to valid UTF-8 string")
            }
            
            return .success(decoded)
        }
    }
    
    // MARK: - Binary
    private func processBinary(_ text: String, isEncoding: Bool) -> CipherResult {
        if isEncoding {
            let binary = text.utf8.map { String($0, radix: 2).leftPadding(toLength: 8, withPad: "0") }.joined(separator: " ")
            return .success(binary)
        } else {
            let binaryNumbers = text.components(separatedBy: " ").filter { !$0.isEmpty }
            
            var data = Data()
            for binary in binaryNumbers {
                guard let byte = UInt8(binary, radix: 2) else {
                    return .failure("Invalid binary format")
                }
                data.append(byte)
            }
            
            guard let decoded = String(data: data, encoding: .utf8) else {
                return .failure("Could not decode to valid UTF-8 string")
            }
            
            return .success(decoded)
        }
    }
    
    // MARK: - ROT13
    private func processROT13(_ text: String) -> CipherResult {
        return processCaesar(text, isEncoding: true, parameters: ["shift": 13])
    }
    
    // MARK: - Substitution Cipher
    private func processSubstitution(_ text: String, isEncoding: Bool, parameters: [String: Any]) -> CipherResult {
        guard let key = parameters["key"] as? String, key.count == 26 else {
            return .failure("Substitution key must be exactly 26 characters")
        }
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let substitutionMap: [Character: Character]
        
        if isEncoding {
            substitutionMap = Dictionary(uniqueKeysWithValues: zip(alphabet, key.uppercased()))
        } else {
            substitutionMap = Dictionary(uniqueKeysWithValues: zip(key.uppercased(), alphabet))
        }
        
        let result = text.map { char -> Character in
            if char.isLetter {
                let upperChar = char.uppercased().first!
                let mappedChar = substitutionMap[upperChar] ?? char
                return char.isUppercase ? mappedChar : mappedChar.lowercased().first!
            }
            return char
        }
        
        return .success(String(result))
    }
    
    // MARK: - Morse Code Mapping
    private let morseCodeMap: [Character: String] = [
        "A": "·−", "B": "−···", "C": "−·−·", "D": "−··", "E": "·",
        "F": "··−·", "G": "−−·", "H": "····", "I": "··", "J": "·−−−",
        "K": "−·−", "L": "·−··", "M": "−−", "N": "−·", "O": "−−−",
        "P": "·−−·", "Q": "−−·−", "R": "·−·", "S": "···", "T": "−",
        "U": "··−", "V": "···−", "W": "·−−", "X": "−··−", "Y": "−·−−",
        "Z": "−−··", "0": "−−−−−", "1": "·−−−−", "2": "··−−−",
        "3": "···−−", "4": "····−", "5": "·····", "6": "−····",
        "7": "−−···", "8": "−−−··", "9": "−−−−·", " ": " "
    ]
}

// MARK: - String Extension for Padding
extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

// MARK: - Character Extensions
extension Character {
    var isUppercase: Bool {
        return self.uppercased() == String(self) && self.lowercased() != String(self)
    }
} 
