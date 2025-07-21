import SwiftUI

struct HomeView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var animationPhase = 0.0
    @State private var selectedCard: CipherType? = nil
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: AppLayout.cardSpacing), count: 2)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: AppLayout.padding) {
                    headerSection
                    cipherGrid
                    recentOperationsSection
                }
                .padding(AppLayout.padding)
            }
        }
        .background(backgroundGradient)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CodeCipher")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text("UTILITY")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(2)
                }
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationPhase)
                
                Spacer()
                
                Button(action: {
                    appViewModel.showingDarkOps = true
                }) {
                    Image(systemName: "display")
                        .font(.title2)
                        .foregroundColor(AppColors.primaryRed)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 4)
                        )
                }
                .scaleEffect(animationPhase == 0 ? 1.0 : 1.05)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationPhase)
            }
            
            statusBar
        }
    }
    
    private var statusBar: some View {
        HStack {
            statusIndicator(label: "CIPHER", value: "\(CipherType.allCases.count)", color: AppColors.primaryGreen)
            Spacer()
            statusIndicator(label: "OPERATIONS", value: "\(appViewModel.operations.count)", color: AppColors.accentOrange)
            Spacer()
            statusIndicator(label: "STATUS", value: "READY", color: AppColors.primaryRed)
        }
        .padding(.horizontal, 8)
    }
    
    private func statusIndicator(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
                .tracking(1)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 2)
        }
    }
    
    // MARK: - Cipher Grid
    private var cipherGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("CIPHER TOOLKIT", icon: "lock.shield")
            
            LazyVGrid(columns: columns, spacing: AppLayout.cardSpacing) {
                ForEach(CipherType.allCases) { cipher in
                    CipherCard(
                        cipher: cipher,
                        isSelected: selectedCard == cipher,
                        animationPhase: animationPhase
                    ) {
                        selectCipher(cipher)
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Operations Section
    private var recentOperationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionHeader("RECENT OPERATIONS", icon: "clock.arrow.circlepath")
                Spacer()
                if !appViewModel.operations.isEmpty {
                    Button("Clear") {
                        withAnimation(.easeInOut) {
                            appViewModel.clearHistory()
                        }
                    }
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            
            if appViewModel.operations.isEmpty {
                emptyStateView
            } else {
                recentOperationsList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No operations yet")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Select a cipher to start encoding")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.cardBackground.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var recentOperationsList: some View {
        VStack(spacing: 8) {
            ForEach(Array(appViewModel.operations.prefix(3).enumerated()), id: \.1.timestamp) { index, operation in
                OperationRow(operation: operation, index: index)
            }
            
            if appViewModel.operations.count > 3 {
                Text("+ \(appViewModel.operations.count - 3) more operations")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 8)
            }
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
    
    private func selectCipher(_ cipher: CipherType) {
        selectedCard = cipher
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            appViewModel.selectCipher(cipher)
            selectedCard = nil
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 0.1)) {
            animationPhase = 1.0
        }
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

// MARK: - Cipher Card Component
struct CipherCard: View {
    let cipher: CipherType
    let isSelected: Bool
    let animationPhase: Double
    let action: () -> Void
    
    @State private var cardScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                iconSection
                contentSection
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(cardBackground)
            .scaleEffect(isSelected ? 0.95 : cardScale)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            startCardAnimations()
        }
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryGreen.opacity(0.2), AppColors.accentOrange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .shadow(color: AppColors.primaryGreen.opacity(glowIntensity), radius: 6)
            
            Image(systemName: cipher.icon)
                .font(.title2)
                .foregroundColor(AppColors.primaryGreen)
                .shadow(color: AppColors.neonGlow, radius: 4)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 4) {
            Text(cipher.rawValue)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(cipher.description)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.primaryGreen.opacity(0.3), AppColors.accentOrange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: AppColors.primaryGreen.opacity(0.1), radius: 8)
    }
    
    private func startCardAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            cardScale = 1.02
            glowIntensity = 0.6
        }
    }
}

// MARK: - Operation Row Component
struct OperationRow: View {
    let operation: CipherOperation
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            operationIcon
            operationDetails
            Spacer()
            timeStamp
        }
        .padding(12)
        .background(rowBackground)
        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
    }
    
    private var operationIcon: some View {
        Image(systemName: operation.type.icon)
            .font(.caption)
            .foregroundColor(operation.isEncoding ? AppColors.primaryGreen : AppColors.primaryRed)
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .fill(operation.isEncoding ? AppColors.primaryGreen.opacity(0.2) : AppColors.primaryRed.opacity(0.2))
            )
    }
    
    private var operationDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(operation.type.rawValue)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPrimary)
            
            Text(operation.isEncoding ? "ENCODE" : "DECODE")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
                .tracking(1)
        }
    }
    
    private var timeStamp: some View {
        Text(RelativeDateTimeFormatter().localizedString(for: operation.timestamp, relativeTo: Date()))
            .font(.caption2)
            .foregroundColor(AppColors.textSecondary)
    }
    
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(AppColors.cardBackground.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    HomeView(appViewModel: AppViewModel())
        .preferredColorScheme(.dark)
} 