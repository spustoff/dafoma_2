import SwiftUI

struct ReferenceVaultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEntry: ReferenceEntry? = nil
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var animationPhase = 0.0
    
    private let categories = ["All", "Classical Ciphers", "Modern Encoding", "Communication Systems", "General Knowledge"]
    
    private var filteredEntries: [ReferenceEntry] {
        let categoryFiltered = selectedCategory == "All" ? 
            ReferenceEntry.entries : 
            ReferenceEntry.entries.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { entry in
                entry.title.lowercased().contains(searchText.lowercased()) ||
                entry.description.lowercased().contains(searchText.lowercased()) ||
                entry.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    headerSection
                    searchAndFilterSection
                    contentSection
                }
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedEntry) { entry in
            ReferenceDetailView(entry: entry)
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
                    Text("Reference")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text("VAULT")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(2)
                }
                
                Spacer()
                
                // Info button
                Button(action: {}) {
                    Image(systemName: "info.circle")
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
            
            statusIndicator
        }
        .padding(.horizontal, AppLayout.padding)
        .padding(.top, AppLayout.padding)
    }
    
    private var statusIndicator: some View {
        HStack {
            statusPill("TOTAL", value: "\(ReferenceEntry.entries.count)", color: AppColors.primaryGreen)
            Spacer()
            statusPill("FILTERED", value: "\(filteredEntries.count)", color: AppColors.accentOrange)
            Spacer()
            statusPill("STATUS", value: "LOADED", color: AppColors.primaryRed)
        }
        .padding(.horizontal, 8)
    }
    
    private func statusPill(_ label: String, value: String, color: Color) -> some View {
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
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("Search reference materials...", text: $searchText)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(searchBackground)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        CategoryPill(
                            title: category,
                            isSelected: selectedCategory == category,
                            animationPhase: animationPhase
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, AppLayout.padding)
            }
        }
        .padding(.horizontal, AppLayout.padding)
        .padding(.vertical, 12)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredEntries) { entry in
                    ReferenceEntryCard(entry: entry) {
                        selectedEntry = entry
                    }
                }
                
                if filteredEntries.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal, AppLayout.padding)
            .padding(.bottom, AppLayout.padding)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No Results Found")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Try adjusting your search or filter criteria")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.linear(duration: 0.1)) {
            animationPhase = 1.0
        }
    }
    
    private var searchBackground: some View {
        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            .fill(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: AppColors.neonGlow, radius: 4)
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

// MARK: - Category Pill Component
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let animationPhase: Double
    let action: () -> Void
    
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(isSelected ? AppColors.background : AppColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(pillBackground)
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
    
    private var pillBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? AppColors.primaryGreen : AppColors.cardBackground.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? AppColors.primaryGreen : AppColors.textSecondary.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primaryGreen.opacity(glowIntensity) : Color.clear,
                radius: 4
            )
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.7
        }
    }
}

// MARK: - Reference Entry Card Component
struct ReferenceEntryCard: View {
    let entry: ReferenceEntry
    let action: () -> Void
    
    @State private var cardScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                headerRow
                descriptionText
                footerRow
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .scaleEffect(cardScale)
            .onAppear {
                startCardAnimation()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(entry.category)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.accentOrange)
                    .tracking(1)
            }
            
            Spacer()
            
            if let cipherType = entry.cipherType {
                Image(systemName: cipherType.icon)
                    .font(.title2)
                    .foregroundColor(AppColors.primaryGreen)
                    .shadow(color: AppColors.neonGlow, radius: 4)
            } else {
                Image(systemName: "book")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryGreen)
                    .shadow(color: AppColors.neonGlow, radius: 4)
            }
        }
    }
    
    private var descriptionText: some View {
        Text(entry.description)
            .font(AppFonts.body)
            .foregroundColor(AppColors.textSecondary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    private var footerRow: some View {
        HStack {
            Text("TAP TO READ more")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                .tracking(1)
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(AppColors.primaryGreen)
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
    
    private func startCardAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            cardScale = 1.01
        }
    }
}

// MARK: - Reference Detail View
struct ReferenceDetailView: View {
    let entry: ReferenceEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    contentSection
                }
                .padding(AppLayout.padding)
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text(entry.category.uppercased())
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(2)
                }
                
                Spacer()
                
                if let cipherType = entry.cipherType {
                    VStack {
                        Image(systemName: cipherType.icon)
                            .font(.largeTitle)
                            .foregroundColor(AppColors.primaryGreen)
                            .shadow(color: AppColors.neonGlow, radius: 8)
                        
                        Text("CIPHER")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(1)
                    }
                }
            }
            
            Text(entry.description)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .padding(.vertical, 8)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DETAILED INFORMATION")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.accentOrange)
                .tracking(1)
            
            Text(entry.content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.cardBackground.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                )
        )
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

#Preview {
    ReferenceVaultView()
        .preferredColorScheme(.dark)
} 