let currentUserRole = null; // Global variable for current user role

firebase.auth().onAuthStateChanged(async (user) => {
  if (user) {
    const userId = user.uid;
    const userRef = firebase.database().ref(`users/${userId}`);
    const snapshot = await userRef.once('value');

    if (snapshot.exists()) {
      const userData = snapshot.val();
      currentUserRole = userData.user_role || null;
      console.log("👤 Current User Role:", currentUserRole);
    } else {
      console.warn("⚠️ No user data found.");
    }
  } else {
    console.warn("⚠️ No user is signed in.");
  }
});


document.addEventListener("DOMContentLoaded", () => {
  console.log("Hello");
  const responderTableBody = document.getElementById("responderPersonnelList");
  const searchInput = document.getElementById("searchResponderPersonnel");
  const form = document.getElementById("addResponderForm");

  const responderIdInput = document.getElementById("responderId");
  const responderModalEl = document.getElementById("responderPersonnelModal");
  const addResponderModalEl = document.getElementById("addResponderModal");
  const responderModal = new bootstrap.Modal(responderModalEl);
  const addResponderModal = new bootstrap.Modal(addResponderModalEl);

  const title = document.getElementById("addResponderLabel");
  const submitBtn = document.getElementById("responderFormBtn");

  const successModalEl = document.getElementById("successModalpersonnel"); // ✅ Matches modal ID
  const successModal = new bootstrap.Modal(successModalEl);
  
  const successModalOkBtn = document.getElementById("successModalOkBtn");

  let allResponders = [];

  // Load personnel from Firebase
  async function loadResponderPersonnel() {
   
    const personnelRef = firebase.database().ref("responder_personnel");
    const usersRef = firebase.database().ref("users");
    const stationRef = firebase.database().ref("emergency_responder_station");
  
    personnelRef.on("value", async (snapshot) => {
      responderTableBody.innerHTML = "";
      allResponders = [];
  
      if (!snapshot.exists()) {
        responderTableBody.innerHTML = `<tr><td colspan="4">No responders found.</td></tr>`;
        return;
      }
  
      const personnelPromises = [];
  
      snapshot.forEach((child) => {
        const data = child.val();
        const id = child.key;
  
        if (data.erp_Status !== "Active") return;
  
        personnelPromises.push(resolveResponderDetails(data, id, usersRef, stationRef));
      });
  
      const resolvedResponders = await Promise.all(personnelPromises);
      allResponders = resolvedResponders;
      renderResponders(allResponders);
    });
  }
  
  async function resolveResponderDetails(data, id, usersRef, stationRef) {
    let stationName = "TaRSIER";
  
    if (data.created_by) {
      try {
        const userSnap = await usersRef.child(data.created_by).once("value");
  
        if (userSnap.exists()) {
          const user = userSnap.val();
          const stationId = user.station_id;
  
          if (stationId) {
            const stationSnap = await stationRef.child(stationId).once("value");
            if (stationSnap.exists()) {
              const station = stationSnap.val();
              stationName = station.station_name || "Unknown Station";
            }
          }
        }
      } catch (err) {
        console.warn("⚠️ Error resolving station for created_by:", data.created_by, err);
      }
    }
  
    return { id, ...data, resolved_station: stationName };
  }
  
  function renderResponders(data) {
    responderTableBody.innerHTML = "";
  
    if (data.length === 0) {
      responderTableBody.innerHTML = `<tr><td colspan="4">No matching personnel.</td></tr>`;
      return;
    }
  
    data.forEach((person) => {
      const row = document.createElement("tr");
  
      // Determine if buttons should be shown
      let showButtons = false;
  
      if (currentUserRole === "Admin") {
        showButtons = true; // Admin always sees buttons
      } else if (currentUserRole === "Resource Manager" && (!person.created_by || person.created_by === "")) {
        showButtons = true; // Resource Manager sees buttons only if TaRSIER (created_by is blank)
      }
  
      row.innerHTML = `
        <td>${person.erp_fname} ${person.erp_lname}</td>
        <td>${person.erp_Contact}</td>
        <td>${person.resolved_station}</td>
        <td>
          ${showButtons 
            ? `
            <button class="btn btn-outline-warning btn-sm archive-btn-personnel" data-id="${person.id}">Archive</button>
            <button class="btn btn-outline-danger btn-sm update-btn-personnel" data-id="${person.id}">Update</button>
            `
            : `<span class="text-muted">Restricted</span>`
          }
        </td>
      `;
  
      responderTableBody.appendChild(row);
    });
  
    attachEventListeners();
  }
  
  

  // Attach archive & update events
  function attachEventListeners() {
    
    document.querySelectorAll(".archive-btn-personnel").forEach((btn) => {
      btn.onclick = () => {
        const id = btn.dataset.id;
        document.getElementById("archiveResponderId").value = id;
        const archiveModal = new bootstrap.Modal(document.getElementById("archiveResponderModal"));
        archiveModal.show();
      };      
    });

    document.querySelectorAll(".update-btn-personnel").forEach((btn) => {
      btn.onclick = () => {
        const id = btn.dataset.id;
        const person = allResponders.find(p => p.id === id);
        if (!person) return;

        // Prefill form
        responderIdInput.value = person.id;
        document.getElementById("responderFName").value = person.erp_fname || "";
        document.getElementById("responderLName").value = person.erp_lname || "";
        document.getElementById("responderContact").value = person.erp_Contact || "";


        // Update labels
        title.textContent = "Update Emergency Responder Personnel";
        submitBtn.textContent = "Update Personnel";

        // Open modal (and hide main)
        addResponderModal.show();
      };
    });
  }

  // Handle form submit (Add or Update)
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const contactInput = document.getElementById("responderContact");
    const phoneError = document.getElementById("phoneError");
    
    const id = responderIdInput.value;
    const fName = document.getElementById("responderFName").value.trim();
    const lName = document.getElementById("responderLName").value.trim();
    const contact = document.getElementById("responderContact").value.trim();
    
    const selectedStationUID = document.getElementById("selectedStationUID").value;
     console.log("📤 Submitting with selected station:", selectedStationUID);

    if (!fName || !lName || !contact) {
      alert("Please fill in all required fields.");
      return;
    }

    const phoneRegex = /^\+63\d{10}$/;
    if (!phoneRegex.test(contact)) {
      contactInput.classList.add("is-invalid");
      phoneError.style.display = "block";
      return;
    } else {
      contactInput.classList.remove("is-invalid");
      phoneError.style.display = "none";
    }


    const data = {
      erp_fname: fName,
      erp_lname: lName,
      erp_Contact: contact,
      erp_Status: "Active",
      created_by: selectedStationUID,
      updatedAt: new Date().toISOString()
    };

    try {
      if (id) {
        await firebase.database().ref(`responder_personnel/${id}`).update(data);
        showSuccessModal("✅ Personnel updated successfully!");
      } else {
        data.createdAt = new Date().toISOString();
        await firebase.database().ref("responder_personnel").push(data);
        showSuccessModal("✅ Personnel added successfully!");
      }
    
      form.reset();
      responderIdInput.value = "";
      addResponderModal.hide();
    } catch (error) {
      console.error("Error saving personnel:", error);
      alert("❌ Failed to save personnel.");
    }
    
  });

  addResponderModalEl.addEventListener("show.bs.modal", async () => {
    const instance = bootstrap.Modal.getInstance(responderModalEl);
    if (instance) instance.hide();
  
    const responderCreatedForDiv = document.getElementById("responderCreatedForDiv");
    const responderCreatedFor = document.getElementById("responderCreatedFor");
    const selectedStationUID = document.getElementById("selectedStationUID");
  
    responderCreatedFor.innerHTML = "";
  
    if (currentUserRole === "Admin") {
      responderCreatedForDiv.style.display = "block"; // Show the field
      responderCreatedFor.disabled = false;
      responderCreatedFor.innerHTML = `<option value="" disabled selected>Select station</option>`;
  
      const stationRef = firebase.database().ref("emergency_responder_station");
      const snapshot = await stationRef.once("value");
      const stations = snapshot.val() || {};
  
      for (let id in stations) {
        const station = stations[id];
        const option = document.createElement("option");
        option.value = id;
        option.textContent = station.station_name;
        responderCreatedFor.appendChild(option);
      }
  
      selectedStationUID.value = "";
    } else if (currentUserRole === "Resource Manager") {
      responderCreatedForDiv.style.display = "none"; // Hide the whole field!
      responderCreatedFor.disabled = true;
      selectedStationUID.value = ""; // Assigned automatically to TaRSIER
    }
  });
  

  addResponderModalEl.addEventListener("hidden.bs.modal", () => {
    // Reset modal content
    form.reset();
    responderIdInput.value = "";
    title.textContent = "Add Emergency Responder Personnel";
    submitBtn.textContent = "Add Personnel";
  
    // ✅ Reopen responder modal after closing add modal
    const responderModal = new bootstrap.Modal(responderModalEl);
    responderModal.show();
  });
  

  searchInput.addEventListener("input", () => {
    const query = searchInput.value.toLowerCase().trim();
  
    const filtered = allResponders.filter((r) => {
      const fullName = `${r.erp_fname} ${r.erp_lname}`.toLowerCase();
      const contact = r.erp_Contact?.toLowerCase() || "";
      const station = r.resolved_station?.toLowerCase() || ""
      return fullName.includes(query) || contact.includes(query) || station.includes(query);
    });
  
    renderResponders(filtered);
  });
  

  // Load list when modal opens
  responderModalEl.addEventListener("shown.bs.modal", () => {
    loadResponderPersonnel();
  });


  successModalOkBtn.addEventListener("click", () => {
    // Attach before modal is dismissed to ensure it works
    console.log("1");
    const handler = () => {
      responderModal.show();
      successModalEl.removeEventListener("hidden.bs.modal", handler); // Clean up
      
    };
    successModalEl.addEventListener("hidden.bs.modal", handler);
  });
  
  document.getElementById("confirmArchiveBtn").addEventListener("click", async () => {
    const id = document.getElementById("archiveResponderId").value;
    if (!id) return;
  
    try {
      // Fetch personnel data first
      const snapshot = await firebase.database().ref(`responder_personnel/${id}`).once("value");
      const personnel = snapshot.val();
  
      // ❌ Check if assigned to a unit
      if (personnel && personnel.unit_ID) {
        alert("❌ Cannot archive personnel. Personnel is already assigned to a unit.");
        return;
      }
  
      // ✅ Proceed to archive if not assigned
      await firebase.database().ref(`responder_personnel/${id}`).update({ erp_Status: "Archived" });
  
      const modal = bootstrap.Modal.getInstance(document.getElementById("archiveResponderModal"));
      modal.hide();
  
      showSuccessModal("✅ Personnel archived successfully!");
  
    } catch (err) {
      console.error("❌ Error archiving:", err);
      alert("❌ Failed to archive personnel.");
    }
  });
   


  const archivedResponderModalEl = document.getElementById("archivedResponderModal");
  const archivedResponderList = document.getElementById("archivedResponderList");

  function loadArchivedPersonnel() {
    const ref = firebase.database().ref("responder_personnel");
  
    ref.once("value").then((snapshot) => {
      archivedResponderList.innerHTML = "";
      if (!snapshot.exists()) {
        archivedResponderList.innerHTML = `<tr><td colspan="3">No archived personnel found.</td></tr>`;
        return;
      }
  
      snapshot.forEach((child) => {
        const data = child.val();
        const id = child.key;
  
        if (data.erp_Status !== "Archived") return;
  
        const isScheduledForDeletion = !!data.delete_scheduled_at;
  
        const row = document.createElement("tr");
        row.innerHTML = `
          <td>${data.erp_fname} ${data.erp_lname}</td>
          <td>${data.erp_Contact}</td>
          <td>
            ${isScheduledForDeletion
              ? `<button class="btn btn-outline-secondary btn-sm cancel-delete-btn" data-id="${id}">Cancel Delete</button>`
              : `
                <button class="btn btn-success btn-sm activate-btn" data-id="${id}">Activate</button>
                <button class="btn btn-danger btn-sm delete-btn" data-id="${id}">Delete</button>
              `
            }
          </td>
        `;
        archivedResponderList.appendChild(row);
      });
  
      // ✅ Activate logic
      document.querySelectorAll(".activate-btn").forEach((btn) => {
        btn.onclick = () => {
          const id = btn.dataset.id;
          firebase.database().ref(`responder_personnel/${id}`).update({
            erp_Status: "Active",
            delete_scheduled_at: null
          }).then(() => {
            alert("✅ Personnel activated.");
            loadArchivedPersonnel();
          }).catch((err) => {
            console.error(err);
            alert("❌ Failed to activate personnel.");
          });
        };
      });
  
      // ✅ Schedule delete logic
      document.querySelectorAll(".delete-btn").forEach((btn) => {
        btn.onclick = () => {
          const id = btn.dataset.id;
          const twoDaysFromNow = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();
          firebase.database().ref(`responder_personnel/${id}`).update({
            delete_scheduled_at: twoDaysFromNow
          }).then(() => {
            alert("🗓️ Personnel scheduled for deletion in 2 days.");
            loadArchivedPersonnel();
          }).catch((err) => {
            console.error(err);
            alert("❌ Failed to schedule delete.");
          });
        };
      });
  
      // ✅ Cancel delete logic
      document.querySelectorAll(".cancel-delete-btn").forEach((btn) => {
        btn.onclick = () => {
          const id = btn.dataset.id;
          firebase.database().ref(`responder_personnel/${id}/delete_scheduled_at`).remove()
            .then(() => {
              alert("⛔ Deletion canceled.");
              loadArchivedPersonnel();
            })
            .catch((err) => {
              console.error(err);
              alert("❌ Failed to cancel deletion.");
            });
        };
      });
    });
  }
  

  // Load archived personnel when modal is opened
  archivedResponderModalEl.addEventListener("shown.bs.modal", () => {
    loadArchivedPersonnel();
  });

  // Reopen responderPersonnelModal after archived modal is closed
  archivedResponderModalEl.addEventListener("hidden.bs.modal", () => {
   
    const responderModal = new bootstrap.Modal(document.getElementById("responderPersonnelModal"));
    responderModal.show();
  });

  async function purgeExpiredPersonnel() {
    const now = new Date();
    const today = now.toISOString().split("T")[0]; // Format: YYYY-MM-DD
  
    const ref = firebase.database().ref("responder_personnel");
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
      console.log(`🗑️ Automatically deleted ${deletedCount} expired personnel.`);
    }
  }

  purgeExpiredPersonnel();

});

