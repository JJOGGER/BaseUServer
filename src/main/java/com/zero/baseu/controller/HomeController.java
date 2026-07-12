package com.zero.baseu.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 首页控制器
 * 
 * @author Zero Team
 */
@RestController
public class HomeController {
    
    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to BaseU Server");
        response.put("status", "running");
        response.put("version", "1.0.0");
        response.put("docs", "/swagger-ui.html");
        return response;
    }
}
