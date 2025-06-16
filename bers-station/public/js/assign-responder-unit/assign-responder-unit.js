document.addEventListener("DOMContentLoaded", () => {
  
    const assignResponderModalEl = document.getElementById("assignResponderModal");
    const responderPersonnelModalEl = document.getElementById("responderPersonnelModal");
  
    let allResponderUnits = []; // Cache for search

    function fetchResponderUnits() {
      const tableBody = document.getElementById("responderUnitList");
      if (!tableBody) return;
    
      firebase.auth().onAuthStateChanged((user) => {
        if (!user) {
          console.warn("⚠️ No user logged in.");
          tableBody.innerHTML = `<tr><td colspan="3">User not logged in</td></tr>`;
          return;
        }
    
        const currentUID = user.uid;
        const responderUnitRef = firebase.database().ref("responder_unit");
        const usersRef = firebase.database().ref("users");
        const stationsRef = firebase.database().ref("emergency_responder_station");
    
        Promise.all([usersRef.once("value"), stationsRef.once("value")])
          .then(([usersSnapshot, stationsSnapshot]) => {
            const users = usersSnapshot.val() || {};
            const stations = stationsSnapshot.val() || {};
    
            responderUnitRef.on("value", (snapshot) => {
              const allResponderUnits = [];
    
              snapshot.forEach((childSnapshot) => {
                const unit = childSnapshot.val();
                const unitId = childSnapshot.key;
    
                // ✅ Filter units by current user UID as station_ID
                if (unit.unit_Status !== "Active" || unit.station_ID !== currentUID) return;
    
                const userData = users[unit.station_ID];
                const stationId = userData?.station_id;
                const stationData = stationId ? stations[stationId] : null;
                const stationName = stationData?.station_name || "N/A";
    
                allResponderUnits.push({
                  unitId,
                  unitName: unit.unit_Name || "Unnamed Unit",
                  stationName,
                });
              });
    
              renderResponderUnitTable(allResponderUnits);
            });
          })
          .catch((error) => {
            console.error("❌ Failed to fetch responder units:", error);
            tableBody.innerHTML = `<tr><td colspan="3">Error loading units</td></tr>`;
          });
      });
    }
    

    function renderResponderUnitTable(units) {
      const tableBody = document.getElementById("responderUnitList");
      tableBody.innerHTML = "";

      if (!units.length) {
        tableBody.innerHTML = `<tr><td colspan="3">No units found.</td></tr>`;
        return;
      }

      units.forEach(unit => {
        tableBody.innerHTML += `
          <tr>
            <td>${unit.unitName}</td>
            <td>${unit.stationName}</td>
            <td>
              <button class="btn btn-sm btn-primary" onclick="assignUnit('${unit.unitId}')">Assign</button>
              <button class="btn btn-sm btn-warning ms-1" onclick="editUnit('${unit.unitId}')">Update</button>
              <button class="btn btn-sm btn-danger ms-1" onclick="confirmArchiveUnit('${unit.unitId}')">Archive</button>
            </td>
          </tr>
        `;
      });
    }

    document.getElementById("searchResponderUnit").addEventListener("input", (e) => {
      const query = e.target.value.toLowerCase();
      const filtered = allResponderUnits.filter(unit =>
        unit.unitName.toLowerCase().includes(query) ||
        unit.stationName.toLowerCase().includes(query)
      );

      renderResponderUnitTable(filtered);
    });

      
    assignResponderModalEl.addEventListener("shown.bs.modal", fetchResponderUnits);
    
    let autoShowResponderPersonnelModal = false; // Toggle this if needed later

    assignResponderModalEl.addEventListener("hidden.bs.modal", function () {
      if (autoShowResponderPersonnelModal && !suppressPersonnelModal) {
        const personnelModal = new bootstrap.Modal(responderPersonnelModalEl);
        personnelModal.show();
      }
    
      suppressPersonnelModal = false;
    });
    

    let allArchivedUnits = []; // Cache for search

    function fetchArchivedResponderUnits() {
      const tableBody = document.getElementById("archivedResponderUnitList");
      if (!tableBody) return;

      const responderUnitRef = firebase.database().ref("responder_unit");
      const usersRef = firebase.database().ref("users");
      const stationsRef = firebase.database().ref("emergency_responder_station");

      const currentUser = firebase.auth().currentUser;
      if (!currentUser) {
        console.warn("⚠️ No user signed in.");
        return;
      }

      const currentUID = currentUser.uid;

      Promise.all([usersRef.once("value"), stationsRef.once("value")])
        .then(([usersSnapshot, stationsSnapshot]) => {
          const users = usersSnapshot.val() || {};
          const stations = stationsSnapshot.val() || {};

          responderUnitRef.on("value", (snapshot) => {
            allArchivedUnits = [];

            snapshot.forEach((childSnapshot) => {
              const unit = childSnapshot.val();

              // Filter: Only Archived + created_by matches signed-in user
              if (unit.unit_Status !== "Archived" || unit.unit_Assign !== currentUID) return;

              const userUID = unit.station_ID;
              const userData = users[userUID];
              const stationId = userData?.station_id;
              const stationData = stationId ? stations[stationId] : null;
              const stationName = stationData?.station_name || "N/A";

              allArchivedUnits.push({
                unitId: childSnapshot.key,
                unitName: unit.unit_Name || "Unnamed Unit",
                stationName
              });
            });

            renderArchivedUnitTable(allArchivedUnits);
          });
        })
        .catch((error) => {
          console.error("❌ Error loading archived units:", error);
          tableBody.innerHTML = `<tr><td colspan="3">Error loading archived units.</td></tr>`;
        });
    }

    function renderArchivedUnitTable(units) {
      const tableBody = document.getElementById("archivedResponderUnitList");
      tableBody.innerHTML = "";

      if (!units.length) {
        tableBody.innerHTML = `<tr><td colspan="3">No archived units found.</td></tr>`;
        return;
      }

      units.forEach(unit => {
        tableBody.innerHTML += `
          <tr>
            <td>${unit.unitName}</td>
            <td>${unit.stationName}</td>
            <td>
              <button class="btn btn-sm btn-success" onclick="activateUnit('${unit.unitId}')">Activate</button>
            </td>
          </tr>
        `;
      });
    }

    document.getElementById("searchArchivedUnit").addEventListener("input", (e) => {
      const query = e.target.value.toLowerCase();
      const filtered = allArchivedUnits.filter(unit =>
        unit.unitName.toLowerCase().includes(query) ||
        unit.stationName.toLowerCase().includes(query)
      );

      renderArchivedUnitTable(filtered);
    });

    
      
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
});
  