package com.epharmacy.backend.controller;

import com.epharmacy.backend.dto.OrderRequest;
import com.epharmacy.backend.entity.Order;
import com.epharmacy.backend.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<?> createOrder(@RequestBody OrderRequest request) {
        try {
            Order order = orderService.createOrder(request);
            return ResponseEntity.ok(order);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating order: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserOrders(
            @PathVariable Long userId,
            @RequestParam(required = false) String status) {
        try {
            if (status != null && !status.isEmpty()) {
                return ResponseEntity.ok(orderService.getUserOrdersByStatus(userId, status));
            }
            return ResponseEntity.ok(orderService.getUserOrders(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error fetching orders: " + e.getMessage());
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllOrders() {
        try {
            return ResponseEntity.ok(orderService.getAllOrders());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error fetching orders: " + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(orderService.getOrderById(id));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/track/{orderNumber}")
    public ResponseEntity<?> trackOrder(@PathVariable String orderNumber) {
        try {
            return ResponseEntity.ok(orderService.getOrderByNumber(orderNumber));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        try {
            String newStatus = body.get("status");
            if (newStatus == null) {
                return ResponseEntity.badRequest().body("Status is required");
            }
            Order updated = orderService.updateOrderStatus(id, newStatus);
            return ResponseEntity.ok(updated);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error updating order status: " + e.getMessage());
        }
    }
}
