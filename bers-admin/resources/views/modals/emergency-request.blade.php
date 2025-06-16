<!-- Emergency Request History Modal -->
<div class="modal fade" id="emergencyRequestHistoryModal" tabindex="-1" aria-labelledby="emergencyRequestHistoryLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content rounded-4 shadow" style="max-height: 90vh;">
      
      <div class="modal-header border-0">
        <h5 class="modal-title w-100 text-center fw-bold" id="emergencyRequestHistoryLabel">Emergency Request History</h5>
        <button type="button" class="btn-close position-absolute end-0 me-3 mt-2" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <!-- Scrollable Content Wrapper -->
      <div class="modal-body overflow-auto" style="max-height: 70vh;">

        <!-- Filter Dropdowns & Search -->
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
          <div class="d-flex gap-2 flex-wrap">
            <select class="form-select" id="yearFilter" style="width: 100px;"></select>
            <select class="form-select" id="monthFilter" style="width: 120px;"></select>
            <select class="form-select" id="dayFilter" style="width: 100px;">
              <option value="">1–31</option>
            </select>
          </div>

          <div class="mt-2 mt-md-0">
            <input type="text" class="form-control" id="searchEmergencyRequests" placeholder="Search...">
          </div>
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="table table-hover align-middle text-center">
            <thead class="table-light">
              <tr>
                <th>Caller</th>
                <th>Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="emergencyRequestTableBody">
              <!-- Dynamic content injected by Firebase JS -->
            </tbody>
          </table>
        </div>

      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="viewEmergencyModal" tabindex="-1" aria-labelledby="viewEmergencyModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content rounded-4">
      <div class="modal-header">
        <h5 class="modal-title" id="viewEmergencyModalLabel">DISPATCH RECORD</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" style="max-height: 70vh; overflow-y: auto; font-family: 'Courier New', monospace;">
        <div class="text-center mb-2">
          <img src="../images/bers_name.png" alt="Logo" style="max-height: 60px;" />
          <div class="fw-bold">Telephone and Radio System Integrated Emergency Response<br>TaRSIER 117</div>
        </div>

        <table class="table table-bordered" style="font-size: 14px;">
          <tbody>
            <tr>
              <td colspan="2">CALLER'S NAME & TEL. NO.: <span id="detailCaller"></span></td>
              <td>DATE & TIME OF CALL: <span id="detailDate"></span></td>
            </tr>
            <tr>
              <td>PATIENT NAME: <span id="detailPatient"></span></td>
              <td>PATIENT AGE: <span id="detailBirth"></span></td>
              <td>SEX: <span id="detailGender"></span></td>
            </tr>
            <tr>
              <td colspan="3">TYPE OF EMERGENCY:
                <span id="detailType"></span>
              </td>
            </tr>
            <tr>
              <td colspan="3">LOCATION OF INCIDENT: <span id="detailLocation"></span><br></span></td>
            </tr>
            <tr>
              <td colspan="3">CHIEF COMPLAINT / INCIDENT: <span id="detailIncident"></span></td>
            </tr>

            <tr>
              <td colspan="3">PRIMARY ASSESSMENT:<br>
                Responsiveness: <span id="detailResponse"></span><br>
                Breathing: <span id="detailBreathing"></span><br>
                Ambulatory: <span id="detailAmbulatory"></span><br>
                Bleeding: <span id="detailBleeding"></span>
              </td>
            </tr>

            <tr>
              <td colspan="3">EMERGENCY FIRST RESPONDERS ON SITE: <span id="detailResponders"></span></td>
            </tr>
            <tr>
              <td>ERU DISPATCHED: <span id="detailERU"></span></td>
              <td>DISPATCH TIME: <span id="detailDispatchTime"></span></td>
              <td>
                   AT SCENE: <span id="detailAtScene"></span> <br>
                   DESTINATION: <span id="detailAtDestination"></span> <br>
                   BASE: <span id="detailAtBase"></span></td>
            </tr>
            <tr>
              <td colspan="3">HAZARDS ON SCENE: <span id="detailHazard"></span></td>
            </tr>
            <tr>
              <td colspan="3">ACTIONS TAKEN: <span id="detailActions"></span></td>
            </tr>
            <tr>
              <td colspan="3">PRE-ARRIVAL INSTRUCTION(S) GIVEN: <span id="detailInstructions"></span></td>
            </tr>
            <tr>
              <td colspan="3">UPDATE ON PATIENT'S STATUS:<br>
                Responsiveness: <span id="detailResponseUpdate"></span> <br>
                Breathing: <span id="detailBreathingUpdate"></span><br>
                Ambulatory: <span id="detailAmbulatoryUpdate"></span> <br>
                Bleeding: <span id="detailBleedingUpdate"></span>
              </td>
            </tr>
         
            <tr>
              <td colspan="3">REMARKS: <span id="detailNotes"></span></td>
            </tr>
            <tr>
              <td>COMMUNICATOR/S ON DUTY: <span id="detailCommunicator"></span></td>
              <td>DATE & SHIFT: <span id="detailShift"></span></td>
              <td>SIGNATURE: ______________________</td>
            </tr>

         

          </tbody>
        </table>

        <div class="text-end mt-3" style="font-size: 12px; color: #666;">
          Generated on: <span id="printTimestamp"></span>
        </div>

        <tr class="no-print">
          <td colspan="3">
            <div id="responderDispatchContainer"></div>
            <div class="d-flex justify-content-between mt-2">
              <button id="prevResponderBtn" class="btn btn-sm btn-outline-secondary" disabled>← Previous</button>
              <button id="nextResponderBtn" class="btn btn-sm btn-outline-secondary" disabled>Next →</button>
            </div>
          </td>
        </tr>

      </div>

            

      <div class="modal-footer justify-content-between">
        <button class="btn btn-outline-secondary" id="printDetailsBtn">
          <i class="fas fa-print me-1"></i> Print
        </button>

        <div id="ambulanceContainer">
            <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#ambulanceReportModal" id="openAmbulanceFormBtn">
              <i class="fas fa-ambulance me-1"></i> View Ambulance Report Form
            </button>
        </div>

      </div>
    </div>
  </div>
</div>

