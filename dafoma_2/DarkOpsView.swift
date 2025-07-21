import SwiftUI

struct DarkOpsView: View {
    @StateObject private var viewModel = DarkOpsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var terminalLines: [TerminalLine] = []
    @State private var glowPhase = 0.0
    @State private var scanlineOffset: CGFloat = 0
    @State private var showingCipherSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundEffects
                
                VStack(spacing: 0) {
                    if !viewModel.isFullScreen {
                        headerSection
                    }
                    
                    terminalInterface
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if !viewModel.isFullScreen {
                        controlPanel
                    }
                }
                
                scanlineEffect
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(viewModel.isFullScreen)
        .onAppear {
            startAnimations()
            initializeTerminal()
        }
        .onTapGesture(count: 2) {
            viewModel.isFullScreen.toggle()
        }
        .sheet(isPresented: $showingCipherSelector) {
            CipherSelectorSheet(selectedCipher: $viewModel.selectedCipher)
        }
    }
    
    // MARK: - Background Effects
    private var backgroundEffects: some View {
        ZStack {
            // Base dark background
            Color.black
                .ignoresSafeArea()
            
            // Matrix-style background pattern
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Path { path in
                        let startY = CGFloat(i) * geometry.size.height / 20
                        path.move(to: CGPoint(x: 0, y: startY))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: startY))
                    }
                    .stroke(AppColors.primaryGreen.opacity(0.05), lineWidth: 1)
                }
                
                ForEach(0..<10, id: \.self) { i in
                    Path { path in
                        let startX = CGFloat(i) * geometry.size.width / 10
                        path.move(to: CGPoint(x: startX, y: 0))
                        path.addLine(to: CGPoint(x: startX, y: geometry.size.height))
                    }
                    .stroke(AppColors.primaryGreen.opacity(0.03), lineWidth: 1)
                }
            }
            
            // Subtle glow
            RadialGradient(
                colors: [
                    AppColors.primaryGreen.opacity(0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 300
            )
            .opacity(glowPhase)
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowPhase)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryRed)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.primaryRed.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("DARKOPS")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.primaryGreen)
                    .shadow(color: AppColors.primaryGreen, radius: 8)
                
                Text("CIPHER TERMINAL")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.accentOrange)
                    .tracking(2)
            }
            
            Spacer()
            
            Button(action: { viewModel.isFullScreen.toggle() }) {
                Image(systemName: viewModel.isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.title2)
                    .foregroundColor(AppColors.accentOrange)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.accentOrange.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Terminal Interface
    private var terminalInterface: some View {
        VStack(spacing: 0) {
            // Terminal header
            terminalHeader
            
            // Terminal content
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(terminalLines.indices, id: \.self) { index in
                        TerminalLineView(line: terminalLines[index])
                    }
                    
                    inputPrompt
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .padding(.horizontal, viewModel.isFullScreen ? 40 : 20)
    }
    
    private var terminalHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppColors.primaryRed)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(AppColors.accentOrange)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(AppColors.primaryGreen)
                    .frame(width: 12, height: 12)
            }
            
            Spacer()
            
            Text("codecipher://darkops/terminal")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Button(action: { showingCipherSelector = true }) {
                Text(viewModel.selectedCipher.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.accentOrange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(AppColors.accentOrange.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
        .overlay(
            Rectangle()
                .fill(AppColors.primaryGreen.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var inputPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Input section
            HStack(spacing: 8) {
                Text("input>")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.primaryGreen)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.inputText.isEmpty {
                        Text("Enter text to process...")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            .padding(.top, 8)
                    }
                    
                    TextEditor(text: $viewModel.inputText)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.textPrimary)
                        .background(Color.clear)
                        .frame(minHeight: 20)
                        .onChange(of: viewModel.inputText) { _ in
                            processInputChange()
                        }
                }
            }
            
            // Output section
            if !viewModel.outputText.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Text(viewModel.isEncoding ? "encode>" : "decode>")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.isEncoding ? AppColors.primaryGreen : AppColors.primaryRed)
                    
                    Text(viewModel.outputText)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.primaryGreen)
                        .animation(.easeInOut, value: viewModel.outputText)
                }
            }
            
            // Cursor blink
            HStack {
                Text("▋")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.primaryGreen)
                    .opacity(glowPhase > 0.5 ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: glowPhase)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Control Panel
    private var controlPanel: some View {
        HStack {
            // Mode toggle
            Button(action: { viewModel.toggleMode() }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isEncoding ? "lock" : "lock.open")
                        .font(.caption)
                    
                    Text(viewModel.isEncoding ? "ENCODE" : "DECODE")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(viewModel.isEncoding ? AppColors.primaryGreen : AppColors.primaryRed)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    viewModel.isEncoding ? AppColors.primaryGreen.opacity(0.5) : AppColors.primaryRed.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                )
            }
            
            Spacer()
            
            // Status indicators
            statusIndicators
            
            Spacer()
            
            // Clear button
            Button(action: clearTerminal) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.caption)
                    
                    Text("CLEAR")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(AppColors.primaryRed)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.primaryRed.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var statusIndicators: some View {
        HStack(spacing: 16) {
            statusDot(label: "PWR", color: AppColors.primaryGreen, isActive: true)
            statusDot(label: "NET", color: AppColors.accentOrange, isActive: false)
            statusDot(label: "SEC", color: AppColors.primaryRed, isActive: true)
        }
    }
    
    private func statusDot(label: String, color: Color, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? color : color.opacity(0.3))
                .frame(width: 8, height: 8)
                .shadow(color: isActive ? color : Color.clear, radius: 4)
            
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(isActive ? color : color.opacity(0.5))
        }
    }
    
    // MARK: - Scanline Effect
    private var scanlineEffect: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, AppColors.primaryGreen.opacity(0.1), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .offset(y: scanlineOffset)
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: scanlineOffset)
                .onAppear {
                    scanlineOffset = geometry.size.height + 10
                }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.linear(duration: 0.1)) {
            glowPhase = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            scanlineOffset = -10
        }
    }
    
    private func initializeTerminal() {
        terminalLines = [
            TerminalLine(text: "CodeCipher DarkOps Terminal v2.0", type: .system),
            TerminalLine(text: "Initializing secure cipher environment...", type: .info),
            TerminalLine(text: "[OK] Cipher modules loaded", type: .success),
            TerminalLine(text: "[OK] Security protocols active", type: .success),
            TerminalLine(text: "Ready for operations.", type: .info),
            TerminalLine(text: "", type: .separator)
        ]
    }
    
    private func processInputChange() {
        viewModel.processText()
        
        if !viewModel.inputText.isEmpty && !viewModel.outputText.isEmpty {
            addTerminalLog()
        }
    }
    
    private func addTerminalLog() {
        let timestamp = DateFormatter.terminalFormatter.string(from: Date())
        let operation = viewModel.isEncoding ? "ENCODE" : "DECODE"
        
        terminalLines.append(
            TerminalLine(
                text: "[\(timestamp)] \(operation) \(viewModel.selectedCipher.rawValue)",
                type: .operation
            )
        )
        
        // Keep only last 20 lines
        if terminalLines.count > 20 {
            terminalLines = Array(terminalLines.suffix(20))
        }
    }
    
    private func clearTerminal() {
        viewModel.inputText = ""
        viewModel.outputText = ""
        terminalLines.removeAll()
        initializeTerminal()
    }
}

// MARK: - Terminal Line Model
struct TerminalLine {
    let text: String
    let type: TerminalLineType
    let timestamp = Date()
}

enum TerminalLineType {
    case system, info, success, error, operation, separator
    
    var color: Color {
        switch self {
        case .system:
            return AppColors.accentOrange
        case .info:
            return AppColors.textSecondary
        case .success:
            return AppColors.primaryGreen
        case .error:
            return AppColors.primaryRed
        case .operation:
            return AppColors.primaryGreen
        case .separator:
            return Color.clear
        }
    }
}

// MARK: - Terminal Line View
struct TerminalLineView: View {
    let line: TerminalLine
    
    var body: some View {
        HStack {
            Text(line.text)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(line.type.color)
            
            Spacer()
        }
    }
}

// MARK: - Cipher Selector Sheet
struct CipherSelectorSheet: View {
    @Binding var selectedCipher: CipherType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Cipher")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryGreen)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(CipherType.allCases) { cipher in
                        Button(action: {
                            selectedCipher = cipher
                            dismiss()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: cipher.icon)
                                    .font(.title)
                                    .foregroundColor(selectedCipher == cipher ? AppColors.primaryGreen : AppColors.textSecondary)
                                
                                Text(cipher.rawValue)
                                    .font(AppFonts.caption)
                                    .foregroundColor(selectedCipher == cipher ? AppColors.primaryGreen : AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedCipher == cipher ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCipher == cipher ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let terminalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

#Preview {
    DarkOpsView()
} 
