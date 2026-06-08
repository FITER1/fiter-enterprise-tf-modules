import os
import sys
import json
import logging
import boto3
from botocore.exceptions import ClientError
import psycopg
from psycopg import sql


logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

def create_secret(client, secret_name, username, db_owner):
    SECRET_BACKEND = os.environ.get("SECRET_BACKEND", "aws").lower()

    if SECRET_BACKEND == "aws":
        try:
            randomPassword = client.get_random_password(
                PasswordLength=16,
                ExcludePunctuation=True
            )
            password = randomPassword["RandomPassword"]
        except ClientError as e:
            logger.error(f"Failed to generate AWS random password: {e}")
            raise e
    else:
        password = os.environ.get("DB_PASSWORD")
        if not password:
            logger.error("Missing DB_PASSWORD environment variable in local mode.")
            raise ValueError("DB_PASSWORD must be set when SECRET_BACKEND=local")

        logger.info(f"[LOCAL MODE] Using provided password from environment for {username}")

    secret = {
        "username": username,
        "password": password,
        "host": os.environ.get("DB_HOST"),
        "jdbc_url": f"jdbc:postgresql://{os.environ.get('DB_HOST')}:{os.environ.get('DB_PORT')}/{db_owner}"
    }

    if SECRET_BACKEND == "aws":
        try:
            client.create_secret(
                Name=secret_name,
                SecretString=json.dumps(secret),
                Tags=[
                    {
                        'Key': 'OwnedBy',
                        'Value': 'Terraform'
                     }],
            )
            logger.info(f"Secret {secret_name} created in AWS Secrets Manager.")
        except ClientError as error:
            if error.response['Error']['Code'] == 'ResourceExistsException':
                existing_secret = get_secret(client, secret_name)
                password = existing_secret["password"]
                logger.info(f"Secret {secret_name} already exists. Using existing password.")
            else:
                logger.error(f"Error creating secret {secret_name}: {error}")
                raise error
    else:
        logger.info("[LOCAL MODE] Secret not stored in AWS.")

    return password

def get_secret(client, secret_name):
    logger.info(f"attempting to get secret: {secret_name}")
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)
    except ClientError as e:
        logger.error(f"Error retrieving secret {secret_name}: {e}")
        raise e


def delete_secret(client, secret_name):
    logger.info(f"Attempting to delete secret: {secret_name}")
    try:
        client.delete_secret(SecretId=secret_name, ForceDeleteWithoutRecovery=True)
        logger.info(f"Secret {secret_name} deleted successfully.")
        return True
    except ClientError as e:
        logger.error(f"Error deleting secret {secret_name}: {e}")
        raise e

def db_connection_manager(db_params, database, query):
    db_params["dbname"] = database
    try:
        connection = psycopg.connect(**db_params)
        # connection.isolation_level(IsolationLevel.READ_UNCOMMITTED)
        connection.autocommit = True
        cursor = connection.cursor()
        cursor.execute(query)
    except (Exception, psycopg.Error) as error:
        logger.error(f"Error connecting to the database: {error}")
    finally:
        if connection:
            cursor.close()
            connection.close()
            logger.info("Database connection closed.")
    return True

def db_manager(event):
    DB_IDENTIFIER = os.environ["DB_IDENTIFIER"]
    SECRET_PATH = os.environ["SECRET_PATH"]
    USER_NAME = f'{event["USERNAME"]}'
    SECRET_NAME = f'{SECRET_PATH}/{USER_NAME}'
    DATABASES = event["DATABASES"]
    REGION_NAME = os.environ['AWS_REGION'] if os.environ.get("SECRET_BACKEND", "aws").lower() == "aws" else None
    ADMIN_SECRET_NAME = os.environ["ADMIN_SECRET_NAME"]
    DB_HOST = os.environ["DB_HOST"]
    DB_PORT = os.environ["DB_PORT"]
    ADMIN_DB_NAME = os.environ["ADMIN_DB_NAME"]
    DB_INIT = f'{event["DB_INIT"]}'
    ACCESS_TYPE = f'{event["ACCESS_TYPE"]}'
    DB_OWNER = f'{event["DB_OWNER"]}'
    SECRET_BACKEND = os.environ.get("SECRET_BACKEND", "aws").lower()

    if SECRET_BACKEND == "aws":
        session = boto3.session.Session()
        client = session.client(service_name='secretsmanager', region_name=REGION_NAME)
        db_secret = get_secret(client, ADMIN_SECRET_NAME)
    else:
        logger.info("Running in local mode skipping AWS Secrets Manager.")
        client = None
        db_secret = {
            "username": os.getenv("USERNAME"),
            "password": os.getenv("PASSWORD"),
        }

    db_params = {
        "host": DB_HOST,
        "dbname": ADMIN_DB_NAME,
        "user": db_secret["username"],
        "password": db_secret["password"],
        "port": DB_PORT,
        "sslmode": "disable" if SECRET_BACKEND == "local" else "require"
    }

    try:
        connection = psycopg.connect(**db_params)
        connection.autocommit = True
        cursor = connection.cursor()

        if DB_INIT == "True":
            cursor.execute("REVOKE CREATE ON SCHEMA public FROM PUBLIC;")
        else:
            ACTION = event["tf"]["action"]
            if ACTION == "create":
                for database_name in DATABASES:
                    cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = %s", (database_name,))
                    exists = cursor.fetchone()
                    if not exists:
                        cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(database_name)))
                        cursor.execute(f"REVOKE ALL ON DATABASE {database_name} FROM PUBLIC")
                        cursor.execute(f"CREATE ROLE {database_name}_readwrite")
                        cursor.execute(f"GRANT CONNECT ON DATABASE {database_name} TO {database_name}_readwrite")
                        cursor.execute(f"CREATE ROLE {database_name}_readonly")
                        cursor.execute(f"GRANT CONNECT ON DATABASE {database_name} TO {database_name}_readonly")

                        queries = f"""
                            DO $$
                            BEGIN
                                REVOKE CREATE ON SCHEMA public FROM PUBLIC;
                                GRANT ALL ON SCHEMA public TO {database_name}_readwrite;
                                GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO {database_name}_readwrite;
                                ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO {database_name}_readwrite;
                                GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO {database_name}_readwrite;
                                GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO {database_name}_readwrite;
                                ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO {database_name}_readwrite;
                                GRANT pg_write_all_data TO {database_name}_readwrite;
                                GRANT USAGE ON SCHEMA public TO {database_name}_readonly;
                                GRANT SELECT ON ALL TABLES IN SCHEMA public TO {database_name}_readonly;
                                GRANT {database_name}_readwrite TO postgres;
                                ALTER DEFAULT PRIVILEGES FOR ROLE {database_name}_readwrite IN SCHEMA public GRANT SELECT ON TABLES TO {database_name}_readonly;
                                ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO {database_name}_readonly;
                                GRANT pg_read_all_data TO {database_name}_readonly;
                                CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
                            END $$;
                        """
                        db_connection_manager(db_params, database_name, queries)
                        logger.info(f"Database {database_name} created successfully.")
                    else:
                        logger.info(f"Database {database_name} already exists.")

                cursor.execute("SELECT 1 FROM pg_roles WHERE rolname=%s", (USER_NAME,))
                user_exists = cursor.fetchone()

                if not user_exists:
                    user_secret = create_secret(client, SECRET_NAME, USER_NAME, DB_OWNER)
                    cursor.execute(
                        sql.SQL("CREATE USER {} WITH PASSWORD {}").format(
                            sql.Identifier(USER_NAME),
                            sql.Literal(user_secret)
                        )
                    )
                    cursor.execute(f"REVOKE ALL PRIVILEGES ON DATABASE postgres FROM {USER_NAME}")
                    for database_name in DATABASES:
                        queries = f"GRANT {database_name}_{ACCESS_TYPE} TO {USER_NAME}"
                        db_connection_manager(db_params, database_name, queries)
                        logger.info(f"User {USER_NAME} created successfully with Role {database_name}_{ACCESS_TYPE}.")
                else:
                    logger.info(f"User {USER_NAME} already exists.")
            elif ACTION == "update":
                for database_name in DATABASES:
                    queries = f"GRANT {database_name}_{ACCESS_TYPE} TO {USER_NAME}"
                    db_connection_manager(db_params, database_name, queries)
                    logger.info(f"User {USER_NAME} updated successfully with Role {database_name}_{ACCESS_TYPE}.")

            elif ACTION == "delete":
                for database_name in DATABASES:
                    queries = f"REVOKE {database_name}_{ACCESS_TYPE} FROM {USER_NAME}"
                    db_connection_manager(db_params, database_name, queries)
                
                cursor.execute(f"DROP USER IF EXISTS {USER_NAME}")
                delete_secret(client, SECRET_NAME)
            else:
                logger.info(f"No Action to take'")

    except (Exception, psycopg.Error) as error:
        logger.error(f"Error connecting to the database: {error}")

    finally:
        if connection:
            cursor.close()
            connection.close()
            logger.info("Database connection closed.")
            
    return {
        "secretname": SECRET_NAME
    }

def lambda_handler(event, context):
    try:
        db_manager(event)
    except Exception as e:
        logger.error(f"Error in lambda_handler: {e}")

if __name__ == "__main__":
    if os.environ.get("LAMBDA_TASK_ROOT") == None:
        config_file = os.environ.get("CONFIG_FILE")
        if not config_file:
            raise ValueError("CONFIG_FILE environment variable must be set when running locally")

        with open(config_file, "r") as file:
            event_data = json.load(file)
            db_manager(event_data)