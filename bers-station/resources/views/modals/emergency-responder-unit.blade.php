<!-- Assign Emergency Responder Unit Modal -->
<div class="modal fade" id="assignResponderModal" tabindex="-1" aria-labelledby="assignResponderLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title w-100 text-center fw-bold" id="assignResponderLabel">Assign Emergency Responder Unit</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <!-- Actions -->
        <div class="d-flex justify-content-between flex-column flex-md-row gap-2 mb-3">
        <!-- Buttons with spacing -->
        <div class="d-flex flex-column gap-2">
        <button class="btn btn-secondary" data-bs-dismiss="modal" data-bs-toggle="modal" data-bs-target="#addResponderUnitModal">
          <i class="fas fa-plus me-1"></i> Add Emergency Responder Unit
        </button>

            <button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#archivedResponderUnitModal">
            <i class="fas fa-box-archive me-1"></i> Archived Emergency Responder Unit
            </button>
        </div>

        <!-- Search input -->
        <div style="max-width: 300px;">
            <input type="text" class="form-control" id="searchResponderUnit" placeholder="Search unit...">
        </div>
        </div>


        <!-- Table -->
        <div class="table-responsive">
          <table class="table table-hover align-middle text-center">
            <thead class="table-light">
              <tr>
                <th>Unit Name</th>
                <th>Station</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="responderUnitList">
              <!-- Injected via JS -->
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>


<div class="modal fade" id="addResponderUnitModal" tabindex="-1" aria-labelledby="addResponderUnitLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addResponderUnitLabel">Add Emergency Responder Unit</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <form id="addResponderUnitForm">
          <div class="mb-3">
            <label for="unitName" class="form-label">Name</label>
            <input type="text" class="form-control" id="unitName" required />
          </div>

            <div class="mb-3">
              <label for="responderUser" class="form-label">Emergency Responder</label>
              <select class="form-select" id="responderUser" required>
                <option value="">Select Responder</option>
              </select>
            </div>

            <div class="text-end">
              <button type="submit" class="btn btn-primary">Add Unit</button>
            </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Archived Emergency Responder Unit Modal -->
<div class="modal fade" id="archivedResponderUnitModal" tabindex="-1" aria-labelledby="archivedResponderUnitLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title w-100 text-center fw-bold" id="archivedResponderUnitLabel">Archived Emergency Responder Units</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <!-- Search Input -->
        <div class="d-flex justify-content-end mb-3" style="max-width: 300px;">
          <input type="text" class="form-control" id="searchArchivedUnit" placeholder="Search archived unit...">
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="table table-hover align-middle text-center">
            <thead class="table-light">
              <tr>
                <th>Unit Name</th>
                <th>Station</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="archivedResponderUnitList">
              <!-- Populated via JS -->
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>


<div class="modal fade" id="editResponderUnitModal" tabindex="-1" aria-labelledby="editResponderUnitLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="editResponderUnitLabel">Edit Emergency Responder Unit</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <form id="editResponderUnitForm">
          <div class="mb-3">
            <label for="unitNameEdit" class="form-label">Name</label>
            <input type="text" class="form-control" id="unitNameEdit" required />
          </div>

          <div class="mb-3">
            <label for="unitAssignEdit" class="form-label">Unit Assignment</label>
            <select class="form-select" id="unitAssignEdit" required>
              <option value="">Select Assignment</option>
              <option value="PNP">PNP</option>
              <option value="BFP">BFP</option>
              <option value="Coast Guard">Coast Guard</option>
              <option value="MDRRMO">MDRRMO</option>
              <option value="TaRSIER Unit">TaRSIER</option>
            </select>
          </div>

          <div class="mb-3" id="erStationEditGroup">
            <label for="erStationEdit" class="form-label">Emergency Responder Station</label>
            <select class="form-select" id="erStationEdit" >
              <option value="">Select Station</option>
            </select>
          </div>

          <div class="mb-3">
            <label for="responderUserEdit" class="form-label">Emergency Responder</label>
            <select class="form-select" id="responderUserEdit">
              <option value="">Select Responder</option>
            </select>
          </div>

          <div class="text-end">
            <button type="submit" class="btn btn-primary">Update Unit</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>


<!-- Archive Confirmation Modal -->
<div class="modal fade" id="archiveConfirmModal" tabindex="-1" aria-labelledby="archiveConfirmLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content text-center">
      <div class="modal-header">
        <h5 class="modal-title text-danger" id="archiveConfirmLabel">Archive Unit</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        Are you sure you want to archive this unit?
      </div>
      <div class="modal-footer justify-content-center">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No</button>
        <button type="button" class="btn btn-danger" id="confirmArchiveBtnUnit">Yes</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="assignResponderPersonnelModal" tabindex="-1" aria-labelledby="assignResponderPersonnelLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title w-100 text-center fw-bold" id="assignResponderPersonnelLabel">Assign Responder Personnel</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <form id="assignPersonnelForm">
          <div class="table-responsive">
            <table class="table table-hover align-middle text-center">
              <thead class="table-light">
                <tr>
                  <th><input type="checkbox" id="selectAllCheckbox" /></th>
                  <th>Name</th>
                  <th>Contact</th>
                </tr>
              </thead>
              <tbody id="assignablePersonnelList">
                <!-- Injected via JS -->
              </tbody>
            </table>
          </div>

          <div class="text-end mt-3">
            <button type="submit" class="btn btn-primary">Assign Selected</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

