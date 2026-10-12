package com.epharmacy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;

@Entity
@Table(name = "medicines")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Medicine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(length = 150)
    private String genericName;

    @Column(length = 80)
    private String category; // e.g. "Pain relief", "Cold & Flu", "First Aid", "Supplements", "Antibiotics"

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(columnDefinition = "int default 0")
    @Builder.Default
    private Integer stock = 100;

    @Column(length = 500)
    private String imageUrl;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 100)
    private String dosageForm; // e.g. "1 strip (10 tablets)"

    @Column(length = 50)
    private String confidence; // e.g. "96%" for AI match
}