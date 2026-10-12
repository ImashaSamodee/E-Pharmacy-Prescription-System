package com.epharmacy.backend.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String name;
    private String email;
    private String password;
    private String phone;
    private String address;
    private String role; // PATIENT or PHARMACIST
}
