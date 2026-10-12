package com.epharmacy.backend.dto;

import lombok.Data;

@Data
public class AuthRequest {
    private String email;
    private String password;
}
