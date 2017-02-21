#!/usr/bin/python
import sys
import logging
import rds_config
import pymysql

rds_host  = rds_config.db_endpoint
name = rds_config.db_username
password = rds_config.db_password
db_name = rds_config.db_name
port = 3306

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(rds_host, user=name,
                           passwd=password, db=db_name, connect_timeout=5)
except:
    logger.error("ERROR: Unexpected error: Could not connect to Aurora instance.")
    sys.exit()

logger.info("SUCCESS: Connection to RDS Aurora instance succeeded")
def handler(event, context):
    """
    This function inserts content into Aurora RDS instance
    """
    item_count = 0

    with conn.cursor() as cur:
        cur.execute("drop table if exists Employee3")
        cur.execute("create table Employee3 (EmpID  int NOT NULL, Name varchar(255) NOT NULL, PRIMARY KEY (EmpID))")
        cur.execute('insert into Employee3 (EmpID, Name) values(1, "Joe")')
        cur.execute('insert into Employee3 (EmpID, Name) values(2, "Bob")')
        cur.execute('insert into Employee3 (EmpID, Name) values(3, "Mary")')
        conn.commit()
        cur.execute("select * from Employee3")
        for row in cur:
            item_count += 1
            logger.info(row)
    return "Added %d items to RDS Aurora table" %(item_count)
