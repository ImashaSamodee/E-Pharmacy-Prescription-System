package com.epharmacy.backend.repository;

import com.epharmacy.backend.entity.Medicine;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MedicineRepository extends JpaRepository<Medicine, Long> {
    List<Medicine> findByCategoryIgnoreCase(String category);
    List<Medicine> findByNameContainingIgnoreCaseOrGenericNameContainingIgnoreCase(String name, String genericName);
}