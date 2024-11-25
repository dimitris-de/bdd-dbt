import sqlite3
import os
from behave import given, when, then

DATABASE_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "..", "mydata_db.db")

@given("the dbt project is set up")
def step_given_dbt_project(context):
    assert os.path.exists(DATABASE_PATH), f"Database file not found at: {DATABASE_PATH}"
    try:
        context.conn = sqlite3.connect(DATABASE_PATH)
    except sqlite3.Error as e:
        assert False, f"Failed to connect to SQLite database: {e}"

@when('I query the "{model_name}" model')
def step_when_query_model(context, model_name):
    query = f"SELECT * FROM {model_name}"
    try:
        context.cursor = context.conn.cursor()
        context.cursor.execute(query)
        context.results = context.cursor.fetchall()
    except sqlite3.Error as e:
        assert False, f"Failed to query model {model_name}: {e}"

@then("all revenue and ticket prices should be non-negative")
def step_then_validate_non_negative(context):
    # Validate that no revenue or ticket price is negative
    for row in context.results:
        total_revenue = row[2]  # Assuming total_revenue is the third column
        avg_ticket_price = row[3]  # Assuming avg_ticket_price is the fourth column
        assert total_revenue >= 0, f"Found negative revenue: {total_revenue}"
        assert avg_ticket_price >= 0, f"Found negative ticket price: {avg_ticket_price}"

@then("the result should not be empty")
def step_then_validate_not_empty(context):
    # Ensure the query returned results
    assert len(context.results) > 0, "The query result is empty"
