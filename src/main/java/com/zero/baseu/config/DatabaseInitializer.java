package com.zero.baseu.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

/**
 * 数据库初始化器
 * 在应用启动时自动检查并创建数据库
 * 
 * @author Zero Team
 */
@Slf4j
@Component
public class DatabaseInitializer implements CommandLineRunner {
    
    @Value("${spring.datasource.url}")
    private String datasourceUrl;
    
    @Value("${spring.datasource.username}")
    private String username;
    
    @Value("${spring.datasource.password}")
    private String password;
    
    @Override
    public void run(String... args) {
        try {
            // 从完整URL中提取数据库名
            String databaseName = extractDatabaseName(datasourceUrl);
            if (databaseName == null || databaseName.isEmpty()) {
                log.warn("无法从URL中提取数据库名，跳过自动创建");
                return;
            }
            
            // 构建不包含数据库名的URL（用于创建数据库）
            String baseUrl = getBaseUrl(datasourceUrl);
            
            log.info("检查数据库是否存在: {}", databaseName);
            
            // 连接MySQL服务器（不指定数据库）
            try (Connection conn = DriverManager.getConnection(baseUrl, username, password);
                 Statement stmt = conn.createStatement()) {
                
                // 检查数据库是否存在
                String checkSql = String.format(
                    "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '%s'", 
                    databaseName
                );
                
                var rs = stmt.executeQuery(checkSql);
                
                if (!rs.next()) {
                    // 数据库不存在，创建它
                    log.info("数据库 {} 不存在，正在创建...", databaseName);
                    String createSql = String.format(
                        "CREATE DATABASE `%s` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
                        databaseName
                    );
                    stmt.executeUpdate(createSql);
                    log.info("✅ 数据库 {} 创建成功！", databaseName);
                } else {
                    log.info("✅ 数据库 {} 已存在", databaseName);
                }
                
                rs.close();
            }
            
        } catch (Exception e) {
            log.error("数据库初始化失败", e);
            log.warn("请确保MySQL服务已启动，并且用户 {} 有创建数据库的权限", username);
        }
    }
    
    /**
     * 从JDBC URL中提取数据库名
     * 例如: jdbc:mysql://localhost:3306/baseu?xxx -> baseu
     */
    private String extractDatabaseName(String url) {
        try {
            // 移除参数部分
            String urlWithoutParams = url.split("\\?")[0];
            // 提取数据库名
            String[] parts = urlWithoutParams.split("/");
            if (parts.length > 0) {
                return parts[parts.length - 1];
            }
        } catch (Exception e) {
            log.error("提取数据库名失败", e);
        }
        return null;
    }
    
    /**
     * 获取基础URL（不包含数据库名）
     * 例如: jdbc:mysql://localhost:3306/baseu?xxx -> jdbc:mysql://localhost:3306?xxx
     */
    private String getBaseUrl(String url) {
        try {
            String databaseName = extractDatabaseName(url);
            if (databaseName != null) {
                return url.replace("/" + databaseName, "");
            }
        } catch (Exception e) {
            log.error("构建基础URL失败", e);
        }
        return url;
    }
}

