let editingUnitId = null;
const assignPersonnelForm = document.getElementById("assignPersonnelForm");

// ✅ EDIT UNIT FUNCTION
window.editUnit = async function (unitId) {
    console.log(`🔍 Loading unit with ID: ${unitId}`);

    try {
        const snapshot = await firebase.database().ref(`responder_unit/${unitId}`).once("value");
        const unit = snapshot.val();

        console.log("✅ Retrieved unit data:", unit);

        if (!unit) {
            alert("⚠️ Unit not found!");
            return;
        }

        // 🛠️ Populate the form with unit data
        document.getElementById("unitNameEdit").value = unit.unit_Name || "";
        document.getElementById("unitAssignEdit").value = unit.unit_Assign || "";

        const stationSelect = document.getElementById("erStationEdit");
        const responderSelect = document.getElementById("responderUserEdit");

        // 🔥 Clear old values
        stationSelect.innerHTML = `<option value="">Loading stations...</option>`;
        responderSelect.innerHTML = `<option value="">Loading responders...</option>`;

        const unitAssign = unit.unit_Assign;
        const isTarsier = unitAssign === "TaRSIER Unit";

        console.log(`🛠️ Unit Assignment: ${unitAssign}, Is TaRSIER: ${isTarsier}`);

        // 🔥 Fetch Data
        const [usersSnapshot, stationsSnapshot, assignedSnapshot] = await Promise.all([
            firebase.database().ref("users").once("value"),
            firebase.database().ref("emergency_responder_station").once("value"),
            firebase.database().ref("responder_unit").once("value")
        ]);

        console.log("✅ Fetched users, stations, and assigned units");

        // ✅ Create a Set of assigned ER_IDs based on the same station and unit type
        const assignedERIDs = new Set();
        assignedSnapshot.forEach((snap) => {
            const assignedUnit = snap.val();

            if (
                assignedUnit.station_ID === unit.station_ID &&
                assignedUnit.unit_Assign === unitAssign &&
                assignedUnit.ER_ID
            ) {
                assignedERIDs.add(assignedUnit.ER_ID);
            }
        });

        console.log("✅ Assigned ER_IDs:", assignedERIDs);

        // ✅ STEP 1: Populate stations if not TaRSIER
        if (!isTarsier) {
            stationSelect.innerHTML = `<option value="">No station (Unassign)</option>`;  // ✅ Add unassign option

            usersSnapshot.forEach((userSnap) => {
                const user = userSnap.val();
                const uid = userSnap.key;

                if (user.user_role === "Emergency Responder Station") {
                    const stationId = user.station_id;
                    const stationData = stationsSnapshot.child(stationId).val();

                    if (!stationData) return;

                    if (stationData.station_type === unitAssign) {
                        const option = document.createElement("option");
                        option.value = uid;
                        option.textContent = `${stationData.station_name} - ${stationData.station_type}`;
                        stationSelect.appendChild(option);
                    }
                }
            });

            // ✅ Select the existing station or allow unassignment
            stationSelect.value = unit.station_ID || "";
        } else {
            // 🚫 If TaRSIER, disable station select
            stationSelect.innerHTML = `<option value="">Not required</option>`;
            stationSelect.disabled = true;
        }

        console.log("✅ Stations populated");

        // ✅ STEP 2: Populate responders (including null for unassign)
        responderSelect.innerHTML = `<option value="">No responder (Unassign)</option>`;

        usersSnapshot.forEach((child) => {
            const user = child.val();
            const uid = child.key;

            const isResponder = user.user_role === "Emergency Responder";
            const responderName = `${user.f_name || "NoName"} ${user.l_name || ""}`.trim();

            const sameStation = user.created_by === unit.station_ID;  
            const sameUnitType = user.responder_type === unitAssign;

            if (isTarsier) {
                if (isResponder && user.responder_type === "TaRSIER Responder") {
                    const option = document.createElement("option");
                    option.value = uid;
                    option.textContent = responderName;

                    if (assignedERIDs.has(uid) && uid !== unit.ER_ID) {
                        option.disabled = true;  
                        option.textContent += " (Assigned)";
                    }

                    responderSelect.appendChild(option);
                }
            } else {
                if (isResponder && (!unit.station_ID || sameStation) && sameUnitType) {
                    const option = document.createElement("option");
                    option.value = uid;
                    option.textContent = responderName;

                    if (assignedERIDs.has(uid) && uid !== unit.ER_ID) {
                        option.disabled = true;  
                        option.textContent += " (Assigned)";
                    }

                    responderSelect.appendChild(option);
                }
            }
        });

        console.log("✅ Responders populated");

        // ✅ Select the current responder or set to "no responder" if null
        responderSelect.value = unit.ER_ID || "";

        // Store unit ID for update
        document.getElementById("editResponderUnitForm").dataset.unitId = unitId;

        // ✅ Show the modal
        const modalInstance = new bootstrap.Modal(document.getElementById("editResponderUnitModal"));
        modalInstance.show();

        console.log(`✅ Modal shown for unit ID: ${unitId}`);

    } catch (e) {
        console.error("❌ Error loading unit for edit:", e);
    }
};

// ✅ SUBMIT FORM HANDLER
document.getElementById("editResponderUnitForm").addEventListener("submit", async (e) => {
    e.preventDefault();

    const unitId = e.target.dataset.unitId;
    console.log(`🛠️ Submitting form for unit ID: ${unitId}`);

    // ✅ Gather updated data
    const updatedUnit = {
        unit_Name: document.getElementById("unitNameEdit").value,
        unit_Assign: document.getElementById("unitAssignEdit").value,
        unit_Status: "Active",
        ER_ID: document.getElementById("responderUserEdit").value || null  
    };

    const stationId = document.getElementById("erStationEdit").value || null;
    updatedUnit.station_ID = stationId || null;  

    console.log("🔍 Updated unit data:", updatedUnit);

    try {
        // 🔥 Update the unit in Firebase
        console.log(`🔥 Updating Firebase for unit ID: ${unitId}`);
        await firebase.database().ref(`responder_unit/${unitId}`).update(updatedUnit);

        console.log("✅ Firebase update successful");

        // ✅ Show success message and hide modal
        showSuccessModal("✅ Responder Unit updated successfully!");

        const modalInstance = bootstrap.Modal.getInstance(document.getElementById("editResponderUnitModal"));
        if (modalInstance) {
            console.log("✅ Hiding modal...");
            modalInstance.hide();
        }

        // 🔄 Reload units if function exists
        if (typeof fetchResponderUnits === "function") {
            console.log("🔄 Reloading units...");
            fetchResponderUnits();
        }

    } catch (error) {
        console.error("❌ Failed to update unit:", error);
        alert("❌ Error updating unit. Please try again.");
    }
});
