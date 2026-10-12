package com.epharmacy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "prescriptions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Prescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "prescription_code", length = 50)
    private String prescriptionCode; // e.g. "EP1024"

    @Column(name = "image_url", nullable = false, length = 500)
    private String imageUrl;

    @Column(name = "extracted_text", columnDefinition = "LONGTEXT")
    private String extractedText;

    @Column(name = "extracted_medicines_json", columnDefinition = "LONGTEXT")
    private String extractedMedicinesJson;

    @Column(length = 30)
    @Builder.Default
    private String status = "PENDING"; // PENDING, APPROVED, REJECTED, PROCESSED

    @Column(name = "ai_detected_count")
    @Builder.Default
    private Integer aiDetectedCount = 0;

    @Column(name = "total_price", precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "pharmacist_notes", columnDefinition = "TEXT")
    private String pharmacistNotes;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (status == null) {
            status = "PENDING";
        }
    }
}