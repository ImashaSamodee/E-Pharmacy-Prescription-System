package com.epharmacy.backend.controller;

import com.epharmacy.backend.entity.Prescription;
import com.epharmacy.backend.entity.User;
import com.epharmacy.backend.repository.PrescriptionRepository;
import com.epharmacy.backend.repository.UserRepository;
import com.epharmacy.backend.service.GeminiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@RestController
@RequestMapping("/api/prescriptions")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class PrescriptionController {

    private final GeminiService geminiService;
    private final PrescriptionRepository prescriptionRepository;
    private final UserRepository userRepository;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadPrescription(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        try {
            // 1. User wa id eken hoyaganeema
            Optional<User> optionalUser = userRepository.findById(userId);
            if (optionalUser.isEmpty()) {
                return ResponseEntity.badRequest().body("User not found!");
            }

            // 2. Gemini API eka haraha image eken text eka kiyawima
            String extractedText = geminiService.extractTextFromImage(file);

            // 3. Database eke thunduwa save kirima
            Prescription prescription = new Prescription();
            prescription.setUser(optionalUser.get());
            prescription.setImageUrl(file.getOriginalFilename());

            boolean isError = extractedText == null 
                || extractedText.startsWith("Error extracting text:")
                || extractedText.contains("\"error\":")
                || extractedText.contains("503")
                || extractedText.contains("cannot be viewed")
                || extractedText.contains("raw binary data");

            if (isError) {
                prescription.setStatus("REJECTED");
                prescription.setExtractedText("Could not read prescription details clearly. Please upload a clearer photo of the prescription.");
            } else {
                prescription.setStatus("PROCESSED");
                prescription.setExtractedText(extractedText);
            }

            Prescription savedPrescription = prescriptionRepository.save(prescription);

            return ResponseEntity.ok(savedPrescription);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }

    // User kenekge id eka dunnama eyage okkoma thundu tika ganna API eka
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserPrescriptions(@PathVariable Long userId) {
        try {
            return ResponseEntity.ok(prescriptionRepository.findByUserId(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error fetching prescriptions: " + e.getMessage());
        }
    }

    // Thunduwa delete karanna API eka
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePrescription(@PathVariable Long id) {
        try {
            if (!prescriptionRepository.existsById(id)) {
                return ResponseEntity.notFound().build();
            }
            prescriptionRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error deleting: " + e.getMessage());
        }
    }
}