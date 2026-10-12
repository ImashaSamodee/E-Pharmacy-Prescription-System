package com.epharmacy.backend.controller;

import com.epharmacy.backend.dto.PrescriptionReviewRequest;
import com.epharmacy.backend.entity.Prescription;
import com.epharmacy.backend.service.PrescriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/prescriptions")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class PrescriptionController {

    private final PrescriptionService prescriptionService;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadPrescription(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "userId", defaultValue = "1") Long userId) {

        try {
            Prescription prescription = prescriptionService.processAndSavePrescription(file, userId);
            return ResponseEntity.ok(prescription);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error processing prescription: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserPrescriptions(@PathVariable Long userId) {
        try {
            return ResponseEntity.ok(prescriptionService.getUserPrescriptions(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error fetching prescriptions: " + e.getMessage());
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllPrescriptions(@RequestParam(required = false) String status) {
        try {
            if (status != null && !status.isEmpty()) {
                return ResponseEntity.ok(prescriptionService.getPrescriptionsByStatus(status));
            }
            return ResponseEntity.ok(prescriptionService.getAllPrescriptions());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error fetching prescriptions: " + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getPrescriptionById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(prescriptionService.getById(id));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/review")
    public ResponseEntity<?> reviewPrescription(
            @PathVariable Long id,
            @RequestBody PrescriptionReviewRequest request) {
        try {
            Prescription updated = prescriptionService.reviewPrescription(id, request);
            return ResponseEntity.ok(updated);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error updating prescription: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePrescription(@PathVariable Long id) {
        try {
            prescriptionService.deletePrescription(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error deleting: " + e.getMessage());
        }
    }
}