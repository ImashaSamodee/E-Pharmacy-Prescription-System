package com.epharmacy.backend.controller;

import com.epharmacy.backend.entity.AppNotification;
import com.epharmacy.backend.repository.AppNotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class NotificationController {

    private final AppNotificationRepository notificationRepository;

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AppNotification>> getUserNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationRepository.findByUserIdOrderByCreatedAtDesc(userId));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id) {
        return notificationRepository.findById(id).map(notif -> {
            notif.setIsRead(true);
            notificationRepository.save(notif);
            return ResponseEntity.ok(notif);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/user/{userId}/read-all")
    public ResponseEntity<?> markAllAsRead(@PathVariable Long userId) {
        List<AppNotification> list = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        for (AppNotification notif : list) {
            notif.setIsRead(true);
        }
        notificationRepository.saveAll(list);
        return ResponseEntity.ok().build();
    }
}
