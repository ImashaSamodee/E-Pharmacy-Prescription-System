package com.epharmacy.backend.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class AdminController {

    @GetMapping(value = {"/admin", "/admin/", "/admin/index.html"}, produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public ResponseEntity<Resource> getAdminPanel() {
        Resource resource = new ClassPathResource("static/admin/index.html");
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_HTML)
                .body(resource);
    }
}
