package com.epharmacy.backend.service;

import com.epharmacy.backend.dto.AuthRequest;
import com.epharmacy.backend.dto.AuthResponse;
import com.epharmacy.backend.dto.RegisterRequest;
import com.epharmacy.backend.entity.User;
import com.epharmacy.backend.repository.UserRepository;
import com.epharmacy.backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthResponse login(AuthRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid email or password"));

        // Match password (support bcrypt and plain text fallback)
        boolean matches = passwordEncoder.matches(request.getPassword(), user.getPassword())
                || request.getPassword().equals(user.getPassword());

        if (!matches) {
            throw new RuntimeException("Invalid email or password");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getEmail(), user.getRole());
        return AuthResponse.fromUser(user, token);
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone() != null ? request.getPhone() : "+94 77 123 4567")
                .address(request.getAddress() != null ? request.getAddress() : "No. 123, Galle Road, Colombo 04")
                .role(request.getRole() != null ? request.getRole() : "PATIENT")
                .build();

        User savedUser = userRepository.save(user);
        String token = jwtUtil.generateToken(savedUser.getId(), savedUser.getEmail(), savedUser.getRole());
        return AuthResponse.fromUser(savedUser, token);
    }

    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }

    public User updateProfile(Long userId, User updatedData) {
        User user = getUserById(userId);
        if (updatedData.getName() != null) user.setName(updatedData.getName());
        if (updatedData.getPhone() != null) user.setPhone(updatedData.getPhone());
        if (updatedData.getAddress() != null) user.setAddress(updatedData.getAddress());
        return userRepository.save(user);
    }
}
