CREATE SCHEMA IF NOT EXISTS hamburg_inn;
USE hamburg_inn;

-- Employee
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(50),
    hourly_pay DECIMAL(10, 2),
    tips_earned DECIMAL (10, 2),
    start_date DATE
);
 
-- Events
CREATE TABLE Events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(50),
    start_time DATETIME,
    end_time DATETIME,
    day_of_week VARCHAR(15),
    money_made DECIMAL(10, 2),
    most_popular_item VARCHAR(50)
);
 
-- Menu Item
CREATE TABLE Menu_Item (
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    price DECIMAL(10, 2),
    time_available TIME,
    is_breakfast BOOLEAN
);

-- Menu Item Subclasses
CREATE TABLE Entree(
    menu_item_id INT PRIMARY KEY,
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);
CREATE TABLE Side(
    menu_item_id INT PRIMARY KEY,
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);
CREATE TABLE Drink(
    menu_item_id INT PRIMARY KEY,
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);
CREATE TABLE Appetizer(
    menu_item_id INT PRIMARY KEY,
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);
CREATE TABLE Milkshake(
    menu_item_id INT PRIMARY KEY,
    Flavor VARCHAR(50),
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);


-- Key Order Times
CREATE TABLE Key_Order_Times (
    timestamp DATETIME PRIMARY KEY,
    last_breakfast_order BOOLEAN,
    fried_chicken_sold_out BOOLEAN
);
 
-- Customer Transaction
CREATE TABLE Customer_Transaction (
    transaction_id INT PRIMARY KEY,
    timestamp DATETIME,
    total_amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id) ON DELETE SET NULL,
    FOREIGN KEY (timestamp) REFERENCES Key_Order_Times(timestamp)
    -- Removed ItemOrderedID here; that relationship is handled
    -- by IndividualOrder.TransactionID pointing back to this table.
);
 
-- Individual Order
CREATE TABLE Individual_Order (
    item_ordered_id INT PRIMARY KEY,
    transaction_id INT,
    menu_item_id INT,
    add_ons INTEGER,
    add_ons_price DECIMAL(10, 2),
    refill BOOLEAN,
    FOREIGN KEY (transaction_id) REFERENCES Customer_Transaction(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES Menu_Item(menu_item_id)
);
 
-- Complete Order Summary
CREATE TABLE Complete_Order_Summary (
    transaction_id INT PRIMARY KEY,
    appetizers_bought INT,
    entrees_bought INT,
    sides_bought INT,
    drinks_bought INT,
    milkshakes_bought INT,
    add_ons_bought INT,
    refills INT,
    FOREIGN KEY (transaction_id) REFERENCES Customer_Transaction(transaction_id) ON DELETE CASCADE
);

-- Employee
INSERT INTO Employee VALUES (1, 'Sarah Bloom',  'Server',  14.50, 160000.22, '2022-03-15');
INSERT INTO Employee VALUES (2, 'Jake Mercer',  'Server',  14.50, 200000.55, '2021-08-01');
INSERT INTO Employee VALUES (3, 'Carol Tien',   'Manager', 22.00, 00.00, '2019-06-10');
INSERT INTO Employee VALUES (4, 'Luis Ortega',  'Cook',    16.75, 00.00, '2023-01-20');
INSERT INTO Employee VALUES (5, 'Maya Johnson', 'Server',  14.50, 120000.00, '2023-09-05');
 
-- Events
INSERT INTO Events VALUES (1, 'Trivia Night', '2024-01-08 18:00:00', '2024-01-08 21:00:00', 'Monday',    842.50, 'Pie Shake');
INSERT INTO Events VALUES (2, 'Bingo Night',  '2024-01-10 18:00:00', '2024-01-10 20:30:00', 'Wednesday', 610.00, 'Cheeseburger');
INSERT INTO Events VALUES (3, 'Trivia Night', '2024-01-15 18:00:00', '2024-01-15 21:00:00', 'Monday',    795.00, 'Pancakes');
INSERT INTO Events VALUES (4, 'Bingo Night',  '2024-01-17 18:00:00', '2024-01-17 20:30:00', 'Wednesday', 530.75, 'Fried Chicken');
INSERT INTO Events VALUES (5, 'Trivia Night', '2024-01-22 18:00:00', '2024-01-22 21:00:00', 'Monday',    901.25, 'Cheeseburger');

-- MenuItem
-- Entrees
INSERT INTO Menu_Item VALUES (1,  'Pancakes',           8.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (2,  'Scrambled Eggs',     7.49,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (3,  'Cheeseburger',      10.99,  '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (4,  'Fried Chicken',     11.99,  '16:00:00', FALSE);
INSERT INTO Menu_Item VALUES (5,  'French Toast',       8.49,  '09:00:00', TRUE);
-- Drinks
INSERT INTO Menu_Item VALUES (6,  'Coffee',             2.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (7,  'Orange Juice',       3.49,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (8,  'Lemonade',           2.99,  '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (9,  'Hot Tea',            2.49,  '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (10, 'Milk',               2.49,  '09:00:00', FALSE);
 
-- Milkshakes
INSERT INTO Menu_Item VALUES (11, 'Strawberry Pie Shake',  6.49, '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (12, 'Blueberry Pie Shake',   6.49, '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (13, 'Apple Pie Shake',       6.49, '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (14, 'Cherry Pie Shake',      6.49, '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (15, 'Peach Pie Shake',       6.49, '09:00:00', FALSE);
 
-- Sides
INSERT INTO Menu_Item VALUES (16, 'Hash Browns',        3.49,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (17, 'Toast',              1.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (18, 'Onion Rings',        4.49,  '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (19, 'Side Salad',         3.99,  '09:00:00', FALSE);
INSERT INTO Menu_Item VALUES (20, 'Ranch Add-On',       0.50,  '09:00:00', FALSE);
 
-- Appetizers
INSERT INTO Menu_Item VALUES (21, 'Fruit Cup',          2.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (22, 'Yogurt Parfait',     3.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (23, 'Muffin',             2.49,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (24, 'Biscuit',            1.99,  '09:00:00', TRUE);
INSERT INTO Menu_Item VALUES (25, 'Cinnamon Roll',      3.49,  '09:00:00', TRUE);
 
-- Entree (subtype)
INSERT INTO Entree VALUES (1);  -- Pancakes
INSERT INTO Entree VALUES (2);  -- Scrambled Eggs
INSERT INTO Entree VALUES (3);  -- Cheeseburger
INSERT INTO Entree VALUES (4);  -- Fried Chicken
INSERT INTO Entree VALUES (5);  -- French Toast
 
-- Drink (subtype)
INSERT INTO Drink VALUES (6);   -- Coffee
INSERT INTO Drink VALUES (7);   -- Orange Juice
INSERT INTO Drink VALUES (8);   -- Lemonade
INSERT INTO Drink VALUES (9);   -- Hot Tea
INSERT INTO Drink VALUES (10);  -- Milk
 
-- Milkshake (subtype)
INSERT INTO Milkshake VALUES (11, 'Strawberry');
INSERT INTO Milkshake VALUES (12, 'Blueberry');
INSERT INTO Milkshake VALUES (13, 'Apple');
INSERT INTO Milkshake VALUES (14, 'Cherry');
INSERT INTO Milkshake VALUES (15, 'Peach');
 
-- Side (subtype)
INSERT INTO Side VALUES (16);  -- Hash Browns
INSERT INTO Side VALUES (17);  -- Toast
INSERT INTO Side VALUES (18);  -- Onion Rings
INSERT INTO Side VALUES (19);  -- Side Salad
INSERT INTO Side VALUES (20);  -- Ranch Add-On
 
-- Appetizer (subtype)
INSERT INTO Appetizer VALUES (21);  -- Fruit Cup
INSERT INTO Appetizer VALUES (22);  -- Yogurt Parfait
INSERT INTO Appetizer VALUES (23);  -- Muffin
INSERT INTO Appetizer VALUES (24);  -- Biscuit
INSERT INTO Appetizer VALUES (25);  -- Cinnamon Roll
 
-- KeyOrderTimes
INSERT INTO Key_Order_Times VALUES ('2024-01-08 12:15:00', TRUE, FALSE);
INSERT INTO Key_Order_Times VALUES ('2024-01-08 19:30:00', FALSE, TRUE);
INSERT INTO Key_Order_Times VALUES ('2024-01-09 09:45:00', FALSE, TRUE);
INSERT INTO Key_Order_Times VALUES ('2024-01-10 18:20:00', TRUE, FALSE);
INSERT INTO Key_Order_Times VALUES ('2024-01-11 11:00:00', TRUE, FALSE);
 
-- CustomerTransaction
INSERT INTO Customer_Transaction VALUES (1, '2024-01-08 12:15:00', 22.47, 'card',   1);
INSERT INTO Customer_Transaction VALUES (2, '2024-01-08 19:30:00', 35.94, 'cash',   2);
INSERT INTO Customer_Transaction VALUES (3, '2024-01-09 09:45:00', 15.48, 'card',   1);
INSERT INTO Customer_Transaction VALUES (4, '2024-01-10 18:20:00', 28.96, 'card',   3);
INSERT INTO Customer_Transaction VALUES (5, '2024-01-11 11:00:00', 10.98, 'cash',   5);
 
-- IndividualOrder
INSERT INTO Individual_Order VALUES (1, 1, 1, 0, 0.00, FALSE);
INSERT INTO Individual_Order VALUES (2, 1, 6, 0, 0.00, TRUE);
INSERT INTO Individual_Order VALUES (3, 2, 3, 1, 0.50, FALSE);
INSERT INTO Individual_Order VALUES (4, 3, 2, 0, 0.00, FALSE);
INSERT INTO Individual_Order VALUES (5, 5, 11, 0, 0.00, FALSE);
 
-- CompleteOrderSummary
-- (transaction_id, entrees_bought, drinks_bought, add_ons_bought, refills)
INSERT INTO Complete_Order_Summary VALUES (1, 1, 2, 1, 2, 1, 2, 0);
INSERT INTO Complete_Order_Summary VALUES (2, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO Complete_Order_Summary VALUES (3, 1, 3, 3, 0, 0, 0, 1);
INSERT INTO Complete_Order_Summary VALUES (4, 0, 1, 1, 1, 0, 0, 1);
INSERT INTO Complete_Order_Summary VALUES (5, 0, 1, 1, 1, 0, 0, 0);

SELECT * FROM Appetizer;
SELECT * FROM Complete_Order_Summary;
SELECT * FROM Customer_Transaction;
SELECT * FROM Drink;
SELECT * FROM Employee;
SELECT * FROM Entree;
SELECT * FROM Events;
SELECT * FROM Individual_Order;
SELECT * FROM Key_Order_Times;
SELECT * FROM Menu_Item;
SELECT * FROM Milkshake;

-- =======================================================================================================================
-- ===== BEGIN DELIVERABLE 5 CONTENT =====================================================================================
-- =======================================================================================================================

-- Necessary addition to calculate tips
ALTER TABLE Customer_Transaction
ADD COLUMN tips DECIMAL(10, 2) DEFAULT 0.00;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THE 3 TRIGGERS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- TRIGGER 1: Propagate Individual_Order inserts to parent tables
-- When a new row is added to Individual_Order, this trigger automatically updates the running total on Customer_Transaction 
-- and bumps the appropriate counter in Complete_Order_Summary. So if a server adds a Cheeseburger to transaction 7, the 
-- transaction's total_amount jumps by $10.99 and entrees_bought goes up by 1, with no extra application logic needed.
DELIMITER $$

CREATE TRIGGER trg_individual_order_after_insert
AFTER INSERT ON Individual_Order
FOR EACH ROW
BEGIN
    DECLARE item_price DECIMAL(10, 2);

    -- Look up the price of the menu item being added
    SELECT price INTO item_price
    FROM Menu_Item
    WHERE menu_item_id = NEW.menu_item_id;

    -- Add item price plus any add-on price to the transaction total
    UPDATE Customer_Transaction
    SET total_amount = total_amount + item_price + IFNULL(NEW.add_ons_price, 0)
    WHERE transaction_id = NEW.transaction_id;

    -- Bump the right counter in Complete_Order_Summary based on subtype
    IF EXISTS (SELECT 1 FROM Entree WHERE menu_item_id = NEW.menu_item_id) THEN
        UPDATE Complete_Order_Summary
        SET entrees_bought = entrees_bought + 1
        WHERE transaction_id = NEW.transaction_id;
    ELSEIF EXISTS (SELECT 1 FROM Appetizer WHERE menu_item_id = NEW.menu_item_id) THEN
        UPDATE Complete_Order_Summary
        SET appetizers_bought = appetizers_bought + 1
        WHERE transaction_id = NEW.transaction_id;
    ELSEIF EXISTS (SELECT 1 FROM Side WHERE menu_item_id = NEW.menu_item_id) THEN
        UPDATE Complete_Order_Summary
        SET sides_bought = sides_bought + 1
        WHERE transaction_id = NEW.transaction_id;
    ELSEIF EXISTS (SELECT 1 FROM Drink WHERE menu_item_id = NEW.menu_item_id) THEN
        UPDATE Complete_Order_Summary
        SET drinks_bought = drinks_bought + 1
        WHERE transaction_id = NEW.transaction_id;
    ELSEIF EXISTS (SELECT 1 FROM Milkshake WHERE menu_item_id = NEW.menu_item_id) THEN
        UPDATE Complete_Order_Summary
        SET milkshakes_bought = milkshakes_bought + 1
        WHERE transaction_id = NEW.transaction_id;
    END IF;

    -- Track add-ons and refills
    IF NEW.add_ons > 0 THEN
        UPDATE Complete_Order_Summary
        SET add_ons_bought = add_ons_bought + NEW.add_ons
        WHERE transaction_id = NEW.transaction_id;
    END IF;

    IF NEW.refill = TRUE THEN
        UPDATE Complete_Order_Summary
        SET refills = refills + 1
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END$$

DELIMITER ;
-- NOTES ON TRIGGER 1:
-- The EXISTS checks against the subtype tables (Entree, Appetizer, etc.) are how it figures out which counter to 
-- increment, since Menu_Item itself doesn't store the category. This is a good one to demo on the website: insert 
-- an Individual_Order row, then re-query the parent transaction and order summary to show the totals updated automatically.

-- -------------------------------------------------------------------------------------------------

-- TRIGGER 2: Propagate transaction totals to event money_made
-- Description: When a transaction's total_amount changes, this checks whether the transaction's timestamp falls inside 
-- any event's window and adds the difference to that event's money_made. Combined with Trigger 1, this means every item 
-- added to an event-time transaction automatically rolls up to the event's revenue.
DELIMITER $$

CREATE TRIGGER trg_transaction_after_update_total
AFTER UPDATE ON Customer_Transaction
FOR EACH ROW
BEGIN
    -- Only act when total_amount actually changed, otherwise unrelated updates
    -- (like changing payment_method) would corrupt event totals
    IF NEW.total_amount <> OLD.total_amount THEN
        UPDATE Events
        SET money_made = money_made + (NEW.total_amount - OLD.total_amount)
        WHERE NEW.timestamp BETWEEN start_time AND end_time;
    END IF;
END$$

DELIMITER ;
-- NOTES ON TRIGGER 2:
-- The IF NEW.total_amount <> OLD.total_amount guard is important. Without it, every UPDATE on the row 
-- (even one that only changes the payment method) would re-trigger the math, and since the diff would be 
-- 0 it'd technically still be correct, but it's cleaner to skip the update entirely. The BETWEEN clause 
-- handles the event lookup. Note: This assumes a transaction can only fall inside one event at 
-- a time, which seems reasonable given Hamburg only runs one event per night.

-- -------------------------------------------------------------------------------------------------

-- TRIGGER 3: Propagate tip changes to employee's total tips
DELIMITER $$

CREATE TRIGGER trg_transaction_after_update_tips
AFTER UPDATE ON Customer_Transaction
FOR EACH ROW
BEGIN
    -- Add only the change, handling NULLs so first-time tip entry works too
    IF IFNULL(NEW.tips, 0) <> IFNULL(OLD.tips, 0) AND NEW.employee_id IS NOT NULL THEN
        UPDATE Employee
        SET tips_earned = tips_earned + (IFNULL(NEW.tips, 0) - IFNULL(OLD.tips, 0))
        WHERE employee_id = NEW.employee_id;
    END IF;
END$$

DELIMITER ;

-- NOTES ON TRIGGER 3:
-- One thing to call out: this fires on UPDATE only, not INSERT. The assumption is that transactions 
-- are created with tips = 0 (the default I added) and then updated when the customer signs the receipt. 
-- If you create transactions with the tip already populated, you'd want a parallel AFTER INSERT trigger, 
-- or you'd need to handle it on the application side. Probably worth mentioning during the demo.



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THE FUNCTION +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Function: Get the most popular item for an event
-- This takes an event_id and returns the item name (VARCHAR) that was ordered most often during that event's 
-- time window. Useful for end-of-event reporting, and the return value can be slotted right into an UPDATE Events 
-- SET most_popular_item = ... if you want to populate that column programmatically.
DELIMITER $$

CREATE FUNCTION get_event_most_popular_item(p_event_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE popular_item_name VARCHAR(50);

    SELECT mi.item_name INTO popular_item_name
    FROM Events e
    JOIN Customer_Transaction ct
      ON ct.timestamp BETWEEN e.start_time AND e.end_time
    JOIN Individual_Order io
      ON ct.transaction_id = io.transaction_id
    JOIN Menu_Item mi
      ON io.menu_item_id = mi.menu_item_id
    WHERE e.event_id = p_event_id
    GROUP BY mi.menu_item_id, mi.item_name
    ORDER BY COUNT(*) DESC, mi.item_name ASC
    LIMIT 1;

    RETURN popular_item_name;
END$$

DELIMITER ;

-- NOTES ON FUNCTION: 
-- The ORDER BY COUNT(*) DESC, mi.item_name ASC handles ties deterministically, which matters because MySQL 
-- functions need to be consistent (hence the DETERMINISTIC keyword). If two items are tied for most ordered, 
-- you'll consistently get the alphabetically first one. The READS SQL DATA characteristic just tells MySQL 
-- the function reads but doesn't modify data.

-- To call it: SELECT get_event_most_popular_item(1); 
-- or use it inline like UPDATE Events SET most_popular_item = get_event_most_popular_item(event_id) WHERE event_id = 1;



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THE PROCEDURE +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Procedure: Record daily key order times
-- This procedure takes a date as input, scans that day's transactions, and records two key timestamps in 
-- Key_Order_Times: the last breakfast item ordered and the last fried chicken ordered (which Hamburg treats 
-- as the sold-out time, since they keep selling chicken until it runs out). The intent is to run this at end 
-- of day to populate the daily summary.
DELIMITER $$

CREATE PROCEDURE record_daily_key_order_times(IN target_date DATE)
BEGIN
    DECLARE last_breakfast_ts DATETIME;
    DECLARE last_chicken_ts DATETIME;

    -- Find the last breakfast item ordered on the given day
    SELECT MAX(ct.timestamp) INTO last_breakfast_ts
    FROM Customer_Transaction ct
    JOIN Individual_Order io ON ct.transaction_id = io.transaction_id
    JOIN Menu_Item mi ON io.menu_item_id = mi.menu_item_id
    WHERE mi.is_breakfast = TRUE
      AND DATE(ct.timestamp) = target_date;

    -- Find the last Fried Chicken ordered on the given day (treated as sold-out time)
    SELECT MAX(ct.timestamp) INTO last_chicken_ts
    FROM Customer_Transaction ct
    JOIN Individual_Order io ON ct.transaction_id = io.transaction_id
    JOIN Menu_Item mi ON io.menu_item_id = mi.menu_item_id
    WHERE mi.item_name = 'Fried Chicken'
      AND DATE(ct.timestamp) = target_date;

    -- Record the breakfast cutoff (or update flag if timestamp already exists)
    IF last_breakfast_ts IS NOT NULL THEN
        INSERT INTO Key_Order_Times (timestamp, last_breakfast_order, fried_chicken_sold_out)
        VALUES (last_breakfast_ts, TRUE, FALSE)
        ON DUPLICATE KEY UPDATE last_breakfast_order = TRUE;
    END IF;

    -- Record the fried chicken sold-out time (or update flag if timestamp exists)
    IF last_chicken_ts IS NOT NULL THEN
        INSERT INTO Key_Order_Times (timestamp, last_breakfast_order, fried_chicken_sold_out)
        VALUES (last_chicken_ts, FALSE, TRUE)
        ON DUPLICATE KEY UPDATE fried_chicken_sold_out = TRUE;
    END IF;
END$$

DELIMITER ;

-- NOTES ON PRODECURE:
-- The ON DUPLICATE KEY UPDATE matters because of your FK setup: every Customer_Transaction.timestamp already 
-- has to exist in Key_Order_Times, so when the procedure tries to insert that exact timestamp again it'd hit 
-- a primary key collision. Instead it just flips the relevant boolean to TRUE.

-- To call it: CALL record_daily_key_order_times('2024-01-08');


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THE 5 QUERIES +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- FIRST: create 2 required views

-- View 1: Tags each transaction with its event context.
-- Used by Query 1 to compare event-time vs non-event-time ordering.
CREATE VIEW v_transaction_event_context AS
SELECT ct.transaction_id,
       ct.timestamp,
       ct.total_amount,
       ct.employee_id,
       e.event_id,
       e.event_name,
       CASE WHEN e.event_id IS NOT NULL THEN 'Event' ELSE 'Non-Event' END AS context
FROM Customer_Transaction ct
LEFT JOIN Events e
       ON ct.timestamp BETWEEN e.start_time AND e.end_time;

-- View 2: Calculates how long it took for fried chicken to sell out each day,
-- starting from 4 pm (when Hamburg begins serving it).
-- Used by Query 4.
CREATE VIEW v_fried_chicken_sellout AS
SELECT timestamp AS sellout_time,
       DATE(timestamp) AS sellout_date,
       DAYNAME(timestamp) AS day_name,
       CASE WHEN DAYOFWEEK(timestamp) IN (1, 7) THEN 'Weekend' ELSE 'Weeknight' END AS day_type,
       TIMEDIFF(timestamp, CONCAT(DATE(timestamp), ' 16:00:00')) AS time_to_sellout
FROM Key_Order_Times
WHERE fried_chicken_sold_out = TRUE;


-- Query 1: Top 3 most-ordered items during trivia nights vs. non-event nights
(
    SELECT 'Trivia Night' AS context,
           mi.item_name,
           COUNT(*) AS times_ordered
    FROM Individual_Order io
    JOIN v_transaction_event_context tec
      ON io.transaction_id = tec.transaction_id
    JOIN Menu_Item mi
      ON io.menu_item_id = mi.menu_item_id
    WHERE tec.event_name = 'Trivia Night'
    GROUP BY mi.menu_item_id, mi.item_name
    ORDER BY times_ordered DESC
    LIMIT 3
)
UNION ALL
(
    SELECT 'Non-Event' AS context,
           mi.item_name,
           COUNT(*) AS times_ordered
    FROM Individual_Order io
    JOIN v_transaction_event_context tec
      ON io.transaction_id = tec.transaction_id
    JOIN Menu_Item mi
      ON io.menu_item_id = mi.menu_item_id
    WHERE tec.context = 'Non-Event'
    GROUP BY mi.menu_item_id, mi.item_name
    ORDER BY times_ordered DESC
    LIMIT 3
);

-- Query 2: Average time of last breakfast order on weekdays
SELECT SEC_TO_TIME(AVG(TIME_TO_SEC(TIME(last_breakfast_per_day)))) AS avg_last_breakfast_time
FROM (
    SELECT DATE(ct.timestamp) AS order_date,
           MAX(ct.timestamp) AS last_breakfast_per_day
    FROM Customer_Transaction ct
    JOIN Individual_Order io
      ON ct.transaction_id = io.transaction_id
    JOIN Menu_Item mi
      ON io.menu_item_id = mi.menu_item_id
    WHERE mi.is_breakfast = TRUE
      AND DAYOFWEEK(ct.timestamp) BETWEEN 2 AND 6
    GROUP BY DATE(ct.timestamp)
) AS daily_last;

-- Query 3: Average coffee refills per customer visit
SELECT AVG(coffee_refills_per_visit) AS avg_coffee_refills_per_visit
FROM (
    SELECT ct.transaction_id,
           SUM(CASE WHEN io.refill = TRUE THEN 1 ELSE 0 END) AS coffee_refills_per_visit
    FROM Customer_Transaction ct
    JOIN Individual_Order io
      ON ct.transaction_id = io.transaction_id
    JOIN Menu_Item mi
      ON io.menu_item_id = mi.menu_item_id
    WHERE mi.item_name = 'Coffee'
    GROUP BY ct.transaction_id
) AS coffee_visits;


-- Query 4: Fried chicken sellout speed on weeknights vs. weekends
SELECT day_type,
       SEC_TO_TIME(AVG(TIME_TO_SEC(time_to_sellout))) AS avg_time_to_sellout,
       COUNT(*) AS num_days_observed
FROM v_fried_chicken_sellout
GROUP BY day_type;


-- Query 5: Most frequently ordered pie shake flavor
SELECT m.Flavor,
       COUNT(*) AS times_ordered
FROM Individual_Order io
JOIN Milkshake m
  ON io.menu_item_id = m.menu_item_id
GROUP BY m.Flavor
ORDER BY times_ordered DESC;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CREATING VIEWS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Create the three roles
CREATE ROLE IF NOT EXISTS 'manager_role';
CREATE ROLE IF NOT EXISTS 'employee_role';
CREATE ROLE IF NOT EXISTS 'customer_role';

-- Manager: full access to everything
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Employee               TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Customer_Transaction   TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Events                 TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Menu_Item              TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Entree                 TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Side                   TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Drink                  TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Appetizer              TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Milkshake              TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Complete_Order_Summary TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Individual_Order       TO 'manager_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Key_Order_Times        TO 'manager_role';
GRANT EXECUTE ON PROCEDURE hamburg_inn.record_daily_key_order_times       TO 'manager_role';
GRANT EXECUTE ON FUNCTION  hamburg_inn.get_event_most_popular_item        TO 'manager_role';

-- Employee: full CRUD on transaction tables, read-only on reference data
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Customer_Transaction   TO 'employee_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Complete_Order_Summary TO 'employee_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Individual_Order       TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Menu_Item              TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Entree                 TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Side                   TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Drink                  TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Appetizer              TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Milkshake              TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Events                 TO 'employee_role';
GRANT SELECT                          ON hamburg_inn.Key_Order_Times        TO 'employee_role';

-- Customer: can place orders, view menu and events
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Individual_Order       TO 'customer_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON hamburg_inn.Complete_Order_Summary TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Menu_Item              TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Entree                 TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Side                   TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Drink                  TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Appetizer              TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Milkshake              TO 'customer_role';
GRANT SELECT                          ON hamburg_inn.Events                 TO 'customer_role';
