package com.epharmacy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_number", nullable = false, unique = true, length = 50)
    private String orderNumber; // e.g. "EP1024"

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    @Builder.Default
    private List<OrderItem> items = new ArrayList<>();

    @Column(precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "delivery_fee", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal deliveryFee = new BigDecimal("250.00");

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    @Column(length = 30)
    @Builder.Default
    private String status = "PENDING"; // PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED

    @Column(name = "payment_method", length = 30)
    @Builder.Default
    private String paymentMethod = "CARD"; // CARD, COD

    @Column(name = "payment_status", length = 30)
    @Builder.Default
    private String paymentStatus = "PAID"; // PAID, PENDING, FAILED

    @Column(name = "delivery_address", length = 255)
    private String deliveryAddress;

    @Column(name = "customer_name", length = 100)
    private String customerName;

    @Column(name = "customer_phone", length = 30)
    private String customerPhone;

    @Column(name = "estimated_delivery", length = 100)
    private String estimatedDelivery; // e.g. "Tomorrow, 13 Oct 2026 (9:00 AM - 5:00 PM)"

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (orderNumber == null || orderNumber.isEmpty()) {
            orderNumber = "EP" + (1000 + (int)(Math.random() * 9000));
        }
    }
}
