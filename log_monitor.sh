#!/bin/bash


#selfnote : added unique contstraint to avoid duplicates on the entries 


# Database connection parameters
DB_NAME="logdb"
DB_USER="dedsec" 
DB_PASSWORD="admin" 
LOG_FILE="/var/log/app.log" 

# Export the password for the psql command
export PGPASSWORD=$DB_PASSWORD

# Test the database connection
psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Database connection failed. Please check your connection parameters."
    unset PGPASSWORD
    exit 1
fi

echo "Database connection successful."

# Read the log file line by line
while IFS= read -r LINE
do
    # Extract date, level, and message from the log lines
    DATE_TIME=$(echo "$LINE" | awk '{print $1, $2}')
    LEVEL=$(echo "$LINE" | awk -F'[][]' '{print $2}')
    MESSAGE=$(echo "$LINE" | cut -d ' ' -f4-)

    # Escape single quotes in the message for the bug
    MESSAGE=${MESSAGE//\'/\'\'}

    # Check if the log level is "error" or "fatal"
    if [[ "$LEVEL" == "ERROR" || "$LEVEL" == "FATAL" ]]; then
        # Insert the parsed log entry to the database
        psql -U "$DB_USER" -d "$DB_NAME" -c "INSERT INTO logs (date_time, level, message) VALUES ('$DATE_TIME', '$LEVEL', '$MESSAGE');"  && echo "Write test: SUCCESS" || echo "Write test: FAILED"
    fi

done < "$LOG_FILE"

# Unset the password
unset PGPASSWORD

echo "Error and fatal log messages have been successfully imported into the database."