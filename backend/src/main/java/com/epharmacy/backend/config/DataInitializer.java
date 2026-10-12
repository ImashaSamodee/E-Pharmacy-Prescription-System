package com.epharmacy.backend.config;

import com.epharmacy.backend.entity.*;
import com.epharmacy.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.io.File;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final MedicineRepository medicineRepository;
    private final PrescriptionRepository prescriptionRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final AppNotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Ensure uploads folder exists
        File uploadFolder = new File("uploads");
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        // 1. Seed Users
        User kasun = userRepository.findByEmail("kasun@email.com").orElse(null);
        if (kasun == null) {
            kasun = User.builder()
                    .name("Kasun Perera")
                    .email("kasun@email.com")
                    .password(passwordEncoder.encode("123456"))
                    .phone("+94 77 123 4567")
                    .address("No. 123, Galle Road, Colombo 04, Colombo")
                    .role("PATIENT")
                    .createdAt(LocalDateTime.now().minusDays(30))
                    .build();
            kasun = userRepository.save(kasun);
        }

        User pharmacist = userRepository.findByEmail("pharmacist@medicare.lk").orElse(null);
        if (pharmacist == null) {
            pharmacist = User.builder()
                    .name("Pharmacist Admin")
                    .email("pharmacist@medicare.lk")
                    .password(passwordEncoder.encode("admin123"))
                    .phone("+94 11 234 5678")
                    .address("MediCare LK Pharmacy, Colombo 03")
                    .role("PHARMACIST")
                    .createdAt(LocalDateTime.now().minusDays(60))
                    .build();
            pharmacist = userRepository.save(pharmacist);
        }

        User nimesh = userRepository.findByEmail("nimesh@email.com").orElse(null);
        if (nimesh == null) {
            nimesh = User.builder()
                    .name("Nimesh Silva")
                    .email("nimesh@email.com")
                    .password(passwordEncoder.encode("123456"))
                    .phone("+94 71 234 5678")
                    .address("Kandy Road, Kiribathgoda")
                    .role("PATIENT")
                    .createdAt(LocalDateTime.now().minusDays(15))
                    .build();
            nimesh = userRepository.save(nimesh);
        }

        User sohan = userRepository.findByEmail("sohan@email.com").orElse(null);
        if (sohan == null) {
            sohan = User.builder()
                    .name("Sohan Fernando")
                    .email("sohan@email.com")
                    .password(passwordEncoder.encode("123456"))
                    .phone("+94 77 987 6543")
                    .address("Negombo Road, Wattala")
                    .role("PATIENT")
                    .createdAt(LocalDateTime.now().minusDays(20))
                    .build();
            sohan = userRepository.save(sohan);
        }

        User dilani = userRepository.findByEmail("dilani@email.com").orElse(null);
        if (dilani == null) {
            dilani = User.builder()
                    .name("Dilani Perera")
                    .email("dilani@email.com")
                    .password(passwordEncoder.encode("123456"))
                    .phone("+94 74 321 0987")
                    .address("High Level Road, Nugegoda")
                    .role("PATIENT")
                    .createdAt(LocalDateTime.now().minusDays(10))
                    .build();
            dilani = userRepository.save(dilani);
        }

        // 2. Seed Medicines
        if (medicineRepository.count() == 0) {
            List<Medicine> meds = List.of(
                    Medicine.builder()
                            .name("Panadol 500mg")
                            .genericName("Paracetamol")
                            .category("Pain relief")
                            .price(new BigDecimal("120.00"))
                            .stock(200)
                            .dosageForm("1 strip (10 tablets)")
                            .description("Fast and effective relief for headache, body aches, toothache, and fever.")
                            .confidence("96%")
                            .imageUrl("https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Siddhalepa Balm")
                            .genericName("Ayurvedic Relief")
                            .category("Pain relief")
                            .price(new BigDecimal("350.00"))
                            .stock(80)
                            .dosageForm("50g jar")
                            .description("Traditional herbal balm soothing headache, muscle aches, colds, and flu symptoms.")
                            .confidence("90%")
                            .imageUrl("https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Vitamin C 1000mg")
                            .genericName("Immune Support")
                            .category("Supplements")
                            .price(new BigDecimal("450.00"))
                            .stock(120)
                            .dosageForm("1 strip (10 tablets)")
                            .description("High-potency antioxidant immune booster for daily health and defense.")
                            .confidence("94%")
                            .imageUrl("https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Strepsils Lozenges")
                            .genericName("Sore Throat Relief")
                            .category("Cold & Flu")
                            .price(new BigDecimal("260.00"))
                            .stock(180)
                            .dosageForm("1 pack (8 lozenges)")
                            .description("Antiseptic soothing lozenges providing fast action for sore throat and irritated mouth.")
                            .confidence("91%")
                            .imageUrl("https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Amoxicillin 500mg")
                            .genericName("Antibiotic")
                            .category("First Aid")
                            .price(new BigDecimal("280.00"))
                            .stock(100)
                            .dosageForm("1 strip (10 capsules)")
                            .description("Broad spectrum antibiotic for bacterial infections, respiratory tract, and dental infections.")
                            .confidence("95%")
                            .imageUrl("https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Cetirizine 10mg")
                            .genericName("Allergy Relief")
                            .category("Cold & Flu")
                            .price(new BigDecimal("180.00"))
                            .stock(140)
                            .dosageForm("1 strip (10 tablets)")
                            .description("Non-drowsy 24h antihistamine for allergy symptoms, runny nose, sneezing, and skin itching.")
                            .confidence("92%")
                            .imageUrl("https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Augmentin 625mg")
                            .genericName("Amoxicillin & Clavulanate")
                            .category("First Aid")
                            .price(new BigDecimal("850.00"))
                            .stock(60)
                            .dosageForm("1 strip (6 tablets)")
                            .description("Enhanced antibiotic therapy for resistant bacterial respiratory and ear/throat infections.")
                            .confidence("93%")
                            .imageUrl("https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300")
                            .build(),

                    Medicine.builder()
                            .name("Omeprazole 20mg")
                            .genericName("Gastric Acid Reducer")
                            .category("Digestive")
                            .price(new BigDecimal("90.00"))
                            .stock(150)
                            .dosageForm("1 strip (10 capsules)")
                            .description("Proton pump inhibitor effectively treating heartburn, acid reflux, and gastritis discomfort.")
                            .confidence("89%")
                            .imageUrl("https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=300")
                            .build()
            );
            medicineRepository.saveAll(meds);
        }

        // 3. Seed Prescriptions (for Admin Screen 9 & Mobile Scans)
        if (prescriptionRepository.findByPrescriptionCode("EP1024").isEmpty()) {
            Prescription p1 = Prescription.builder()
                    .prescriptionCode("EP1024")
                    .user(kasun)
                    .imageUrl("prescription_sample_1.jpg")
                    .extractedText("1. Tab. Panadol 500mg - 1 strip (10 tablets) - 1 morning, 1 night after meals\n2. Tab. Amoxicillin 500mg - 1 strip (10 capsules) - 1 morning, 1 night after meals\n3. Tab. Cetirizine 10mg - 1 strip (10 tablets) - 1 night after meals")
                    .extractedMedicinesJson("[{\"name\":\"Panadol 500mg\",\"dosage\":\"1 strip (10 tablets)\",\"price\":120.00,\"confidence\":\"96%\"},{\"name\":\"Amoxicillin 500mg\",\"dosage\":\"1 strip (10 capsules)\",\"price\":280.00,\"confidence\":\"95%\"},{\"name\":\"Cetirizine 10mg\",\"dosage\":\"1 strip (10 tablets)\",\"price\":180.00,\"confidence\":\"92%\"}]")
                    .status("PENDING")
                    .aiDetectedCount(3)
                    .totalPrice(new BigDecimal("580.00"))
                    .createdAt(LocalDateTime.now().minusHours(3))
                    .build();
            prescriptionRepository.save(p1);
        }

        if (prescriptionRepository.findByPrescriptionCode("EP1018").isEmpty()) {
            Prescription p2 = Prescription.builder()
                    .prescriptionCode("EP1018")
                    .user(nimesh)
                    .imageUrl("prescription_sample_2.jpg")
                    .extractedText("1. Tab. Augmentin 625mg - 1 strip (6 tablets)\n2. Tab. Panadol 500mg - 1 strip (10 tablets)")
                    .extractedMedicinesJson("[{\"name\":\"Augmentin 625mg\",\"dosage\":\"1 strip (6 tablets)\",\"price\":850.00,\"confidence\":\"94%\"},{\"name\":\"Panadol 500mg\",\"dosage\":\"1 strip (10 tablets)\",\"price\":120.00,\"confidence\":\"96%\"}]")
                    .status("PENDING")
                    .aiDetectedCount(2)
                    .totalPrice(new BigDecimal("970.00"))
                    .createdAt(LocalDateTime.now().minusDays(4))
                    .build();
            prescriptionRepository.save(p2);
        }

        if (prescriptionRepository.findByPrescriptionCode("EP1017").isEmpty()) {
            Prescription p3 = Prescription.builder()
                    .prescriptionCode("EP1017")
                    .user(sohan)
                    .imageUrl("prescription_sample_3.jpg")
                    .extractedText("1. Tab. Panadol 500mg\n2. Tab. Cetirizine 10mg\n3. Tab. Vitamin C 1000mg\n4. Tab. Omeprazole 20mg")
                    .extractedMedicinesJson("[{\"name\":\"Panadol 500mg\",\"price\":120.00,\"confidence\":\"96%\"},{\"name\":\"Cetirizine 10mg\",\"price\":180.00,\"confidence\":\"92%\"},{\"name\":\"Vitamin C 1000mg\",\"price\":450.00,\"confidence\":\"94%\"},{\"name\":\"Omeprazole 20mg\",\"price\":90.00,\"confidence\":\"90%\"}]")
                    .status("APPROVED")
                    .aiDetectedCount(4)
                    .totalPrice(new BigDecimal("840.00"))
                    .pharmacistNotes("Approved by Pharmacist Dr. Nimal")
                    .createdAt(LocalDateTime.now().minusDays(5))
                    .build();
            prescriptionRepository.save(p3);
        }

        if (prescriptionRepository.findByPrescriptionCode("EP1016").isEmpty()) {
            Prescription p4 = Prescription.builder()
                    .prescriptionCode("EP1016")
                    .user(dilani)
                    .imageUrl("prescription_sample_4.jpg")
                    .extractedText("1. Siddhalepa Balm - 50g jar")
                    .extractedMedicinesJson("[{\"name\":\"Siddhalepa Balm\",\"dosage\":\"50g jar\",\"price\":350.00,\"confidence\":\"91%\"}]")
                    .status("PENDING")
                    .aiDetectedCount(1)
                    .totalPrice(new BigDecimal("350.00"))
                    .createdAt(LocalDateTime.now().minusDays(7))
                    .build();
            prescriptionRepository.save(p4);
        }

        // 4. Seed Orders (Matching Screens 5, 6, 7)
        if (orderRepository.findByOrderNumber("EP1024").isEmpty()) {
            Order o1 = Order.builder()
                    .orderNumber("EP1024")
                    .user(kasun)
                    .customerName("Kasun Perera")
                    .customerPhone("+94 77 123 4567")
                    .deliveryAddress("No. 123, Galle Road, Colombo 04, Colombo")
                    .subtotal(new BigDecimal("1030.00"))
                    .deliveryFee(new BigDecimal("250.00"))
                    .totalAmount(new BigDecimal("1280.00"))
                    .status("PROCESSING")
                    .paymentMethod("CARD")
                    .paymentStatus("PAID")
                    .estimatedDelivery("Tomorrow, 13 Oct 2026 (9:00 AM - 5:00 PM)")
                    .createdAt(LocalDateTime.of(2026, 10, 12, 10, 24))
                    .build();

            List<OrderItem> items = List.of(
                    OrderItem.builder().order(o1).medicineName("Panadol 500mg").dosage("Paracetamol, Qty: 1 strip (10 tablets)").quantity(1).unitPrice(new BigDecimal("120.00")).totalPrice(new BigDecimal("120.00")).build(),
                    OrderItem.builder().order(o1).medicineName("Amoxicillin 500mg").dosage("Antibiotic, Qty: 1 strip (10 capsules)").quantity(1).unitPrice(new BigDecimal("280.00")).totalPrice(new BigDecimal("280.00")).build(),
                    OrderItem.builder().order(o1).medicineName("Vitamin C 1000mg").dosage("Supplement, Qty: 1 strip (10 tablets)").quantity(1).unitPrice(new BigDecimal("450.00")).totalPrice(new BigDecimal("450.00")).build(),
                    OrderItem.builder().order(o1).medicineName("Cetirizine 10mg").dosage("Allergy Relief, Qty: 1 strip (10 tablets)").quantity(1).unitPrice(new BigDecimal("180.00")).totalPrice(new BigDecimal("180.00")).build()
            );
            o1.setItems(items);
            orderRepository.save(o1);
        }

        if (orderRepository.findByOrderNumber("EP1018").isEmpty()) {
            Order o2 = Order.builder()
                    .orderNumber("EP1018")
                    .user(kasun)
                    .customerName("Kasun Perera")
                    .customerPhone("+94 77 123 4567")
                    .deliveryAddress("No. 123, Galle Road, Colombo 04, Colombo")
                    .subtotal(new BigDecimal("600.00"))
                    .deliveryFee(new BigDecimal("250.00"))
                    .totalAmount(new BigDecimal("850.00"))
                    .status("DELIVERED")
                    .paymentMethod("COD")
                    .paymentStatus("PAID")
                    .estimatedDelivery("Delivered on 08 Oct 2026")
                    .createdAt(LocalDateTime.of(2026, 10, 8, 14, 15))
                    .build();

            List<OrderItem> items2 = List.of(
                    OrderItem.builder().order(o2).medicineName("Siddhalepa Balm").dosage("50g jar").quantity(1).unitPrice(new BigDecimal("350.00")).totalPrice(new BigDecimal("350.00")).build(),
                    OrderItem.builder().order(o2).medicineName("Strepsils Lozenges").dosage("1 pack (8 lozenges)").quantity(1).unitPrice(new BigDecimal("250.00")).totalPrice(new BigDecimal("250.00")).build()
            );
            o2.setItems(items2);
            orderRepository.save(o2);
        }

        if (orderRepository.findByOrderNumber("EP1006").isEmpty()) {
            Order o3 = Order.builder()
                    .orderNumber("EP1006")
                    .user(kasun)
                    .customerName("Kasun Perera")
                    .customerPhone("+94 77 123 4567")
                    .deliveryAddress("No. 123, Galle Road, Colombo 04, Colombo")
                    .subtotal(new BigDecimal("2200.00"))
                    .deliveryFee(new BigDecimal("250.00"))
                    .totalAmount(new BigDecimal("2450.00"))
                    .status("DELIVERED")
                    .paymentMethod("CARD")
                    .paymentStatus("PAID")
                    .estimatedDelivery("Delivered on 25 Sep 2026")
                    .createdAt(LocalDateTime.of(2026, 9, 25, 11, 40))
                    .build();

            List<OrderItem> items3 = List.of(
                    OrderItem.builder().order(o3).medicineName("Augmentin 625mg").dosage("1 strip (6 tablets)").quantity(2).unitPrice(new BigDecimal("850.00")).totalPrice(new BigDecimal("1700.00")).build(),
                    OrderItem.builder().order(o3).medicineName("Vitamin C 1000mg").dosage("1 strip (10 tablets)").quantity(1).unitPrice(new BigDecimal("450.00")).totalPrice(new BigDecimal("450.00")).build(),
                    OrderItem.builder().order(o3).medicineName("Strepsils Lozenges").dosage("1 pack (8 lozenges)").quantity(1).unitPrice(new BigDecimal("250.00")).totalPrice(new BigDecimal("250.00")).build()
            );
            o3.setItems(items3);
            orderRepository.save(o3);
        }

        if (orderRepository.findByOrderNumber("EP0998").isEmpty()) {
            Order o4 = Order.builder()
                    .orderNumber("EP0998")
                    .user(kasun)
                    .customerName("Kasun Perera")
                    .customerPhone("+94 77 123 4567")
                    .deliveryAddress("No. 123, Galle Road, Colombo 04, Colombo")
                    .subtotal(new BigDecimal("900.00"))
                    .deliveryFee(new BigDecimal("250.00"))
                    .totalAmount(new BigDecimal("1150.00"))
                    .status("CANCELLED")
                    .paymentMethod("COD")
                    .paymentStatus("FAILED")
                    .estimatedDelivery("Order Cancelled")
                    .createdAt(LocalDateTime.of(2026, 9, 20, 16, 10))
                    .build();

            List<OrderItem> items4 = List.of(
                    OrderItem.builder().order(o4).medicineName("Amoxicillin 500mg").dosage("1 strip (10 capsules)").quantity(2).unitPrice(new BigDecimal("280.00")).totalPrice(new BigDecimal("560.00")).build(),
                    OrderItem.builder().order(o4).medicineName("Panadol 500mg").dosage("1 strip (10 tablets)").quantity(2).unitPrice(new BigDecimal("120.00")).totalPrice(new BigDecimal("240.00")).build()
            );
            o4.setItems(items4);
            orderRepository.save(o4);
        }

        // 5. Seed Notifications
        if (notificationRepository.count() == 0) {
            notificationRepository.save(AppNotification.builder()
                    .user(kasun)
                    .title("Order #EP1024 Processing")
                    .message("Your order #EP1024 is being prepared by our pharmacist team.")
                    .type("ORDER")
                    .createdAt(LocalDateTime.now().minusHours(1))
                    .build());

            notificationRepository.save(AppNotification.builder()
                    .user(kasun)
                    .title("Prescription #EP1024 Received")
                    .message("AI has extracted 3 medicines from your prescription.")
                    .type("PRESCRIPTION")
                    .createdAt(LocalDateTime.now().minusHours(3))
                    .build());

            notificationRepository.save(AppNotification.builder()
                    .user(kasun)
                    .title("MediCare LK Special Offer")
                    .message("Stay Healthy Stay Protected - Upto 20% OFF on all immunity supplements this week.")
                    .type("SYSTEM")
                    .createdAt(LocalDateTime.now().minusDays(1))
                    .build());
        }
    }
}
