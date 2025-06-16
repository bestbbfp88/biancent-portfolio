<!-- Edit Profile Modal -->
<div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header text-white" style="background-color: #1E293B;">
        <h5 class="modal-title" id="editProfileModalLabel"><i class="fas fa-user-edit"></i> Update Profile</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="editProfileForm">

          <div class="form-group" id="station-name-container">
                <label for="station_name">Station Name</label>
                <input type="text" id="station_name" name="station_name" placeholder="Enter Station Name">
                <span id="stationName-error" class="error-message" style="color: red; display: none;">Station name is required.</span>
          </div>


          <div class="form-group mt-3">
            <label>Email</label>
            <input type="email" class="form-control" id="editEmail" disabled>
          </div>

          <div class="form-group mt-3">
            <label>Contact Number</label>
            <input type="text" class="form-control" id="editContact" required>
            <div class="invalid-feedback" id="contactError">Contact number must start with +63 followed by 10 digits.</div>
          </div>


          <div class="modal-footer mt-4">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary">Save Changes</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- 🔐 Update Password Modal -->
<div class="modal fade" id="updatePasswordModal" tabindex="-1" aria-labelledby="updatePasswordModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content shadow border-0">
      <div class="modal-header text-white" style="background-color: #1E293B;">
        <h5 class="modal-title" id="updatePasswordModalLabel">Update Password</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form id="updatePasswordForm">
        <div class="modal-body">

        <div class="mb-3">
          <label for="oldPassword" class="form-label">🔒 Old Password</label>
          <input type="password" class="form-control" id="oldPassword" required>
          <div class="invalid-feedback" id="oldPasswordError">Old password is required.</div>
        </div>

        <div class="mb-3">
          <label for="newPassword" class="form-label">🔐 New Password</label>
          <input type="password" class="form-control" id="newPassword" required>
          <div class="invalid-feedback" id="newPasswordError">New password is required.</div>
        </div>

        <div class="mb-3">
          <label for="confirmPassword" class="form-label">✅ Confirm New Password</label>
          <input type="password" class="form-control" id="confirmPassword" required>
          <div class="invalid-feedback" id="confirmPasswordError">Passwords do not match.</div>
        </div>

        </div>
        <div class="modal-footer">
          <button type="submit" class="btn text-white w-100" style="background-color: #1E293B;">Update Password</button>
          
        </div>
            <p class="text-center mt-2">
              <a href="#" id="sendResetLinkBtn" class="text-primary text-decoration-underline">Send Password Reset Link</a>
            </p>

      </form>
    </div>
  </div>
</div>
