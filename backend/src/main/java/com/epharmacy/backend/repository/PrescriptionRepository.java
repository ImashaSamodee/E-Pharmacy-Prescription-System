package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.Prescription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PrescriptionRepository extends JpaRepository {
    // User kenekge id eka dunnama eya upload karapu thundu list ekama ganna meka udaw wenawa
    List findByUserId(Long userId);
}