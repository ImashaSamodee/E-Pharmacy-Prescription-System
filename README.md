# 🏥 MediCare LK - Full-Stack AI E-Pharmacy & Prescription System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17%2F25-ED8B00?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini%20Vision%20OCR-8E75C2?logo=google&logoColor=white)](https://ai.google.dev/)
[![Currency](https://img.shields.io/badge/Currency-LKR%20(Rs.)-00A389)](#)

A modern, full-stack E-Pharmacy mobile application and web administration portal developed with **Flutter** (Material 3 healthcare theme `#0D9488`), **Spring Boot 3 REST APIs**, **Spring Security + JWT**, and **MySQL**. The system integrates **Google Gemini Vision AI** to digitize handwritten and printed prescriptions, extract medicine details with confidence scores, and deliver end-to-end pharmacy ordering and tracking in Sri Lankan Rupees (LKR).

---

## 📱 Complete Screens & Features (Matching Mockup Design)

| # | Screen | Description |
|---|---|---|
| **1** | **Login / Register** | Exact **MediCare LK** healthcare branding, vector doctor hero graphic, email & password authentication, remember me, Google & Phone (+94) sign-in, 1-tap demo access, and smooth Create Account registration. |
| **2** | **Home / Store** | Live search bar, category chips (*Pain relief*, *Cold & Flu*, *Supplements*, *First Aid*), 20% OFF promo banner, and popular medicines grid with real LKR pricing. |
| **3** | **AI Prescription Scan** | Take photo / Upload from gallery, Google Gemini Vision OCR extraction, confidence ratings (96%, 95%, 92%), and recent scan cards (`#EP1024`, `#EP1018`). |
| **4** | **Extracted Medicines / Cart** | Interactive medicine list with selection checkboxes, quantity steppers (+/-), real-time LKR price recalculation, and sticky footer checkout bar. |
| **5** | **Checkout & Payment** | Delivery address editor (*Kasun Perera, Galle Rd, Colombo*), order summary breakdown, Card Payment (Stripe simulation), and Cash on Delivery (COD). |
| **6** | **Order Tracking** | Real-time status stepper (**Pending ➔ Processing ➔ Shipped ➔ Delivered**), estimated delivery banner, and order item details. |
| **7** | **Order History** | Status filter chips (*All*, *Processing*, *Delivered*, *Cancelled*), past orders cards (`#EP1024`, `#EP1018`, `#EP1006`, `#EP0998`), and tap-to-track. |
| **8** | **User Profile** | Personal information, delivery addresses, payment methods, notifications drawer, and direct toggle to Pharmacist Admin mode. |
| **9** | **Pharmacist Admin Portal** | Dedicated web dashboard (`/admin/index.html`) & mobile admin screen for prescription verification, medicine pricing, order status transitions, and inventory control. |

---

## 🏗️ System Architecture & Tech Stack

```plaintext
EPharmacy_System/
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
│   │   └── application.properties            # Database and Gemini API credentials
│   ├── uploads/                              # Stored prescription images (.gitkeep protected)
│   └── pom.xml                               # Maven project dependencies
│
├── frontend/                                 # Flutter Mobile & Web Client
│   ├── lib/
│   │   ├── models/                           # Dart data models
│   │   ├── screens/                          # 9 complete UI screens
│   │   ├── services/                         # REST API service with auto-platform IP resolution
│   │   ├── state/                            # Global state management singleton
│   │   └── main.dart                         # Main entry point, theme & BottomNavigationBar
│   ├── assets/images/                        # High-definition UI assets and vector graphics
│   └── pubspec.yaml                          # Flutter dependencies
│
├── .gitignore                                # Comprehensive master gitignore
└── README.md                                 # Full documentation
```

---

## 🔑 Demo Credentials

Pre-seeded database accounts available for immediate testing:

| Role | Email | Password | Default Data |
|---|---|---|---|
| **Patient (Kasun Perera)** | `kasun@email.com` | `123456` | Active orders `#EP1024`, `#EP1018`, prescriptions, cart items |
| **Pharmacist Admin** | `pharmacist@medicare.lk` | `admin123` | Full access to Web Dashboard & Mobile Admin management |

---

## ⚡ Quick Start & Run Guide

### 1. Prerequisites
- **Java JDK 17 or higher** (JDK 25 compatible)
- **MySQL Server 8.0+** running on `localhost:3306`
- **Flutter SDK `^3.12.2`** & Dart
- **Git**

---

### 2. Database Setup (MySQL)
Create the database in MySQL:
```sql
CREATE DATABASE epharmacy_db;
```

Check [backend/src/main/resources/application.properties](file:///c:/Users/23IT0470/Desktop/EPharmacy_System/backend/src/main/resources/application.properties) credentials:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/epharmacy_db
spring.datasource.username=root
spring.datasource.password=0408
spring.jpa.hibernate.ddl-auto=update
```

---

### 3. Run Backend (Spring Boot)
Open a terminal in the `backend` folder:
```powershell
cd backend
.\mvnw spring-boot:run
```
* The backend will start on **`http://localhost:8080`**.
* Initial sample data (medicines, users, sample prescriptions, and orders) is automatically seeded on first launch.

> 💡 **Troubleshooting Port 8080:** If you ever see `Port 8080 was already in use`, run this PowerShell command to clear the process:
> ```powershell
> Stop-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess -Force
> ```

---

### 4. Run Frontend (Flutter)
In a second terminal, navigate to the `frontend` folder:
```powershell
cd frontend
flutter pub get

# Run on Google Chrome (Web):
flutter run -d chrome

# Or run on Windows Desktop:
flutter run -d windows
```

> 💡 **Hot Restart:** When updating assets or state during development, press **`R` (Shift + R)** in your Flutter terminal.

---

### 5. Access Pharmacist Web Admin Portal
While the Spring Boot backend is running, open the responsive web portal in any browser:
```
http://localhost:8080/admin/index.html
```
Features:
- Live review of prescription requests with AI confidence tags
- Prescription approval / rejection with pricing assignment
- Order status updates (Pending ➔ Processing ➔ Shipped ➔ Delivered)
- Inventory management and price editing

---

## 📡 REST API Reference

### 🔐 Authentication (`/api/auth`)
- `POST /api/auth/login` - Authenticate user & issue JWT token
- `POST /api/auth/register` - Register patient or pharmacist
- `GET /api/auth/user/{id}` - Fetch user profile
- `PUT /api/auth/profile/{id}` - Update profile & delivery address

### 💊 Medicine Catalog (`/api/medicines`)
- `GET /api/medicines` - Get all medicines (filter by `?category=` or `?search=`)
- `GET /api/medicines/{id}` - Get medicine details
- `POST /api/medicines` - Create new medicine (Admin)
- `PUT /api/medicines/{id}` - Update price and stock (Admin)
- `DELETE /api/medicines/{id}` - Delete medicine (Admin)

### 🩺 Prescriptions & AI OCR (`/api/prescriptions`)
- `POST /api/prescriptions/upload` - Upload image & extract medicines with Gemini Vision
- `GET /api/prescriptions/user/{userId}` - User's uploaded prescriptions
- `GET /api/prescriptions/all` - All prescriptions (filter by `?status=`)
- `PUT /api/prescriptions/{id}/review` - Approve/Reject prescription with notes & pricing

### 📦 Orders (`/api/orders`)
- `POST /api/orders` - Place order with delivery address & payment method
- `GET /api/orders/user/{userId}` - User order history
- `GET /api/orders/track/{orderNumber}` - Real-time tracking for an order (e.g. `#EP1024`)
- `GET /api/orders/all` - All orders (Admin)
- `PUT /api/orders/{id}/status` - Advance order status

### 💳 Payments & Notifications (`/api/payment`, `/api/notifications`)
- `POST /api/payment/stripe-intent` - Generate Stripe payment intent simulation
- `POST /api/payment/stripe-confirm` - Confirm card payment
- `GET /api/notifications/user/{userId}` - Fetch user status notifications

---

## 🎨 Design System & Colors

- **Primary Teal**: `#0A6A64` / `#0D9488`
- **Secondary Mint**: `#CCFBF1` / `#E6F7F5`
- **Background**: `#FFFFFF` / `#F8FAFC`
- **Text Dark**: `#0F172A`
- **Text Muted**: `#64748B`
- **Border**: `#E2E8F0`
- **Status Badges**:
  - `Pending`: Amber (`#F59E0B`)
  - `Processing`: Blue (`#3B82F6`)
  - `Delivered / Approved`: Emerald (`#10B981`)
  - `Cancelled / Rejected`: Rose (`#EF4444`)

---

## 📄 License
This project is licensed under the MIT License - feel free to use and adapt for academic and commercial purposes.
