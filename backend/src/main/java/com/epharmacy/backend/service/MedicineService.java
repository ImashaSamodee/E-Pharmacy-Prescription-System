package com.epharmacy.backend.service;

import com.epharmacy.backend.entity.Medicine;
import com.epharmacy.backend.repository.MedicineRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MedicineService {

    private final MedicineRepository medicineRepository;

    public List<Medicine> getAllMedicines() {
        return medicineRepository.findAll();
    }

    public List<Medicine> getByCategory(String category) {
        if (category == null || category.equalsIgnoreCase("ALL")) {
            return medicineRepository.findAll();
        }
        return medicineRepository.findByCategoryIgnoreCase(category);
    }

    public List<Medicine> search(String query) {
        if (query == null || query.trim().isEmpty()) {
            return medicineRepository.findAll();
        }
        return medicineRepository.findByNameContainingIgnoreCaseOrGenericNameContainingIgnoreCase(query, query);
    }

    public Medicine getById(Long id) {
        return medicineRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Medicine not found with ID: " + id));
    }

    public Medicine save(Medicine medicine) {
        return medicineRepository.save(medicine);
    }

    public void delete(Long id) {
        medicineRepository.deleteById(id);
    }
}
