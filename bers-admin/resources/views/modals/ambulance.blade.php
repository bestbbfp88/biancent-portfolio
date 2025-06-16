<div class="modal fade" id="ambulanceReportModal" tabindex="-1" aria-labelledby="ambulanceReportLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
    <div class="modal-content rounded-4">
      <div class="modal-header">
        <h5 class="modal-title w-100 text-center fw-bold" id="ambulanceReportLabel">AMBULANCE REPORT FORM</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" style="font-family: 'Courier New', monospace; font-size: 14px;">

        <div class="text-center mb-3">
            <img src="../images/bers_name.png" alt="BERS Logo" style="max-height: 70px;" />
            <div class="fw-bold mt-2">Telephone and Radio System Integrated Emergency Response</div>
            <div class="fw-bold text-uppercase" style="font-size: 18px;">TaRSIER 117</div>
            <h5 class="fw-bold text-uppercase mt-2">Ambulance Report Form</h5>
        </div>

        <table class="table table-bordered">
          <tbody>
          <!-- 🚑 RESPONSE SECTION -->
        <tr>
        <td rowspan="3" class="vertical-text text-center align-middle fw-bold text-uppercase">Response</td>
        <td><strong>Date Incident Reported:</strong> <span id="amb_date_incident"></span></td>
        <td><strong>Responding Unit:</strong> <span id="amb_responding_unit"></span></td>
        <td><strong>Shift / Time:</strong> <span id="amb_shift_time"></span></td>
        <td><strong>PCR / Alarm No.:</strong> <span id="amb_pcr_number"></span></td>
        </tr>

        <tr>
        <td colspan="4"><strong>Incident Address:</strong> <span id="amb_incident_location"></span></td>
        </tr>

        <tr>
        <td><strong>Hospital / Facility:</strong> <span id="amb_hospital_name"></span></td>
        <td><strong>Lights and Siren:</strong> <span id="amb_lights_scene"></span></td>
        <td><strong>Location Type:</strong> <span id="amb_location_type"></span></td>
        <td><strong>Response Type:</strong> <span id="amb_response_type"></span></td>
        </tr>

                
                    

            <!-- 👤 DEMOGRAPHICS SECTION -->
            <tr>
            <td rowspan="2" class="vertical-text text-center align-middle fw-bold text-uppercase">Demographics</td>
            <td colspan="2"><strong>Patient Name:</strong> <span id="amb_patient_name"></span></td>
            <td><strong>Date of Birth:</strong> <span id="amb_dob"></span></td>
            <td>
                <strong>Gender:</strong> <span id="amb_gender"></span><br>
                <strong>Weight:</strong> <span id="amb_weight"></span>
            </td>
            </tr>
            <tr>
            
            </tr>


            <!-- 📋 HISTORY SECTION -->
            <tr>
            <td rowspan="3" class="vertical-text text-center align-middle fw-bold text-uppercase">History</td>
            <td colspan="4">
                <strong>Signs / Symptoms:</strong> <span id="amb_symptoms"></span>
            </td>
            </tr>

            <tr>
            <td colspan="2">
                <strong>Allergies:</strong> <span id="amb_allergies"></span>
            </td>
            <td colspan="2">
                <strong>Current Medication:</strong> <span id="amb_current_medication"></span>
            </td>
            </tr>

            <tr>
            <td colspan="4">
                <strong>Pre-Existing Medical Conditions:</strong><br>
                <strong>Medical:</strong> <span id="amb_medical_conditions"></span><br>
                <strong>Cardiac:</strong> <span id="amb_cardiac_conditions"></span><br>
                <strong>Other:</strong> <span id="amb_other_conditions"></span>
            </td>
            </tr>


            

          <!-- 🩺 ASSESSMENT SECTION -->
        <tr>
        <td rowspan="3" class="vertical-text text-center align-middle fw-bold text-uppercase">Assessment</td>
        <td colspan="4">
            <strong>Assessment:</strong><br>
            Mental Status: <span id="amb_mental_status"></span><br>
            Eye Status: <span id="amb_eye_status"></span><br>
            Skin Color: <span id="amb_skin_color"></span><br>
            Skin Moisture: <span id="amb_skin_moisture"></span><br>
            Skin Temp: <span id="amb_skin_temp"></span><br>
            Capillary Refill: <span id="amb_capillary_refill"></span><br>
            Breath Sounds: <span id="amb_breath_sounds"></span>
        </td>
        </tr>

        <tr>
        <td colspan="4">
            <strong>Pain Assessment:</strong><br>
            Pain Provoke: <span id="amb_pain_provoke"></span><br>
            Quality: <span id="amb_pain_quality"></span><br>
            Radiates: <span id="amb_pain_radiate"></span><br>
            Severity: <span id="amb_pain_severity"></span><br>
            Onset Time: <span id="amb_pain_onset_time_display"></span>
        </td>
        </tr>

        <tr>
        <td colspan="4">
            <strong>Vitals (Latest Entry)</strong>
            <table class="table table-bordered text-center align-middle mt-2">
            <thead class="table-light">
                <tr>
                <th>BP</th>
                <th>GCS</th>
                <th>Pulse</th>
                <th>Resp</th>
                <th>SpO2</th>
                <th>Temp</th>
                </tr>
            </thead>
            <tbody id="amb_vitals_table_body">
                <!-- JS will populate rows -->
            </tbody>
            </table>
        </td>
        </tr>


          </tbody>
        </table>

        <div class="text-end mt-3" style="font-size: 12px; color: #666;">
          Generated on: <span id="amb_generated"></span>
        </div>


      </div>
      
        <div class="modal-footer justify-content-between">
            <div></div> <!-- spacer -->
            <button class="btn btn-primary" onclick="generateAmbulancePDF()">
                <i class="fas fa-print me-1"></i> Print Report
            </button>
        </div>

    </div>
  </div>
</div>
