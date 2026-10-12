package com.epharmacy.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PrescriptionReviewRequest {
    private String status; // APPROVED or REJECTED
    private BigDecimal totalPrice;
    private String pharmacistNotes;
}
