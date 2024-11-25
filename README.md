### **README.md**

# Hands-On Lab with dbt, SQLite, and BDD Testing Using Behave

Welcome to this hands-on lab! This tutorial is designed to give you a comprehensive understanding of using `dbt` (Data Build Tool) with `SQLite` for data engineering and testing workflows. We will explore how to:

- Set up `dbt` and `SQLite` in your development environment.
- Create and test `dbt` models.
- Use `Behave` for Behavior-Driven Development (BDD) testing to validate your models.

By the end of this lab, you will have a fully functional project for analyzing **London train ticket pricing data**. This lab combines practical coding exercises with conceptual clarity to solidify your learning.

---

## **Prerequisites**

Before starting, ensure you have the following installed on your system:

1. **Python 3.8 or higher**:
   - [Download Python](https://www.python.org/downloads/)
2. **SQLite**:
   - Pre-installed on most Linux/macOS systems.
   - Install on Windows via [SQLite Download Page](https://www.sqlite.org/download.html).
3. **Git** (optional but recommended for version control).

---

## **Step 1: Project Setup**

### **1.1. Set Up a Virtual Environment**

For Windows:
```bash
python -m venv venv
.\venv\Scripts\activate
```

For Ubuntu/macOS:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### **1.2. Install dbt and SQLite Adapter**
Run the following commands to install dbt and the SQLite adapter:
```bash
pip install dbt-core==1.5.1 dbt-sqlite==1.5.0
```

If you have an existing dbt installation, remove it first:
```bash
pip uninstall dbt-core dbt-adapters dbt-common dbt-extractor dbt-semantic-interfaces dbt-sqlite
```

Then, re-install:
```bash
pip install dbt-core==1.5.1
pip install dbt-sqlite==1.5.0
```

---

## **Step 2: Initialize the dbt Project**

### **2.1. Create a dbt Project**

1. Initialize the dbt project:
   ```bash
   dbt init bdd_dbt
   ```
2. Navigate to the project directory:
   ```bash
   cd bdd_dbt
   ```

3. Create a `.gitignore` file and add the virtual environment directory to it:
   ```
   .venv/
   ```

### **2.2. Set Up SQLite Database**

1. Create an SQLite database:
   ```bash
   sqlite3 mydata_db.db
   ```
   Press `CTRL+D` to exit.

2. Add the SQLite database to `profiles.yml`:
   ```yaml
   bdd_dbt:
     target: dev
     outputs:
       dev:
         type: sqlite
         threads: 1
         database: "mydata_db.db"
   ```
   Save this file in `~/.dbt/profiles.yml`.

3. Ensure your `dbt_project.yml` matches the following:
   ```yaml
   name: 'bdd_dbt'
   version: '1.0'
   config-version: 2

   profile: 'bdd_dbt'

   target-path: "target"
   clean-targets:
     - "target"
     - "dbt_packages"
   ```

---

## **Step 3: Seed Data**

1. Add a CSV file for train ticket pricing data in the `seeds/` directory:
   ```csv
   station_from,station_to,price,date,time,train_operator,journey_duration
   London Bridge,Waterloo,5.50,2024-01-01,08:15,Southern,15
   London Bridge,Victoria,6.00,2024-01-01,09:45,Southern,18
   Waterloo,Victoria,4.75,2024-01-02,10:30,South Western Railway,12
   ```

2. Load the seed file into your database:
   ```bash
   dbt seed
   ```

---

## **Step 4: Create and Run Models**

### **4.1. Example Model: Most Popular Routes**
Save this file as `models/most_popular_routes.sql`:
```sql
with route_sales as (
    select
        station_from,
        station_to,
        count(*) as tickets_sold,
        round(sum(price), 2) as total_revenue
    from {{ ref('train_ticket_prices') }}
    group by station_from, station_to
)

select
    station_from,
    station_to,
    tickets_sold,
    total_revenue,
    rank() over (order by tickets_sold desc) as popularity_rank
from route_sales
```

Run the model:
```bash
dbt run --select most_popular_routes
```

---

## **Step 5: Test Models**

### **5.1. Example Test: Validate Non-Negative Values**
Save this as `tests/test_most_popular_routes_non_negative.sql`:
```sql
select *
from {{ ref('most_popular_routes') }}
where tickets_sold < 0 or total_revenue < 0
```

Run the test:
```bash
dbt test --select most_popular_routes
```

---

## **Step 6: BDD Testing with Behave**

### **6.1. Feature File**
Save this as `features/test_most_popular_routes.feature`:
```gherkin
Feature: Validate the most popular routes model

  Scenario: Ensure no negative values
    Given the dbt project is set up
    When I query the "most_popular_routes" model
    Then all tickets_sold and total_revenue should be non-negative
```

### **6.2. Step Definitions**
Save this as `features/steps/test_most_popular_routes.py`:
```python
import sqlite3
from behave import given, when, then

DATABASE_PATH = "mydata_db.db"

@given("the dbt project is set up")
def step_given_dbt_project(context):
    context.conn = sqlite3.connect(DATABASE_PATH)

@when('I query the "{model_name}" model')
def step_when_query_model(context, model_name):
    query = f"SELECT * FROM {model_name}"
    context.results = context.conn.execute(query).fetchall()

@then("all tickets_sold and total_revenue should be non-negative")
def step_then_validate_non_negative(context):
    for row in context.results:
        tickets_sold = row[2]
        total_revenue = row[3]
        assert tickets_sold >= 0, "Negative tickets_sold found"
        assert total_revenue >= 0, "Negative total_revenue found"
```

### **6.3. Run the Behave Tests**
```bash
behave
```

---

## **Conclusion**

Happy Testing!!!