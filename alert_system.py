import psycopg
from datetime import datetime
from collections import defaultdict

def connect_to_db():
    try:
        # Connection to the database 
        connection = psycopg.connect(
            host="/var/run/postgresql",         
            dbname="logdb", 
            user="dedsec",     
            password="admin", 
            port="5432"          
        )
        return connection
    except psycopg.Error as error:
        print(f"Error connecting to the database: {error}")
        return None

def fetch_logs(connection):
    try:
        with connection.cursor() as cursor:
            # Execute a query to fetch all rows from the logs table
            cursor.execute("SELECT id, date_time, level, message FROM logs ORDER BY date_time")
            logs = cursor.fetchall()
            return logs
    except psycopg.Error as error:
        print(f"Error fetching logs: {error}")
        return []

def check_alert_conditions(logs):
    # Dictionary to hold counts of errors and fatals by minute
    alert_counts = defaultdict(lambda: {'error': 0, 'fatal': 0})

    # Iterate through logs to count errors and fatals by minute
    for log in logs:
        if len(log) == 4:
            id, date_time, level, message = log
            
            # Convert date_time to a datetime object and round to the minute
            minute_key = date_time.replace(second=0, microsecond=0)
            
            # Count errors and fatals based on log level
            if level.lower() == 'error':
                alert_counts[minute_key]['error'] += 1
            elif level.lower() == 'fatal':
                alert_counts[minute_key]['fatal'] += 1

    # Check if thresholds are exceeded for each minute
    for minute, counts in alert_counts.items():
        if counts['error'] >= 5:
            print(f"Alert: {counts['error']} errors exceeded the threshold of 5 at {minute}.")
        if counts['fatal'] >= 1:
            print(f"Alert: {counts['fatal']} fatal errors exceeded the threshold of 1 at {minute}.")

def main():
    # Connect to the database
    connection = connect_to_db()
    if connection is None:
        return

    # Fetch logs from the database
    logs = fetch_logs(connection)

    # Check alert conditions based on the logs
    if logs:
        check_alert_conditions(logs)
    else:
        print("No logs found or error fetching logs.")

    # Close the connection
    connection.close()

if __name__ == "__main__":
    main()