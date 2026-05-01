import mysql.connector

# Return SQL connector
def connect():
    return mysql.connector.connect(
            host="localhost",  
            user="root",
            password="PASSWORDHERE",
            database="hamburg_inn"
        )

### GETS THE LIST OF ALL RELATIONS WITHIN A CERTAIN VIEW
def get_view(view_name: str):
    # Define query
    query=f"SELECT TABLE_NAME FROM hamburg_inn.VIEW_TABLE_USAGE WHERE VIEW_NAME = {view_name};"

    # connect to database, open cursor, and execute query
    with connect() as mycon: # handle opening and closing connection
        with mycon.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall() # fetch all rows from the last executed statement
            return rows

### GETS ALL THE RELATIONS IN THE VIEW ALONGSIDE THEIR INTERNAL DATA
def get_all_relations_from_view(view_name: str):
    relations = get_view(view_name)
    results = {} # results is a dictionary

    # define the dictionary - key is relation, value is relation data
    for rel in relations:
        results[rel] = get_relation(rel)

    return results
        
### CREATE OPERATION FUNCTION
def insert_into_relation(rel: str, data: dict):

    # preprocess data
    cols = ", ".join(data.keys())
    values = ", ".join(f"{v}" for v in data.values())

    # define query
    query = f"INSERT INTO `{rel}` ({cols}) VALUES ({values})"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query)
        mycon.commit()
        
### RETRIEVE OPERATION FUNCTION
def get_relation(rel: str, select_params: str = "*"):

    # define query
    query = f"SELECT {select_params} FROM `{rel}`"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall() # fetch all rows from the last executed statement
            return rows

### UPDATE OPERATION FUNCTION
def update_relation(rel: str, updated_items: dict, update_params: dict, ):
    #  preprocess data
    set_clause = ", ".join(f"{k} = {v}" for k, v in updated_items.items())
    where_clause = ", ".join(f"{k} = {v}" for k, v in update_params.items())

    # define query
    query = f"UPDATE {rel} SET {set_clause} WHERE {where_clause}"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query)
        mycon.commit()

### DELETE OPERATION FUNCTION
def delete_from_relation(rel: str, delete_params: dict):
    # preprocess data
    where_clause = ", ".join(f"{k} = {v}" for k, v in delete_params.items())

    # define query
    query = f"DELETE FROM {rel} WHERE {where_clause}"

    # connect to database, open cursor, and execute query
    with connect() as mycon:
        with mycon.cursor() as cursor:
            cursor.execute(query)
        mycon.commit()



# TEST QUERIES
# print(get_relation("Employee"))
# insert_into_relation("Employee", {"employee_id": 8, "name": "thomas", "role": "server", "hourly_pay": 9.25, "tips_earned": 10.00, "start_date": "2026-04-30" })
# print(get_relation("Employee"))
# update_relation("Employee", {"name": "Thomas", "hourly_pay": 12.00}, {"employee_id": 8})
# print(get_relation("Employee"))
# delete_from_relation("Employee", {"employee_id": 8})
# print(get_relation("Employee"))