const API = "http://127.0.0.1:8000/crud";
const modalContentDiv = document.getElementById("new-tuple");
let user_role = "";

// Function to print each relation
async function printRelationsForRole(role_name) {
  user_role = role_name; // DEFINES GLOBALLY
  const data = await getRelationsForRole(role_name);

  console.log(Object.keys(data).length);
  for (const [key, innerDict] of Object.entries(data)) {
    build_relation(key, role_name);
  }
}

// insert button event listener
const addBtn = document.getElementById("add-btn");
if (addBtn) {
  addBtn.addEventListener("click", async function () {
    const inputs = modalContentDiv.querySelectorAll("input");

    const data = {}; // <-- fresh object every time

    inputs.forEach((input) => {
      data[input.id] = input.value;
    });

    console.log(data);

    document.getElementById("close-add-modal")?.click();

    // send to backend
    await insertTuple(window.activeRelation, data);
  });
}

// Close modal event button listener
const closeBtn = document.getElementById("btn-close");
if (closeBtn) {
  closeBtn.addEventListener("click", function () {
    modalContentDiv.innerHTML = "";
  });
}

/* API REQUEST TO GET ALL RELATIONS FOR ROLE */
async function getRelationsForRole() {
  const response = await fetch(API + "/" + user_role, {
    method: "GET",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(response.error || "Failed to retrieve data for this role");
  }

  return data;
}

/* API REQUEST TO INSERT A TUPLE */
async function insertTuple(rel_name, data) {
  const response = await fetch(API + "/" + rel_name, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  build_relation(rel_name, user_role);
}

/* BUILD A SINGLE RELATION */
async function build_relation(relation) {
  const data = await getRelationsForRole(user_role);
  const tableDiv = document.getElementById("tables"); // define div

  //   if (document.getElementById(`table-${relation}`)) {
  //   }

  const headers = data[relation]["columns"];
  const colData = data[relation]["data"];
  const index = data[relation]["index"];

  const insertionHTML = await getInsertionHTML(relation, user_role);
  const editHTML = await getUpdateDeleteHTML(relation, user_role);

  var editHeader = "";

  if (editHTML != "") {
    editHeader = "<th id='table-header'>Update/Delete Options</th>";
  }

  // Map the headers and column data to hTML
  const headerHTML =
    `<tr>` +
    headers.map((h) => `<th id="table-header">${h}</th>`).join("") +
    editHeader +
    `</tr>`;

  // colData - each value is a row with its own list of cells (need two map functions)
  const bodyHTML = colData
    .map(
      (row) => `
      <tr>
        ${row.map((cell) => `<td id="table-cell">${cell}</td>`).join("")}
        <td id="table-cell">${editHTML}</td>
      </tr>
    `,
    )
    .join("");

  tableDiv.innerHTML += `
    <div class='table-${relation}'>
        <h4>${relation}</h4>
        ${insertionHTML}
        <table id="table">
            <thead>
                ${headerHTML}
            </thead>
            <tbody>
                ${bodyHTML}
            </tbody>
        </table>
    </div>`;
}

/* BUILD ADD MODAL */
async function buildAddModal(relation) {
  const data = await getRelationsForRole(user_role);
  const relation_info = data[relation];
  window.activeRelation = relation;

  const cols = relation_info["columns"];

  // create all fields for insertion
  const modalInfo = cols.map(
    (c) =>
      `<div class="mb-3">
        <label for=${c} class="form-label">${c}</label>
        <input type="text" class="form-control" id=${c}>
    </div>`,
  );

  modalContentDiv.innerHTML = modalInfo;
}

/* See if user has insert privileges, and if so, return available button */
async function getInsertionHTML(relation) {
  const privileges = await getPrivileges(user_role);
  console.log(privileges);
  var innerHTML = "";

  if (privileges[relation].includes("INSERT")) {
    innerHTML = `
              <button
                id="insertTrigger"
                data-bs-toggle="modal"
                data-bs-target="#modal-add"
                data-relation="${relation}"
                type="button"
                class="btn insertTrigger"
                onclick="buildAddModal('${relation}')"
              >
                <i class="bi bi-plus-circle"></i> Add Item
              </button>
        `;
  }

  return innerHTML;
}

/* See if user has update and/or delete privileges, and if so, return corresponding HTML */
async function getUpdateDeleteHTML(relation) {
  const privileges = await getPrivileges(user_role);
  console.log(privileges);
  var innerHTML = "";

  if (privileges[relation].includes("UPDATE")) {
    innerHTML += `
            <button class="btn btn-primary btn-sm me-2"
              data-bs-toggle="modal"
              data-bs-target="#modal-edit"
              data-relation="${relation}">
              Edit
            </button>
        `;
  }

  if (privileges[relation].includes("DELETE")) {
    innerHTML += `
            <button class="btn btn-danger btn-sm" data-relation="${relation}">
              Delete
            </button>
        `;
  }

  return innerHTML;
}

/* GET USER PRIVILEGES AND RETURN */
async function getPrivileges(role_name) {
  const response = await fetch(API + "/" + role_name + "/privileges", {
    method: "GET",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(response.error || "Failed to retrieve data for this role");
  }

  return data;
}
