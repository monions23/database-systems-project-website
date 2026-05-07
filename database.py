from locale import D_FMT

import mysql.connector
import pandas as pd

# Return SQL connector
def connect():
    return mysql.connector.connect(
            host="localhost",  
            user="root",
            password="Xutax#39865452!",
            database="hamburg_inn"
        )

### GET PRIVILEGES FOR A SPECIFIC ROLE
### RETURNS A DICTIONARY WITH FORMAT { Relation_Name: Privileges}
def get_privileges(user_name: str):
    query=f"SHOW GRANTS FOR '{user_name}';"

    relation_privileges = {}

    # connect to database, open cursor, and execute query
    with connect() as mycon: # handle opening and closing connection
        with mycon.cursor() as cursor:
            cursor.execute(query)
            grants = cursor.fetchall()
            
            # loop through grants, and use split functions to find user privileges for corresponding relation
            # add result to relation_privileges dictionary
            for grant in grants:
                grant_statement = grant[0];
                if "`hamburg_inn`.`" in grant_statement and "` TO" in grant_statement:
                    relation = grant_statement.split("`hamburg_inn`.`")[1].split("` TO")[0]
                    relation = relation.title() # make sure relation is in title case
                    privileges = grant_statement.split("GRANT")[1].split("ON")[0]
                    relation_privileges[relation] = privileges

            print(relation_privileges)
            return relation_privileges


### GETS ALL THE RELATIONS FOR A ROLE ALONGSIDE EACH RELATION'S INTERNAL DATA
### RETURNS A DICTIONARY IN FORMAT { ROLE: RELATIONS }
def get_all_relations_for_role(role_name: str):
    privileges = get_privileges(role_name)
    results = {} # results is a dictionary

    # define the dictionary - key is relation, value is relation data
    for rel in privileges.keys():
        if "Record_Daily_Key_Order_Times" not in rel and "Get_Event_Most_Popular_Item" not in rel:
            results[rel] = get_relation(rel)

    return results
        
### CREATE OPERATION FUNCTION
def insert_into_relation(rel: str, data: dict):

    cols = ", ".join(data.keys())
    placeholders = ", ".join(["%s"] * len(data))
    values = list(data.values())

    query = f"INSERT INTO `{rel}` ({cols}) VALUES ({placeholders})"

    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query, values)
            new_id = cursor.lastrowid   # 🔥 THIS IS THE KEY
        mycon.commit()

    return new_id
### RETRIEVE OPERATION FUNCTION
### RETURNS A PANDAS DATAFRAME AS A DICT
def get_relation(rel: str, select_params: str = "*"):

    # define query
    query = f"SELECT {select_params} FROM `{rel}`"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query)
            col_name = cursor.column_names # get column names
            rows = cursor.fetchall() # fetch all rows from the last executed statement
            relation_df = pd.DataFrame(rows, columns=col_name)
            return relation_df.to_dict(orient = "split")

### UPDATE OPERATION FUNCTION
def update_relation(rel: str, updated_items: dict, update_params: dict, ):
    # FIX: use parameterized queries (%s placeholders) to prevent SQL injection and handle quoted values
    set_clause = ", ".join(f"{k} = %s" for k in updated_items.keys())
    where_clause = " AND ".join(f"{k} = %s" for k in update_params.keys())
    values = list(updated_items.values()) + list(update_params.values())

    # define query
    query = f"UPDATE `{rel}` SET {set_clause} WHERE {where_clause}"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query, values)
        mycon.commit()

### DELETE OPERATION FUNCTION
def delete_from_relation(rel: str, delete_params: dict):
    # FIX: use parameterized queries (%s placeholders) to prevent SQL injection and handle quoted values
    where_clause = " AND ".join(f"{k} = %s" for k in delete_params.keys())
    values = list(delete_params.values())

    # define query
    query = f"DELETE FROM `{rel}` WHERE {where_clause}"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query, values)
        mycon.commit()



# TEST QUERIES
# print(get_relation("Employee"))
# insert_into_relation("Employee", {"employee_id": 8, "name": "thomas", "role": "server", "hourly_pay": 9.25, "tips_earned": 10.00, "start_date": "2026-04-30" })
# print(get_relation("Employee"))
# update_relation("Employee", {"name": "Thomas", "hourly_pay": 12.00}, {"employee_id": 8})
# print(get_relation("Employee"))
# delete_from_relation("Employee", {"employee_id": 8})
# print(get_relation("Employee"))

# Print Privileges
# privileges = get_privileges("manager_role")
# print(privileges.keys())
# print(type(privileges[1][0]))
# result = privileges[1][0]
# print(type(result))
# result = result.split("GRANT")[1].split("ON")[0]
# print(result.strip())
# print(get_all_relations_for_role("manager_role"))
# FIX: removed stray get_relation("Appetizer")

get_privileges("manager_role") #call that ran on every import
