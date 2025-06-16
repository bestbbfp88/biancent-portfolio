document.addEventListener("DOMContentLoaded", () => {
  // 🔗 DOM References
  const assignablePersonnelList = document.getElementById("assignablePersonnelList");
  const assignPersonnelModalEl = document.getElementById("assignResponderPersonnelModal");
  const assignPersonnelForm = document.getElementById("assignPersonnelForm");
  const selectAllCheckbox = document.getElementById("selectAllCheckbox");

  // 🆔 Track selected unit
  let selectedUnitToAssign = null;

  // 🔘 Triggered by Assign button
  window.assignUnit = function(unitId) {
    selectedUnitToAssign = unitId;
    loadAssignablePersonnel();
    const modal = new bootstrap.Modal(assignPersonnelModalEl);
    modal.show();
  };

  // 📥 Load personnel who have no unit_ID
  function loadAssignablePersonnel() {
    const user = firebase.auth().currentUser;
    if (!user) {
      console.warn("⚠️ No user signed in.");
      return;
    }
  
    const currentUID = user.uid;
    const ref = firebase.database().ref("responder_personnel");
  
    ref.once("value").then(snapshot => {
      assignablePersonnelList.innerHTML = "";
  
      snapshot.forEach(child => {
        const data = child.val();
        const id = child.key;
  
        // ✅ Only show personnel created by this user
        if (data.created_by !== currentUID) return;
  
        const isUnassigned = !data.unit_ID || data.unit_ID === null;
        const isAssignedToThisUnit = data.unit_ID === selectedUnitToAssign;
  
        if (isUnassigned || isAssignedToThisUnit) {
          const row = document.createElement("tr");
          row.innerHTML = `
            <td>
              <input type="checkbox" class="personnel-checkbox" value="${id}" ${isAssignedToThisUnit ? 'checked' : ''} />
            </td>
            <td>${data.erp_fname} ${data.erp_lname}</td>
            <td>${data.erp_Contact}</td>
          `;
          assignablePersonnelList.appendChild(row);
        }
      });
  
      if (assignablePersonnelList.children.length === 0) {
        assignablePersonnelList.innerHTML = `<tr><td colspan="3">No available personnel found.</td></tr>`;
      }
    });
  }
  

  // 🔁 Select All Functionality
  selectAllCheckbox.addEventListener("change", function () {
    const isChecked = this.checked;
    document.querySelectorAll(".personnel-checkbox").forEach((box) => {
      box.checked = isChecked;
    });
  });

  // ✅ Submit Assigned Personnel
  assignPersonnelForm.addEventListener("submit", async (e) => {
      e.preventDefault();
    
      const checkboxes = document.querySelectorAll(".personnel-checkbox");
      const updates = {};
      let atLeastOneChecked = false;
    
      checkboxes.forEach((checkbox) => {
        const personnelId = checkbox.value;
        const isChecked = checkbox.checked;
    
        if (isChecked) atLeastOneChecked = true;
    
        updates[`responder_personnel/${personnelId}/unit_ID`] = isChecked ? selectedUnitToAssign : null;
      });
    
      // ⚠️ If no one is selected, confirm the action
      if (!atLeastOneChecked) {
        const confirmUnassign = confirm("⚠️ You have unassigned all personnel from this unit. Are you sure?");
        if (!confirmUnassign) return;
      }
    
      try {
        await firebase.database().ref().update(updates);
        alert("✅ Personnel assignments updated!");
        bootstrap.Modal.getInstance(assignPersonnelModalEl).hide();
        assignPersonnelForm.reset();
        loadAssignablePersonnel(); // Optional: Refresh personnel list
      } catch (error) {
        console.error("❌ Failed to update assignments:", error);
        alert("❌ Error updating assignments.");
      }
    });
    


  // DOM References
const assignResponderModalEl = document.getElementById("assignResponderModal");

// Hide AssignResponderModal when AssignPersonnelModal is opened
assignPersonnelModalEl.addEventListener("show.bs.modal", () => {
const assignModalInstance = bootstrap.Modal.getInstance(assignResponderModalEl);
if (assignModalInstance) assignModalInstance.hide();
});

// Hide AssignPersonnelModal when AssignResponderModal is opened
assignResponderModalEl.addEventListener("show.bs.modal", () => {
const personnelModalInstance = bootstrap.Modal.getInstance(assignPersonnelModalEl);
if (personnelModalInstance) personnelModalInstance.hide();
});

// Reopen assignResponderModal when assignResponderPersonnelModal is closed
assignPersonnelModalEl.addEventListener("hidden.bs.modal", () => {
  const assignModal = new bootstrap.Modal(assignResponderModalEl);
  assignModal.show();
});


});
