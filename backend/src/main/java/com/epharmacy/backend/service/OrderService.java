package com.epharmacy.backend.service;

import com.epharmacy.backend.dto.OrderRequest;
import com.epharmacy.backend.entity.AppNotification;
import com.epharmacy.backend.entity.Medicine;
import com.epharmacy.backend.entity.Order;
import com.epharmacy.backend.entity.OrderItem;
import com.epharmacy.backend.entity.User;
import com.epharmacy.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final MedicineRepository medicineRepository;
    private final AppNotificationRepository notificationRepository;

    @Transactional
    public Order createOrder(OrderRequest request) {
        User user = null;
        if (request.getUserId() != null) {
            user = userRepository.findById(request.getUserId()).orElse(null);
        }

        String orderNumber = "EP" + (1000 + (int)(Math.random() * 9000));

        BigDecimal subtotal = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();

        Order order = Order.builder()
                .orderNumber(orderNumber)
                .user(user)
                .deliveryAddress(request.getDeliveryAddress() != null ? request.getDeliveryAddress() : (user != null ? user.getAddress() : "No. 123, Galle Road, Colombo 04"))
                .customerName(request.getCustomerName() != null ? request.getCustomerName() : (user != null ? user.getName() : "Kasun Perera"))
                .customerPhone(request.getCustomerPhone() != null ? request.getCustomerPhone() : (user != null ? user.getPhone() : "+94 77 123 4567"))
                .paymentMethod(request.getPaymentMethod() != null ? request.getPaymentMethod().toUpperCase() : "CARD")
                .paymentStatus(request.getPaymentMethod() != null && request.getPaymentMethod().equalsIgnoreCase("COD") ? "PENDING" : "PAID")
                .status("PROCESSING")
                .deliveryFee(request.getDeliveryFee() != null ? request.getDeliveryFee() : new BigDecimal("250.00"))
                .estimatedDelivery("Tomorrow, 13 Oct 2026 (9:00 AM - 5:00 PM)")
                .createdAt(LocalDateTime.now())
                .build();

        if (request.getItems() != null && !request.getItems().isEmpty()) {
            for (OrderRequest.OrderItemDto itemDto : request.getItems()) {
                Medicine medicine = null;
                if (itemDto.getMedicineId() != null) {
                    medicine = medicineRepository.findById(itemDto.getMedicineId()).orElse(null);
                }

                BigDecimal unitPrice = itemDto.getUnitPrice() != null ? itemDto.getUnitPrice() : BigDecimal.valueOf(150.0);
                int qty = itemDto.getQuantity() != null ? itemDto.getQuantity() : 1;
                BigDecimal itemTotal = unitPrice.multiply(BigDecimal.valueOf(qty));
                subtotal = subtotal.add(itemTotal);

                OrderItem orderItem = OrderItem.builder()
                        .order(order)
                        .medicine(medicine)
                        .medicineName(itemDto.getMedicineName() != null ? itemDto.getMedicineName() : "Medicine")
                        .dosage(itemDto.getDosage() != null ? itemDto.getDosage() : "1 strip (10 tablets)")
                        .quantity(qty)
                        .unitPrice(unitPrice)
                        .totalPrice(itemTotal)
                        .build();

                items.add(orderItem);
            }
        } else {
            // Default fallback item if cart was empty
            subtotal = new BigDecimal("1030.00");
            OrderItem defaultItem = OrderItem.builder()
                    .order(order)
                    .medicineName("Panadol 500mg")
                    .dosage("1 strip (10 tablets)")
                    .quantity(1)
                    .unitPrice(new BigDecimal("120.00"))
                    .totalPrice(new BigDecimal("120.00"))
                    .build();
            items.add(defaultItem);
        }

        order.setItems(items);
        order.setSubtotal(request.getSubtotal() != null ? request.getSubtotal() : subtotal);
        order.setTotalAmount(order.getSubtotal().add(order.getDeliveryFee()));

        Order saved = orderRepository.save(order);

        // Notify user
        if (user != null) {
            AppNotification notif = AppNotification.builder()
                    .user(user)
                    .title("Order Confirmed")
                    .message("Order #" + orderNumber + " placed! Total: LKR " + order.getTotalAmount() + ". Estimated delivery tomorrow.")
                    .type("ORDER")
                    .build();
            notificationRepository.save(notif);
        }

        return saved;
    }

    public List<Order> getUserOrders(Long userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public List<Order> getUserOrdersByStatus(Long userId, String status) {
        if (status == null || status.equalsIgnoreCase("ALL")) {
            return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        }
        return orderRepository.findByUserIdAndStatusOrderByCreatedAtDesc(userId, status.toUpperCase());
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAllByOrderByCreatedAtDesc();
    }

    public Order getOrderById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with ID: " + id));
    }

    public Order getOrderByNumber(String orderNumber) {
        return orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new RuntimeException("Order not found with Number: " + orderNumber));
    }

    public Order updateOrderStatus(Long orderId, String newStatus) {
        Order order = getOrderById(orderId);
        order.setStatus(newStatus.toUpperCase());
        Order updated = orderRepository.save(order);

        if (order.getUser() != null) {
            AppNotification notif = AppNotification.builder()
                    .user(order.getUser())
                    .title("Order #" + order.getOrderNumber() + " Updated")
                    .message("Status changed to " + newStatus.toUpperCase() + ".")
                    .type("ORDER")
                    .build();
            notificationRepository.save(notif);
        }

        return updated;
    }
}
