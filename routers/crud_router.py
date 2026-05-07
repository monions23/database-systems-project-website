from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from datetime import datetime
from database import connect, get_dashboard_stats, delete_from_relation, get_all_relations_for_role, get_privileges, insert_into_relation, perform_transaction_join, update_relation

crud_router = APIRouter()

class OrderItem(BaseModel):
    id: int
    name: str
    price: float

class OrderRequest(BaseModel):
    items: List[OrderItem]
    employee_id: int

# ── Specific routes FIRST ─────────────────────────────────────────────────────

@crud_router.post("/create_order")
async def create_order(order: OrderRequest):
    conn = None
    cursor = None
    try:
        conn = connect()
        cursor = conn.cursor()

        total = sum(item.price for item in order.items)
        now = datetime.now().replace(microsecond=0)

        cursor.execute("""
            INSERT INTO Key_Order_Times (timestamp, last_breakfast_order, fried_chicken_sold_out)
            VALUES (%s, FALSE, FALSE)
            ON DUPLICATE KEY UPDATE
                last_breakfast_order = last_breakfast_order,
                fried_chicken_sold_out = fried_chicken_sold_out
        """, (now,))

        cursor.execute("""
            INSERT INTO Customer_Transaction 
            (timestamp, total_amount, payment_method, employee_id, tips, status)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (now, 0, "card", order.employee_id, 0, "pending"))

        transaction_id = cursor.lastrowid
        if not transaction_id:
            cursor.execute("SELECT LAST_INSERT_ID()")
            transaction_id = cursor.fetchone()[0]

        # ✅ Insert summary row BEFORE individual orders so trigger can update it
        cursor.execute("""
            INSERT INTO Complete_Order_Summary 
            (transaction_id, appetizers_bought, entrees_bought, sides_bought,
             drinks_bought, milkshakes_bought, add_ons_bought, refills)
            VALUES (%s, 0, 0, 0, 0, 0, 0, 0)
        """, (transaction_id,))

        # Individual orders — trigger will update total_amount and summary counts
        for item in order.items:
            cursor.execute("""
                INSERT INTO Individual_Order 
                (transaction_id, menu_item_id, add_ons, add_ons_price, refill)
                VALUES (%s, %s, 0, 0, 0)
            """, (transaction_id, item.id))

        conn.commit()
        return {"message": "Order created successfully", "transaction_id": transaction_id, "total": total}

    except Exception as e:
        if conn:
            conn.rollback()
        print("FULL ERROR:", repr(e))
        return {"error": str(e)}
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@crud_router.put("/complete_transaction/{transaction_id}")
async def complete_transaction(transaction_id: int):
    conn = None
    cursor = None
    try:
        conn = connect()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE Customer_Transaction
            SET status = 'completed'
            WHERE transaction_id = %s
        """, (transaction_id,))
        conn.commit()
        return {"message": "Transaction marked completed"}
    except Exception as e:
        if conn:
            conn.rollback()
        return {"error": str(e)}
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@crud_router.get("/transactions-summary")
async def transaction_summary():
    try:
        return perform_transaction_join()
    except Exception as e:
        return {"error": str(e)}

@crud_router.get("/dashboard-stats")
async def dashboard_stats():
    return get_dashboard_stats()

# ── Generic routes LAST ───────────────────────────────────────────────────────

@crud_router.get("/{role_name}/privileges")
async def get_privilege_info(role_name: str):
    return get_privileges(role_name)

@crud_router.get("/{role_name}")
async def get_all_view_data(role_name: str):
    return get_all_relations_for_role(role_name)

@crud_router.post("/{rel_name}", status_code=201)
async def insert_view_data(rel_name: str, data: dict):
    new_id = insert_into_relation(rel_name, data)
    return {"transaction_id": new_id}

@crud_router.put("/{tuple_key}")
async def update_view_data(rel_name: str, items_to_update: dict, update_conditions: dict):
    update_relation(rel_name, items_to_update, update_conditions)

@crud_router.delete("/{tuple_key}")
async def delete_view_data(rel: str, delete_conditions: dict):
    delete_from_relation(rel, delete_conditions)