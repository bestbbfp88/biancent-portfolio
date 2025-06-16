document.addEventListener("DOMContentLoaded", () => {
  
    const assignResponderModalEl = document.getElementById("assignResponderModal");
    const responderPersonnelModalEl = document.getElementById("responderPersonnelModal");
  
    let allResponderUnits = []; // Global cache for search

    function fetchResponderUnits() {
      const tableBody = document.getElementById("responderUnitList");
      if (!tableBody) return;

      const responderUnitRef = firebase.database().ref("responder_unit");
      const usersRef = firebase.database().ref("users");
      const stationsRef = firebase.database().ref("emergency_responder_station");

      Promise.all([usersRef.once("value"), stationsRef.once("value")])
        .then(([usersSnapshot, stationsSnapshot]) => {
          const users = usersSnapshot.val() || {};
          const stations = stationsSnapshot.val() || {};

          responderUnitRef.on("value", (snapshot) => {
            allResponderUnits = [];

            snapshot.forEach((childSnapshot) => {
              const unit = childSnapshot.val();
              const unitId = childSnapshot.key;

              if (unit.unit_Status !== "Active" && unit.unit_Status !== "Responding") return;

              const userUID = unit.station_ID;
              const userData = users[userUID];
              const stationId = userData?.station_id;
              const stationData = stationId ? stations[stationId] : null;
              const stationName = stationData?.station_name || "TaRSIER";

              allResponderUnits.push({
                unitId,
                unitName: unit.unit_Name || "Unnamed Unit",
                stationName,
                unitAssign: unit.unit_Assign || ""
              });              
            });

            renderResponderUnitTable(allResponderUnits);
          });
        })
        .catch((error) => {
          console.error("❌ Failed to fetch responder units:", error);
          tableBody.innerHTML = `<tr><td colspan="3">Error loading units</td></tr>`;
        });
    }

    function renderResponderUnitTable(units) {
      const tableBody = document.getElementById("responderUnitList");
      tableBody.innerHTML = "";
    
      if (!units.length) {
        tableBody.innerHTML = `<tr><td colspan="3">No units found.</td></tr>`;
        return;
      }
    
      // Get signed-in user details
      const currentUser = firebase.auth().currentUser;
    
      firebase.database().ref(`users/${currentUser.uid}`).once("value").then(snapshot => {
        const userData = snapshot.val();
        const userRole = userData?.user_role || "";
    
        units.forEach(unit => {
          let actionButtons = '';
    
          // Conditions
          if (userRole === "Admin") {
            // Admin: allow all
            actionButtons = `
              <button class="btn btn-sm btn-primary" onclick="assignUnit('${unit.unitId}')">Assign</button>
              <button class="btn btn-sm btn-warning ms-1" onclick="editUnit('${unit.unitId}')">Update</button>
              <button class="btn btn-sm btn-danger ms-1" onclick="confirmArchiveUnit('${unit.unitId}')">Archive</button>
            `;
          } else if (userRole === "Resource Manager" && unit.unitAssign === "TaRSIER Unit") {
            // Resource Manager: allow only if unit_Assign == "TaRSIER Unit"
            actionButtons = `
              <button class="btn btn-sm btn-primary" onclick="assignUnit('${unit.unitId}')">Assign</button>
              <button class="btn btn-sm btn-warning ms-1" onclick="editUnit('${unit.unitId}')">Update</button>
              <button class="btn btn-sm btn-danger ms-1" onclick="confirmArchiveUnit('${unit.unitId}')">Archive</button>
            `;
          } else {
            // Otherwise: No buttons at all
            actionButtons = `<span class="text-muted">Restricted</span>`;
          }
    
          tableBody.innerHTML += `
            <tr>
              <td>${unit.unitName}</td>
              <td>${unit.stationName}</td>
              <td>${actionButtons}</td>
            </tr>
          `;
        });
      });
    }
    

      
    assignResponderModalEl.addEventListener("shown.bs.modal", fetchResponderUnits);
    
    let autoShowResponderPersonnelModal = false; // Toggle this if needed later

    assignResponderModalEl.addEventListener("hidden.bs.modal", function () {
      if (autoShowResponderPersonnelModal && !suppressPersonnelModal) {
        const personnelModal = new bootstrap.Modal(responderPersonnelModalEl);
        personnelModal.show();
      }
    
      suppressPersonnelModal = false;
    });
    
    function fetchArchivedResponderUnits() {
      const tableBody = document.getElementById("archivedResponderUnitList");
      if (!tableBody) return;
    
      const responderUnitRef = firebase.database().ref("responder_unit");
      const usersRef = firebase.database().ref("users");
      const stationsRef = firebase.database().ref("emergency_responder_station");
    
      // Get currently logged-in user first
      const currentUser = firebase.auth().currentUser;
    
      Promise.all([
        usersRef.once("value"),
        stationsRef.once("value"),
        firebase.database().ref(`users/${currentUser.uid}`).once("value") // 🆕 Fetch current user info
      ])
      .then(([usersSnapshot, stationsSnapshot, currentUserSnapshot]) => {
        const users = usersSnapshot.val() || {};
        const stations = stationsSnapshot.val() || {};
        const currentUserData = currentUserSnapshot.val() || {};
        const userRole = currentUserData.user_role || "";
    
        responderUnitRef.once("value").then((snapshot) => {
          tableBody.innerHTML = "";
          const now = new Date();
          const today = now.toISOString().split("T")[0];
    
          snapshot.forEach((childSnapshot) => {
            const unit = childSnapshot.val();
            const unitKey = childSnapshot.key;
    
            if (unit.unit_Status !== "Archived") return;
    
            // ✅ Auto-delete expired
            if (unit.delete_scheduled_at) {
              const deleteDate = new Date(unit.delete_scheduled_at);
              const deleteDateOnly = deleteDate.toISOString().split("T")[0];
              if (deleteDateOnly <= today) {
                responderUnitRef.child(unitKey).remove();
                return;
              }
            }
    
            // 🏢 Get station name via user -> station mapping
            const userUID = unit.station_ID;
            const userData = users[userUID];
            const stationId = userData?.station_id;
            const stationData = stationId ? stations[stationId] : null;
            const stationName = stationData?.station_name || "N/A";
    
            // 🔘 Buttons: role-based condition
            let actionButtons = "";
    
            if (userRole === "Admin") {
              // Admin unrestricted
              if (unit.delete_scheduled_at) {
                actionButtons = `
                  <button class="btn btn-outline-secondary btn-sm" onclick="cancelDeleteUnit('${unitKey}')">Cancel Delete</button>
                `;
              } else {
                actionButtons = `
                  <button class="btn btn-success btn-sm" onclick="activateUnit('${unitKey}')">Activate</button>
                  <button class="btn btn-danger btn-sm" onclick="scheduleDeleteUnit('${unitKey}')">Delete</button>
                `;
              }
            } else if (userRole === "Resource Manager" && unit.unit_Assign === "TaRSIER Unit") {
              // Resource Manager but ONLY TaRSIER Unit
              if (unit.delete_scheduled_at) {
                actionButtons = `
                  <button class="btn btn-outline-secondary btn-sm" onclick="cancelDeleteUnit('${unitKey}')">Cancel Delete</button>
                `;
              } else {
                actionButtons = `
                  <button class="btn btn-success btn-sm" onclick="activateUnit('${unitKey}')">Activate</button>
                  <button class="btn btn-danger btn-sm" onclick="scheduleDeleteUnit('${unitKey}')">Delete</button>
                `;
              }
            } else {
              // Restricted view
              actionButtons = `<span class="text-muted">Restricted</span>`;
            }
    
            const row = `
              <tr>
                <td>${unit.unit_Name || "Unnamed Unit"}</td>
                <td>${stationName}</td>
                <td>${actionButtons}</td>
              </tr>
            `;
    
            tableBody.innerHTML += row;
          });
    
          if (!tableBody.innerHTML.trim()) {
            tableBody.innerHTML = `<tr><td colspan="3">No archived units found.</td></tr>`;
          }
        });
      })
      .catch((error) => {
        console.error("❌ Error loading archived units:", error);
        tableBody.innerHTML = `<tr><td colspan="3">Error loading archived units.</td></tr>`;
      });
    }
    
      
      document.getElementById("archivedResponderUnitModal")?.addEventListener("shown.bs.modal", fetchArchivedResponderUnits);

      window.activateUnit = async function (unitId) {
        try {
          await firebase.database().ref(`responder_unit/${unitId}`).update({
            unit_Status: "Active"
          });
      
          showSuccessModal("✅ Unit activated successfully!");
      
          // Optionally refresh the archived list
          if (typeof fetchArchivedResponderUnits === "function") {
            fetchArchivedResponderUnits();
          }
      
          // Optionally refresh the active units list
          if (typeof fetchResponderUnits === "function") {
            fetchResponderUnits();
          }
      
        } catch (error) {
          console.error("❌ Failed to activate unit:", error);
          alert("❌ Failed to activate the unit. Please try again.");
        }
      };


      document.getElementById("searchResponderUnit").addEventListener("input", (e) => {
        const query = e.target.value.toLowerCase();
        const filtered = allResponderUnits.filter(unit =>
          unit.unitName.toLowerCase().includes(query) ||
          unit.stationName.toLowerCase().includes(query)
        );
      
        renderResponderUnitTable(filtered);
      });
      
      window.scheduleDeleteUnit = function(unitId) {
        const deleteTime = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();
        firebase.database().ref(`responder_unit/${unitId}`).update({
          delete_scheduled_at: deleteTime
        }).then(() => {
          alert("🗑️ Unit scheduled for deletion in 2 days.");
          fetchArchivedResponderUnits();
        }).catch((error) => {
          console.error(error);
          alert("❌ Failed to schedule delete.");
        });
      };
      
      window.cancelDeleteUnit = function(unitId) {
        firebase.database().ref(`responder_unit/${unitId}/delete_scheduled_at`).remove()
          .then(() => {
            alert("🛑 Deletion cancelled.");
            fetchArchivedResponderUnits();
          })
          .catch((error) => {
            console.error(error);
            alert("❌ Failed to cancel deletion.");
          });
      };

      async function purgeExpiredResponderUnits() {
        const now = new Date();
        const today = now.toISOString().split("T")[0]; // Format: YYYY-MM-DD
      
        const ref = firebase.database().ref("responder_unit");
        const snapshot = await ref.once("value");
      
        let deletedCount = 0;
      
        snapshot.forEach((child) => {
          const data = child.val();
          const id = child.key;
      
          if (data.delete_scheduled_at) {
            const deleteDate = new Date(data.delete_scheduled_at);
            const deleteDateOnly = deleteDate.toISOString().split("T")[0];
      
            if (deleteDateOnly <= today) {
              ref.child(id).remove();
              deletedCount++;
            }
          }
        });
      
        if (deletedCount > 0) {
          console.log(`🗑️ Automatically deleted ${deletedCount} expired responder units.`);
        }
      }
      
      purgeExpiredResponderUnits();  
});
  