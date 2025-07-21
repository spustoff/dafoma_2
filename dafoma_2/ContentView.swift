//
//  ContentView.swift
//  dafoma_2
//
//  Created by Вячеслав on 7/18/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @State private var showingCipherTool = false
    @State private var showingReferenceVault = false
    @State private var showingDarkOps = false
    @State private var showingExport = false
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            TabView(selection: $appViewModel.currentScreen) {
                // Home Tab
                HomeView(appViewModel: appViewModel)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(AppScreen.home)
                
                // Reference Tab
                Button(action: { showingReferenceVault = true }) {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Reference")
                }
                .tag(AppScreen.reference)
                
                // DarkOps Tab
                Button(action: { showingDarkOps = true }) {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "terminal.fill")
                    Text("DarkOps")
                }
                .tag(AppScreen.darkOps)
                
                // Export Tab
                Button(action: { showingExport = true }) {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Export")
                }
                .tag(AppScreen.export)
            }
            .accentColor(AppColors.primaryGreen)
            .preferredColorScheme(.dark)
            .onAppear {
                setupTabBarAppearance()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $appViewModel.showingCipherTool) {
            CipherToolView(cipher: appViewModel.selectedCipher, appViewModel: appViewModel)
        }
        .fullScreenCover(isPresented: $showingReferenceVault) {
            ReferenceVaultView()
        }
        .fullScreenCover(isPresented: $showingDarkOps) {
            DarkOpsView()
        }
        .fullScreenCover(isPresented: $showingExport) {
            ExportView(appViewModel: appViewModel)
        }
        .onChange(of: appViewModel.currentScreen) { newValue in
            handleTabSelection(newValue)
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
    
    private func setupTabBarAppearance() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Tab bar background
        tabBarAppearance.backgroundColor = UIColor(AppColors.background.opacity(0.95))
        
        // Normal state
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.textSecondary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.primaryGreen)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.primaryGreen),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Add subtle border
        UITabBar.appearance().layer.borderWidth = 1
        UITabBar.appearance().layer.borderColor = UIColor(AppColors.primaryGreen.opacity(0.2)).cgColor
    }
    
    private func handleTabSelection(_ screen: AppScreen) {
        // Handle tab selection with haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Switch to appropriate view
        switch screen {
        case .home:
            // Already on home - no action needed
            break
        case .reference:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingReferenceVault = true
                appViewModel.currentScreen = .home // Reset to home after showing sheet
            }
        case .darkOps:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingDarkOps = true
                appViewModel.currentScreen = .home // Reset to home after showing sheet
            }
        case .export:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingExport = true
                appViewModel.currentScreen = .home // Reset to home after showing sheet
            }
        }
    }
}

// MARK: - App Launch View (for onboarding)
struct AppLaunchView: View {
    @AppStorage("showingMainApp") private var showingMainApp = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var showingFeatures = false
    
    var body: some View {
        ZStack {
            // Background
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
            
            if !showingMainApp {
                launchContent
            } else {
                ContentView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startLaunchAnimation()
        }
    }
    
    private var launchContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App logo and title
            VStack(spacing: 20) {
                // Logo placeholder - you can replace with custom logo
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.primaryGreen.opacity(0.3), AppColors.accentOrange.opacity(0.1)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.shield")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 10)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                VStack(spacing: 8) {
                    Text("CodeCipher")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGreen)
                        .shadow(color: AppColors.neonGlow, radius: 8)
                    
                    Text("UTILITY")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(AppColors.accentOrange)
                        .tracking(4)
                }
                .offset(y: titleOffset)
                .opacity(logoOpacity)
            }
            
            if showingFeatures {
                featuresList
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            if showingFeatures {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showingMainApp = true
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.right")
                            .font(.headline)
                        
                        Text("GET STARTED")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .tracking(2)
                    }
                    .foregroundColor(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryGreen)
                            .shadow(color: AppColors.primaryGreen.opacity(0.5), radius: 20)
                    )
                }
                .padding(.horizontal, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, 40)
    }
    
    private var featuresList: some View {
        VStack(spacing: 20) {
            Text("Secure Offline Cipher Tool")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                featureRow(icon: "shield.lefthalf.filled", title: "Multiple Ciphers", description: "Caesar, Base64, Morse, Hex, Binary & more")
                featureRow(icon: "doc.text", title: "Reference Library", description: "Educational content about cryptography")
                featureRow(icon: "terminal", title: "DarkOps Mode", description: "Full-screen terminal interface")
                featureRow(icon: "square.and.arrow.up", title: "Export Results", description: "Share as text, JSON, or images")
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primaryGreen)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private func startLaunchAnimation() {
        // Logo animation
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            titleOffset = 0
        }
        
        // Features animation
        withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
            showingFeatures = true
        }
    }
}

#Preview {
    AppLaunchView()
}
