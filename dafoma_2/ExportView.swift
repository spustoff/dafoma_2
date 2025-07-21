import SwiftUI

struct ExportView: View {
    @StateObject private var exportViewModel = ExportViewModel()
    @ObservedObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOperation: CipherOperation?
    @State private var animationPhase = 0.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    headerSection
                    
                    if appViewModel.operations.isEmpty {
                        emptyStateView
                    } else {
                        contentSection
                    }
                }
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $exportViewModel.showingShareSheet) {
            ShareSheet(items: exportViewModel.shareItems)
        }
        .onAppear {
            startAnimations()
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
                    Text("Export")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text("VAULT")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(2)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(AppColors.accentOrange)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColors.cardBackground)
                                .shadow(color: AppColors.accentOrange.opacity(0.3), radius: 4)
                        )
                }
                .opacity(0.7)
            }
            
            exportOptionsSection
        }
        .padding(.horizontal, AppLayout.padding)
        .padding(.top, AppLayout.padding)
    }
    
    private var exportOptionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("EXPORT FORMAT")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.accentOrange)
                    .tracking(1)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    ExportFormatButton(
                        format: format,
                        isSelected: exportViewModel.selectedFormat == format,
                        animationPhase: animationPhase
                    ) {
                        exportViewModel.selectedFormat = format
                    }
                }
            }
            
            HStack {
                Toggle("Include Metadata", isOn: $exportViewModel.includeMetadata)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .toggleStyle(NeonToggleStyle())
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("OPERATION HISTORY")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.accentOrange)
                    .tracking(1)
                
                Spacer()
                
                Text("\(appViewModel.operations.count) operations")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppLayout.padding)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(appViewModel.operations.enumerated()), id: \.element.timestamp) { index, operation in
                        ExportOperationCard(
                            operation: operation,
                            index: index,
                            isSelected: selectedOperation?.timestamp == operation.timestamp
                        ) {
                            selectedOperation = operation
                            exportViewModel.prepareExport(operation: operation)
                        }
                    }
                }
                .padding(.horizontal, AppLayout.padding)
                .padding(.bottom, AppLayout.padding)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No Operations to Export")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Perform some cipher operations first, then return here to export your results.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.headline)
                    
                    Text("BACK TO HOME")
                        .font(AppFonts.headline)
                        .tracking(1)
                }
                .foregroundColor(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(AppColors.primaryGreen)
                        .shadow(color: AppColors.primaryGreen.opacity(0.5), radius: 8)
                )
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Helper Functions
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

// MARK: - Export Format Button
struct ExportFormatButton: View {
    let format: ExportFormat
    let isSelected: Bool
    let animationPhase: Double
    let action: () -> Void
    
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: format.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textSecondary)
                    .shadow(color: isSelected ? AppColors.neonGlow : Color.clear, radius: 4)
                
                Text(format.rawValue)
                    .font(AppFonts.caption)
                    .foregroundColor(isSelected ? AppColors.primaryGreen : AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(buttonBackground)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .onAppear {
            if isSelected {
                startGlowAnimation()
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                startGlowAnimation()
            }
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(isSelected ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(
                        isSelected ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primaryGreen.opacity(glowIntensity) : Color.clear,
                radius: 6
            )
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
    }
}

// MARK: - Export Operation Card
struct ExportOperationCard: View {
    let operation: CipherOperation
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    @State private var cardScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                headerSection
                
                operationDetails
                
                footerSection
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .scaleEffect(isSelected ? 0.98 : cardScale)
            .animation(.spring(response: 0.3), value: isSelected)
            .onAppear {
                startCardAnimation()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: operation.type.icon)
                    .font(.headline)
                    .foregroundColor(operation.isEncoding ? AppColors.primaryGreen : AppColors.primaryRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(operation.type.rawValue)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(operation.isEncoding ? "ENCODE" : "DECODE")
                        .font(.caption2)
                        .foregroundColor(operation.isEncoding ? AppColors.primaryGreen : AppColors.primaryRed)
                        .tracking(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("#\(index + 1)")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(RelativeDateTimeFormatter().localizedString(for: operation.timestamp, relativeTo: Date()))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var operationDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            detailRow(label: "INPUT", value: operation.input, maxLength: 60)
            detailRow(label: "OUTPUT", value: operation.output, maxLength: 60)
        }
    }
    
    private func detailRow(label: String, value: String, maxLength: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.accentOrange)
                .tracking(1)
            
            Text(value.count > maxLength ? String(value.prefix(maxLength)) + "..." : value)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
        }
    }
    
    private var footerSection: some View {
        HStack {
            HStack(spacing: 12) {
                statusPill(label: "IN", value: "\(operation.input.count)", color: AppColors.primaryGreen)
                statusPill(label: "OUT", value: "\(operation.output.count)", color: AppColors.accentOrange)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Text("TAP TO EXPORT")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    .tracking(1)
                
                Image(systemName: "square.and.arrow.up")
                    .font(.caption)
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
    }
    
    private func statusPill(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(color)
                .tracking(1)
            
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
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
    
    private func startCardAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            cardScale = 1.005
        }
    }
}

// MARK: - Neon Toggle Style
struct NeonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            Button(action: {
                configuration.isOn.toggle()
            }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.3))
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .animation(.spring(response: 0.3), value: configuration.isOn)
                    )
                    .shadow(color: configuration.isOn ? AppColors.primaryGreen.opacity(0.5) : Color.clear, radius: 4)
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView(appViewModel: AppViewModel())
        .preferredColorScheme(.dark)
} 