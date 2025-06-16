document.addEventListener("DOMContentLoaded", () => {
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
  function loadResponderPersonnel() {
    firebase.auth().onAuthStateChanged((user) => {
      if (!user) {
        console.warn("⚠️ User not authenticated.");
        return;
      }
  
      const currentUID = user.uid;
      const ref = firebase.database().ref("responder_personnel");
  
      ref.on("value", (snapshot) => {
        responderTableBody.innerHTML = "";
        allResponders = [];
  
        if (snapshot.exists()) {
          snapshot.forEach((child) => {
            const data = child.val();
            const id = child.key;
  
            // ✅ Only include active personnel created by the logged-in user
            if (data.erp_Status === "Active" && data.created_by === currentUID) {
              allResponders.push({ id, ...data });
            }
          });
  
          renderResponders(allResponders);
        } else {
          responderTableBody.innerHTML = `<tr><td colspan="3">No responders found.</td></tr>`;
        }
      });
    });
  }
  
  // Render responders in the table
  function renderResponders(data) {
    responderTableBody.innerHTML = "";

    if (data.length === 0) {
      responderTableBody.innerHTML = `<tr><td colspan="3">No matching personnel.</td></tr>`;
      return;
    }

    data.forEach((person) => {
      const row = document.createElement("tr");
      row.innerHTML = `
        <td>${person.erp_fname} ${person.erp_lname}</td>
        <td>${person.erp_Contact}</td>
        <td>
          <button class="btn btn-outline-warning btn-sm archive-btn-personnel" data-id="${person.id}">Archive</button>
          <button class="btn btn-outline-danger btn-sm update-btn-personnel" data-id="${person.id}">Update</button>
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

    if (!fName || !lName || !contact) {
      alert("Please fill in all required fields.");
      return;
    }

    const user = firebase.auth().currentUser;
    if (!user) {
      alert("⚠️ You must be signed in to perform this action.");
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
      created_by: user.uid, // ✅ Set to authenticated user's UID
      updatedAt: new Date().toISOString()
    };


    try {
      if (id) {
        await firebase.database().ref(`responder_personnel/${id}`).update(data);
        showSuccessModal("✅ Personnel updated successfully!");
      } else {
        data.createdAt = new Date().toISOString();
        await firebase.database().ref("responder_personnel").push(data);
        console.log("🤖 Calling showSuccessModal...");

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

  // Modal events for chaining behavior
  addResponderModalEl.addEventListener("show.bs.modal", () => {
    const instance = bootstrap.Modal.getInstance(responderModalEl);
    if (instance) instance.hide();
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
  

  // Search handler
  searchInput.addEventListener("input", () => {
    const query = searchInput.value.toLowerCase().trim();
    const filtered = allResponders.filter((r) => {
      const fullName = `${r.f_name} ${r.l_name}`.toLowerCase();
      return fullName.includes(query);
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
    const user = firebase.auth().currentUser;
    if (!user) {
      console.warn("⚠️ User not signed in.");
      return;
    }
  
    const currentUID = user.uid;
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
  
        // ✅ Check if status is Archived AND created_by matches signed-in user
        if (data.erp_Status !== "Archived" || data.created_by !== currentUID) return;
  
        const row = document.createElement("tr");
        row.innerHTML = `
          <td>${data.erp_fname} ${data.erp_lname}</td>
          <td>${data.erp_Contact}</td>
          <td>
            <button class="btn btn-success btn-sm activate-btn" data-id="${id}">Activate</button>
          </td>
        `;
        archivedResponderList.appendChild(row);
      });
  
      // 🔄 Bind activate buttons
      document.querySelectorAll(".activate-btn").forEach((btn) => {
        btn.onclick = () => {
          const id = btn.dataset.id;
          firebase.database().ref(`responder_personnel/${id}`).update({ erp_Status: "Active" })
            .then(() => {
              alert("✅ Personnel activated.");
              loadArchivedPersonnel(); // refresh list
            })
            .catch((err) => {
              console.error(err);
              alert("❌ Failed to activate personnel.");
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


  

});
