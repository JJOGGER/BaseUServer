@echo off
chcp 65001 >nul
echo ======================================
echo    BaseU API 测试脚本
echo ======================================
echo.

echo 1. 测试发送验证码接口...
echo.
curl -X POST http://localhost:8080/api/auth/sendCode ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\":\"13800138000\",\"country\":\"CN\"}"
echo.
echo.

echo 2. 测试用户注册接口...
echo.
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"phoneNumber\":\"13800138000\",\"password\":\"Test123456\",\"verificationCode\":\"123456\",\"country\":\"CN\"}"
echo.
echo.

echo 测试完成！
pause

