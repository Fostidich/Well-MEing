package com.wellmeing.presentation;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
public class StatusController {

    @GetMapping("/")
    public Map<String, String> serviceStatus() {
        return Map.of("message", "Service is running");
    }

    @PostMapping("/mirror")
    public Map<String, Object> mirror(@RequestBody Map<String, Object> data) {
        return data;
    }

    @GetMapping("/ping")
    public String ping() {
        return "pong";
    }

    @GetMapping("/health")
    public Map<String, String> healthCheck() {
        return Map.of("status", "ok");
    }

}
