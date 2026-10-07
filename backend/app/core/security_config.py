"""Security Configuration."""
from pydantic import BaseModel
from typing import Optional

class SecurityConfig(BaseModel):
    """Application security settings."""
    
    # JWT Configuration
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 60
    
    # Password Security
    password_min_length: int = 8
    password_require_uppercase: bool = True
    password_require_numbers: bool = True
    password_require_special: bool = True
    
    # Rate Limiting
    rate_limit_requests: int = 100
    rate_limit_window_seconds: int = 60
    
    # CORS Settings
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost"]
    
    # API Security
    api_rate_limit_per_ip: int = 1000
    api_max_request_size_mb: float = 10.0
    
    # Audit Logging
    audit_enabled: bool = True
    audit_log_retention_days: int = 90
    
    class Config:
        env_prefix = "SECURITY_"

config = SecurityConfig()
