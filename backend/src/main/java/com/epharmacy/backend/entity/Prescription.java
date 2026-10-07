package com.epharmacy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "prescriptions")
@Data
public class Prescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Database eke thiyena user_id foreign key eka meken link wenawa
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "image_url", nullable = false)
    private String imageUrl;

    @Column(name = "extracted_text", columnDefinition = "TEXT")
    private String extractedText;

    @Column(columnDefinition = "ENUM('PENDING', 'PROCESSED', 'REJECTED') DEFAULT 'PENDING'")
    private String status;

    @Column(name = "created_at", updatable = false, insertable = false)
    private LocalDateTime createdAt;
}