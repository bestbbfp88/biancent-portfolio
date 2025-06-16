<!-- Emergency Responder Personnel Modal -->
<div class="modal fade" id="responderPersonnelModal" tabindex="-1" aria-labelledby="responderPersonnelLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title w-100 text-center fw-bold" id="responderPersonnelLabel">Emergency Responder Personnel</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <!-- Action Buttons -->
                <div class="d-flex flex-column flex-md-row justify-content-between gap-2 align-items-start mb-3">
                    <div class="d-flex gap-2 flex-wrap">
                        <button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#addResponderModal">
                        <i class="fas fa-plus me-1"></i> Add Personnel
                        </button>
                        <button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#assignResponderModal">
                        <i class="fas fa-user-plus me-1"></i> Assign Personnel
                        </button>
                        <button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#archivedResponderModal">
                        <i class="fas fa-box-archive me-1"></i> Archived Emergency Personnel
                        </button>
                    </div>

                    <!-- Search input spacing fixed -->
                    <div class="w-100 mt-2 mt-md-0" style="max-width: 300px;">
                        <input type="text" class="form-control" placeholder="Search..." id="searchResponderPersonnel">
                    </div>
                </div>


                <!-- Table -->
                <div class="table-responsive">
                    <table class="table table-hover align-middle text-center">
                        <thead class="table-light">
                            <tr>
                                <th>Personnel</th>
                                <th>Contact Number</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="responderPersonnelList">
                            <!-- Dynamic rows will be injected here -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- Add/Update Responder Modal -->
<div class="modal fade" id="addResponderModal" tabindex="-1" aria-labelledby="addResponderLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addResponderLabel">Add Emergency Responder Personnel</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <form id="addResponderForm">
          <!-- Hidden ID for update -->
          <input type="hidden" id="responderId">

          <div class="mb-3">
            <label for="responderFName" class="form-label">First Name</label>
            <input type="text" class="form-control" id="responderFName" required>
          </div>

          <div class="mb-3">
            <label for="responderLName" class="form-label">Last Name</label>
            <input type="text" class="form-control" id="responderLName" required>
          </div>

          <div class="mb-3">
            <label for="responderContact" class="form-label">Phone Number</label>
            <input type="tel" class="form-control" id="responderContact" name="responderContact" placeholder="+639123456789" required>
            <div class="invalid-feedback" id="phoneError">Please enter a valid phone number in +63 format.</div>
          </div>

          <div class="text-end">
            <button type="submit" class="btn btn-primary" id="responderFormBtn">Add Personnel</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>


<!-- Success Modal -->
<div class="modal fade" id="successModalpersonnel" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true" style="z-index:2000">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow rounded-4">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="successModalLabel">Success</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center">
        <p id="successModalMessage" class="fs-5 mb-3">✔️ Operation completed successfully!</p>
        <button id="successModalOkBtn" class="btn btn-success" data-bs-dismiss="modal">OK</button>
      </div>
    </div>
  </div>
</div>

<!-- Archive Confirmation Modal -->
<div class="modal fade" id="archiveResponderModal" tabindex="-1" aria-labelledby="archiveResponderModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content rounded-4">
      <div class="modal-header bg-warning">
        <h5 class="modal-title" id="archiveResponderModalLabel">Confirm Archive</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body text-center">
        <p class="fs-5">Are you sure you want to archive this personnel?</p>
        <input type="hidden" id="archiveResponderId"> <!-- store responder ID -->
      </div>
      <div class="modal-footer justify-content-center">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger" id="confirmArchiveBtn">Yes, Archive</button>
      </div>
    </div>
  </div>
</div>

<!-- Archived Emergency Personnel Modal -->
<div class="modal fade" id="archivedResponderModal" tabindex="-1" aria-labelledby="archivedResponderLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title w-100 text-center fw-bold" id="archivedResponderLabel">Archived Emergency Personnel</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <!-- Table -->
        <div class="table-responsive">
          <table class="table table-hover align-middle text-center">
            <thead class="table-light">
              <tr>
                <th>Personnel</th>
                <th>Contact Number</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="archivedResponderList">
              <!-- Dynamic archived responders -->
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>


