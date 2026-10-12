package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.Prescription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PrescriptionRepository extends JpaRepository<Prescription, Long> {
    List<Prescription> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<Prescription> findByUserId(Long userId);
    List<Prescription> findAllByOrderByCreatedAtDesc();
    List<Prescription> findByStatusOrderByCreatedAtDesc(String status);
    Optional<Prescription> findByPrescriptionCode(String prescriptionCode);
}