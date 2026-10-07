package com.epharmacy.backend.service;

import com.epharmacy.backend.entity.User;
import com.epharmacy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    // Aluth patient kenek hari admin kenek hari system ekata save kirima
    public User registerUser(User user) {
        // Methanadi apita isarahata password hashing (Bcrypt) wage ewa ekathu karanna puluwan
        return userRepository.save(user);
    }

    // Email eka dunnama database eken user ge details ganna function eka
    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}