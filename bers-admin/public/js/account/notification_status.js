const db = firebase.database();
const auth = firebase.auth();

console.log("🟢 Notification System Initialized");

// 🔁 Load previously notified units and responders
let notifiedUnitStatus = new Map();
let notifiedResponders = new Set();
let shownNotifications = new Set();
const notificationsRef = db.ref("notifications");

if (localStorage.getItem("notifiedUnitStatus")) {
  const stored = JSON.parse(localStorage.getItem("notifiedUnitStatus"));
  notifiedUnitStatus = new Map(stored);
  console.log("🔁 Loaded notified unit statuses:", stored);
}

if (localStorage.getItem('notifiedResponders')) {
  notifiedResponders = new Set(JSON.parse(localStorage.getItem('notifiedResponders')));
  console.log("🔁 Loaded notified responders:", notifiedResponders);
}

if (localStorage.getItem("shownNotifIDs")) {
  shownNotifications = new Set(JSON.parse(localStorage.getItem("shownNotifIDs")));
  console.log("🔁 Loaded shown notification IDs:", shownNotifications);
}

// 🔔 Listen for new notifications added directly
notificationsRef.on("child_added", (snapshot) => {
  const notifId = snapshot.key;
  const notifData = snapshot.val();

  if (!notifData || notifData.status !== "unread") return;

  console.log("📨 New unread notification:", notifData);

  // ✅ Prevent showing duplicate notifications
  if (shownNotifications.has(notifId)) return;

  // ✅ Cache it
  shownNotifications.add(notifId);
  localStorage.setItem("shownNotifIDs", JSON.stringify([...shownNotifications]));

  // 🔊 Determine notification message
  let msg = `📩 New message from ${notifData.From || "Unknown"}`;
  if (notifData.type === "decline") msg = `❌ Emergency responder declined a request`;
  else if (notifData.type === "accept") msg = `✅ Emergency responder accepted the assignment`;
  else if (notifData.type === "cancel") msg = `🚫 Assignment was canceled`;

  // ✅ Show notification
  showNotification(msg, "info");

  // 🔄 Mark as read in Firebase
  db.ref(`notifications/${notifId}/status`).set("read")
    .then(() => console.log(`✅ Marked notification ${notifId} as read.`))
    .catch((err) => console.error(`❌ Failed to mark as read:`, err));
});


db.ref("responder_unit").on("child_changed", snapshot => {
  const unit = snapshot.val();
  const unitId = snapshot.key;
  if (!unit || !unit.ER_ID) return;

  const newStatus = unit.unit_Status;
  const prevStatus = notifiedUnitStatus.get(unitId);

  console.log(`📡 ${unit.unit_Name || unitId} status changed: ${prevStatus || "Unknown"} ➜ ${newStatus}`);

  if (newStatus === "Emergency" && prevStatus !== "Emergency") {
    showNotification(`${unit.unit_Name || "A responder unit"} is now <strong>IN DISTRESS</strong>.`, "danger");
    notifiedUnitStatus.set(unitId, "Emergency");
  } else if (newStatus === "Active" && prevStatus === "Emergency") {
    showNotification(`${unit.unit_Name || "A responder unit"} is now <strong>Marked Safe</strong>.`, "success");
    notifiedUnitStatus.set(unitId, "Active");
  }

  localStorage.setItem("notifiedUnitStatus", JSON.stringify([...notifiedUnitStatus]));
});

// 🔔 Listen for Emergency Responders with Pending status
db.ref("users").orderByChild("user_role").equalTo("Emergency Responder")
  .on("child_changed", snapshot => {
    const responder = snapshot.val();
    const responderId = snapshot.key;
    if (!responder) return;

    if (responder.user_status === "Pending" && !notifiedResponders.has(responderId)) {
      notifiedResponders.add(responderId);
      localStorage.setItem("notifiedResponders", JSON.stringify([...notifiedResponders]));

      showNotification(
        `<div class="d-flex justify-content-between align-items-center">
          <div>
            🕓 ${responder.f_name || "Responder"} is <strong>Pending</strong> approval.
          </div>
          <button class="btn btn-sm btn-outline-primary ms-2" onclick="approveResponder('${responderId}')">
            Approve
          </button>
        </div>`,
        "info"
      );
    }
  });

// 🔘 Approve function for pending responders
function approveResponder(responderId) {
  db.ref(`users/${responderId}`).update({ user_status: "Active" }).then(() => {
    showNotification("✅ Responder approved successfully.", "success");
  });
}

function showNotification(message, type = "success") {
  const list = document.getElementById("notificationList");
  const count = document.getElementById("notificationCount");

  const header = list.querySelector(".dropdown-header");
  const footer = list.querySelector(".dropdown-footer");

  const newNotification = document.createElement("li");
  newNotification.className = "dropdown-item small text-dark py-2 px-3 fade-in border-bottom";

  const icon =
    type === "danger" ? '<i class="fas fa-exclamation-circle text-danger me-2"></i>' :
    type === "info" ? '<i class="fas fa-user-clock text-warning me-2"></i>' :
    '<i class="fas fa-check-circle text-success me-2"></i>';

  newNotification.innerHTML = `${icon}${message}`;
  if (footer) list.insertBefore(newNotification, footer);
  else list.appendChild(newNotification);

  const currentCount = list.querySelectorAll("li.dropdown-item").length;
  count.textContent = currentCount;
  count.style.display = "inline-block";

  const audio = new Audio(type === "danger" ? '/audio/distress.mp3' : '/audio/approve.mp3');
  audio.play();

  console.log(`🔔 [${type.toUpperCase()}] Notification: ${message}`);
}

function clearNotifications() {
  const list = document.getElementById("notificationList");
  const count = document.getElementById("notificationCount");

  list.querySelectorAll("li.dropdown-item").forEach(item => item.remove());
  count.style.display = "none";
  count.textContent = 0;

  localStorage.removeItem("notifiedUnitStatus");
  localStorage.removeItem("notifiedResponders");

  notifiedUnitStatus.clear();
  notifiedResponders.clear();

  console.log("🧹 Cleared all notifications.");
}
