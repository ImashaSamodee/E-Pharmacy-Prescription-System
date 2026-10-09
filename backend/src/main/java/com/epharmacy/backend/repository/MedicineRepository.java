package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.Medicine;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MedicineRepository extends JpaRepository<Medicine, Long> {
    // Meke amuthuwen monawath liyanna one na, default functions hodatama athi
}