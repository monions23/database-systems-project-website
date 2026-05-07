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
    if rel == "Customer_Transaction" and select_params == "*":
        select_params = "transaction_id, timestamp, total_amount, payment_method, employee_id, tips, status"
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

def perform_transaction_join():
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute("SELECT * FROM Customer_Transaction t JOIN Complete_Order_Summary s WHERE t.transaction_id = s.transaction_id ORDER BY timestamp DESC;")
            rows = cursor.fetchall()
            col_name = cursor.column_names # get column names
            df = pd.DataFrame(rows, columns=col_name)
            return df.to_dict(orient="split")
        
def get_dashboard_stats():
    customer_orders_query = """
    SELECT 
        COUNT(transaction_id) as total_tx,
        SUM(total_amount) as total_rev,
        AVG(total_amount) as avg_val,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count
    FROM Customer_Transaction;
    """
    popular_item_query = """SELECT most_popular_item, COUNT(*) AS count
        FROM Events
        WHERE most_popular_item IS NOT NULL
        GROUP BY most_popular_item
        ORDER BY count DESC
        LIMIT 1;
    """
    refills_query = """SELECT 
            AVG(io.refill) AS avg_coffee_refills
        FROM Individual_Order io
        JOIN Menu_Item mi ON mi.menu_item_id = io.menu_item_id
        WHERE mi.item_name = 'Coffee' AND io.refill = 'True';
    """
    addons_query = """
        SELECT avg(add_ons_bought) AS avg_add_ons FROM Complete_Order_Summary;"""
    times_query = """
        SELECT
            DATE_FORMAT(
                SEC_TO_TIME(AVG(CASE WHEN last_breakfast_order = TRUE THEN TIME_TO_SEC(`timestamp`) END)),
                '%h:%i %p'
            ) AS avg_last_breakfast_cutoff,
            DATE_FORMAT(
                SEC_TO_TIME(AVG(CASE WHEN fried_chicken_sold_out = TRUE THEN TIME_TO_SEC(`timestamp`) END)),
                '%h:%i %p'
            ) AS avg_chicken_soldout
        FROM Key_Order_Times;
        """
    with connect() as mycon:
        import pandas as pd
        df = pd.concat([
            pd.read_sql(customer_orders_query, mycon),
            pd.read_sql(popular_item_query, mycon),
            pd.read_sql(refills_query, mycon),
            pd.read_sql(addons_query, mycon),
            pd.read_sql(times_query, mycon),
        ], ignore_index=True)
        df = df.fillna(0)
        return df.to_dict(orient="split")



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
