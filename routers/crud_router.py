from fastapi import APIRouter

# Import necessary database functions
from database import delete_from_relation, get_all_relations_for_role, insert_into_relation, update_relation


crud_router = APIRouter()

# Show all relation data
@crud_router.get("/")
async def get_all_view_data(role_name: str):
    role_rels = get_all_relations_for_role(role_name)
    return role_rels

# Create a row in a relation
@crud_router.post("/", status_code=201)
async def insert_view_data(rel_name: str, data: dict):
    insert_into_relation(rel_name, data)


# Update a record
@crud_router.put("/{tuple_key}")
async def update_view_data(rel_name: str, items_to_update: dict, update_conditions: dict):
    update_relation(rel_name, items_to_update, update_conditions)


# Delete a record
@crud_router.put("/{tuple_key}")
async def delete_view_data(rel: str, delete_conditions: dict ):
    delete_from_relation(rel, delete_conditions)