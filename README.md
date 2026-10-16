# 🏥 MediCare LK - Full-Stack AI E-Pharmacy & Prescription System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17%2F21%2F25-ED8B00?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase%20Cloud-336791?logo=postgresql&logoColor=white)](https://supabase.com/)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini%20Vision%20OCR-8E75C2?logo=google&logoColor=white)](https://ai.google.dev/)
[![Currency](https://img.shields.io/badge/Currency-LKR%20(Rs.)-00A389)](#)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A modern, full-stack E-Pharmacy mobile application and web administration portal developed with **Flutter** (Material 3 healthcare theme `#0D9488`), **Spring Boot 3 REST APIs**, **Spring Security + JWT**, and **PostgreSQL** (hosted on Supabase / local PostgreSQL). The system integrates **Google Gemini Vision AI** to digitize handwritten and printed prescriptions, extract medicine details with confidence scores, and deliver end-to-end pharmacy ordering and tracking in Sri Lankan Rupees (LKR).

---

## 📱 Complete Screens & Key Capabilities

| # | Screen | Description |
|---|---|---|
| **1** | **Login & Role Selector** | Modern **MediCare LK** healthcare branding, interactive **Patient / Pharmacist role toggle**, email & password authentication, demo quick-switch menu, remember me, and account registration. |
| **2** | **Home / Storefront** | Live search bar, category chips (*Pain relief*, *Cold & Flu*, *Supplements*, *First Aid*), promotional banners, and catalog with real-time LKR pricing and stock indicators. |
| **3** | **AI Prescription Scanner** | Take photo or upload prescription images from gallery, automated **Google Gemini Vision OCR** extraction, confidence ratings (96%, 95%, 92%), and prescription cards. |
| **4** | **Extracted Medicines / Cart** | Interactive medicine list with selection checkboxes, quantity steppers (+/-), real-time LKR price recalculation, and sticky footer checkout bar. |
| **5** | **Checkout & Payment** | Delivery address editor (*Kasun Perera, Galle Rd, Colombo*), order breakdown summary, Card Payment simulation (Stripe), and Cash on Delivery (COD). |
| **6** | **Live Order Tracking** | Real-time status stepper (**Pending ➔ Processing ➔ Shipped ➔ Delivered**), estimated delivery banner, and order item details. |
| **7** | **Order History** | Status filter chips (*All*, *Processing*, *Delivered*, *Cancelled*), past orders cards (`#EP1024`, `#EP1018`, `#EP1006`, `#EP0998`), and tap-to-track details. |
| **8** | **User Profile** | Personal information, delivery addresses, payment methods, notifications drawer, and direct toggle between Patient and Pharmacist mode. |
| **9** | **Pharmacist Portal** | Dedicated responsive dashboard (`/admin/index.html`) & in-app Pharmacist Screen for prescription verification, medicine pricing, order status transitions, and store preview. |

---

## 🏗️ System Architecture & Tech Stack

```plaintext
E-Pharmacy-Prescription-System/
├── backend/                                  # Spring Boot 3 Java Backend
│   ├── src/main/java/com/epharmacy/backend/
│   │   ├── config/                           # Data seeding & CORS configuration
│   │   ├── controller/                       # REST APIs (Auth, Medicine, Prescription, Order, Admin)
│   │   ├── dto/                              # Request/Response Data Transfer Objects
│   │   ├── entity/                           # JPA Entities (User, Medicine, Prescription, Order, etc.)
│   │   ├── repository/                       # Spring Data JPA Repositories
│   │   ├── security/                         # Spring Security filter & JWT utilities
│   │   └── service/                          # Business logic & Gemini Vision AI service
│   ├── src/main/resources/
│   │   ├── static/admin/index.html           # Pharmacist Admin Web Dashboard
│   │   └── application.properties            # Supabase PostgreSQL / Gemini API configuration
│   ├── uploads/                              # Stored prescription images (.gitkeep protected)
│   ├── mvnw / mvnw.cmd                       # Maven Wrapper executables
│   └── pom.xml                               # Maven project dependencies
│
├── frontend/                                 # Flutter Mobile & Web Client
│   ├── lib/
│   │   ├── models/                           # Dart data models
│   │   ├── screens/                          # 9 complete UI screens
│   │   ├── services/                         # REST API service with auto-platform IP resolution
│   │   ├── state/                            # Global state management singleton
│   │   └── main.dart                         # Main entry point, theme & role-based routing
│   ├── assets/images/                        # High-definition UI assets, logos & doctor hero banner
│   └── pubspec.yaml                          # Flutter dependencies
│
├── .gitignore                                # Comprehensive master gitignore
└── README.md                                 # Full documentation
```

---

## 🔑 Demo Credentials

Pre-seeded database accounts available for immediate testing:

| Role | Email | Password | Access Details |
|---|---|---|---|
| **Patient (Kasun Perera)** | `kasun@email.com` | `123456` | Full Patient Store, Cart, Prescription Scanner, Checkout, and Order History |
| **Pharmacist Admin** | `pharmacist@medicare.lk` | `admin123` | Pharmacist Dashboard, Prescription Review & Pricing, Order Dispatch, Store Preview |

> 💡 **Tip:** Use the top-right Quick Login button (⚡ icon) or the interactive **Patient / Pharmacist** role toggle on the login screen to autofill test credentials in 1 click!

---

## ⚡ Quick Start & Run Guide

### 1. Prerequisites
- **Java JDK 17 or higher** (JDK 21 and JDK 25 fully supported)
- **Flutter SDK `^3.12.2`** & Dart
- **PostgreSQL** (Cloud instance pre-configured via Supabase or local instance)
- **Git**

---

### 2. Database Configuration

The application is configured to connect to PostgreSQL (including Supabase Cloud PostgreSQL with connection pooling & SSL).

Credentials can be reviewed in `backend/src/main/resources/application.properties`:
```properties
# Supabase PostgreSQL Connection (IPv4 Pooler)
spring.datasource.url=jdbc:postgresql://aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require
spring.datasource.username=postgres.wwggukqeuzjqysmhlzfi
spring.datasource.password=Js$z8Vcfu%HgpQK
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

*To use a local PostgreSQL instance instead:*
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/epharmacy_db
spring.datasource.username=postgres
spring.datasource.password=your_password
```

---

### 3. Run Backend (Spring Boot)

> ⚠️ **Important:** Ensure your terminal is in the **`backend`** directory before running Maven commands:

```powershell
# Navigate into backend directory
cd backend

# Run with Maven Wrapper (Windows PowerShell)
.\mvnw spring-boot:run

# Or on macOS/Linux
./mvnw spring-boot:run
```

* The backend service will start on **`http://localhost:8080`**.
* Initial sample data (medicines, users, sample prescriptions, and orders) is automatically seeded on launch.

> 💡 **Troubleshooting Port 8080:** If you see `Port 8080 was already in use`, run this PowerShell command to terminate the existing process:
> ```powershell
> Stop-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess -Force
> ```

---

### 4. Run Frontend (Flutter)

In a separate terminal, navigate to the **`frontend`** directory:

```powershell
# Navigate into frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Google Chrome (Web):
flutter run -d chrome

# Or run on Windows Desktop:
flutter run -d windows
```

> 💡 **Hot Reload / Hot Restart:**
> - Press **`r`** in your Flutter terminal for Instant Hot Reload.
> - Press **`R` (Shift + R)** for Full Hot Restart.

---

### 5. Access Pharmacist Web Admin Portal

While the Spring Boot backend is running, open the responsive web dashboard in any browser:
```
http://localhost:8080/admin/index.html
```
Features available in the portal:
- Live review of submitted prescription requests with Gemini AI confidence indicators
- Prescription approval / rejection with pricing assignment and pharmacist notes
- Order status updates (**Pending ➔ Processing ➔ Shipped ➔ Delivered**)
- Catalog inventory management and pricing adjustment

---

## 📡 REST API Reference

### 🔐 Authentication (`/api/auth`)
- `POST /api/auth/login` - Authenticate user & issue JWT token
- `POST /api/auth/register` - Register new patient or pharmacist account
- `GET /api/auth/user/{id}` - Fetch user profile information
- `PUT /api/auth/profile/{id}` - Update profile & delivery address

### 💊 Medicine Catalog (`/api/medicines`)
- `GET /api/medicines` - List medicines (filter with `?category=` or `?search=`)
- `GET /api/medicines/{id}` - Retrieve medicine details
- `POST /api/medicines` - Create new medicine (Admin/Pharmacist)
- `PUT /api/medicines/{id}` - Update price and stock (Admin/Pharmacist)
- `DELETE /api/medicines/{id}` - Delete medicine (Admin/Pharmacist)

### 🩺 Prescriptions & AI OCR (`/api/prescriptions`)
- `POST /api/prescriptions/upload` - Upload prescription image & extract medicines with Gemini Vision
- `GET /api/prescriptions/user/{userId}` - Retrieve prescriptions for a specific user
- `GET /api/prescriptions/all` - List all prescriptions (filter with `?status=`)
- `PUT /api/prescriptions/{id}/review` - Approve/Reject prescription with notes & assigned pricing

### 📦 Orders & Tracking (`/api/orders`)
- `POST /api/orders` - Place order with delivery address & payment method
- `GET /api/orders/user/{userId}` - Customer order history
- `GET /api/orders/track/{orderNumber}` - Real-time tracking for an order (e.g. `#EP1024`)
- `GET /api/orders/all` - List all orders across system (Admin/Pharmacist)
- `PUT /api/orders/{id}/status` - Advance order fulfillment status

### 💳 Payments & Notifications (`/api/payment`, `/api/notifications`)
- `POST /api/payment/stripe-intent` - Create Stripe payment intent simulation
- `POST /api/payment/stripe-confirm` - Confirm card payment
- `GET /api/notifications/user/{userId}` - Fetch user order status notifications

---

## 🎨 Design System & Colors

- **Primary Teal**: `#0D9488` / `#0A6A64`
- **Secondary Mint**: `#CCFBF1` / `#E6F7F5`
- **Dark Neutral**: `#0F172A` / `#1E293B`
- **Muted Gray**: `#64748B` / `#94A3B8`
- **Border / Outline**: `#E2E8F0`
- **Background**: `#FFFFFF` / `#F8FAFC`
- **Status Badges**:
  - `Pending`: Amber (`#F59E0B`)
  - `Processing`: Blue (`#3B82F6`)
  - `Delivered / Approved`: Emerald (`#10B981`)
  - `Cancelled / Rejected`: Rose (`#EF4444`)

---

## 📄 License
This project is licensed under the MIT License - feel free to use and adapt for academic, research, and commercial purposes.
