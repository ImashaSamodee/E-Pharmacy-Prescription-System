package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.AppNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AppNotificationRepository extends JpaRepository<AppNotification, Long> {
    List<AppNotification> findByUserIdOrderByCreatedAtDesc(Long userId);
    long countByUserIdAndIsReadFalse(Long userId);
}
