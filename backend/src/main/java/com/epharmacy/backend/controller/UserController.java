package com.epharmacy.backend.controller;

import com.epharmacy.backend.entity.User;
import com.epharmacy.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*") // React frontend eken call karaddi ena CORS error eka nathi karanna
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // POST request ekak haraha aluth user kenek register kirima
    @PostMapping("/register")
    public ResponseEntity<User> registerUser(@RequestBody User user) {
        User savedUser = userService.registerUser(user);
        return ResponseEntity.ok(savedUser);
    }

    // GET request ekak haraha email eken user ge details ganeema
    @GetMapping("/{email}")
    public ResponseEntity<User> getUserByEmail(@PathVariable String email) {
        Optional<User> user = userService.getUserByEmail(email);
        return user.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
