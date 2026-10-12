package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, String status);
    List<Order> findAllByOrderByCreatedAtDesc();
    List<Order> findByStatusOrderByCreatedAtDesc(String status);
    Optional<Order> findByOrderNumber(String orderNumber);
}
