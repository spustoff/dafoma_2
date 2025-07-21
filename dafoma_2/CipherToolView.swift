import SwiftUI

struct CipherToolView: View {
    @StateObject private var viewModel: CipherToolViewModel
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var terminalAnimation = false
    @State private var showingParameters = false
    
    init(cipher: CipherType, appViewModel: AppViewModel) {
        self._viewModel = StateObject(wrappedValue: CipherToolViewModel(cipher: cipher))
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: AppLayout.padding) {
                        headerSection
                        parameterSection
                        inputSection
                        processingIndicator
                        outputSection
                        actionButtons
                    }
                    .padding(AppLayout.padding)
                }
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            startTerminalAnimation()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryRed)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 4)
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(viewModel.cipher.rawValue)
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text("CIPHER TOOL")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(2)
                }
                
                Spacer()
                
                Button(action: { showingParameters.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.accentOrange)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.accentOrange.opacity(0.3), radius: 4)
                        )
                }
            }
            
            modeToggle
        }
    }
    
    private var modeToggle: some View {
        HStack(spacing: 0) {
            modeButton("ENCODE", isSelected: viewModel.isEncoding, color: AppColors.primaryGreen) {
                if !viewModel.isEncoding {
                    viewModel.isEncoding = true
                }
            }
            
            modeButton("DECODE", isSelected: !viewModel.isEncoding, color: AppColors.primaryRed) {
                if viewModel.isEncoding {
                    viewModel.isEncoding = false
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.neonGlow, radius: 4)
        )
    }
    
    private func modeButton(_ title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(isSelected ? AppColors.background : AppColors.textSecondary)
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(isSelected ? color : Color.clear)
                        .shadow(color: isSelected ? color.opacity(0.5) : Color.clear, radius: 4)
                )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    // MARK: - Parameter Section
    @ViewBuilder
    private var parameterSection: some View {
        if showingParameters && needsParameters {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("PARAMETERS", icon: "slider.horizontal.3")
                
                switch viewModel.cipher {
                case .caesar:
                    caesarParameters
                case .substitution:
                    substitutionParameters
                default:
                    EmptyView()
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
        }
    }
    
    private var caesarParameters: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Shift Amount:")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.caesarShift)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.primaryGreen)
                    .shadow(color: AppColors.neonGlow, radius: 2)
            }
            
            Slider(value: Binding(
                get: { Double(viewModel.caesarShift) },
                set: { viewModel.caesarShift = Int($0) }
            ), in: 1...25, step: 1)
            .accentColor(AppColors.primaryGreen)
        }
        .padding(16)
        .background(parameterBackground)
    }
    
    private var substitutionParameters: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Substitution Key (26 characters):")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            TextField("Enter 26-character key", text: $viewModel.substitutionKey)
                .font(AppFonts.cipherResult)
                .foregroundColor(AppColors.textPrimary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.background.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.accentOrange.opacity(0.3), lineWidth: 1)
                        )
                )
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
        }
        .padding(16)
        .background(parameterBackground)
    }
    
    private var parameterBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(AppColors.cardBackground.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColors.accentOrange.opacity(0.3), lineWidth: 1)
            )
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("INPUT", icon: "keyboard")
            
            ZStack(alignment: .topLeading) {
                if viewModel.inputText.isEmpty {
                    Text("Enter text to \(viewModel.isEncoding ? "encode" : "decode")...")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, 12)
                }
                
                TextEditor(text: $viewModel.inputText)
                    .font(AppFonts.cipherResult)
                    .foregroundColor(AppColors.textPrimary)
                    .background(Color.clear)
                    .frame(minHeight: 100)
            }
            .padding(12)
            .background(textFieldBackground)
            
            inputToolbar
        }
    }
    
    private var inputToolbar: some View {
        HStack {
            Button("Paste") {
                viewModel.pasteInput()
            }
            .buttonStyle(ToolbarButtonStyle(color: AppColors.accentOrange))
            
            Button("Clear") {
                viewModel.inputText = ""
            }
            .buttonStyle(ToolbarButtonStyle(color: AppColors.primaryRed))
            
            Spacer()
            
            Text("\(viewModel.inputText.count) chars")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    // MARK: - Processing Indicator
    @ViewBuilder
    private var processingIndicator: some View {
        if viewModel.isProcessing {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.7)
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryGreen))
                
                Text("PROCESSING...")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryGreen)
                    .tracking(1)
            }
            .padding(.vertical, 8)
            .transition(.opacity)
        }
    }
    
    // MARK: - Output Section
    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("OUTPUT", icon: "doc.text")
            
            ZStack(alignment: .topLeading) {
                if viewModel.outputText.isEmpty && !viewModel.isProcessing {
                    Text("Processed text will appear here...")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, 12)
                }
                
                ScrollView {
                    Text(viewModel.outputText)
                        .font(AppFonts.cipherResult)
                        .foregroundColor(AppColors.primaryGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .animation(.easeInOut, value: viewModel.outputText)
                        .opacity(terminalAnimation ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: terminalAnimation)
                }
                .frame(minHeight: 100)
            }
            .background(outputBackground)
            
            outputToolbar
        }
    }
    
    private var outputToolbar: some View {
        HStack {
            Button("Copy") {
                viewModel.copyOutput()
            }
            .buttonStyle(ToolbarButtonStyle(color: AppColors.primaryGreen))
            .disabled(viewModel.outputText.isEmpty)
            
            Spacer()
            
            if !viewModel.outputText.isEmpty {
                Text("\(viewModel.outputText.count) chars")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: viewModel.swapInputOutput) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.headline)
                    
                    Text("SWAP INPUT/OUTPUT")
                        .font(AppFonts.headline)
                        .tracking(1)
                }
                .foregroundColor(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(AppColors.accentOrange)
                        .shadow(color: AppColors.accentOrange.opacity(0.5), radius: 8)
                )
            }
            .disabled(viewModel.outputText.isEmpty)
            
            Button(action: saveOperation) {
                HStack(spacing: 8) {
                    Image(systemName: "archivebox")
                        .font(.headline)
                    
                    Text("SAVE TO HISTORY")
                        .font(AppFonts.headline)
                        .tracking(1)
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.primaryGreen, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColors.cardBackground)
                        )
                )
            }
            .disabled(viewModel.outputText.isEmpty)
        }
    }
    
    // MARK: - Helper Functions
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(AppColors.accentOrange)
            
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .tracking(1)
        }
    }
    
    private func saveOperation() {
        guard !viewModel.inputText.isEmpty && !viewModel.outputText.isEmpty else { return }
        
        var parameters: [String: Any] = [:]
        if viewModel.cipher == .caesar {
            parameters["shift"] = viewModel.caesarShift
        } else if viewModel.cipher == .substitution {
            parameters["key"] = viewModel.substitutionKey
        }
        
        let operation = CipherOperation(
            type: viewModel.cipher,
            input: viewModel.inputText,
            output: viewModel.outputText,
            isEncoding: viewModel.isEncoding,
            parameters: parameters
        )
        
        appViewModel.addOperation(operation)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func startTerminalAnimation() {
        withAnimation(.linear(duration: 0.1)) {
            terminalAnimation = true
        }
    }
    
    private var needsParameters: Bool {
        viewModel.cipher == .caesar || viewModel.cipher == .substitution
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(AppColors.background.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: AppColors.neonGlow, radius: 4)
    }
    
    private var outputBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(AppColors.background.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColors.primaryGreen.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 8)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppColors.background,
                AppColors.secondaryBackground,
                AppColors.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Toolbar Button Style
struct ToolbarButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    CipherToolView(cipher: .caesar, appViewModel: AppViewModel())
        .preferredColorScheme(.dark)
} 