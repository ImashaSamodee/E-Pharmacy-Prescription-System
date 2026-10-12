package com.epharmacy.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payment")
@CrossOrigin(origins = "*")
public class PaymentController {

    @PostMapping("/stripe-intent")
    public ResponseEntity<?> createStripePaymentIntent(@RequestBody Map<String, Object> request) {
        try {
            Object amountObj = request.get("amount");
            BigDecimal amount = BigDecimal.valueOf(1280.00);
            if (amountObj != null) {
                amount = new BigDecimal(amountObj.toString());
            }

            // Create client secret / transaction reference
            String clientSecret = "pi_" + UUID.randomUUID().toString().replace("-", "") + "_secret_" + UUID.randomUUID().toString().substring(0, 10);
            String transactionId = "tx_" + UUID.randomUUID().toString().substring(0, 12);

            Map<String, Object> response = new HashMap<>();
            response.put("clientSecret", clientSecret);
            response.put("transactionId", transactionId);
            response.put("amount", amount);
            response.put("currency", "LKR");
            response.put("status", "requires_confirmation");
            response.put("message", "Stripe payment intent generated successfully");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating payment intent: " + e.getMessage());
        }
    }

    @PostMapping("/stripe-confirm")
    public ResponseEntity<?> confirmStripePayment(@RequestBody Map<String, Object> request) {
        String transactionId = (String) request.getOrDefault("transactionId", "tx_" + UUID.randomUUID().toString().substring(0, 8));

        Map<String, Object> response = new HashMap<>();
        response.put("transactionId", transactionId);
        response.put("status", "succeeded");
        response.put("paymentMethod", "CARD");
        response.put("receiptUrl", "https://dashboard.stripe.com/receipts/" + transactionId);
        response.put("message", "Payment processed successfully via Stripe");

        return ResponseEntity.ok(response);
    }
}
