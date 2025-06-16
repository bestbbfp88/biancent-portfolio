let responderUserSelect = null;

document.addEventListener("DOMContentLoaded", () => {
    console.log("Responder Select");
  
    firebase.auth().onAuthStateChanged(async (signedInUser) => {
      if (!signedInUser) {
        console.error("❌ No authenticated user found.");
        return;
      }
  
      responderUserSelect = document.getElementById("responderUser");
  
      if (!responderUserSelect) {
        console.error("❌ Missing DOM elements! Aborting initialization.");
        return;
      }
  
      // ✅ Initialize Select Element
      responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;
  
      const assignedResponders = await getAssignedResponders();
      await loadResponderOptions(signedInUser.uid, assignedResponders);
    });
  });
  
  
  async function getAssignedResponders() {
    console.log("🔍 Fetching assigned responders...");
    const assignedResponders = new Set();
  
    try {
      const snapshot = await firebase.database().ref("responder_unit").once("value");
  
      if (!snapshot.exists()) {
        console.warn("⚠️ No assigned responders found.");
        return assignedResponders;
      }
  
      snapshot.forEach((child) => {
        const unit = child.val();
        if (unit.ER_ID) {
          assignedResponders.add(unit.ER_ID);
          console.log(`✔️ Assigned ER_ID: ${unit.ER_ID}`);
        }
      });
  
      console.log("✅ Assigned responders fetched:", assignedResponders);
    } catch (error) {
      console.error("❌ Failed to fetch assigned responders:", error);
    }
  
    return assignedResponders;
  }
  
  async function loadResponderOptions(stationUID, assignedResponders) {
    console.log("🔄 Loading responders for station:", stationUID);
    const usersRef = firebase.database().ref("users");
  
    try {
      const snapshot = await usersRef.orderByChild("created_by").equalTo(stationUID).once("value");
  
      if (!snapshot.exists()) {
        console.warn("⚠️ No responders found for this station.");
        return;
      }
  
      snapshot.forEach((child) => {
        const user = child.val();
        const userId = child.key;
  
        // ✅ Filter only users with user_status === "Active"
        if (user.user_status !== "Active") return;
  
        const fullName = `${user.f_name} ${user.l_name}`;
        const isAssigned = assignedResponders.has(userId);
        const option = document.createElement("option");
  
        option.value = isAssigned ? "" : userId;
        option.textContent = isAssigned ? `${fullName} (Assigned Already)` : fullName;
        if (isAssigned) option.disabled = true;
  
        responderUserSelect.appendChild(option);
      });
  
      console.log("✅ Responder dropdown updated.");
    } catch (error) {
      console.error("❌ Error loading responders:", error);
    }
  }
  