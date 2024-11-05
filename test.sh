#!/bin/bash

# PostgreSQL connection details
DB_NAME="logdb"
DB_USER="dedsec"
DB_PASSWORD="Fuzzybear2001!"
DB_HOST="localhost"
DB_PORT="5432"

# Table and test log details
TABLE_NAME="test_logs"
TEST_LOG_MESSAGE="Test log entry for write check."

# Export the password for the PostgreSQL user to avoid password prompt
export PGPASSWORD="$DB_PASSWORD"

# Check if the database connection works and the user can create a table and insert data
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    id SERIAL PRIMARY KEY,
    log_message TEXT NOT NULL,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
" && echo "Table check: SUCCESS" || echo "Table check: FAILED"

# Attempt to insert a test log entry
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
INSERT INTO $TABLE_NAME (log_message) VALUES ('$TEST_LOG_MESSAGE');
" && echo "Write test: SUCCESS" || echo "Write test: FAILED"

# Optional: Clean up by deleting the test log entry (if desired)
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
DELETE FROM $TABLE_NAME WHERE log_message = '$TEST_LOG_MESSAGE';
" && echo "Cleanup: SUCCESS" || echo "Cleanup: FAILED"
