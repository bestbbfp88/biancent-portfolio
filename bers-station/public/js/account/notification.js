const db = firebase.database();
const auth = firebase.auth();

let notifiedResponders = new Set();

// 🔍 Load previously notified IDs from localStorage
if (localStorage.getItem('notifiedResponders')) {
  notifiedResponders = new Set(JSON.parse(localStorage.getItem('notifiedResponders')));
  console.log("🔁 Loaded notified responders from localStorage:", notifiedResponders);
} else {
  console.log("ℹ️ No notified responders in localStorage.");
}

// 🔐 Sign in using custom token and then set up listener
firebase.auth().signInWithCustomToken(window.firebaseCustomToken)
  .then(() => {
    const currentUser = firebase.auth().currentUser;
    if (!currentUser) {
      console.error("❌ User is not authenticated even after token sign-in.");
      return;
    }

    const currentUID = currentUser.uid;
    console.log("✅ Signed in with UID:", currentUID);

    const respondersRef = db.ref("users").orderByChild("user_role").equalTo("Emergency Responder");

    // 🔔 Listen for responder account updates
    respondersRef.on("child_changed", snapshot => {
        const responder = snapshot.val();
        const responderId = snapshot.key;
      
        console.log("📡 Detected change for responder:", responderId, responder);
      
        if (
          responder.user_status === "Active" &&  // ✅ correct key name
          responder.created_by === currentUID
        ) {
          if (!notifiedResponders.has(responderId)) {
            console.log("✅ Approved responder created by this user. Showing notification.");
            notifiedResponders.add(responderId);
            localStorage.setItem("notifiedResponders", JSON.stringify([...notifiedResponders]));
      
            showNotification(`${responder.f_name || "Emergency Responder"} has been <strong>Approved</strong>.`);
          } else {
            console.log("⏩ Already notified:", responderId);
          }
        } else {
          console.log("❌ Ignored - not created by user or not Active yet.");
        }
      });
      

  }).catch(error => {
    console.error("❌ Firebase Auth Error:", error);
  });

function showNotification(message) {
  const list = document.getElementById("notificationList");
  const count = document.getElementById("notificationCount");

  const newNotification = document.createElement("li");
  newNotification.className = "dropdown-item small text-dark py-2 px-3 fade-in";
  newNotification.innerHTML = `<i class="fas fa-check-circle text-success me-2"></i> ${message}`;
  list.appendChild(newNotification);

  const currentCount = list.querySelectorAll("li.dropdown-item").length;
  count.textContent = currentCount;
  count.style.display = "inline-block";

  console.log("🔔 Notification shown. Total now:", currentCount);

  const audio = new Audio('/audio/approve.mp3');
  audio.play();
}

function clearNotifications() {
  document.querySelectorAll("#notificationList .dropdown-item").forEach(item => item.remove());
  document.getElementById("notificationCount").style.display = "none";
  localStorage.removeItem("notifiedResponders");
  notifiedResponders.clear();

  console.log("🧹 Cleared all notifications.");
}
