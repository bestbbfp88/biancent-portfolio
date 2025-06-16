<!-- Hospital Management Modal -->
<div class="modal fade hospital-modal" id="hospitalModal" tabindex="-1" aria-labelledby="hospitalModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header hospital-modal-header">
                <h5 class="modal-title hospital-modal-title" id="hospitalModalLabel">Hospital</h5>
                <button type="button" class="btn-close hospital-modal-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body hospital-modal-body">
                <div class="d-flex justify-content-between mb-3 hospital-modal-actions">
                    <button class="btn btn-secondary hospital-add-btn" data-bs-toggle="modal" data-bs-target="#addHospitalModal">+ Add Hospital</button>
                    <button class="btn btn-secondary hospital-archive-btn">Hospital Archive</button>
                    
                </div>
                <table class="table mt-3 hospital-table">
                    <thead>
                        <tr class="hospital-table-header">
                            <th>Institution</th>
                            <th>Address</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="hospitalList" class="hospital-table-body">
                        <!-- Dynamic rows will be added here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Hospital Modal -->
<div class="modal fade" id="addHospitalModal" tabindex="-1" aria-labelledby="addHospitalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addHospitalLabel">Add New Hospital</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="addHospitalForm" novalidate>
                    <div class="mb-3">
                        <label for="hospitalName" class="form-label">Hospital Name</label>
                        <input type="text" class="form-control" id="hospitalName" placeholder="Enter hospital name" required>
                        <div class="invalid-feedback" id="hospitalNameFeedback">Please enter a hospital name.</div>
                    </div>

                    <div class="mb-3">
                        <label for="hospitalAddress" class="form-label">Hospital Address (Enter Manually)</label>
                        <input type="text" class="form-control" id="hospitalAddress" placeholder="Enter hospital address" required>
                        <div class="invalid-feedback">Please enter the hospital address.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Contact Numbers</label>
                        <div id="contactNumbersContainer">
                            <!-- Initial input group -->
                            <div class="input-group mb-2">
                                <input type="text" class="form-control contact-number" name="contactNumbers[]" placeholder="Enter contact number" required>
                                <div class="invalid-feedback">Invalid contact number.</div>
                                <!-- The remove button will be shown only when more than one input is present -->
                                <button type="button" class="btn btn-danger remove-contact" style="display: none;">&times;</button>
                            </div>
                        </div>
                        <button type="button" class="btn btn-outline-primary mt-2" id="addContactNumber">
                            ➕ Add another number
                        </button>
                    </div>


                    <!-- Auto-generated Latitude & Longitude -->
                    <input type="hidden" id="hospitalLat" name="latitude">
                    <input type="hidden" id="hospitalLng" name="longitude">
                    
                    <button type="submit" class="btn btn-primary">Add Hospital</button>
                </form>
            </div>
        </div>
    </div>
</div>


<!-- View Hospital Modal -->
<div class="modal fade" id="viewHospitalModal" tabindex="-1" aria-labelledby="viewHospitalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="viewHospitalLabel">Hospital Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div>
                    <strong>Name:</strong> <span id="viewHospitalName"></span>
                </div>
                <div>
                    <strong>Address:</strong> <span id="viewHospitalAddress"></span>
                </div>
            
                <div class="mt-3">
                    <strong>Contact Numbers:</strong>
                    <ul id="viewHospitalContacts" class="list-group mt-2"></ul>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- Update Hospital Modal -->
    <div class="modal fade" id="updateHospitalModal" tabindex="-1" aria-labelledby="updateHospitalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="updateHospitalLabel">Update Hospital</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="updateHospitalForm">
                        <input type="hidden" id="updateHospitalId"> <!-- Hidden field for hospital ID -->

                        <div class="mb-3">
                            <label for="updateHospitalName" class="form-label">Hospital Name</label>
                            <input type="text" class="form-control" id="updateHospitalName" required>
                        </div>
                        <div class="mb-3">
                            <label for="updateHospitalAddress" class="form-label">Hospital Address</label>
                            <input type="text" class="form-control" id="updateHospitalAddress" required>
                        </div>
                        <div class="mb-3">
                            <label for="updateHospitalLat" class="form-label">Latitude</label>
                            <input type="text" class="form-control" id="updateHospitalLat" required>
                        </div>
                        <div class="mb-3">
                            <label for="updateHospitalLng" class="form-label">Longitude</label>
                            <input type="text" class="form-control" id="updateHospitalLng" required>
                        </div>

                        <!-- Contact Numbers -->
                        <div class="mb-3">
                            <label class="form-label">Contact Numbers</label>
                            <div id="updateContactNumbersContainer"></div>
                            <button type="button" class="btn btn-dark mt-2" id="addUpdateContactNumber">+</button>
                        </div>

                        <button type="submit" class="btn btn-primary">Update Hospital</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
<!-- End Update Hospital Modal -->

<!-- Archive Hospital Modal -->
    <div class="modal fade" id="archiveHospitalModal" tabindex="-1" aria-labelledby="archiveHospitalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header  text-dark">
                    <h5 class="modal-title" id="archiveHospitalLabel">Archive Hospital</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to archive this hospital?</p>
                    <input type="hidden" id="archiveHospitalId"> <!-- Stores the hospital ID -->
                    <button class="btn btn-danger" id="confirmHospitalArchivebtn">Yes</button>
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successModalLabel">Success</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <p>✅ The hospital has been successfully archived.</p>
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>
<!-- End Archive Hospital Modal -->

<!-- Archived Hospitals List Modal -->
<div class="modal fade" id="archivedHospitalsModal" tabindex="-1" style="z-index: 1100">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header ">
                <h5 class="modal-title modal-title hospital-modal-title">Archived Hospitals</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Institution</th>
                            <th>Address</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="archivedHospitalsTable"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

