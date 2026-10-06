-- AI ERP System Database Schema
-- PostgreSQL 16 Compatible

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users & Authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    role VARCHAR(50) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Departments (HR Module)
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    budget DECIMAL(15,2),
    parent_department_id INTEGER REFERENCES departments(id),
    manager_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_departments_manager ON departments(manager_id);

-- Employees (HR Module)
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    employee_number VARCHAR(50) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES departments(id),
    position VARCHAR(100),
    salary DECIMAL(12,2),
    hire_date DATE,
    performance_rating DECIMAL(3,2),
    attrition_risk_score DECIMAL(5,4),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(status);

-- Employee Performance Records
CREATE TABLE performance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id),
    review_period_start DATE,
    review_period_end DATE,
    rating DECIMAL(3,2),
    goals_achieved JSONB,
    feedback TEXT,
    reviewer_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_performance_employee ON performance_records(employee_id);

-- Financial Transactions
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    transaction_type VARCHAR(50) NOT NULL,
    category VARCHAR(100),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    transaction_date DATE NOT NULL,
    description TEXT,
    department_id INTEGER REFERENCES departments(id),
    created_by UUID REFERENCES users(id),
    fraud_score DECIMAL(5,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_fraud ON transactions(fraud_score);

-- Revenue Forecasting Data
CREATE TABLE revenue_forecasts (
    id SERIAL PRIMARY KEY,
    forecast_month DATE NOT NULL,
    predicted_revenue DECIMAL(15,2),
    actual_revenue DECIMAL(15,2),
    confidence_interval_lower DECIMAL(15,2),
    confidence_interval_upper DECIMAL(15,2),
    generated_by_model VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_forecasts_month ON revenue_forecasts(forecast_month);

-- Inventory Products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    quantity_in_stock INTEGER DEFAULT 0,
    reorder_point INTEGER,
    unit_price DECIMAL(12,2),
    supplier VARCHAR(200),
    category VARCHAR(100),
    forecast_demand_daily DECIMAL(10,2),
    stock_status VARCHAR(20),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_stock ON products(quantity_in_stock);
CREATE INDEX idx_products_status ON products(stock_status);

-- Stock Movements
CREATE TABLE stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    movement_type VARCHAR(20) NOT NULL,
    quantity_change INTEGER NOT NULL,
    reference_number VARCHAR(100),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_stock_product ON stock_movements(product_id);

-- Customers (CRM Module)
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(200),
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50),
    industry VARCHAR(100),
    annual_revenue DECIMAL(15,2),
    customer_segment VARCHAR(50),
    churn_risk_score DECIMAL(5,4),
    satisfaction_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_segment ON customers(customer_segment);
CREATE INDEX idx_customers_churn ON customers(churn_risk_score);

-- Leads (CRM Module)
CREATE TABLE leads (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(200),
    contact_person VARCHAR(200),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    lead_source VARCHAR(100),
    lead_score INT DEFAULT 50,
    qualification_status VARCHAR(50) DEFAULT 'new',
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_leads_status ON leads(qualification_status);
CREATE INDEX idx_leads_score ON leads(lead_score);

-- Workflow Executions
CREATE TABLE workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_name VARCHAR(100) NOT NULL,
    parameters JSONB,
    status VARCHAR(20) DEFAULT 'pending',
    result JSONB,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_workflow_status ON workflow_executions(status);
CREATE INDEX idx_workflow_name ON workflow_executions(workflow_name);

-- Audit Logs
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);

-- Analytics Snapshots
CREATE TABLE analytics_snapshots (
    id SERIAL PRIMARY KEY,
    snapshot_date DATE NOT NULL,
    hr_metrics JSONB,
    finance_metrics JSONB,
    inventory_metrics JSONB,
    crm_metrics JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_snapshots_date ON analytics_snapshots(snapshot_date);

-- Insert default admin user
INSERT INTO users (email, username, password_hash, full_name, role, is_active)
VALUES ('admin@company.com', 'admin', 
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.GRJlv.veX.qGBK',
        'System Administrator', 'administrator', true);

-- Create additional indexes for common queries
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_customers_revenue ON customers(annual_revenue);
CREATE INDEX idx_leads_created ON leads(created_at);

-- Add comments for documentation
COMMENT ON TABLE users IS 'User authentication and profile data';
COMMENT ON TABLE employees IS 'Employee records and HR management';
COMMENT ON TABLE transactions IS 'Financial transaction records';
COMMENT ON TABLE products IS 'Product inventory data';
COMMENT ON TABLE customers IS 'Customer relationship management data';
COMMENT ON TABLE leads IS 'Sales lead tracking data';
COMMENT ON TABLE workflow_executions IS 'Workflow execution history';
COMMENT ON TABLE audit_logs IS 'System audit trail';

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO erp_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO erp_user;

ANALYZE;
