package com.epharmacy.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderRequest {
    private Long userId;
    private String customerName;
    private String customerPhone;
    private String deliveryAddress;
    private String paymentMethod; // CARD or COD
    private BigDecimal subtotal;
    private BigDecimal deliveryFee;
    private BigDecimal totalAmount;
    private List<OrderItemDto> items;

    @Data
    public static class OrderItemDto {
        private Long medicineId;
        private String medicineName;
        private String dosage;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal totalPrice;
    }
}
