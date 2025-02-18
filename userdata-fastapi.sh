#!/bin/bash

exec > /var/log/userdata.log 2>&1

echo "Starting user-data script execution..."

# ALB_DNS_ENDPOINT=${ALB_DNS_ENDPOINT}

# Function to retry a command up to 5 times with backoff
retry_command() {
    local retries=5
    local count=0
    local delay=10
    local command=$1
    until $command; do
        ((count++))
        if [ $count -ge $retries ]; then
            echo "Command failed after $count attempts: $command"
            return 1
        fi
        echo "Command failed. Retrying ($count/$retries)..."
        sleep $delay
    done
}

# Update package list and install required packages
echo "Updating packages..."
retry_command "apt update -y"

echo "Installing Python3, Git, curl, net-tools, and dependencies..."
retry_command "apt install -y  python3 python3-pip git  ufw curl net-tools python3-venv"

# Disable UFW
echo "Disabling UFW..."
systemctl stop ufw
systemctl disable ufw


# Set up Python virtual environment for FastAPI
echo "Setting up Python virtual environment..."
mkdir -p /var/www/fastapi
cd /var/www/fastapi
python3 -m venv venv
source venv/bin/activate

# Install FastAPI, Gunicorn, Uvicorn, pymysql, python-multipart in the virtual environment
echo "Installing FastAPI, Gunicorn, Uvicorn, pymysql, boto3 and python-multipart..."
pip install fastapi pymysql gunicorn uvicorn python-multipart boto3

# Create FastAPI app with 'course' field handling
cat <<EOF > /var/www/fastapi/main.py
from fastapi import FastAPI, Form
from fastapi.middleware.cors import CORSMiddleware
import pymysql
import os
import boto3

app = FastAPI()

# CORS Middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins. Replace with specific domains if necessary.
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)


# Fetch RDS credentials and endpoint from AWS SSM Parameter Store
ssm = boto3.client("ssm", region_name="us-east-1")  # Replace with your AWS region

'''
# Fetch parameters from SSM securely
db_name_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-name", WithDecryption=True)
db_password_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-password", WithDecryption=True)
db_user_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-user", WithDecryption=True)
rds_endpoint_param = ssm.get_parameter(Name="tcb-fullstack-app-rds-endpoint", WithDecryption=True)

# Extract values from the parameters
DB_NAME = db_name_param["Parameter"]["Value"]
DB_USER = db_user_param["Parameter"]["Value"]
DB_PASSWORD = db_password_param["Parameter"]["Value"]
RDS_ENDPOINT = rds_endpoint_param["Parameter"]["Value"]

'''

try:
    db_name_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-name", WithDecryption=True)
    db_password_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-password", WithDecryption=True)
    db_user_param = ssm.get_parameter(Name="tcb-fullstack-app-mysql-db-user", WithDecryption=True)
    rds_endpoint_param = ssm.get_parameter(Name="tcb-fullstack-app-rds-endpoint", WithDecryption=True)

    DB_NAME = db_name_param["Parameter"]["Value"]
    DB_USER = db_user_param["Parameter"]["Value"]
    DB_PASSWORD = db_password_param["Parameter"]["Value"]
    RDS_ENDPOINT = rds_endpoint_param["Parameter"]["Value"]
except ssm.exceptions.ParameterNotFound as e:
    print(f"Parameter not found: {e}")
    raise Exception("One or more required SSM parameters are missing.")
except Exception as e:
    print(f"Error retrieving parameters: {e}")
    raise Exception("Error retrieving parameters from SSM.")

# Database connection function
def get_db_connection():
    return pymysql.connect(
        host=RDS_ENDPOINT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )


'''
def get_db_connection():
    return pymysql.connect(
        host="localhost",
        user="tcbadmin",
        password="Tcb@2025",
        database="tcb_db"
    )
'''
@app.post("/api/enquiry-register/")
async def submit_form(
    name: str = Form(...), 
    email: str = Form(...), 
    phone: str = Form(...), 
    message: str = Form(...),
    course: str = Form(...),  # Added course field
):
    # Open database connection
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Insert the form data into the database
        cursor.execute(
            "INSERT INTO tcb_enquiry (name, email, phone, message, course) VALUES (%s, %s, %s, %s, %s)",
            (name, email, phone, message, course)  # Insert course field
        )
        conn.commit()  # Commit the changes
    except Exception as e:
        conn.rollback()  # Rollback in case of an error
        return {"status": "error", "message": f"Error saving data: {str(e)}"}
    finally:
        cursor.close()
        conn.close()
    
    # Return success response
    return {"status": "success", "message": "Data saved successfully"}

@app.get("/api/enquiries/")
async def get_enquiries():
    # Open database connection
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)  # Using DictCursor to get results as dictionaries
    
    try:
        # Retrieve all the enquiries from the database
        cursor.execute("SELECT * FROM tcb_enquiry")
        rows = cursor.fetchall()  # Get all the rows
        
        # Return the rows as a JSON response
        return rows
    
    except Exception as e:
        return {"status": "error", "message": f"Error fetching data: {str(e)}"}
    
    finally:
        cursor.close()
        conn.close()


EOF

# Create systemd service for Gunicorn
echo "Creating Gunicorn service..."
cat <<EOF > /etc/systemd/system/fastapi.service
[Unit]
Description=FastAPI with Gunicorn Service
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/fastapi
ExecStart=/var/www/fastapi/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start FastAPI service
echo "Starting FastAPI service..."
systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi

# Verify installation
echo "Verifying installation..."

echo "Checking installed packages..."
dpkg -l | grep -E "python3|git|curl|net-tools"

echo "Checking running services..."
systemctl status fastapi --no-pager

echo "User-data script execution completed."
