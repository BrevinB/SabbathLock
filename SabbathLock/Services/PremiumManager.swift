import Foundation
import StoreKit

/// Manages premium subscription state and StoreKit interactions
@MainActor
class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var purchaseError: String?
    @Published var isLoading: Bool = false

    /// Product identifiers — configure these in App Store Connect
    static let monthlyProductID = "com.sabbathlock.premium.monthly"
    static let yearlyProductID = "com.sabbathlock.premium.yearly"

    private let premiumKey = "IsPremiumUser"

    private init() {
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)

        Task {
            await loadProducts()
            await listenForTransactions()
        }
    }

    // MARK: - Products

    /// Load available products from App Store Connect
    func loadProducts() async {
        isLoading = true
        do {
            let productIDs: Set<String> = [
                Self.monthlyProductID,
                Self.yearlyProductID
            ]
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            purchaseError = "Failed to load products: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Purchase

    /// Purchase a product
    func purchase(_ product: Product) async {
        isLoading = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePremiumStatus(true)
                await transaction.finish()

            case .userCancelled:
                break

            case .pending:
                purchaseError = "Purchase is pending approval."

            @unknown default:
                purchaseError = "Unknown purchase result."
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        purchaseError = nil

        do {
            try await AppStore.sync()

            var hasPremium = false
            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result) {
                    if transaction.productID == Self.monthlyProductID ||
                       transaction.productID == Self.yearlyProductID {
                        hasPremium = true
                    }
                }
            }

            await updatePremiumStatus(hasPremium)

            if !hasPremium {
                purchaseError = "No active subscription found."
            }
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Transaction Listening

    /// Listen for transaction updates (renewals, revocations, etc.)
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                if transaction.revocationDate != nil {
                    await updatePremiumStatus(false)
                } else {
                    await updatePremiumStatus(true)
                }
                await transaction.finish()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePremiumStatus(_ premium: Bool) async {
        isPremium = premium
        UserDefaults.standard.set(premium, forKey: premiumKey)
    }

    // MARK: - Premium Feature Checks

    /// Whether automatic scheduling is available
    var canUseAutoSchedule: Bool { isPremium }

    /// Whether custom shield messages are available
    var canCustomizeShield: Bool { isPremium }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
