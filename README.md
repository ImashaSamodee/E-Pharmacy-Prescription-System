# 💊 E-Pharmacy & Prescription System

An AI-powered E-Pharmacy and Prescription Processing System designed to simplify medicine ordering and prescription digitization. The application enables users to capture or upload medical prescriptions, automatically extracts medicine details and dosage instructions using **Google Gemini Vision AI**, and manages user prescription history.

---

## 🌟 Key Features

- 📸 **Smart Prescription Scanner**: Capture photos of prescriptions using camera or upload from gallery.
- 🤖 **AI-Powered OCR**: Analyzes doctor's handwriting and printed prescriptions via **Google Gemini API** to extract medicine names, dosages, and instructions.
- 📜 **Prescription History**: View past uploaded prescriptions and their extraction status.
- 🔐 **User Management**: Associate uploaded prescriptions and orders with specific user profiles.
- 🌐 **Cross-Platform Support**: Frontend built with Flutter (Android, iOS, Web, Desktop).
- ⚡ **Robust REST API**: High-performance Spring Boot backend connected with MySQL.

---

## 🛠️ Tech Stack & Architecture

### **Frontend**
- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.12.2`)
- **UI Components**: Material 3 Design
- **Key Packages**:
  - `image_picker` (Camera & Gallery image selection)
  - `http` & `http_parser` (Multipart HTTP REST API communication)

### **Backend**
- **Framework**: [Spring Boot](https://spring.io/projects/spring-boot) (Java 17)
- **Database ORM**: Spring Data JPA & Hibernate
- **Database**: MySQL (`epharmacy_db`)
- **AI Integration**: Google Gemini Vision API (`generativelanguage.googleapis.com`)
- **Build Tool**: Apache Maven (`mvnw`)
- **Utilities**: Lombok

---

## 📁 Project Structure

```plaintext
EPharmacy_System/
├── backend/                              # Spring Boot REST API
│   ├── src/main/java/com/epharmacy/backend/
│   │   ├── controller/                   # REST Controllers (Prescription, User)
│   │   ├── entity/                       # JPA Entities (User, Prescription, Medicine)
│   │   ├── repository/                   # Spring Data Repositories
│   │   └── service/                      # Business Logic & Gemini AI Service
│   ├── src/main/resources/
│   │   └── application.properties        # Backend configurations & DB credentials
│   ├── pom.xml                           # Maven dependencies
│   └── mvnw / mvnw.cmd                   # Maven wrapper
│
├── frontend/                             # Flutter Cross-Platform Application
│   ├── lib/
│   │   └── main.dart                     # UI screens, camera picker, API integration
│   ├── pubspec.yaml                      # Flutter dependencies
│   ├── android/                          # Android native configuration
│   ├── ios/                              # iOS native configuration
│   └── web/                              # Web configuration
│
├── .gitignore                            # Unified root gitignore
└── README.md                             # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your system:
- **Java Development Kit (JDK 17 or higher)**
- **MySQL Server** (running locally or remotely)
- **Flutter SDK** (`>= 3.12.2`) & Dart
- **Git**
- A **Google Gemini API Key** (from [Google AI Studio](https://aistudio.google.com/))

---

### 1. Backend Setup (Spring Boot)

1. **Configure MySQL Database:**
   Create a database in MySQL:
   ```sql
   CREATE DATABASE epharmacy_db;
   ```

2. **Configure `application.properties`:**
   Navigate to [backend/src/main/resources/application.properties](file:///c:/Users/23IT0470/Desktop/EPharmacy_System/backend/src/main/resources/application.properties) and verify your MySQL credentials:
   ```properties
   spring.application.name=epharmacy_db
   spring.datasource.url=jdbc:mysql://localhost:3306/epharmacy_db
   spring.datasource.username=root
   spring.datasource.password=YOUR_MYSQL_PASSWORD
   spring.jpa.hibernate.ddl-auto=update
   server.port=8080

   # Set your Gemini API key (or pass via environment variable GEMINI_API_KEY)
   gemini.api.key=${GEMINI_API_KEY:YOUR_GEMINI_API_KEY}
   ```

3. **Run the Backend:**
   Open a terminal in the `backend` folder:
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```
   Or on Windows:
   ```cmd
   mvnw.cmd spring-boot:run
   ```
   The backend server will start on `http://localhost:8080`.

---

### 2. Frontend Setup (Flutter)

1. **Install Dependencies:**
   Open a terminal in the `frontend` folder:
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Configure API URL (if running on Android Emulator or Physical Device):**
   In [frontend/lib/main.dart](file:///c:/Users/23IT0470/Desktop/EPharmacy_System/frontend/lib/main.dart):
   - For **Chrome / Web**: `http://localhost:8080`
   - For **Android Emulator**: `http://10.0.2.2:8080`
   - For **Physical Device**: `http://<YOUR_LOCAL_IP>:8080`

3. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📡 API Endpoints

### 🩺 Prescription Management
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/prescriptions/upload` | Uploads prescription image & extracts medicine details via Gemini AI |
| `GET` | `/api/prescriptions/user/{userId}` | Retrieves prescription history for a specific user |

### 👤 User Management
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/users/register` | Registers a new user |
| `GET` | `/api/users/{id}` | Fetches user details |

---

## 🔒 Security Best Practices

- Never commit sensitive API keys or credentials directly to public repositories.
- Use environment variables (e.g., `GEMINI_API_KEY`) to manage third-party service credentials securely.

---

## 👥 Contributors

- **Imasha Samodee** - [GitHub Profile](https://github.com/ImashaSamodee)
- Repository: [E-Pharmacy-Prescription-System](https://github.com/ImashaSamodee/E-Pharmacy-Prescription-System.git)
