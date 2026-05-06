from fastapi import APIRouter

# Import necessary database functions
from database import delete_from_relation, get_all_relations_for_role, get_privileges, insert_into_relation, update_relation


crud_router = APIRouter()

# Show all relation data
@crud_router.get("/{role_name}")
async def get_all_view_data(role_name: str):
    role_rels = get_all_relations_for_role(role_name)
    return role_rels

@crud_router.get("/{role_name}/privileges")
async def get_privilege_info(role_name: str):
    privileges = get_privileges(role_name)
    return privileges

# Create a row in a relation
@crud_router.post("/{rel_name}", status_code=201)
async def insert_view_data(rel_name: str, data: dict):
    insert_into_relation(rel_name, data)
    return {"message": f"Successfully inserted into {rel_name}"}


# Update a record
# FIX: path was /{tuple_key} but function uses rel_name — changed to match
@crud_router.put("/{rel_name}")
async def update_view_data(rel_name: str, items_to_update: dict, update_conditions: dict):
    update_relation(rel_name, items_to_update, update_conditions)


# Delete a record
# FIX: path was /{tuple_key} and param was rel — changed both to rel_name for consistency
@crud_router.delete("/{rel_name}")
async def delete_view_data(rel_name: str, delete_conditions: dict):
    delete_from_relation(rel_name, delete_conditions)