from fastapi import APIRouter

# Import necessary database functions
from database import delete_from_relation, get_all_relations_from_view, insert_into_relation, update_relation


manager_router = APIRouter()

# Show all relation data
@manager_router.get("/")
async def get_all_view_data(view_name: str):
    view_rels = get_all_relations_from_view(view_name)
    return view_rels

# Create a row in a relation
@manager_router.post("/", status_code=201)
async def insert_view_data(rel_name: str, data: dict):
    insert_into_relation(rel_name, data)


# Update a record
@manager_router.put("/{tuple_key}")
async def update_view_data(rel_name: str, items_to_update: dict, update_conditions: dict):
    update_relation(rel_name, items_to_update, update_conditions)


# Delete a record
@manager_router.put("/{tuple_key}")
async def delete_view_data(rel: str, delete_conditions: dict ):
    delete_from_relation(rel, delete_conditions)