//
//  SeedDataService.swift
//  PlateShareBD
//
//  Seeds demo donor profiles and food listings around KUET on first launch.
//  Idempotent: guarded by both a UserDefaults flag and a Firestore existence check.
//  NOTE: Requires Firestore security rules that permit creates in the dev environment.
//

import Foundation
import FirebaseFirestore

final class SeedDataService {
    static let shared = SeedDataService()
    private init() {}

    private let db = Firestore.firestore()

    var needsSeeding: Bool {
        !UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hasSeededDemoData)
    }

    // MARK: - Entry Point

    func seedIfNeeded() async {
        guard needsSeeding else { return }

        do {
            // Secondary guard: if Firestore already has listings, skip
            let existing = try await db.collection(FirestoreKeys.Collections.listings)
                .limit(to: 1)
                .getDocuments()
            guard existing.isEmpty else {
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasSeededDemoData)
                return
            }

            try await seedDonors()
            try await seedListings()
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasSeededDemoData)
            print("[SeedDataService] Seeded demo data successfully.")
        } catch {
            // Non-fatal — app works without seed data
            print("[SeedDataService] Seeding failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Donor Profiles

    private func seedDonors() async throws {
        let donors = Self.sampleDonors
        for donor in donors {
            let data = try Firestore.Encoder().encode(donor)
            try await db.collection(FirestoreKeys.Collections.users)
                .document(donor.id)
                .setData(data, merge: true)
        }
    }

    // MARK: - Food Listings

    private func seedListings() async throws {
        let listings = Self.sampleListings
        for listing in listings {
            let data = try Firestore.Encoder().encode(listing)
            try await db.collection(FirestoreKeys.Collections.listings)
                .document(listing.id)
                .setData(data, merge: true)
        }
    }

    // MARK: - Sample Donors

    static let sampleDonors: [PSUser] = [
        PSUser(
            id: "seed_donor_001",
            displayName: "Karim Rahman",
            email: "karim.rahman@demo.plateshare",
            area: "KUET Campus, Khulna",
            profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face",
            phoneNumber: "+8801711000001",
            isVerified: true,
            donorRating: 4.8,
            totalDonations: 23,
            fcmToken: nil,
            preferredLanguage: "bn",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 30)
        ),
        PSUser(
            id: "seed_donor_002",
            displayName: "Fatema Begum",
            email: "fatema.begum@demo.plateshare",
            area: "Boyra, Khulna",
            profileImageURL: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face",
            phoneNumber: nil,
            isVerified: true,
            donorRating: 4.9,
            totalDonations: 41,
            fcmToken: nil,
            preferredLanguage: "bn",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 60)
        ),
        PSUser(
            id: "seed_donor_003",
            displayName: "Rashed Ahmed",
            email: "rashed.ahmed@demo.plateshare",
            area: "Khulna City",
            profileImageURL: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face",
            phoneNumber: "+8801911000003",
            isVerified: false,
            donorRating: 4.5,
            totalDonations: 12,
            fcmToken: nil,
            preferredLanguage: "en",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 15)
        ),
        PSUser(
            id: "seed_donor_004",
            displayName: "Nusrat Jahan",
            email: "nusrat.jahan@demo.plateshare",
            area: "Sonadanga, Khulna",
            profileImageURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&crop=face",
            phoneNumber: nil,
            isVerified: true,
            donorRating: 5.0,
            totalDonations: 67,
            fcmToken: nil,
            preferredLanguage: "bn",
            createdAt: Date(timeIntervalSinceNow: -60 * 60 * 24 * 90)
        )
    ]

    // MARK: - Sample Listings (12 items around KUET: 22.8998, 89.5022, within 2 km)

    static let sampleListings: [FoodListing] = [
        FoodListing(
            id: "seed_listing_001",
            donorId: "seed_donor_004",
            donorName: "Nusrat Jahan",
            title: "কাচ্চি বিরিয়ানি (Kacchi Biryani)",
            description: "Wedding surplus — 30 portions of authentic Dhakaiya kacchi biryani with raita and salad. Still warm.",
            category: .biryani,
            quantity: "Serves 30",
            imageURLs: [
                "https://images.unsplash.com/photo-1645177628172-a786b461099a?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "House 12, KUET Staff Quarters, Khulna",
            latitude: 22.8998,
            longitude: 89.5022,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 3 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -30 * 60)
        ),
        FoodListing(
            id: "seed_listing_002",
            donorId: "seed_donor_001",
            donorName: "Karim Rahman",
            title: "ইলিশ ভাপা ও ভাত (Ilish Bhapa with Rice)",
            description: "Freshly cooked hilsa fish steamed with mustard — enough for 8 people. From a family gathering.",
            category: .fish,
            quantity: "Serves 8",
            imageURLs: [
                "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "KUET Campus, Near Hall No. 2, Khulna",
            latitude: 22.9050,
            longitude: 89.5080,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 2 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -45 * 60)
        ),
        FoodListing(
            id: "seed_listing_003",
            donorId: "seed_donor_002",
            donorName: "Fatema Begum",
            title: "মোরগ পোলাও (Morog Polao)",
            description: "Chicken polao cooked for an Eid gathering — about 15 portions remaining with korma sauce.",
            category: .rice,
            quantity: "Serves 15",
            imageURLs: [
                "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Plot 5, Boyra Housing, Khulna",
            latitude: 22.8950,
            longitude: 89.4980,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 4 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -60 * 60)
        ),
        FoodListing(
            id: "seed_listing_004",
            donorId: "seed_donor_003",
            donorName: "Rashed Ahmed",
            title: "গরুর মাংস ভুনা (Beef Bhuna) + রুটি",
            description: "Restaurant surplus — beef bhuna with freshly made roti, approx 20 servings. Spicy.",
            category: .curry,
            quantity: "Serves 20",
            imageURLs: [
                "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Khulna City College Road, Near KUET Gate 1",
            latitude: 22.9010,
            longitude: 89.4950,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 5 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -20 * 60)
        ),
        FoodListing(
            id: "seed_listing_005",
            donorId: "seed_donor_004",
            donorName: "Nusrat Jahan",
            title: "মিষ্টি দই ও রসগোল্লা (Mishti Doi & Rosogolla)",
            description: "Dessert from a dawat — 3 kg of mishti doi and 2 kg rosogolla from a famous Khulna shop.",
            category: .sweets,
            quantity: "3 kg + 2 kg",
            imageURLs: [
                "https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Sonadanga R/A, House 77, Khulna",
            latitude: 22.8940,
            longitude: 89.5100,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 6 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -15 * 60)
        ),
        FoodListing(
            id: "seed_listing_006",
            donorId: "seed_donor_001",
            donorName: "Karim Rahman",
            title: "ইফতারের থালি (Iftar Platter)",
            description: "Leftover iftar platters: piyaju, beguni, halim, dates and jilapi — 10 full sets remaining.",
            category: .iftar,
            quantity: "10 platters",
            imageURLs: [
                "https://images.unsplash.com/photo-1606914907888-31f0a782c5f7?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "KUET Faculty Mosque Area, Khulna",
            latitude: 22.9070,
            longitude: 89.5150,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 1 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -10 * 60)
        ),
        FoodListing(
            id: "seed_listing_007",
            donorId: "seed_donor_002",
            donorName: "Fatema Begum",
            title: "ডাল-ভাত-তরকারি (Dal Bhat Tarkari)",
            description: "Home-cooked lentil soup, white rice and mixed vegetables — classic Bangladeshi meal for 12.",
            category: .rice,
            quantity: "Serves 12",
            imageURLs: [
                "https://images.unsplash.com/photo-1567337710282-00832b415979?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Khalishpur, Near KUET Road, Khulna",
            latitude: 22.8880,
            longitude: 89.5050,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 3 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -90 * 60)
        ),
        FoodListing(
            id: "seed_listing_008",
            donorId: "seed_donor_003",
            donorName: "Rashed Ahmed",
            title: "সেমাই ও ফিরনি (Shemai & Firni)",
            description: "Eid special — vermicelli with condensed milk and creamy firni. About 25 servings.",
            category: .sweets,
            quantity: "Serves 25",
            imageURLs: [
                "https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "KUET Industrial Area Gate, Khulna",
            latitude: 22.9030,
            longitude: 89.4850,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 5 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -2 * 60 * 60)
        ),
        FoodListing(
            id: "seed_listing_009",
            donorId: "seed_donor_004",
            donorName: "Nusrat Jahan",
            title: "পিঠা সমগ্র (Pitha Assortment)",
            description: "Homemade pitha: chitoi pitha, bhapa pitha and puli pitha — 40 pieces from a winter gathering.",
            category: .bakery,
            quantity: "40 pieces",
            imageURLs: [
                "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Rupsha River Side, Near KUET Bridge, Khulna",
            latitude: 22.8970,
            longitude: 89.5200,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 4 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -3 * 60 * 60)
        ),
        FoodListing(
            id: "seed_listing_010",
            donorId: "seed_donor_001",
            donorName: "Karim Rahman",
            title: "শাহী টুকরো (Shahi Tukra)",
            description: "Bread pudding soaked in sweetened milk with nuts and saffron — 20 portions from a conference.",
            category: .sweets,
            quantity: "Serves 20",
            imageURLs: [
                "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "KUET CSE Building Area, Khulna",
            latitude: 22.9110,
            longitude: 89.5000,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 2 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -4 * 60 * 60)
        ),
        FoodListing(
            id: "seed_listing_011",
            donorId: "seed_donor_002",
            donorName: "Fatema Begum",
            title: "ফলের ঝুড়ি (Seasonal Fruit Basket)",
            description: "Mixed fruits from a corporate event — banana, guava, papaya, watermelon. About 5 kg total.",
            category: .fruits,
            quantity: "5 kg",
            imageURLs: [
                "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Fulbarigate, Khulna City",
            latitude: 22.8850,
            longitude: 89.4900,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 8 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -30 * 60)
        ),
        FoodListing(
            id: "seed_listing_012",
            donorId: "seed_donor_003",
            donorName: "Rashed Ahmed",
            title: "মুরগির ঝোল ও নান রুটি (Chicken Jhol + Naan)",
            description: "Restaurant closing surplus — chicken curry with naan bread, 18 full portions.",
            category: .curry,
            quantity: "Serves 18",
            imageURLs: [
                "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "Khulna New Market Area, Near KUET Road",
            latitude: 22.9000,
            longitude: 89.5300,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 2 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -1 * 60 * 60)
        ),
        FoodListing(
            id: "seed_listing_013",
            donorId: "seed_donor_004",
            donorName: "Nusrat Jahan",
            title: "নিহারি ও পরোটা (Nihari + Parota)",
            description: "Slow-cooked beef nihari with freshly layered parotas — 22 portions from a dawat surplus.",
            category: .curry,
            quantity: "Serves 22",
            imageURLs: [
                "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&auto=format&fit=crop"
            ],
            pickupAddress: "KUET Staff Club Area, Khulna",
            latitude: 22.9020,
            longitude: 89.5060,
            isHalal: true,
            isAvailable: true,
            expiresAt: Date(timeIntervalSinceNow: 3 * 60 * 60),
            createdAt: Date(timeIntervalSinceNow: -50 * 60)
        )
    ]
}
