const API = "http://127.0.0.1:8000/crud";
let cachedData = null;

// Helper: Update the connection status UI
function setStatus(state, msg) {
  const badge = document.getElementById("status-badge");
  const text = document.getElementById("status-text");
  const classes = {
    ok: "bg-success",
    error: "bg-danger",
    loading: "bg-warning text-dark",
  };
  const labels = {
    ok: "Connected",
    error: "Error",
    loading: "Connecting...",
  };

  badge.className = "badge " + classes[state];
  badge.textContent = labels[state];
  text.textContent = msg;
}

// Helper: Format data for display
function fmt(val, type) {
  if (val === null || val === undefined) return "—";
  if (type === "money") return "$" + parseFloat(val).toFixed(2);
  if (type === "dt") {
    return new Date(val).toLocaleString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
    });
  }
  return val;
}

// Helper: Render Booleans as Badges
function yesNo(val) {
  const yes = val == 1 || val === true;
  return yes
    ? '<span class="badge bg-success">Yes</span>'
    : '<span class="badge bg-secondary">No</span>';
}

// 1. MAIN LOAD FUNCTION
async function loadAll() {
  setStatus("loading", "Fetching database state...");
  try {
    // Fetch generic table data for manager role
    const res = await fetch(`${API}/manager_role`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    cachedData = await res.json();

    // Fetch the specialized joined data for the main table
    const txRes = await fetch(`${API}/transactions-summary`);
    if (!txRes.ok) throw new Error("Join query failed");
    const joinedData = await txRes.json();

    // NEW: Fetch dashboard stats
    const statsRes = await fetch(`${API}/dashboard-stats`);
    console.log("statsRes status:", statsRes.status);
    if (!statsRes.ok) throw new Error("Stats query failed");
    const stats = await statsRes.json();
    // Save stats so render functions can use them
    cachedData["Dashboard_Stats"] = stats;

    setStatus(
      "ok",
      `hamburg_inn · Connected · ${new Date().toLocaleTimeString()}`,
    );

    // Trigger all individual render functions
    renderTransactions(joinedData);
    renderEvents();
    renderKeyOrderTimes();
    renderAnalytics();
    renderDashboardStats();
  } catch (e) {
    setStatus("error", `${e.message} — Check backend & CORS`);
    console.error("Load error:", e);
  }
}

// 2. RENDER TRANSACTIONS (Joined Table)
function renderTransactions(joinedObj) {
  const tbody = document.getElementById("tx-body");
  if (!joinedObj || !joinedObj.data) return;

  const rows = joinedObj.data;
  let totalRevenue = 0;
  let pendingCount = 0;

  tbody.innerHTML = rows
    .map((row) => {
      // Destructuring based on the SELECT * or specific JOIN order
      const [
        tid,
        ts,
        total,
        payMethod,
        empId,
        tips,
        status,
        _skip,
        apps,
        ents,
        sides,
        drinks,
        shakes,
        addons,
        refills,
      ] = row;

      totalRevenue += parseFloat(total || 0);
      if ((status || "").toLowerCase() === "pending") pendingCount++;

      const statusBadge =
        (status || "").toLowerCase() === "completed"
          ? '<span class="badge bg-success">completed</span>'
          : '<span class="badge bg-warning text-dark">pending</span>';

      return `
      <tr>
        <td class="text-muted">#${tid}</td>
        <td>${fmt(ts, "dt")}</td>
        <td class="fw-bold">${fmt(total, "money")}</td>
        <td>${payMethod}</td>
        <td>${statusBadge}</td>
        <td>${empId}</td>
        <td class="text-center">${ents || 0}</td>
        <td class="text-center">${apps || 0}</td>
        <td class="text-center">${sides || 0}</td>
        <td class="text-center">${drinks || 0}</td>
        <td class="text-center">${shakes || 0}</td>
        <td class="text-center">${addons || 0}</td>
        <td class="text-center">${refills || 0}</td>
      </tr>`;
    })
    .join("");
}

// 3. RENDER EVENTS
function renderEvents() {
  const tableData = cachedData["Events"];
  if (!tableData) return;

  const filter = document.getElementById("event-filter").value;
  const filtered =
    filter === "all"
      ? tableData.data
      : tableData.data.filter((r) => r[1] === filter);

  document.getElementById("events-body").innerHTML = filtered
    .map((row) => {
      const [id, name, start, end, day, money, popular] = row;
      return `
      <tr>
        <td>#${id}</td>
        <td><strong>${name}</strong></td>
        <td>${day}</td>
        <td class="text-muted">${fmt(start, "dt")}</td>
        <td class="text-muted">${fmt(end, "dt")}</td>
        <td class="text-success fw-bold">${fmt(money, "money")}</td>
        <td><span class="badge bg-light text-dark border">${popular || "None"}</span></td>
      </tr>`;
    })
    .join("");
}

// 4. RENDER KEY ORDER TIMES
function renderKeyOrderTimes() {
  const tableData = cachedData["Key_Order_Times"];
  if (!tableData) return;

  document.getElementById("kot-body").innerHTML = tableData.data
    .map((row) => {
      const [ts, lastBf, chickenOut] = row;
      const rowClass = chickenOut
        ? "table-danger"
        : lastBf
          ? "table-primary"
          : "";
      return `
      <tr class="${rowClass}">
        <td>${fmt(ts, "dt")}</td>
        <td>${yesNo(lastBf)}</td>
        <td>${yesNo(chickenOut)}</td>
      </tr>`;
    })
    .join("");
}

// 5. RENDER ANALYTICS
function renderAnalytics() {
  const tableData = cachedData["Complete_Order_Summary"];
  if (!tableData) return;

  document.getElementById("analytics-body").innerHTML = tableData.data
    .map((row) => {
      const [tid, apps, ents, sides, drinks, shakes, addons, refills] = row;
      const totalItems = [apps, ents, sides, drinks, shakes].reduce(
        (a, b) => a + (b || 0),
        0,
      );
      return `
      <tr>
        <td>#${tid}</td>
        <td>${fmt(new Date(), "dt")}</td> <td class="text-center">${addons}</td>
        <td class="text-center">${refills}</td>
        <td class="text-center fw-bold">${totalItems}</td>
      </tr>`;
    })
    .join("");
}

function renderDashboardStats() {
  const stats = cachedData["Dashboard_Stats"];
  if (!stats || !stats.data) return;

  const rows = stats.data;

  const customer = rows[0]; // [total_tx, total_rev, avg_val, pending_count]
  const popular = rows[1]; // [popular_item, count]

  // Customer stats
  document.getElementById("stat-tx-count").textContent = customer[0];
  document.getElementById("stat-tx-rev").textContent = fmt(
    customer[1],
    "money",
  );
  document.getElementById("stat-tx-avg").textContent = fmt(
    customer[2],
    "money",
  );
  document.getElementById("stat-tx-pending").textContent = customer[3];

  // Key order times
  const kot = rows[2]; // [avg_bf_cutoff, avg_chicken_soldout]
  console.log(kot);

  document.getElementById("stat-kot-bf-avg").textContent = kot[6];
  document.getElementById("stat-kot-ch-avg").textContent = kot[7];

  // Popular item (you need an HTML ID for this — see below)
  const popularEl = document.getElementById("stat-popular-item");
  if (popularEl) popularEl.textContent = popular[0];
}

loadAll();
