document.addEventListener("DOMContentLoaded", () => {
  
  const responderUserSelect = document.getElementById("responderUser");
  const unitAssignSelect = document.getElementById("unitAssign");
  const erStationSelect = document.getElementById("erStation");

  console.log("🔍 DOM Elements:");
  console.log(`   - responderUserSelect: ${responderUserSelect ? "Found" : "Not Found"}`);
  console.log(`   - unitAssignSelect: ${unitAssignSelect ? "Found" : "Not Found"}`);
  console.log(`   - erStationSelect: ${erStationSelect ? "Found" : "Not Found"}`);

  if (!responderUserSelect || !unitAssignSelect || !erStationSelect) {
      console.error("❌ Missing DOM elements! Aborting initialization.");
      return; 
  }

  // ✅ Initialize Select Elements
  responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;

  // ✅ Add event listeners after DOM is ready
  unitAssignSelect.addEventListener("change", async () => {
      console.log("🔁 Unit changed...");
      await loadRespondersForTarsier();
  });

  // 🟢 STEP 2: Load responders when station is selected
  erStationSelect.addEventListener("change", async function () {
    const selectedUnit = unitAssignSelect.value;             // e.g., PNP, BFP, TaRSIER
    const selectedOption = this.options[this.selectedIndex];  // Selected station option
    const selectedStationUID = selectedOption.value;         // Station UID from the dropdown

    // 🧠 First: Check if selected unit is "TaRSIER Unit"
    const isTarsierUnit = selectedUnit === "TaRSIER Unit";

    // 🛑 If not TaRSIER and no station is selected, skip loading
    if (!isTarsierUnit && !selectedStationUID) {
        console.warn("⚠️ No station selected and not TaRSIER. Skipping responder load.");
        responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;
        return;
    }

    console.log("🔍 Selected Unit Type:", selectedUnit);
    console.log("🏢 Selected Station UID:", selectedStationUID || "(Not Required for TaRSIER)");

    // ✅ Set loading message while fetching responders
    responderUserSelect.innerHTML = `<option value="">Loading responders...</option>`;

    try {
        // 👉 Fetch all users and responder units in parallel
        const [usersSnapshot, unitsSnapshot] = await Promise.all([
            firebase.database().ref("users").once("value"),
            firebase.database().ref("responder_unit").once("value")
        ]);

        const assignedERIDs = new Set();

        // 🔥 Store all assigned ER_IDs
        unitsSnapshot.forEach((unit) => {
            const unitData = unit.val();
            if (unitData.ER_ID) {
                assignedERIDs.add(unitData.ER_ID);  // Store all assigned responders
            }
        });

        responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;
        let foundResponders = false;

        // 🔥 Iterate through all users
        usersSnapshot.forEach((child) => {
            const user = child.val();
            const uid = child.key;

            const isResponder = user.user_role === "Emergency Responder";  // ✅ Filter by role
            const responderName = `${user.f_name || "NoName"} ${user.l_name || ""}`.trim();

            let isAssigned = assignedERIDs.has(uid);  // 🚫 Check if responder is already assigned

            if (isTarsierUnit) {
                // ✅ For TaRSIER units, match only TaRSIER responders
                const isTarsier = user.responder_type === "TaRSIER Responder";

                if (isResponder && isTarsier) {
                    console.log("✅ TaRSIER Responder:", responderName);

                    foundResponders = true;
                    responderUserSelect.innerHTML += `
                        <option value="${uid}" ${isAssigned ? 'disabled' : ''}>
                            ${responderName} ${isAssigned ? '(Assigned)' : ''}
                        </option>`;
                } else {
                    console.log("⛔ Skipping (Not TaRSIER):", responderName);
                }

            } else {
                // ✅ For other units, match responders by `created_by` (station UID)
                const createdByThisStation = user.created_by === selectedStationUID;

                if (isResponder && createdByThisStation) {
                    console.log("✅ Responder matched station:", responderName);

                    foundResponders = true;
                    responderUserSelect.innerHTML += `
                        <option value="${uid}" ${isAssigned ? 'disabled' : ''}>
                            ${responderName} ${isAssigned ? '(Assigned)' : ''}
                        </option>`;
                } else {
                    console.log("⛔ Skipping:", responderName);
                }
            }
        });

        // 🚫 Handle no matching responders
        if (!foundResponders) {
            responderUserSelect.innerHTML = `<option value="">No responders found</option>`;
            console.warn("⚠️ No matching responders.");
        }

    } catch (error) {
        console.error("❌ Failed to load responders:", error);
        responderUserSelect.innerHTML = `<option value="">Error loading responders</option>`;
    }
  });
});

// 🔥 Refactor to Select DOM Inside the Function
async function loadRespondersForTarsier() {
  console.log("🔁 Loading TaRSIER responders...");

  // ✅ Select DOM again inside the function to avoid missing references
  const responderUserSelect = document.getElementById("responderUser");

  if (!responderUserSelect) {
      console.error("❌ responderUserSelect is not available!");
      return;
  }

  responderUserSelect.innerHTML = `<option value="">Loading responders...</option>`;

  try {
      console.log("📥 Fetching assigned responders...");
      const assignedResponders = await getAssignedResponders();
      console.log("✅ Assigned Responders:", assignedResponders);

      console.log("📥 Fetching all users...");
      const usersSnapshot = await firebase.database().ref("users").once("value");
      console.log("✅ Users Fetched:", usersSnapshot.exists() ? "Yes" : "No");

      responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;

      let found = false;
      let totalUsers = 0;
      let matchedTarsier = 0;
      let assignedCount = 0;

      usersSnapshot.forEach((child) => {
          totalUsers++;

          const user = child.val();
          const uid = child.key;

          const isResponder = user.user_role === "Emergency Responder";
          const isTarsier = user.responder_type === "TaRSIER Responder";
          const name = `${user.f_name || "NoName"} ${user.l_name || ""}`.trim();

          // 🚫 Check if already assigned
          let isDisabled = assignedResponders.has(uid) ? "disabled" : ""; 
          let assignedLabel = assignedResponders.has(uid) ? " (Already Assigned)" : "";

          if (assignedResponders.has(uid)) {
              assignedCount++;
          }

          console.log(`🔍 Responder: ${name} (UID: ${uid})`);
          console.log(`   - Role: ${user.user_role}`);
          console.log(`   - Type: ${user.responder_type}`);
          console.log(`   - Assigned: ${assignedResponders.has(uid)}, Disabled: ${isDisabled}`);

          if (isResponder && isTarsier) {
              matchedTarsier++;
              found = true;

              responderUserSelect.innerHTML += `
                  <option value="${uid}" ${isDisabled}>
                      ${name}${assignedLabel}
                  </option>`;
              console.log(`✅ Added TaRSIER Responder: ${name}`);
          }
      });

      console.log("🔎 Summary:");
      console.log(`   - Total Users: ${totalUsers}`);
      console.log(`   - Matched TaRSIER Responders: ${matchedTarsier}`);
      console.log(`   - Already Assigned: ${assignedCount}`);

      if (!found) {
          console.warn("⚠️ No TaRSIER responders found.");
          responderUserSelect.innerHTML = `<option value="">No responders found</option>`;
      }

  } catch (error) {
      console.error("❌ Failed to load TaRSIER responders:", error);
      responderUserSelect.innerHTML = `<option value="">Error loading responders</option>`;
  }
}

// 🔥 Fetch Assigned Responders with Debug Logs
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
