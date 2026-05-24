import os
import json
import logging
import pymysql.cursors
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def create_secret(client, secret_name, username):
    try:
        randomPassword = client.get_random_password(
            PasswordLength=16,
            ExcludePunctuation=True
        )
        password = randomPassword["RandomPassword"]
        secret = json.dumps({
            "username": username,
            "password": password
        })
        client.create_secret(
            Name=secret_name,
            SecretString=secret,
            Tags=[
                {
                    'Key': 'OwnedBy',
                    'Value': 'Terraform'
                }
            ],
        )
    except ClientError as error:
        if error.response['Error']['Code'] == 'ResourceExistsException':
            secret = get_secret(client, secret_name)
            password = secret["password"]
        else:
            raise error

    return password

def get_secret(client, secret_name):
    logger.info(f"attempting to get {secret_name}")
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e
    
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

def delete_secret(client, secret_name):
    logger.info(f"attempting to Delete {secret_name}")
    try:
        response = client.delete_secret(
            SecretId=secret_name,
            ForceDeleteWithoutRecovery=True
        )
    except ClientError as e:
        raise e
    return True



queries = {
    "CREATE_DB": "CREATE DATABASE IF NOT EXISTS %s;",
    "CREATE_USER": "CREATE USER %s@'%%' IDENTIFIED BY %s;",
    "GRANT_SERVICE": "GRANT ALL PRIVILEGES ON %s.* TO %s@'%%';",
    "FLUSH": "FLUSH PRIVILEGES;",
    "DROP_USER": "DROP USER IF EXISTS %s;",
    "USER_EXIST": "SELECT user FROM mysql.user WHERE user = %s;",
    "DB_EXIST": "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = %s;"
}

def createConnection(db_secret, host, db_name, db_port=3306):
    conn = pymysql.connect(host=host,
                                user=db_secret["username"],
                                password=db_secret["password"],
                                database=db_name,
                                charset='utf8mb4',
                                port=db_port,
                                cursorclass=pymysql.cursors.DictCursor)
    return conn

def lambda_handler(event, context):
    SECRET_PATH = os.environ["SECRET_PATH"]
    USER_NAME = f'{event["USERNAME"]}'
    SECRET_NAME = f'{SECRET_PATH}/{USER_NAME}'
    DATABASES = event["DATABASES"]
    REGION_NAME = os.environ['AWS_REGION']
    ADMIN_SECRET_NAME = os.environ["ADMIN_SECRET_NAME"]
    DB_HOST = os.environ["DB_HOST"]
    DB_PORT = int(os.environ.get("DB_PORT", 3306))
    ADMIN_DB_NAME = os.environ["ADMIN_DB_NAME"]
    DB_INIT = f'{event["DB_INIT"]}'
    ACCESS_TYPE = f'{event["ACCESS_TYPE"]}'

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=REGION_NAME
    )

    db_secret = get_secret(client, ADMIN_SECRET_NAME)
    
    # Initialize cursor and conn to None
    cursor = None
    conn = None
    
    try:
        conn = createConnection(db_secret, DB_HOST, ADMIN_DB_NAME, DB_PORT)
        admin_user = db_secret["username"]
        cursor = conn.cursor()
        
        if DB_INIT == "True":
            cursor.execute(f"GRANT ROLE_ADMIN on *.* TO {admin_user};")
        else:
            ACTION = event["tf"]["action"]
            if ACTION == "create":
                for database_name in DATABASES:
                    cursor.execute(queries["DB_EXIST"], (database_name,))
                    exists = cursor.fetchone()
                    if not exists:
                        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {database_name};")


                cursor.execute(queries["USER_EXIST"], (USER_NAME,))
                user_exists = cursor.fetchone() is not None

                if user_exists:
                    logger.info(f"User '{USER_NAME}' already exists.")
                else:
                    user_secret = create_secret(client, SECRET_NAME, USER_NAME)

                    CREATE_USER_SQL = queries["CREATE_USER"]
                    cursor.execute(CREATE_USER_SQL, (USER_NAME, user_secret))
                    for database_name in DATABASES:
                        if ACCESS_TYPE == 'readwrite':
                            cursor.execute(f"GRANT ALL ON {database_name}.* TO %s@'%%';", (USER_NAME,))
                        else:
                            cursor.execute(f"GRANT SELECT ON {database_name}.* TO %s@'%%';", (USER_NAME,))
                        logger.info(f"User {USER_NAME} created successfully with Role {ACCESS_TYPE} on database {database_name}.")
                    logger.info(f"User '{USER_NAME}' created.")
                # Commit the changes
                conn.commit()
                cursor.execute(queries["FLUSH"])

            elif ACTION == "update":
                # Grant all permissions on the database to the user
                for database_name in DATABASES:
                    if ACCESS_TYPE == 'readwrite':
                        cursor.execute(f"GRANT ALL ON {database_name}.* TO %s@'%%';", (USER_NAME,))
                    else:
                        cursor.execute(f"GRANT SELECT ON {database_name}.* TO %s@'%%';", (USER_NAME,))
                    logger.info(f"User {USER_NAME} update successfully with Role {ACCESS_TYPE} on database {database_name}.")
                conn.commit()
                cursor.execute(queries["FLUSH"])
            elif ACTION == "delete":
                delete_secret(client, SECRET_NAME)
                # Delete User
                DROP_USER_SQL = queries["DROP_USER"]
                cursor.execute(DROP_USER_SQL, (USER_NAME))
                conn.commit()
                cursor.execute(queries["FLUSH"])
            else:
                logger.info(f"No Action to take'")

    except pymysql.MySQLError as e:
        logger.error(f"Error: {e}")
    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None:
            conn.close()
        
    return {
        "secretname": SECRET_NAME
    }
