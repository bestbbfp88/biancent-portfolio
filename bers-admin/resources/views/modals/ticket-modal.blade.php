<div class="modal fade" id="createTicketModal" tabindex="-1" aria-labelledby="createTicketModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content shadow-lg border-0 rounded-lg">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="createTicketModalLabel">Create New Ticket</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4" style="max-height: 75vh; overflow-y: auto;">
                <form id="ticketForm">
                    <!-- Section 1: Emergency & Reporter Details -->
                    <div class="section" id="section1">
                        <div class="row">
                            <!-- ✅ Column 1: Emergency Details -->
                            <div class="col-md-4">
                                <h6 class="text-primary fw-bold"><i class="fas fa-info-circle"></i> Emergency Details</h6>
                                <div class="mb-3 position-relative">
                                    <label class="form-label">📍 Location</label>
                                    <input type="text" class="form-control" id="ticketDescription" onclick="openMapLocationModal()" readonly>
                                    <small id="locationAccuracyWarning" class="text-danger d-block mt-1" style="display: none;">
                                    ⚠️ Location is low accuracy
                                    </small>
                                </div>

                                <div class="mb-3">
                                <label class="form-label">📌 Status</label>
                                <select class="form-control" id="ticketStatus">
                                    <option value="">-- Select Status --</option>
                                    <option value="Pending">Pending</option>
                                    <option value="Assigning">Assigning</option>
                                    <option value="Responding">Responding</option>
                                    <option value="Done">Done</option>
                                </select>
                                <div id="ticketStatusError"></div>

                                </div>

                                <div class="mb-3">
                                    <label class="form-label">⏳ Reported Time</label>
                                    <input type="text" class="form-control" id="ticketDateTime" readonly>
                                </div>
                            </div>

                            <!-- ✅ Column 2: Reporter Details -->
                            <div class="col-md-4">
                                <h6 class="text-success fw-bold"><i class="fas fa-user"></i> Reporter Details</h6>
                                <div class="mb-3">
                                    <label class="form-label">🙍‍♂️ Reported By</label>
                                    <input type="text" class="form-control" id="ticketUserName" >
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">📞 Contact (Please enter N/A if not applicable)</label>
                                    <input type="text" class="form-control" id="ticketUserContact" >
                                    <div class="invalid-feedback" id="ticketUserContactError"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">📧 Email (Please enter N/A if not applicable)</label>
                                    <input type="email" class="form-control" id="ticketUserEmail" >
                                    <div class="invalid-feedback" id="ticketUserEmailError"></div>
                                </div>
                            </div>

                            <div class="col-md-4" id="emergencyContactSection" style="display: none;">
                                <h6 class="text-warning fw-bold"><i class="fas fa-user-shield"></i> Emergency Contact</h6>
                                <div class="mb-3">
                                    <label class="form-label">👨‍👩‍👧 Emergency Contact Name</label>
                                    <input type="text" class="form-control ticket-input" id="ticketEContactName" readonly>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">📞 Emergency Contact Number</label>
                                    <input type="text" class="form-control ticket-input" id="ticketEContactNumber" readonly>
                                </div>
                            </div>

                        </div>

                        <button type="button" class="btn btn-primary mt-3" onclick="showNextSection2()">Next</button>
                    </div>

                    <!-- Section 2: Patient Condition & Dispatch Details -->
                    <div class="section" id="section2" style="display: none;">
                        <h6 class="text-success fw-bold"><i class="fas fa-user-injured"></i> Incident Details</h6>
                        <div class="row">

                            <div class="mb-3">
                                <label class="form-label">🧑🏽‍✈️ Person Concerned</label>
                                <input type="text" class="form-control ticket-input" id="ticketPatientName">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">📅 Birthdate</label>
                                <input type="date" class="form-control ticket-input" id="ticketBirthdate" onchange="calculateAge()">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">🎂 Age</label>
                                <input type="text" class="form-control ticket-input" id="ticketAge" readonly>
                            </div>
                            <div class="col-md-4">
                                    <label class="form-label">🧑‍⚕️ Gender</label>
                                    <select class="form-control" id="patientGender">
                                        <option value="">-- Select Gender --</option>
                                        <option value="Male">Male</option>
                                        <option value="Female">Female</option>
                                        <option value="Other">Other</option>
                                    </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">👥 Affected Individual(s)</label>
                                <input type="number" class="form-control" id="numberPatients">
                            </div>
                            
                            <div class="col-md-4">
                                <label class="form-label">⚕️ Responsiveness Status</label>
                                <select class="form-control" id="responsiveness">
                                    <option value="">-- Select Responsiveness Status --</option>
                                    <option value="Responsive">Responsive</option>
                                    <option value="Unresponsive">Unresponsive</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">🚶 Ambulatory Status</label>
                                <select class="form-control" id="ambulatory_status">
                                    <option value="">-- Select Ambulatory Status --</option>
                                    <option value="Ambulatory">Ambulatory</option>
                                    <option value="Non-Ambulatory">Non-Ambulatory</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">🩸 Bleeding Site</label>
                                <select class="form-control" id="bleeding_site_option" onchange="toggleBleedingInput(this.value)">
                                    <option value="">-- Select Bleeding Status --</option>
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                </select>
                                <input type="text" class="form-control mt-2" id="bleeding_site_input" placeholder="Specify bleeding site..." style="display: none;">
                            </div>



                            <div class="mb-3 mt-2">
                                <label class="form-label">🆘 Situation Overview</label>
                                <textarea class="form-control" id="complaintIncident" rows="4" placeholder="Enter Complaint/Incident..."></textarea>
                            </div>

                            
                        </div>

                        <div class="row mt-2">
                          
                            <div class="col-md-6">
                                <label class="form-label">⚠️ Hazard Site</label>
                                <input type="text" class="form-control" id="hazardSite">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">🫁 Breathing</label>
                                <select class="form-control" id="breathing">
                                    <option value="" selected disabled>Select an option</option>
                                    <option value="Breathing">Breathing</option>
                                    <option value="Difficulty in Breathing">Difficulty in Breathing</option>
                                    <option value="Not Breathing">Not Breathing</option>
                                </select>
                            </div>

                        </div>
                                <div class="d-flex justify-content-between mt-4">
                                    <button type="button" id="backBtn" class="btn btn-secondary" onclick="showPreviousSection1()">Back</button>
                                    <button type="button" id="nextBtn" class="btn btn-primary" onclick="showNextSection3()">Next</button>
                                    <button type="button" style="display: none;" id="submit-btn" class="btn btn-success" onclick="submitTicket()">Update</button>
                                </div>

                    </div>

                    <div class="section" id="section3" style="display: none;">
                        <h6 class="text-danger fw-bold"><i class="fas fa-exclamation-triangle"></i> Assign Responder</h6>
                            <div class="row"> 
                                    <!-- ✅ Assign Responder Section -->
                                    <div class="row mt-3">
                                        <!-- ✅ Assign Responder Section -->
                                        <div class="col-md-6">
                                        
                                        <div class="mb-3">
                                            <label class="form-label">🚨 Emergency Type</label>
                                            <select class="form-control" id="emergencyType">
                                                <option value="">-- Select Emergency Type --</option>
                                                <option value="Medical">Medical</option>
                                                <option value="Trauma">Trauma</option>
                                                <option value="Fire">Fire</option>
                                                <option value="Police">Police</option>
                                                <option value="MVC">MVC</option>
                                                <option value="Other">Other</option>
                                            </select>

                                            <!-- Show when type is "Other" -->
                                            <input type="text" class="form-control mt-2" id="otherEmergencyType" placeholder="Describe Emergency" style="display: none;">

                                            <!-- MVC Sub-options -->
                                            <div id="mvcSubOptions" class="mt-2" style="display: none;">
                                                <label class="form-label">🚗 MVC Subtype</label>
                                                <div class="form-check">
                                                <input class="form-check-input" type="radio" name="mvcType" id="mvcExtrication" value="For Extrication">
                                                <label class="form-check-label" for="mvcExtrication">For Extrication</label>
                                                </div>
                                                <div class="form-check">
                                                <input class="form-check-input" type="radio" name="mvcType" id="mvcNonExtrication" value="Not For Extrication">
                                                <label class="form-check-label" for="mvcNonExtrication">Not For Extrication</label>
                                                </div>
                                            </div>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label">🚑 Select Nearest Emergency Responder Station(s)</label>
                                                <div class="dropdown">
                                                    <button class="btn btn-light dropdown-toggle w-100" type="button" id="stationDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">
                                                        -- Select Station(s) --
                                                    </button>
                                                    <ul class="dropdown-menu w-100" id="stationDropdownMenu">
                                                        <!-- Checkbox options will be added dynamically here -->
                                                    </ul>
                                                </div>
                                                <!-- ✅ Hidden input to store selected station IDs for submission -->
                                                <input type="hidden" id="nearestStation" value="">
                                            </div>


                                            <div class="mb-3" style="display:none">
                                                <label class="form-label">📏 Distance to Selected Station (km)</label>
                                                <input type="text" class="form-control ticket-input" id="distanceToStation" readonly>
                                            </div>
                                        </div>

                                        <!-- ✅ Assign TaRSIER Responder Section -->
                                        <div class="col-md-6">

                                            <div class="mb-3" id="recommendField" style="display: none;">
                                                <label class="form-label">🦺 Recommended Responder</label>
                                                <input type="text" class="form-control ticket-input" id="recommendedTaRSIER" readonly>
                                            </div>

                                            <div class="mb-3"  id="tarsierResponderSection" style="display: none;">
                                                <label class="form-label">🚑 Select Available TaRSIER 117 Responder</label>
                                                <div class="dropdown">
                                                    <button class="btn btn-light dropdown-toggle w-100" type="button" id="tarsierDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">
                                                        -- Select TaRSIER Responder(s) --
                                                    </button>
                                                    <ul class="dropdown-menu w-100" id="tarsierDropdownMenu">
                                                        <!-- Checkbox items will be populated here -->
                                                    </ul>
                                                </div>
                                                <!-- Hidden input to store selected responder IDs -->
                                                <input type="hidden" id="assignedResponder" value="">
                                            </div>
                                        </div>
                                    </div>
                                <div class="row">
                                    <div class="col-12">
                                        <h6 class="text-secondary fw-bold"><i class="fas fa-edit"></i> Additional Notes</h6>
                                        <textarea class="form-control ticket-input" id="ticketNotes" rows="4" placeholder="Enter additional details..."></textarea>
                                    </div>
                                </div>

                                </div>
                                    <button type="button" class="btn btn-secondary mt-3" onclick="showPreviousSection2()">Back</button>
                                    <button type="button" class="btn btn-primary mt-3" id="submit-btn" onclick="submitTicket()">Submit</button>
                            </div>
                    </div>

                </form>
            </div>
        </div>
    </div>
</div>


<!-- ✅ Call Recommendation Modal -->
<div class="modal fade" id="callRecommendationModal" tabindex="-1" aria-labelledby="callRecommendationModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" id="callRecommendationModalDialog">
        <div class="modal-content shadow-lg border-0 rounded-lg">
            <div class="modal-header bg-warning text-dark" id="callRecommendationModalHeader">
                <h5 class="modal-title" id="callRecommendationModalLabel">Best Communication Method</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <p id="callRecommendationText" class="fw-bold"></p>

                <!-- ✅ WebRTC Call Option -->
                <div id="webrtcCallOption" style="display: none;">
                    <button id="startWebRTCCall" class="btn btn-success m-1" onclick="startWebRTCCallFromButton(this)">Start WebRTC Call</button>
                </div>

                <!-- ✅ Phone Call Option -->
                <div id="localCallOption" style="display: none;">
                    <a href="#" id="phoneCall" class="btn btn-danger m-1">Call via Phone</a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ✅ WebRTC Video Call UI
<div class="modal fade" id="webrtcModal" tabindex="-1" aria-labelledby="webrtcModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" id="webrtcModalDialog">
        <div class="modal-content shadow-lg border-0 rounded-lg">
            <div class="modal-header bg-primary text-white" id="webrtcModalHeader">
                <h5 class="modal-title">WebRTC Video Call</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" onclick="endCall()"></button>
            </div>
            <div class="modal-body text-center">
                <video id="localVideo" autoplay playsinline></video>
                <video id="remoteVideo" autoplay playsinline></video>
            </div>
            <div class="modal-footer">
                <button class="btn btn-danger" onclick="endCall()">End Call</button>
            </div>
        </div>
    </div>
</div> -->

<div id="incomingCallModal" class="incoming-call-ui" style="display: none;">
    <div class="call-info">
        <span id="incomingCallText">Incoming Call...</span>
        <span id="callerName">From: Unknown</span>
    </div>
    <div class="call-controls">
        <button class="call-btn accept-btn" onclick="acceptCall()">
            <img src="/images/acceptcall.png" alt="Accept" style="width: 30px; height: 30px;" />
        </button>
        <button class="call-btn end-btn" onclick="declineCall()">
            <img src="/images/endcall.png" alt="Decline" style="width: 30px; height: 30px;" />
        </button>
    </div>
</div>

<!-- ✅ Calling Modal -->
<div class="modal fade" id="callingModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content shadow rounded">
      <div class="modal-header bg-info text-white">
        <h5 class="modal-title">Calling...</h5>
      </div>
      <div class="modal-body text-center">
        <p id="callingStatusText">Calling the user, waiting for response...</p>
        <div class="spinner-border text-primary" role="status"></div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-danger" onclick="cancelOutgoingCall()">Cancel</button>
      </div>
    </div>
  </div>
</div>


<div class="modal fade" id="ticketSuccessModal" tabindex="-1" aria-labelledby="ticketSuccessModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content text-center">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="ticketSuccessModalLabel">✅ Success</h5>
        <button type="button" class="btn-close text-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="successModalMessage">
        Ticket submitted successfully!
      </div>
    </div>
  </div>
</div>


<div class="modal fade" id="mapLocationModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header bg-primary text-white">
        <h5 class="modal-title">🗺️ Select New Location</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        
        <div id="mapLocationPicker" style="height: 400px;"></div>
        <input type="hidden" id="update_latitude">
        <input type="hidden" id="update_longitude">
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-success" onclick="confirmLocationUpdate()">Confirm</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="confirmNewEmergencyModal" tabindex="-1" aria-labelledby="confirmNewEmergencyLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content text-center">
      <div class="modal-header bg-warning text-dark">
        <h5 class="modal-title" id="confirmNewEmergencyLabel">Create Emergency Ticket</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        Do you want to create a new emergency ticket for a phone call report?
      </div>
      <div class="modal-footer justify-content-center">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" onclick="proceedCreateEmergencyFromCall()">Yes, Proceed</button>
      </div>
    </div>
  </div>
</div>
