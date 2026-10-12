package com.epharmacy.backend.controller;

import com.epharmacy.backend.entity.Medicine;
import com.epharmacy.backend.service.MedicineService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/medicines")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class MedicineController {

    private final MedicineService medicineService;

    @GetMapping
    public ResponseEntity<List<Medicine>> getMedicines(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String search) {

        if (search != null && !search.trim().isEmpty()) {
            return ResponseEntity.ok(medicineService.search(search));
        }
        if (category != null && !category.trim().isEmpty()) {
            return ResponseEntity.ok(medicineService.getByCategory(category));
        }
        return ResponseEntity.ok(medicineService.getAllMedicines());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getMedicineById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(medicineService.getById(id));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<?> createMedicine(@RequestBody Medicine medicine) {
        try {
            return ResponseEntity.ok(medicineService.save(medicine));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateMedicine(@PathVariable Long id, @RequestBody Medicine medicine) {
        try {
            Medicine existing = medicineService.getById(id);
            if (medicine.getName() != null) existing.setName(medicine.getName());
            if (medicine.getGenericName() != null) existing.setGenericName(medicine.getGenericName());
            if (medicine.getCategory() != null) existing.setCategory(medicine.getCategory());
            if (medicine.getPrice() != null) existing.setPrice(medicine.getPrice());
            if (medicine.getStock() != null) existing.setStock(medicine.getStock());
            if (medicine.getImageUrl() != null) existing.setImageUrl(medicine.getImageUrl());
            if (medicine.getDescription() != null) existing.setDescription(medicine.getDescription());
            if (medicine.getDosageForm() != null) existing.setDosageForm(medicine.getDosageForm());
            return ResponseEntity.ok(medicineService.save(existing));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMedicine(@PathVariable Long id) {
        try {
            medicineService.delete(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
