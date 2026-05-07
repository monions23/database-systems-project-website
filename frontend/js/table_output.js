const API = "http://127.0.0.1:8000/crud";
const modalContentDiv = document.getElementById("new-tuple");
let user_role = "";
let cachedData = null;
let cachedPrivileges = null;

// ─── Entry Point ────────────────────────────────────────────────────────────

async function printRelationsForRole(role_name) {
  user_role = role_name;
  cachedData = await getRelationsForRole(role_name);
  cachedPrivileges = await getPrivileges(role_name);

  if (role_name === "customer_role") {
    await renderCustomerPage();
  } else if (role_name === "employee_role") {
    await renderEmployeePage();
  } else if (role_name === "manager_role") {
    await renderManagerPage();
  }
}

// ─── Role-Specific Page Renderers ────────────────────────────────────────────
async function renderCustomerPage() {
  const tableDiv = document.getElementById("tables");
  tableDiv.innerHTML = "";
  const menuData = cachedData["Menu_Item"];
  const subtypes = ["Entree", "Appetizer", "Side", "Drink", "Milkshake"];
  // Build type lookup
  const typeMap = {};
  for (const subtype of subtypes) {
    if (cachedData[subtype]) {
      const ids = cachedData[subtype]["data"].map((row) => row[0]);
      ids.forEach((id) => {
        typeMap[id] = subtype;
      });
    }
  }
  // Build grouped structure
  const grouped = {
    Breakfast: [],
    Entree: [],
    Side: [],
    Appetizer: [],
    Drink: [],
    Milkshake: [],
  };
  menuData["data"].forEach((row) => {
    const id = row[0];
    const name = row[1];
    const price = row[2];
    const isBreakfast = row[4];
    const type = typeMap[id] || "Other";
    const item = { name, price };
    if (isBreakfast && type != "Drink") {
      grouped["Breakfast"].push(item);
    } else if (grouped[type]) {
      grouped[type].push(item);
    }
  });
  // Render 2-page menu layout
  tableDiv.innerHTML = `
    <div class="menu-container">
      <div class="menu-page">
        ${renderMenuSection("Breakfast", grouped.Breakfast)}
        ${renderMenuSection("Entrees", grouped.Entree)}
        ${renderMenuSection("Sides", grouped.Side)}
        ${renderMenuSection("Appetizers", grouped.Appetizer)}
      </div>
      <div class="menu-page">
        ${renderMenuSection("Drinks", grouped.Drink)}
        ${renderMenuSection("Milkshakes", grouped.Milkshake)}
      </div>
    </div>
  `;
}

async function renderEmployeePage() {
  const tableDiv = document.getElementById("tables");
  tableDiv.innerHTML = "";

  const menuData = cachedData["Menu_Item"];

  const items = menuData["data"].map((row) => ({
    id: row[0],
    name: row[1],
    price: parseFloat(row[2]),
  }));

  window.currentOrder = [];

  tableDiv.innerHTML = `
    <div class="pos-container">

      <!-- MENU -->
      <div class="pos-menu">
        <h2>Menu</h2>
        ${items
          .map(
            (item) => `
          <div class="pos-item">
            <span>${item.name}</span>
            <button onclick="addToOrder(${item.id}, '${item.name}', ${item.price})">
              Add $${item.price.toFixed(2)}
            </button>
          </div>
        `,
          )
          .join("")}
      </div>

      <!-- ORDER -->
      <div class="pos-order">
        <h2>Current Order</h2>
        <div id="order-items"></div>

        <hr />

        <h3 id="order-total">Total: $0.00</h3>

        <button onclick="finalizeOrder()" class="btn btn-success">
          Complete Order
        </button>
      </div>

    </div>
  `;
  tableDiv.innerHTML += `<h2>Transactions</h2>`;
  tableDiv.innerHTML += await buildRelationSection(
    "Customer_Transaction",
    true,
    false,
  );
}

async function renderManagerPage() {
  const tableDiv = document.getElementById("tables");
  tableDiv.innerHTML = "";

  // Section 1: Joined Transaction + Order Summary
  tableDiv.innerHTML += `<h3>Transactions & Order Summaries</h3>`;
  tableDiv.innerHTML += buildTransactionSummaryJoin(true);

  // Section 2: Individual Orders (with add form)
  tableDiv.innerHTML += `<h3>Individual Orders</h3>`;
  tableDiv.innerHTML += await buildRelationSection(
    "Individual_Order",
    true,
    true,
  );

  // Section 3: Employees
  tableDiv.innerHTML += `<h3>Employees</h3>`;
  tableDiv.innerHTML += await buildRelationSection("Employee", true, true);

  // Section 4: Events + Key Order Times side by side
  tableDiv.innerHTML += `<h3>Events</h3>`;
  tableDiv.innerHTML += await buildRelationSection("Events", true, true);
  tableDiv.innerHTML += `<h3>Key Order Times</h3>`;
  tableDiv.innerHTML += await buildRelationSection(
    "Key_Order_Times",
    false,
    false,
  );
}

// ─── Join Builder: Customer_Transaction + Complete_Order_Summary ─────────────

function buildTransactionSummaryJoin(allowEdit) {
  const txData = cachedData["Customer_Transaction"];
  const sumData = cachedData["Complete_Order_Summary"];

  if (!txData || !sumData) return "<p>Data unavailable.</p>";

  // Build lookup from Complete_Order_Summary by transaction_id
  const sumCols = sumData["columns"]; // [transaction_id, appetizers_bought, ...]
  const sumMap = {};
  sumData["data"].forEach((row) => {
    sumMap[row[0]] = row; // key by transaction_id
  });

  // Merged columns: all tx cols + summary cols minus the repeated transaction_id
  const txCols = txData["columns"];
  const sumExtraCols = sumCols.slice(1); // drop transaction_id from summary side
  const mergedCols = [...txCols, ...sumExtraCols];

  const mergedRows = txData["data"].map((txRow) => {
    const txId = txRow[0];
    const sumRow = sumMap[txId]
      ? sumMap[txId].slice(1)
      : sumExtraCols.map(() => "N/A");
    return [...txRow, ...sumRow];
  });

  const canEdit =
    allowEdit && cachedPrivileges["Customer_Transaction"]?.includes("UPDATE");
  const canDelete =
    allowEdit && cachedPrivileges["Customer_Transaction"]?.includes("DELETE");

  return buildTableHTML(
    "Customer_Transaction + Complete_Order_Summary",
    mergedCols,
    mergedRows,
    canEdit,
    canDelete,
  );
}

// ─── Generic Relation Section Builder ────────────────────────────────────────

async function buildRelationSection(relation, allowEdit, allowInsert) {
  const relData = cachedData[relation];
  if (!relData) return `<p>${relation} data unavailable.</p>`;

  const cols = relData["columns"];
  const rows = relData["data"];

  const canInsert =
    allowInsert && cachedPrivileges[relation]?.includes("INSERT");
  const canEdit = allowEdit && cachedPrivileges[relation]?.includes("UPDATE");
  const canDelete = allowEdit && cachedPrivileges[relation]?.includes("DELETE");

  let html = "";

  if (canInsert) {
    html += `
      <button
        id="insertTrigger"
        data-bs-toggle="modal"
        data-bs-target="#modal-add"
        type="button"
        class="btn insertTrigger"
        onclick="buildAddModal('${relation}')">
        <i class="bi bi-plus-circle"></i> Add Item
      </button>`;
  }

  html += buildTableHTML(relation, cols, rows, canEdit, canDelete);
  return html;
}

// ─── Table HTML Builder ───────────────────────────────────────────────────────

function buildTableHTML(label, cols, rows, canEdit = false, canDelete = false) {
  const editHeader =
    canEdit || canDelete
      ? `<th id="table-header">Update/Delete Options</th>`
      : "";

  const headerHTML =
    `<tr>` +
    cols.map((h) => `<th id="table-header">${h}</th>`).join("") +
    editHeader +
    `</tr>`;

  const bodyHTML = rows
    .map((row) => {
      let editCell = "";
      if (canEdit || canDelete || label.includes("Customer_Transaction")) {
        editCell = `<td id="table-cell" style="white-space: nowrap; text-align: right;">`;
        if (canEdit) {
          editCell += `<button class="btn btn-primary btn-sm me-1">Edit</button>`;
        }
        if (canDelete) {
          editCell += `<button class="btn btn-danger btn-sm me-1">Delete</button>`;
        }
        if (label.includes("Customer_Transaction")) {
          editCell += `
      <button class="btn btn-success btn-sm"
        onclick="completeTransaction(${row[0]})">
        Complete
      </button>
    `;
        }

        editCell += `</td>`;
      }
      return `<tr>
      ${row.map((cell) => `<td id="table-cell">${cell ?? ""}</td>`).join("")}
      ${editCell}
    </tr>`;
    })
    .join("");

  return `
    <div class="table-${label.replace(/\s+/g, "_")}">
      <table id="table">
        <thead>${headerHTML}</thead>
        <tbody>${bodyHTML}</tbody>
      </table>
    </div>`;
}

// ─── Add Modal ────────────────────────────────────────────────────────────────

async function buildAddModal(relation) {
  window.activeRelation = relation;
  const cols = cachedData[relation]["columns"];

  const modalInfo = cols
    .map(
      (c) => `
    <div class="mb-3">
      <label for="${c}" class="form-label">${c}</label>
      <input type="text" class="form-control" id="${c}">
    </div>`,
    )
    .join("");

  modalContentDiv.innerHTML = modalInfo;
}

// Insert button listener
const addBtn = document.getElementById("add-btn");
if (addBtn) {
  addBtn.addEventListener("click", async function () {
    const inputs = modalContentDiv.querySelectorAll("input");
    const data = {};
    inputs.forEach((input) => {
      data[input.id] = input.value;
    });

    document.getElementById("close-add-modal")?.click();
    await insertTuple(window.activeRelation, data);
  });
}

const closeBtn = document.getElementById("btn-close");
if (closeBtn) {
  closeBtn.addEventListener("click", function () {
    modalContentDiv.innerHTML = "";
  });
}

// ─── API Calls ────────────────────────────────────────────────────────────────
async function completeTransaction(transactionId) {
  await fetch(`${API}/complete_transaction/${transactionId}`, {
    method: "PUT",
  });

  cachedData = await getRelationsForRole(user_role);
  await printRelationsForRole(user_role);
}

async function getRelationsForRole() {
  const response = await fetch(`${API}/${user_role}`, { method: "GET" });
  if (!response.ok) throw new Error("Failed to retrieve data for this role");
  return await response.json();
}

async function getPrivileges(role_name) {
  const response = await fetch(`${API}/${role_name}/privileges`, {
    method: "GET",
  });
  if (!response.ok) throw new Error("Failed to retrieve privileges");
  return await response.json();
}

async function insertTuple(rel_name, data) {
  await fetch(`${API}/${rel_name}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  // Refresh page data after insert
  cachedData = await getRelationsForRole(user_role);
  await printRelationsForRole(user_role);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function formatTime(seconds) {
  if (seconds == null || isNaN(seconds)) return seconds;
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const ampm = h >= 12 ? "PM" : "AM";
  const h12 = h % 12 || 12;
  return `${h12}:${String(m).padStart(2, "0")} ${ampm}`;
}
function renderMenuSection(title, items) {
  if (!items || items.length === 0) return "";

  const rows = items
    .map(
      (i) => `
    <div class="menu-item">
      <span class="item-name">${i.name}</span>
      <span class="item-price">$${Number(i.price).toFixed(2)}</span>
    </div>
  `,
    )
    .join("");

  return `
    <div class="menu-section">
      <h2>${title}</h2>
      ${rows}
    </div>
  `;
}
function addToOrder(id, name, price) {
  window.currentOrder.push({ id, name, price });
  renderOrder();
}

function renderOrder() {
  const orderDiv = document.getElementById("order-items");

  let total = 0;

  orderDiv.innerHTML = window.currentOrder
    .map((item, index) => {
      total += item.price;

      return `
      <div class="order-line">
        ${item.name} - $${item.price.toFixed(2)}
        <button onclick="removeFromOrder(${index})">x</button>
      </div>
    `;
    })
    .join("");

  document.getElementById("order-total").innerText =
    `Total: $${total.toFixed(2)}`;
}

function removeFromOrder(index) {
  window.currentOrder.splice(index, 1);
  renderOrder();
}
async function finalizeOrder() {
  if (!window.currentOrder || window.currentOrder.length === 0) {
    alert("No items in order");
    return;
  }

  const response = await fetch(`${API}/create_order`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      items: window.currentOrder.map((item) => ({
        id: item.id,
        name: item.name,
        price: item.price,
      })),
      employee_id: 1,
    }),
  });

  if (!response.ok) {
    alert("Failed to create transaction");
    return;
  }

  const data = await response.json();
  if (data.error) {
    alert("Error: " + data.error);
    return;
  }

  window.currentOrder = [];
  renderOrder();
  cachedData = await getRelationsForRole(user_role);
  await printRelationsForRole(user_role);
  alert("Order completed! Transaction ID: " + data.transaction_id);
}
