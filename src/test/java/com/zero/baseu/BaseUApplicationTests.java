package com.zero.baseu;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * 应用启动测试
 * 
 * @author Zero Team
 */
@SpringBootTest
@ActiveProfiles("dev")
class BaseUApplicationTests {

    @Test
    void contextLoads() {
        // 测试应用上下文是否能正常加载
    }
}

