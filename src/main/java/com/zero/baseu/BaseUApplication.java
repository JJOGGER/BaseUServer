package com.zero.baseu;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;

import java.net.InetAddress;

/**
 * BaseU 应用主启动类
 * 
 * @author Zero Team
 * @version 1.0.0
 */
@SpringBootApplication
@MapperScan("com.zero.baseu.mapper")
public class BaseUApplication {

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(BaseUApplication.class);
        Environment env = app.run(args).getEnvironment();
        
        logApplicationStartup(env);
    }
    
    private static void logApplicationStartup(Environment env) {
        String protocol = "http";
        String serverPort = env.getProperty("server.port", "8080");
        String contextPath = env.getProperty("server.servlet.context-path", "/");
        String hostAddress = "localhost";
        
        try {
            hostAddress = InetAddress.getLocalHost().getHostAddress();
        } catch (Exception e) {
            // ignore
        }
        
        String profiles = String.join(", ", env.getActiveProfiles());
        String appName = env.getProperty("app.name", "BaseU Server");
        String environment = env.getProperty("app.environment", "unknown");
        
        System.out.println("""
                
                ========================================
                   %s 启动成功！
                ========================================
                环境: %s
                配置: %s
                
                访问地址:
                ------------------------------------------
                本地: %s://localhost:%s%s
                外部: %s://%s:%s%s
                
                API文档:
                ------------------------------------------
                Swagger: %s://localhost:%s/swagger-ui.html
                
                ========================================
                """.formatted(
                appName,
                environment,
                profiles.isEmpty() ? "default" : profiles,
                protocol, serverPort, contextPath,
                protocol, hostAddress, serverPort, contextPath,
                protocol, serverPort
        ));
    }
}

