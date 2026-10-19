# 👑 ORIGIN — Where Royalty Begins

> **A luxury digital maison curated for certified royal heirlooms, imperial jewels, and haute couture from world-renowned civilisations.**

---

## 📖 Overview

**ORIGIN** is an ultra-premium luxury e-commerce and cultural heritage platform built with **Flutter**. Designed to evoke the prestige of private royal auctions and high-end atelier galleries, ORIGIN bridges the gap between verified museum-grade antiquities and discerning global patrons.

Whether discovering an 18th-century Patiala Mughal emerald necklace, commissioning bespoke couture, or verifying provenance certificates, ORIGIN provides a bespoke, royal-class digital experience.

---

## ✨ Key Features

### 🏛️ 1. Curated Royal Collections & Civilisations
- **Imperial Jewels & Regalia**: Gemmological-certified gemstones, kundan jewellery, and ceremonial diadems.
- **Royal Wardrobe & Textiles**: Historic court robes (e.g., Joseon Dynasty Wonsam) and hand-embroidered zari garments.
- **Civilisation Journeys**: Curated heritage collections spanning **India, Korea, China, Persia, Japan, and Europe**.
- **The Royal Journal**: Long-form editorial essays and stories detailing historical eras, preservation techniques, and craftsmanship.

### 💎 2. Two Distinct Product Tiers & Cart Rules
- **Certified Antique (One-of-a-Kind)**:
  - Museum-grade artifacts with verified provenance, archival condition reports, and authentication certificates.
  - **Strict Inventory Enforcement**: Since certified antiques are unique single pieces, the cart automatically enforces a maximum quantity of `1`.
- **Royal-Inspired**:
  - Contemporary heirloom reproductions and bespoke creations handcrafted by heritage artisans.
  - Supports multi-quantity purchases and personalized sizing/finish requests.

### 🌍 3. Multi-Currency Engine
- Switch seamlessly between currencies with instant price conversion:
  - **USD** ($)
  - **INR** (₹)
  - **EUR** (€)
  - **GBP** (£)
  - **AED** (د.إ)

### 📜 4. Authenticity & Provenance Verification
- Dedicated **Authenticity Standard** detailing ORIGIN’s 4-tier verification protocol:
  - Material analysis & radiocarbon dating.
  - Archival provenance tracing & historic inventories.
  - Gemmological and textile council certification.
  - Tamper-evident digital certification viewer.

### 🛡️ 5. Private Concierge & Bespoke Enquiries
- Direct booking modal for high-net-worth patrons to request private gallery viewings or bespoke custom commissions.
- Instant submission tracking stored across patron accounts and administrative dashboards.

### 💼 6. Administrative Portal (`/admin`)
- **Executive Dashboard**: Real-time sales metrics, order volumes, active enquiries, and catalogue value.
- **Catalogue Management**: Add, update, and manage products with categorization, civilization tagging, and artefact vectors.
- **Order Tracking**: Review customer purchases, shipping status, and fulfilment records.
- **Enquiry Manager**: Manage bespoke collector queries and private appointment requests.

---

## 🏗️ Architecture & Project Structure

The project adopts a clean, feature-first modular architecture powered by **Riverpod** for state management and **GoRouter** for routing:

```text
lib/
├── app/
│   ├── router.dart              # GoRouter definitions with smooth cinematic transitions
│   └── theme.dart               # Royal color scheme, typography & custom button styles
├── core/
│   ├── animation/               # Custom painters (Lotus draw, dust particle shimmer, sway)
│   ├── fonts.dart               # Google Fonts typography definitions
│   ├── riverpod.dart            # Central provider export helpers
│   ├── utils/                   # Breakpoints (responsive mobile/tablet/desktop), price formatters
│   └── widgets/                 # Reusable UI (ArtefactArt vector renders, OriginHeader, Footer, Buttons)
├── data/
│   ├── models/                  # Domain models: Product, Order, Enquiry, Article, AppUser, Category
│   └── repositories/            # In-memory & reactive state: ProductRepository, Cart, Currency, Seed Data
├── features/
│   ├── account/                 # Patron account profile, past orders, and preferences
│   ├── admin/                   # Administrative portal (Catalogue, Orders, Enquiries)
│   ├── auth/                    # Patron authentication dialogs, Riverpod AuthController
│   ├── authenticity/            # The ORIGIN Authenticity & Provenance pledge page
│   ├── cart/                    # Shopping bag, checkout flow, and order confirmation
│   ├── enquiry/                 # Bespoke inquiry & private appointment scheduling
│   ├── heritage/                # Civilization detail showcases
│   ├── journal/                 # Cultural articles and reading room
│   ├── landing/                 # Hero gallery, interactive arches, animated teaser banner
│   ├── legal/                   # Terms of service, privacy policy, and shipping policies
│   ├── shop/                    # Filterable catalogue (by civilization, category, price, type)
│   └── wishlist/                # Saved patron favorites
└── main.dart                    # Application entry point mounting ProviderScope
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, Dart 3.13+)
- **State Management**: [Riverpod 3.x](https://riverpod.dev/) (`flutter_riverpod`)
- **Navigation & Deep Linking**: [GoRouter 18.x](https://pub.dev/packages/go_router)
- **Local Persistence**: `shared_preferences`
- **Formatting**: `intl`
- **Design System**:
  - Palette: Imperial Ivory (`#FDFBF7`), Royal Bronze (`#1B1713`), Antique Gold (`#C5A059`), and Silk Accents.
  - Typography: *Playfair Display*, *Cormorant Garamond*, and *Montserrat*.
  - Procedural Canvas Art: Handcrafted Flutter CustomPainters rendering vector artefacts without external heavy assets.

---

## 🚀 Getting Started

### Prerequisites

Ensure you have installed:
1. **Flutter SDK** (Version >= 3.13.5):
   ```bash
   flutter --version
   ```
2. **Google Chrome** (for web) or **Visual Studio C++ Build Tools** (for Windows desktop).

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/origin.git
   cd origin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**

   - **Run on Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```

   - **Run on Windows Desktop:**
     ```bash
     flutter run -d windows
     ```

   - **Run on Mobile Simulator / Connected Device:**
     ```bash
     flutter run
     ```

---

## 🧪 Running Automated Tests

Run the test suite verifying unit tests, single-quantity antique enforcement, and currency converters:

```bash
flutter test
```

Expected output:
```text
All tests passed!
```

---

## 🔑 Demo Access & Key Routes

You can navigate directly through the application header or via URL routes:

| Route | Page Description | Quick Note |
|---|---|---|
| `/` | **Landing Page** | Hero slideshow, civilization arches, featured treasures |
| `/shop` | **The Royal Catalogue** | Filter by category, type (Antique / Inspired), and civilization |
| `/authenticity` | **Authenticity & Care** | Archival protocols and verification standard |
| `/journal` | **The Royal Journal** | Editorial essays and craftsmanship chronicles |
| `/cart` | **Patron Bag** | Real-time totals and single-item validation |
| `/checkout` | **Checkout** | Bespoke white-glove shipping form |
| `/account` | **Patron Profile** | View saved orders and member perks |
| `/admin` | **Curator Admin Portal** | Manage products, track orders and review inquiries |

### Quick Admin Login
To access the Admin Portal:
- Click the **Patron / Login** button in the header.
- Enter any email containing `admin` (e.g. `admin@origin.com`) with any password (min 6 characters).
- You will be automatically granted the **Imperial Curator (Admin)** role.

---

## 🤝 Contributing

Contributions are welcomed to expand civilizations, add editorial stories, or optimize render performance.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

# DEVLOPER NAME: Pravallika Gogineni

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
