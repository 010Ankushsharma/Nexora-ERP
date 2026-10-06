"""Database Seed Data Generator."""
import asyncio
import random
from datetime import datetime, timedelta
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend', 'app'))

async def seed_database():
    """Populate database with sample data."""
    
    print("=" * 60)
    print("🌱 Seeding AI ERP Database")
    print("=" * 60)
    
    # Sample HR Data
    departments = [
        {"name": "Engineering", "budget": 2000000},
        {"name": "Sales", "budget": 1500000},
        {"name": "Marketing", "budget": 800000},
        {"name": "Finance", "budget": 600000},
        {"name": "Human Resources", "budget": 400000},
    ]
    
    employees_sample = [
        {"first_name": "John", "last_name": "Doe", "position": "Senior Developer"},
        {"first_name": "Jane", "last_name": "Smith", "position": "Product Manager"},
        {"first_name": "Robert", "last_name": "Johnson", "position": "Sales Director"},
        {"first_name": "Emily", "last_name": "Davis", "position": "HR Manager"},
        {"first_name": "Michael", "last_name": "Brown", "position": "Financial Analyst"},
    ]
    
    # Sample Financial Transactions
    transaction_types = ['expense', 'income']
    categories = ['office_supplies', 'software', 'marketing', 'salaries', 'equipment']
    
    transactions_sample = []
    for i in range(100):
        transactions_sample.append({
            "transaction_type": random.choice(transaction_types),
            "category": random.choice(categories),
            "amount": random.uniform(100, 10000),
            "currency": "USD",
            "transaction_date": (datetime.now() - timedelta(days=random.randint(0, 365))).strftime("%Y-%m-%d"),
        })
    
    # Sample Products
    products_sample = [
        {"sku": "WGT-001", "name": "Widget A", "quantity_in_stock": 150, "unit_price": 29.99},
        {"sku": "WGT-002", "name": "Widget B", "quantity_in_stock": 75, "unit_price": 49.99},
        {"sku": "WGT-003", "name": "Gadget X", "quantity_in_stock": 200, "unit_price": 99.99},
        {"sku": "WGT-004", "name": "Gadget Y", "quantity_in_stock": 50, "unit_price": 149.99},
        {"sku": "WGT-005", "name": "Tool Z", "quantity_in_stock": 300, "unit_price": 19.99},
    ]
    
    # Sample Customers
    customers_sample = [
        {"company_name": "TechCorp Inc.", "contact_email": "contact@techcorp.com", "annual_revenue": 5000000},
        {"company_name": "Global Solutions", "contact_email": "info@globalsolutions.com", "annual_revenue": 3500000},
        {"company_name": "Innovation Labs", "contact_email": "hello@innovationlabs.com", "annual_revenue": 2000000},
    ]
    
    # Print confirmation
    print(f"
✓ Sample data generated:")
    print(f"  - {len(departments)} departments")
    print(f"  - {len(employees_sample)} employees")
    print(f"  - {len(transactions_sample)} financial transactions")
    print(f"  - {len(products_sample)} products")
    print(f"  - {len(customers_sample)} customers")
    print("
✅ Database seeding completed!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(seed_database())
