# Deliverable 5 — Notes & Flags for Discussion

A running list of things I noticed while writing the triggers, procedure, function, and queries. Some need fixing before submission, others we can leave but should be ready to explain during the demo. Let's talk through these before finalizing.

---

## 1. Missing `tips` column on `Customer_Transaction`

**The issue:** Our Deliverable 4 data dictionary lists `tips` as a Customer_Transaction attribute, but the actual SQL file doesn't have that column. Trigger 3 (tips rolling up to employee total) needs it.

**Proposed fix:** Add the column to the CREATE TABLE statement directly:
```sql
tips DECIMAL(10, 2) DEFAULT 0.00
```
Or use an `ALTER TABLE` after creation. Either works, but adding it to the CREATE is cleaner for the final script.

**Verdict:** Must fix. Our own documentation says it should exist.

---

## 2. Trigger 1 fires on INSERT, not UPDATE

**The issue:** Our original plan said "When Individual Order is updated, update Transaction + Complete Order Summary." But the operation that actually happens in real life is *adding* an item to an order (INSERT), not modifying an existing line item.

**Proposed fix:** I wrote it as `AFTER INSERT`. If we want UPDATE behavior too (e.g., changing a line item from a Coke to a Sprite), we'd need a parallel `AFTER UPDATE` trigger that subtracts the old values and adds the new ones.

**Verdict:** Leave as INSERT for now, it's the more common case. We can mention during demo that an UPDATE version would be a natural extension.

---

## 3. Trigger 3 (tips) fires on UPDATE only, not INSERT

**The issue:** Trigger 3 assumes transactions are created with `tips = 0` and then updated when the customer signs the receipt. If we ever insert a transaction with the tip already filled in, that initial tip won't roll up to the employee.

**Proposed fix options:**
- **Option A (do nothing):** Just be consistent in the web app — always insert with tips = 0, then UPDATE later. Easy.
- **Option B (parallel trigger):** Add an `AFTER INSERT` trigger that adds `NEW.tips` to the employee's `tips_earned` if it's nonzero. ~5 lines of SQL.

**Verdict:** Probably fine to leave as-is, but worth mentioning during the demo. If the web team is creating transactions with tips already populated, we should go with Option B.

---

## 4. Customer role has CRUD on `Individual_Order` but no access to `Customer_Transaction`

**The issue:** This is from our Deliverable 4 authorization table. It's a broken foreign key chain — you can't insert an `Individual_Order` without a parent `Customer_Transaction` already existing, and customers can't create that parent.

**Proposed fix options:**
- **Option A:** Grant customers INSERT (and maybe SELECT) on Customer_Transaction. Simple, but expands customer privileges.
- **Option B:** Document that the web app handles transaction creation under a different role (probably the employee/system role) and the customer session only sees Individual_Order operations. This is actually pretty normal for restaurant POS systems — the server opens the tab, the customer just adds items.
- **Option C:** Use a stored procedure that the customer can EXECUTE, which creates the transaction + first order atomically under elevated privileges.

**Verdict:** Need to decide as a group. My vote is Option B since it matches how real POS systems work, and we just add a sentence to the PDF explaining it. The web team should know which path we picked since it affects their auth flow.

---

## 5. Customer has DELETE on `Complete_Order_Summary`

**The issue:** Letting a customer wipe their own order summary after a transaction is unusual. Normally that'd be an employee/manager action (e.g., voiding an order).

**Proposed fix options:**
- **Option A (restrict):** Drop DELETE from customer's permissions on Complete_Order_Summary. Only INSERT/UPDATE remain.
- **Option B (keep + justify):** Argue that customers can cancel an order before checkout, which requires DELETE access. Document this as the intent.

**Verdict:** Leaning toward Option A — it's cleaner and matches typical restaurant logic. But if the web team has already designed a "cancel my order" flow that uses DELETE, we keep it and explain.

---

## 6. The two views I wrote are analytical, not role-based

**Context:** The deliverable explicitly says views "do not need to correspond to the actual user types in your project." So I made `v_transaction_event_context` (used in Query 1) and `v_fried_chicken_sellout` (used in Query 4). These showcase view creation better than role-based filters would, plus they actually get used by our queries.

**Verdict:** No action needed. Just flagging so nobody's confused why our views aren't named "customer_view" or "manager_view." Role-based access is being handled by GRANT statements + the web app's auth logic, which is the right place for it.

---

## 7. Trigger 2 assumes a transaction falls within at most one event

**The issue:** The trigger that propagates transaction totals to event `money_made` uses `WHERE NEW.timestamp BETWEEN start_time AND end_time`. If two events ever overlap in time, the same money would get added to both events' totals.

**Proposed fix:** Not really an issue given Hamburg only runs one event per night (Trivia Mondays, Bingo Wednesdays). But if we wanted to be defensive, we could add `LIMIT 1` or pick the event with the earliest start time.

**Verdict:** Leave as-is. Easy to explain during the demo if asked.

---

## Summary — what actually needs to change before submission

1. **Add `tips` column to Customer_Transaction** (must fix)
2. **Decide on customer's Customer_Transaction access** — pick Option A, B, or C from item 4
3. **Decide on customer's DELETE on Complete_Order_Summary** — keep or drop

Everything else is fine to leave but worth knowing how to explain during the demo presentation.
