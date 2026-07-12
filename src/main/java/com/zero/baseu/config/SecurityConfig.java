package com.zero.baseu.config;

import com.zero.baseu.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security 配置
 * 
 * @author Zero Team
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 禁用CSRF（使用JWT不需要CSRF保护）
                .csrf(AbstractHttpConfigurer::disable)
                
                // 配置会话管理为无状态
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                
                // 配置授权规则
                .authorizeHttpRequests(auth -> auth
                        // 允许访问认证相关接口
                        .requestMatchers("/api/auth/**").permitAll()
                        // 允许访问充值回调接口
                        .requestMatchers("/api/recharge/callback/**").permitAll()
                        // 允许访问Swagger文档
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
                        // 允许访问根路径
                        .requestMatchers("/").permitAll()
                        // 允许管理员接口
                        .requestMatchers("/api/user/admin/**").permitAll()
                        .requestMatchers("/api/transaction/admin/**").permitAll()
                        .requestMatchers("/api/recharge/admin/**").permitAll()
                        // 其他所有请求需要认证
                        .anyRequest().authenticated()
                )
                
                // 添加JWT过滤器
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}

