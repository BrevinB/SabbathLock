import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Features
                    featuresSection

                    // Products
                    productsSection

                    // Restore
                    restoreButton

                    // Legal
                    legalSection
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Upgrade to Premium")
                .font(.title.bold())

            Text("Unlock automatic scheduling and advanced features for a more peaceful Sabbath.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            featureRow(
                icon: "clock.badge.checkmark.fill",
                color: .green,
                title: "Automatic Scheduling",
                description: "Set it and forget it — Sabbath mode activates on your schedule."
            )

            featureRow(
                icon: "paintbrush.fill",
                color: .purple,
                title: "Custom Shield Messages",
                description: "Personalize what you see when trying to open blocked apps."
            )

            featureRow(
                icon: "bell.badge.fill",
                color: .blue,
                title: "Smart Notifications",
                description: "Get a heads-up before Sabbath starts so you can prepare."
            )

            featureRow(
                icon: "heart.fill",
                color: .red,
                title: "Support Development",
                description: "Help us keep improving SabbathLock for the community."
            )
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Products

    private var productsSection: some View {
        VStack(spacing: 12) {
            if premiumManager.isLoading {
                ProgressView()
                    .padding()
            } else if premiumManager.products.isEmpty {
                Text("Products unavailable. Please try again later.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()

                Button("Retry") {
                    Task { await premiumManager.loadProducts() }
                }
            } else {
                ForEach(premiumManager.products, id: \.id) { product in
                    productCard(product)
                }
            }

            if let error = premiumManager.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func productCard(_ product: Product) -> some View {
        Button {
            Task { await premiumManager.purchase(product) }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.title3.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(premiumManager.isLoading)
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task { await premiumManager.restorePurchases() }
        }
        .font(.subheadline)
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: 4) {
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
            Text("Payment will be charged to your Apple ID account at confirmation of purchase.")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    PaywallView()
        .environmentObject(PremiumManager.shared)
}
