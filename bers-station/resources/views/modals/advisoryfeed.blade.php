<!-- Create Advisory Modal -->
<div class="modal fade" id="advisoryModal" tabindex="-1" aria-labelledby="advisoryModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content rounded-4 shadow-lg">

      <!-- Header -->
      <div class="modal-header bg-primary text-white rounded-top-4">
        <h6 class="modal-title fw-bold" id="advisoryModalLabel">Create Advisory</h6>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <!-- Body -->
      <div class="modal-body p-4">

        <!-- Error Container -->
        <div id="advisoryErrorContainer" class="alert alert-danger d-none rounded-3">
          <ul id="advisoryErrorList" class="mb-0"></ul>
        </div>

        <form id="advisoryForm" enctype="multipart/form-data" class="d-flex flex-column gap-3">

          <!-- Headline Input -->
          <input type="text" class="form-control rounded-3 shadow-sm" id="advisoryHeadline" name="headline" placeholder="Enter advisory headline" required>

          <!-- Message Input -->
          <textarea class="form-control rounded-3 shadow-sm" id="advisoryMessage" name="message" rows="3" placeholder="Tell us about your thoughts..." required></textarea>

          <!-- End Date Input -->
          <div>
            <label for="advisoryEndDate" class="form-label fw-semibold">End Date</label>
            <input type="date" class="form-control rounded-3 shadow-sm" id="advisoryEndDate" name="end_date" required>
          </div>

          <!-- Image Preview Section -->
          <div class="d-flex flex-wrap gap-2" id="imagePreviewContainer"></div>

          <!-- File Preview Section -->
          <div id="filePreviewContainer"></div>

          <!-- Hidden File Inputs -->
          <input type="file" id="advisoryImageInput" name="image" accept="image/*" class="d-none">
          <input type="file" id="advisoryFileInput" name="attachments" accept=".pdf,.doc,.docx,.txt,.xls,.xlsx,.zip" class="d-none" multiple>

        </form>

      </div>

      <!-- Footer -->
      <div class="modal-footer d-flex justify-content-between p-3 rounded-bottom-4">
        <div class="d-flex gap-2">
          <button type="button" class="btn btn-outline-primary rounded-pill" id="advisoryImageButton">📷 Picture/Video</button>
          <button type="button" class="btn btn-outline-primary rounded-pill" id="advisoryFileButton">📎 Attachments</button>
        </div>
        <button type="button" id="submitAdvisoryButton" class="btn btn-primary rounded-pill px-4">Post</button>
      </div>

    </div>
  </div>
</div>




<!--  Success Modal -->
    <div id="successAdvisoryModal" class="success-modal hidden fixed inset-0 flex justify-center items-center">
        <div class="success-modal-content">
            <h2 class="success-message">Advisory Posted Successfully!</h2>
        </div>
    </div>

<!-- End Create Account-->

<!-- Active Advisories Modal -->
    <div id="activeAdvisoryModal" class="modal fade" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
            <!-- Header -->
            <div class="modal-header" style="background-color: #1E293B; color: white; position: sticky; top: 0; z-index: 1050;">
                <h5 class="modal-title">Active Advisories</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <!-- Body (Scrollable) -->
            <div class="modal-body overflow-auto" style="max-height: 70vh;">
                <input type="text" id="searchAdvisories" class="form-control mb-3" placeholder="Search by headline or creator">

                <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th>Headline</th>
                        <th>Creator</th>
                        <th>Posted Date</th>
                        <th>Days Left</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody id="activeAdvisoryList">
                    <!-- Dynamically loaded -->
                    </tbody>
                </table>
                </div>
            </div>
            </div>
        </div>
    </div>

<!-- End Active Advisories Modal -->

<!-- View Advisory Modal -->
    <div id="viewAdvisoryModal" class="view-advisory hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center transition-opacity duration-300 ease-in-out">
        <div class="view-advisory-content bg-white rounded-xl shadow-2xl w-4/5 max-w-3xl relative overflow-hidden transform scale-95 transition-transform duration-300 ease-in-out p-6 flex flex-col items-center">
            
            <!-- Image Container (Centered) -->
            <div id="viewModalImageContainer" class="relative w-full max-h-[300px] flex justify-center items-center bg-gray-200 rounded-lg overflow-hidden shadow-lg">
                <img id="viewModalImage" src="" alt="Advisory Image" class="w-full object-cover rounded-lg">
                
                <!-- Headline (Overlay on Image, Bottom-Left) -->
                <div class="absolute bottom-4 left-4 bg-black bg-opacity-40 text-white text-sm font-semibold px-4 py-2 rounded-lg shadow-md">
                    <h2 id="viewModalHeadline" class="uppercase tracking-wide"></h2>
                </div>
            </div>

            <!-- Creator (After Image) -->
            <div class="w-full mt-4 self-start">
                <p class="text-gray-600 text-lg font-medium">
                    Created by: <span id="viewModalCreator" class="text-gray-900 font-semibold"></span>
                </p>

                <p class="text-gray-600 mt-1 text-lg font-medium">
                    Created on: <span id="viewModalCreation" class="text-gray-900 font-semibold"></span>
                </p>
            </div>

            <!-- Message (Below Creator) -->
            <div class="mt-3 text-left w-full px-2">
                <p class="text-gray-800 text-lg font-medium">Advisory Message:</p>
                <p id="viewModalMessage" class="text-gray-700 mt-1 px-4"></p>
            </div>


            <!-- Close Button (Top Right) -->
            <button id="closeButton" class="absolute top-4 right-4 text-white bg-gray-700 hover:bg-gray-900 p-2 rounded-full transition duration-300">
                <i class="fas fa-times text-xl"></i>
            </button>
        </div>
    </div>

<!-- End View Advisory Modal -->


<!-- Update Advisory Modal -->
<div class="modal fade" id="updateAdvisoryModal" tabindex="-1" aria-labelledby="updateAdvisoryModalLabel">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content rounded-4 shadow-lg">

      <!-- Header -->
      <div class="modal-header bg-primary text-white rounded-top-4">
        <h6 class="modal-title fw-bold" id="updateAdvisoryModalLabel">Update Advisory</h6>
        <button type="button" class="btn-close btn-close-white ms-auto" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <!-- Body -->
      <div class="modal-body p-4">

        <!-- Error Container -->
        <div id="updateAdvisoryErrorContainer" class="alert alert-danger d-none rounded-3">
          <ul id="updateAdvisoryErrorList" class="mb-0"></ul>
        </div>

        <form id="updateAdvisoryForm" enctype="multipart/form-data" class="d-flex flex-column gap-3">
          <input type="hidden" id="updateAdvisoryId" name="id"> <!-- Hidden ID field -->

          <!-- Headline Input -->
          <input type="text" class="form-control rounded-3 shadow-sm" id="updateAdvisoryHeadline" name="headline" placeholder="Enter advisory headline" required>

          <!-- Message Input -->
          <textarea class="form-control rounded-3 shadow-sm" id="updateAdvisoryMessage" name="message" rows="3" placeholder="Tell us about your thoughts?" required></textarea>
            <!-- End Date Input -->
            <div>
            <label for="updateAdvisoryEndDate" class="form-label fw-semibold">End Date</label>
            <input type="date" class="form-control rounded-3 shadow-sm" id="updateAdvisoryEndDate" name="end_date" required>
            </div>

          <!-- Image Preview Section -->
          <div class="d-flex flex-wrap gap-2" id="updateImagePreviewContainer"></div>

          <!-- File Preview Section -->
          <div id="updateFilePreviewContainer"></div>

          <!-- Hidden File Inputs -->
          <input type="file" id="updateAdvisoryImage" name="image" accept="image/*" class="d-none">
          <input type="file" id="updateAdvisoryFile" name="attachments" accept=".pdf,.doc,.docx,.txt,.xls,.xlsx,.zip" class="d-none" multiple>
        </form>

      </div>

      <!-- Footer -->
      <div class="modal-footer d-flex justify-content-between p-3 rounded-bottom-4">
        <div class="d-flex gap-2">
          <button type="button" class="btn btn-outline-primary rounded-pill" id="updateAdvisoryImageButton">📷 Picture/Video</button>
          <button type="button" class="btn btn-outline-primary rounded-pill" id="updateAdvisoryFileButton">📎 Attachments</button>
        </div>
        <button type="button" id="submitUpdatebtnAdvisory" class="btn btn-primary rounded-pill px-4">Update</button>
      </div>

    </div>
  </div>
</div>

    <!-- Success Advisory Update Modal -->
    <div class="modal fade" id="successAdvisoryUpdateModal" tabindex="-1" aria-labelledby="successAdvisoryUpdateModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successAdvisoryUpdateModalLabel">Success</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <h2>Advisory activated successfully! ✅</h2>
                </div>
            </div>
        </div>
    </div>
<!-- End Update Advisory Modal -->


<!-- Archive Advisory Modal -->
    <div class="modal fade" id="confirmArchiveModal" tabindex="-1" aria-labelledby="confirmArchiveModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header text-dark">
                    <h5 class="modal-title" id="confirmArchiveModalLabel">Warning!</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <p>Are you sure you want to archive this advisory?</p>
                    <div class="mt-3">
                        <button id="confirmArchive-btn" class="btn btn-danger">Yes</button>
                        <button class="btn btn-secondary" data-bs-dismiss="modal">No</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Archive Advisory Modal -->
    <div class="modal fade" id="successArchiveModal" tabindex="-1" aria-labelledby="successArchiveModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successArchiveModalLabel">Success</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <h2 class="text-success">Advisory Archived Successfully! ✅</h2>
                </div>
            </div>
        </div>
    </div>

<!-- End Archive Advisory Modal -->


<!-- Deactivated Advisories Modal -->
    <div id="deactivatedAdvisoryModal" class="modal fade" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
            <!-- Header -->
            <div class="modal-header" style="background-color: #1E293B; color: white;">
                <h5 class="modal-title">Deactivated Advisories</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <!-- Body -->
            <div class="modal-body">
                <input type="text" id="searchAdvisoryDeactivated" class="form-control mb-3" placeholder="Search by title or creator">
                
                <table class="table table-striped">
                <thead>
                    <tr>
                    <th>Headline</th>
                    <th>Posted Date</th>
                    <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="deactivatedAdvisoryTableBody">
                    <!-- Dynamically loaded content -->
                </tbody>
                </table>
            </div>
            </div>
        </div>
    </div>


    <div id="confirmAdvisoryActivateModal" class="confirmmodaladvisory">
            <div class="confirm-modal-content-advisory">
                <span class="close-btn-advisory" id="close-confirm-modal-advisory">&times;</span>
                <h2>Warning!</h2>
                <p>Are you sure you want to activate this advisory?</p>
                <div class="modal-actions-advisory">
                <button class="confirm-btn-advisory" id="confirmActivateBtn-advisory">Yes</button>
                    <button class="cancel-btn-advisory" id="cancel-confirm-modal-advisory">No</button>
                </div>
            </div>
    </div>

    <!-- Success Modal -->
    <div id="successAdvisoryActivateModal" class="confirmmodaladvisory">
        <div class="confirm-modal-content-advisory">
            <span class="close-btn-advisory " id="close-success-modal-advisory">&times;</span>
            <h2>Advisory activated successfully!</h2>
        </div>
    </div>


    <div id="confirmDeleteModalAdvisory" class="modal fade" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">Confirm Delete</h5>
                    <button type="button" class="btn-close" id="close-delete-modal-advisory"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this advisory? Deletion will take up to 2 days to fully remove all data.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="cancel-delete-modal-advisory">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn-advisory">Delete</button>
                </div>
            </div>
        </div>
    </div>


<!-- End Deactivated Advisories Modal -->

<!-- Advisory Approval Modal -->
<div class="modal fade" id="advisoryApprovalModal" tabindex="-1" aria-labelledby="advisoryApprovalModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background-color: #1E293B; color: white;">
                <h5 class="modal-title" id="advisoryApprovalModalLabel">Pending Advisories</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="text" id="searchAdvisoryApproval" class="form-control mb-3" placeholder="Search advisory...">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Creator</th>
                                <th>Headline</th>
                                <th>Created At</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="advisoryApprovalTableBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Confirm Approval Modal -->
<div id="advisoryConfirmApprovalModal" class="modal fade">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-center">
            <div class="modal-header bg-warning text-white">
                <h5 class="modal-title">Confirm Approval</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to approve this advisory?</p>
                <button class="btn btn-success" id="advisoryConfirmApproveBtn">Yes</button>
                <button class="btn btn-secondary" data-bs-dismiss="modal">No</button>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Success Approval Modal -->
<div id="advisorySuccessApprovalModal" class="modal fade">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-center">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title">Approved</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Advisory approved successfully!</p>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Confirm Rejection Modal -->
<div id="advisoryConfirmRejectModal" class="modal fade">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-center">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirm Rejection</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to reject this advisory?</p>
                <button class="btn btn-danger" id="advisoryConfirmRejectBtn">Yes</button>
                <button class="btn btn-secondary" data-bs-dismiss="modal">No</button>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Success Rejection Modal -->
<div id="advisorySuccessRejectModal" class="modal fade">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-center">
            <div class="modal-header bg-secondary text-white">
                <h5 class="modal-title">Rejected</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Advisory rejected successfully!</p>
            </div>
        </div>
    </div>
</div>

