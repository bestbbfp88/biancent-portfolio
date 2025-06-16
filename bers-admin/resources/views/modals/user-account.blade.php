<div id="account-modal" class="custom-modal">
    <div class="custom-modal-content">
        <span class="close-btn-modal" id="close-modal-btn">&times;</span>
        <h4>Create Account</h4>
        <hr class="my-3" style="height: 3px; background-color: #1E293B; border: none;">

        <form id="create-account-form" class="create-account-form">
            
            <!-- First Name & Last Name (Side by Side) -->
            <div class="form-group name-container" id="name-container">
                <div>
                    <label for="f_name">First Name</label>
                    <input type="text" id="f_name" name="f_name">
                    <span id="fname-error" class="error-message" style="color: red; display: none;">First name is required.</span>
                </div>
                <div>
                    <label for="l_name">Last Name</label>
                    <input type="text" id="l_name" name="l_name">
                    <span id="lname-error" class="error-message" style="color: red; display: none;">Last name is required.</span>
                </div>
            </div>

            <!-- Station Name (Shown only for Emergency Responder Station) -->
            <div class="form-group" id="station-name-container" style="display: none;">
                <label for="station_name">Station Name</label>
                <input type="text" id="station_name" name="station_name" placeholder="Enter Station Name">
                <span id="stationName-error" class="error-message" style="color: red; display: none;">Station name is required.</span>
            </div>

            <!-- Email -->
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required>
                <span id="email-error" class="error-message" style="color: red; display: none;">Invalid email address.</span>
            </div>

            <!-- Phone -->
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="tel" id="phone" placeholder="+63xxxxxxxxxx" name="phone" required>
                <span id="phone-error" style="color: red; font-size: 14px; display: none;">
                    Please enter a valid phone number starting with <strong>+63</strong> followed by 10 digits (e.g., <strong>+639123456789</strong>).
                </span>
            </div>

            <!-- Role Selection -->
            <div class="form-group">
                <label for="role">Select Role</label>
                <select id="role" name="role" required>
                    <option value="" disabled selected>Select a Role</option>
                    <option value="Communicator">TaRSIER 117 Communicator</option>
                    <option value="Emergency Responder">Emergency Responder</option>
                    <option value="Emergency Responder Station">Emergency Responder Station</option>
                    <option value="Resource Manager">Resource Manager</option>
                </select>
                <span id="role-error" class="error-message" style="color: red; display: none;">Please select a role.</span>
            </div>

            <!-- Emergency Responder Type (Shown for Emergency Responder) -->
            <div class="form-group" id="responder-type-container" style="display: none;">
                <label for="responder-type">Emergency Responder Type</label>
                <select id="responder-type" name="responder_type">
                    <option value="" disabled selected>Select Type</option>
                    <option value="PNP">LGU Responder: PNP</option>
                    <option value="BFP">LGU Responder: BFP</option>
                    <option value="Coast Guard">LGU Responder: Coast Guard</option>
                    <option value="MDRRMO">LGU Responder: MDRRMO</option>
                    <option value="TaRSIER Responder">TaRSIER 117 Responder</option>
                </select>
                <span id="responder-type-error" class="error-message" style="color: red; display: none;">Please select a Responder Type.</span>
            </div>

            <!-- LGU Responder Station Dropdown (Shown for LGU Responder) -->
            <div class="form-group" id="lgu-station-container" style="display: none;">
                <label for="lgu-station">Select LGU Responder Station</label>
                <select id="lgu-station" name="lgu_station">
                    <option value="" disabled selected>Select LGU Responder Station</option>
                </select>
                <p id="lgu-station-error" style="color: red; font-size: 14px; display: none;">Please select an LGU Responder Station.</p>
            </div>

            <!-- Emergency Responder Station Fields -->
            <div id="station-fields-container" style="display: none;">
                
                <!-- Station Type -->
                <div class="form-group">
                    <label for="station-type">Station Type</label>
                    <select id="station-type" name="station_type">
                        <option value="" disabled selected>Select Station Type</option>
                        <option value="PNP">PNP</option>
                        <option value="BFP">BFP</option>
                        <option value="Coast Guard">Coast Guard</option>
                        <option value="MDRRMO">MDRRMO</option>
                        <option value="TaRSIER Unit">TaRSIER 117 Unit</option>
                    </select>
                    <span id="station-type-error" class="error-message" style="color: red; display: none;">Please select a Station Type.</span>
                </div>

                <div class="form-group">
                    <label for="address">Station Address</label>
                    <input type="text" id="address" name="address" placeholder="Enter Station Address">
                    <span id="address-error" class="error-message" style="color: red; display: none;">Please select a Station Address.</span>
                </div>

             <!-- ✅ Google Maps Picker Modal -->
                <div id="map-modal-location">
                    <div class="modal-content">
                        <h2>Select Location</h2>

                        <!-- ✅ Search Box for Location -->
                        <input id="map-search" type="text" placeholder="Search location..." style="width: 100%; padding: 8px; margin-bottom: 10px;">

                        <!-- ✅ Map Container -->
                        <div id="map-location"></div>

                        <button id="confirm-location">Confirm Location</button>
                        <button id="close-map">Cancel</button>
                    </div>
                </div>


                <!-- Latitude & Longitude (Auto-filled) -->
                <div class="form-group" >
                    <label for="latitude">Latitude</label>
                    <input type="text" id="latitude" name="latitude" placeholder="Auto-fetched Latitude" readonly>
                </div>

                <div class="form-group" >
                    <label for="longitude">Longitude</label>
                    <input type="text" id="longitude" name="longitude" placeholder="Auto-fetched Longitude" readonly>
                </div>

            </div>

            <button type="submit" class="submit-btn">Create Account</button>
        </form>
    </div>
</div>


        <div id="success-modal" class="custom-modal">
            <div class="custom-modal-content ">
                <span class="close-btn" id="close-success-modal">&times;</span>
                <h2>Success!</h2>
                <p>Account created successfully.</p>
            </div>
        </div>


    <!-- ✅ Active Accounts Modal -->
    <div id="userManagementModal" class="modal fade" tabindex="-1">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                <!-- ✅ Fixed Header -->
                <div class="modal-header" style="background-color: #1E293B; color: white; position: sticky; top: 0; z-index: 1050;">
                    <h5 class="modal-title">Manage Users</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <!-- ✅ Scrollable Body -->
                <div class="modal-body overflow-auto" style="max-height: 70vh;">
                    <!-- ✅ Search Input -->
                    <input type="text" id="searchUsers" class="form-control mb-3" placeholder="Search by name, role, or email">

                    <!-- ✅ Table Wrapper -->
                    <div class="table-responsive">
                        <table class="table">
                                <tr>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Actions</th>
                                </tr>
                            <tbody id="tableBody">
                                <!-- ✅ Dynamic User Data Will Be Loaded Here -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>




      <!-- Confirm Deactivation Modal -->
      <div id="confirmDeactivateModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-confirm-modal-deactivate">&times;</span>
            <h2>Warning!</h2>
            <p>Are you sure you want to deactivate this account?</p>
            <div class="modal-actions">
            <button class="confirm-btn" id="confirmDeactivateBtn">Yes</button>
                <button class="cancel-btn" id="cancel-confirm-modal-deactivate">No</button>
            </div>
        </div>
    </div>

    <!--  Success Deactivation Modal -->
    <div id="successDeactivateModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-success-modal-deactivate">&times;</span>
            <h2>Account deactivated successfully!</h2>
        </div>
    </div>

   <!-- Update Account Modal -->
   <div class="modal fade" id="updateAccountModal" tabindex="-1" aria-labelledby="updateAccountModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="updateAccountModalLabel">Update Account</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <form id="update-account-form">
                    <input type="hidden" id="update_user_id" name="user_id">

                    <!-- Name Fields -->
                    <div class="form-group name-container" id="update-name-container">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="update_f_name" class="form-label">First Name</label>
                                <input type="text" class="form-control" id="update_f_name" name="f_name">
                            </div>
                            <div class="col-md-6">
                                <label for="update_l_name" class="form-label">Last Name</label>
                                <input type="text" class="form-control" id="update_l_name" name="l_name">
                            </div>
                        </div>
                    </div>

                    <!-- Station Name -->
                    <div class="mb-3" id="update_station-name-container" style="display: none;">
                        <label for="update_station_name" class="form-label">Station Name</label>
                        <input type="text" class="form-control" id="update_station_name" name="station_name" placeholder="Enter Station Name">
                    </div>

                    <!-- Email -->
                    <div class="mb-3">
                        <label for="update_email" class="form-label">Email Address</label>
                        <input type="email" class="form-control" id="update_email" name="email" required>
                    </div>

                    <!-- Phone -->
                    <div class="mb-3">
                        <label for="update_phone" class="form-label">Phone Number</label>
                        <input type="tel" class="form-control" id="update_phone" name="phone" required>
                    </div>

                    <!-- Role -->
                    <div class="mb-3" >
                        <label for="update_role" class="form-label">Select Role</label>
                        <select class="form-select" id="update_role" name="role" readonly>
                            <option value="" disabled selected>Select a Role</option>
                            <option value="Communicator">TaRSIER 117 Communicator</option>
                            <option value="Emergency Responder">Emergency Responder</option>
                            <option value="Emergency Responder Station">Emergency Responder Station</option>
                            <option value="Resource Manager">Resource Manager</option>
                        </select>
                    </div>

                    <!-- Responder Type -->
                    <div class="mb-3" id="update_responder-type-container" style="display: none;">
                        <label for="update_responder-type" class="form-label">Emergency Responder Type</label>
                        <select class="form-select" id="update_responder-type" name="responder_type" readonly>
                            <option value="" disabled selected>Select Type</option>
                            <option value="PNP">LGU Responder: PNP</option>
                            <option value="BFP">LGU Responder: BFP</option>
                            <option value="Coast Guard">LGU Responder: Coast Guard</option>
                            <option value="MDRRMO">LGU Responder: MDRRMO</option>
                            <option value="TaRSIER Responder">TaRSIER 117 Responder</option>
                        </select>
                    </div>

                    <!-- LGU Station -->
                    <div class="mb-3" id="update_lgu-station-container" style="display: none;">
                        <label for="update_lgu-station" class="form-label">Select LGU Responder Station</label>
                        <select class="form-select" id="update_lgu-station" name="lgu_station">
                            <option value="" disabled selected>Select LGU Responder Station</option>
                        </select>
                        <div id="update_lgu-station-error" class="text-danger small mt-1" style="display: none;">
                            Please select an LGU Responder Station.
                        </div>
                    </div>

                    <!-- Station Fields -->
                    <div id="update_station-fields-container" style="display: none;">
                        <div class="mb-3">
                            <label for="update_station-type" class="form-label">Station Type</label>
                            <select class="form-select" id="update_station-type" name="station_type">
                                <option value="" disabled selected>Select Station Type</option>
                                <option value="PNP">PNP</option>
                                <option value="BFP">BFP</option>
                                <option value="Coast Guard">Coast Guard</option>
                                <option value="MDRRMO">MDRRMO</option>
                                <option value="TaRSIER Unit">TaRSIER 117 Unit</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="update_address" class="form-label">Station Address</label>
                            <div class="d-flex gap-2">
                                <input type="text" class="form-control flex-grow-1" id="update_address" name="address" placeholder="Enter Station Address" readonly>
            
                            </div>
                        </div>


                        <!-- Map Modal -->
                        <div id="update_map-modal-location" style="display: none;">
                            <div class="p-3 border rounded bg-light">
                                <h5>Select Location</h5>
                                <input id="update_map-search" type="text" class="form-control mb-2" placeholder="Search location...">
                                <div id="update_map-location" style="height: 300px;"></div>
                                <div class="mt-3 d-flex gap-2">
                                    <button type="button" class="btn btn-success" id="update_confirm-location">Confirm Location</button>
                                    <button type="button" class="btn btn-secondary" id="update_close-map">Cancel</button>
                                </div>
                            </div>
                        </div>


                        <div class="row">
                            <div class="col-md-6 mb-3" style="display: none;">
                                <label for="update_latitude" class="form-label">Latitude</label>
                                <input type="text" class="form-control" id="update_latitude" name="latitude" readonly>
                            </div>
                            <div class="col-md-6 mb-3" style="display: none;">
                                <label for="update_longitude" class="form-label">Longitude</label>
                                <input type="text" class="form-control" id="update_longitude" name="longitude" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="submit" class="btn btn-primary w-100">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>


<!-- View User Modal -->
<div id="viewModal" class="modal fade" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content ">
            <div class="modal-header"  style="background-color: #1E293B; color: white; position: sticky; top: 0; z-index: 1050;">
                <h5 class="modal-title" id="viewModalFullName"></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body px-4 py-4 text-start">
                <div class="mb-3 d-flex align-items-center">
                    <i class="bi bi-envelope-fill me-2 text-primary"></i>
                    <strong>Email:</strong>&nbsp;
                    <span id="viewModalEmail" class="text-muted"></span>
                </div>

                <div class="mb-3 d-flex align-items-center">
                    <i class="bi bi-telephone-fill me-2 text-success"></i>
                    <strong>Phone:</strong>&nbsp;
                    <span id="viewModalPhone" class="text-muted"></span>
                </div>

                <div class="mb-3 d-flex align-items-center">
                    <i class="bi bi-person-badge-fill me-2 text-info"></i>
                    <strong>Role:</strong>&nbsp;
                    <span id="viewModalRole" class="text-muted"></span>
                </div>

                <div id="viewModalLocationContainer" class="mb-3 d-flex align-items-center" style="display: none;">
                    <i class="bi bi-geo-alt-fill me-2 text-danger"></i>
                    <strong>Location:</strong>&nbsp;
                    <span id="viewModalLocation" class="text-muted"></span>
                </div>

                <div id="viewModalLGUStationContainer" class="mb-3 d-flex align-items-center" style="display: none;">
                    <i class="bi bi-building me-2 text-warning"></i>
                    <strong>Emergency Responder Station:</strong>&nbsp;
                    <span id="viewModalLGUStation" class="text-muted"></span>
                </div>
            </div>
        </div>
    </div>
</div>



<!-- Loading Modal -->

    <div id="approvalModal" class="modal fade" tabindex="-1" aria-labelledby="approvalModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="background-color: white; color: black;">  <!-- ✅ Ensures modal is white -->
                <div class="modal-header" style="background-color: #1E293B; color: white;">
                    <h5 class="modal-title" id="approvalModalLabel">For Approval: Accounts</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <!-- ✅ Search Input -->
                    <input type="text" id="searchApproval" class="form-control" placeholder="Search by name or email">

                    <!-- ✅ Table for Deactivated Accounts -->
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Role</th>
                                    <th>Created by</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="approvalTableBody">
                                <!-- Rows Will Be Loaded Dynamically Using JavaScript -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <!-- ✅ Confirm Activation Modal -->
    <div id="confirmApprovalModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-confirm-modal-approval">&times;</span>
            <h2>Warning!</h2>
            <p>Are you sure you want to approve this account?</p>
            <div class="modal-actions">
            <button class="confirm-btn" id="confirmActivateBtn-approval">Yes</button>
                <button class="cancel-btn" id="cancel-confirm-modal-approval">No</button>
            </div>
        </div>
    </div>

    <!-- ✅ Success Activation Modal -->
    <div id="successApprovalModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-success-modal-approval">&times;</span>
            <h2>Account approved successfully!</h2>
        </div>
    </div>

      <!-- ✅ Confirm Activation Modal -->
      <div id="confirmRejectModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-confirm-modal-reject">&times;</span>
            <h2>Warning!</h2>
            <p>Are you sure you want to reject this account?</p>
            <div class="modal-actions">
            <button class="confirm-btn" id="confirmActivateBtn-reject">Yes</button>
                <button class="cancel-btn" id="cancel-confirm-modal-reject">No</button>
            </div>
        </div>
    </div>

    <!-- ✅ Success Activation Modal -->
    <div id="successRejectModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-success-modal-reject">&times;</span>
            <h2>Account rejected successfully!</h2>
        </div>
    </div>

    
   <!-- Deactivated Accounts Modal -->
   <div id="deactivatedModal" class="modal fade" tabindex="-1" aria-labelledby="deactivatedModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <!-- ✅ Fixed Header -->
            <div class="modal-header sticky-top" style="background-color: #1E293B; color: white; top: 0; z-index: 1050;">
                <h5 class="modal-title" id="deactivatedModalLabel">Deactivated Accounts</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <!-- ✅ Scrollable Body -->
            <div class="modal-body" style="max-height: 70vh; overflow-y: auto;">
                <!-- ✅ Search Input -->
                <input type="text" id="searchDeactivated" class="form-control mb-3" placeholder="Search by name or email">

                <!-- ✅ Table Wrapper -->
                <div class="table-responsive">
                    <table class="table table-striped">
                      
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Actions</th>
                            </tr>
                        
                        <tbody id="deactivatedTableBody">
                            <!-- Rows Will Be Loaded Dynamically Using JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

    <!-- ✅ Confirm Activation Modal -->
    <div id="confirmActivateModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-confirm-modal">&times;</span>
            <h2>Warning!</h2>
            <p>Are you sure you want to activate this account?</p>
            <div class="modal-actions">
            <button class="confirm-btn" id="confirmActivateBtn">Yes</button>
                <button class="cancel-btn" id="cancel-confirm-modal">No</button>
            </div>
        </div>
    </div>

    <!-- ✅ Success Activation Modal -->
    <div id="successActivateModal" class="confirmmodal">
        <div class="confirm-modal-content">
            <span class="close-btn" id="close-success-modal">&times;</span>
            <h2>Account activated successfully!</h2>
        </div>
    </div>



  

    <!-- ✅ Delete Confirmation Modal -->
<div id="confirmDeleteModal" class="modal fade" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="btn-close" id="close-delete-modal"></button>
            </div>
            <div class="modal-body">
                 <p>Are you sure you want to delete this user? Deletion will take up to 2 days to fully remove all data.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="cancel-delete-modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
            </div>
        </div>
    </div>
</div>

