<div class="modal fade" id="generateReportModal" tabindex="-1" aria-labelledby="generateReportLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="generateReportLabel">Generate Report</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
            <form id="generateReportForm">
                <div class="row">
                    <div class="col-md-3 mb-3">
                    <label for="reportYear" class="form-label">Year</label>
                    <select class="form-select" id="reportYear">
                        <option selected>Choose Year</option>
                    </select>
                    </div>
                    <div class="col-md-3 mb-3">
                    <label for="reportMonth" class="form-label">Month</label>
                    <select class="form-select" id="reportMonth">
                        <option selected>Choose Month</option>
                    </select>
                    </div>
                    <div class="col-md-3 mb-3" style="display: none;">
                    <label for="reportPlace" class="form-label">Place</label>
                    <input type="text" class="form-control" id="reportPlace" placeholder="Enter place">
                    </div>
                    <div class="col-md-3 mb-3" style="display: none;">
                    <label for="reportStatus" class="form-label">Status</label>
                    <select class="form-select" id="reportStatus">
                        <option value="">Any</option>
                        <option value="Responding">Responding</option>
                        <option value="Resolved">Resolved</option>
                        <option value="Pending">Pending</option>
                    </select>
                    </div>
                </div>

                <!-- Generate Report Button (Full Width & Centered on Small Screens) -->
                <div class="text-end mt-3">
                    <button type="button" class="btn btn-primary px-4 py-2" id="generateReportButton">
                    <i class="fas fa-file-alt me-1"></i> Generate Report
                    </button>
                </div>
                </form>


                <!-- Report Generation Result -->
                <div id="reportResult" class="mt-4" style="display: none;">
                    <h5>Report Summary</h5>
                
                    <div class="row">
                        <div class="col-md-6" style="height: 360px;">
                            <div class="p-2 border rounded bg-white h-100">
                            <canvas id="typeChart" style="width: 100%; height: 360px;"></canvas>
                            </div>
                        </div>
                        <div class="col-md-6" >
                            <div class="p-2 border rounded bg-white h-100">
                            <p class="fw-bold">Heat Map:</p>
                            <div id="heatmapContainer" style="height: 300px; width: 100%;"></div>
                            </div>
                        </div>
                    </div>

                        <button type="button" class="btn btn-outline-secondary ms-2" id="printReportButton">
                            <i class="fas fa-print me-1"></i> Print Report
                        </button>
                    </div>

            </div>
        </div>
    </div>
</div>

<script>
  window.onload = () => {
    initMap();
  };
</script>