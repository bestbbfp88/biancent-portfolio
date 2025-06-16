<!-- Emergency Number Management Modal -->
<div class="modal fade emergency-modal" id="emergencyModalEmNumber" tabindex="-1" aria-labelledby="emergencyModalLabelEmNumber" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header emergency-modal-header">
                <h5 class="modal-title emergency-modal-title" id="emergencyModalLabelEmNumber">Emergency Numbers</h5>
                <button type="button" class="btn-close emergency-modal-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body emergency-modal-body">
                <div class="d-flex justify-content-between mb-3 emergency-modal-actions">
                    <button class="btn btn-secondary emergency-add-btn" data-bs-toggle="modal" data-bs-target="#addEmergencyModalEmNumber">+ Add Emergency Number</button>
                    <button class="btn btn-secondary emergency-archive-btn" data-bs-toggle="modal" data-bs-target="#archivedEmergencyModalEmNumber">Archived Emergency Numbers</button>
                </div>
                <table class="table mt-3 emergency-table">
                    <thead>
                        <tr class="emergency-table-header">
                            <th>Number Name</th>
                            <th>Number</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="emergencyListEmNumber" class="emergency-table-body">
                        <!-- Dynamic rows will be added here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Emergency Number Modal -->
<div class="modal fade" id="addEmergencyModalEmNumber" tabindex="-1" aria-labelledby="addEmergencyLabelEmNumber" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addEmergencyLabelEmNumber">Add Emergency Number</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="addEmergencyFormEmNumber">
                    <div class="mb-3">
                        <label for="emergencyNameEmNumber" class="form-label">Number Name</label>
                        <input type="text" class="form-control" id="emergencyNameEmNumber" required>
                    </div>
                    <div class="mb-3">
                        <label for="emergencyNumberEmNumber" class="form-label">Number</label>
                        <input type="text" class="form-control" id="emergencyNumberEmNumber" required>
                        <div class="invalid-feedback">Please enter a valid Philippine mobile number starting with +63.</div>
                    </div>

                    <button type="submit" class="btn btn-primary">Add Number</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Update Emergency Number Modal -->
<div class="modal fade" id="updateEmergencyModalEmNumber" tabindex="-1" aria-labelledby="updateEmergencyLabelEmNumber" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="updateEmergencyLabelEmNumber">Update Emergency Number</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="updateEmergencyFormEmNumber">
                    <input type="hidden" id="updateEmergencyIdEmNumber">
                    <div class="mb-3">
                        <label for="updateEmergencyNameEmNumber" class="form-label">Number Name</label>
                        <input type="text" class="form-control" id="updateEmergencyNameEmNumber" required>
                    </div>
                    <div class="mb-3">
                        <label for="updateEmergencyNumberEmNumber" class="form-label">Number</label>
                        <input type="text" class="form-control" id="updateEmergencyNumberEmNumber" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Update Number</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Archived Emergency Numbers Modal -->
<div class="modal fade" id="archivedEmergencyModalEmNumber" tabindex="-1" aria-labelledby="archivedEmergencyLabelEmNumber" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="archivedEmergencyLabelEmNumber">Archived Emergency Numbers</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Number Name</th>
                            <th>Number</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="archivedEmergencyListEmNumber">
                        <!-- Archived emergency numbers will be listed here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmActionModal" tabindex="-1" aria-labelledby="confirmActionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header text-dark">
                <h5 class="modal-title" id="confirmActionModalLabel">Action Needed</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <p id="confirmActionModalBody">Are you sure you want to perform this action?</p>
                <input type="hidden" id="currentEmergencyId"> <!-- Hidden input for storing emergency ID for actions -->
                <div class="mt-3">
                    <button id="confirmActionBtn" class="btn btn-danger">Confirm</button>
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- Confirm Archive Emergency Number Modal -->
    <div class="modal fade" id="archiveEmergencyModal" tabindex="-1" aria-labelledby="archiveEmergencyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header text-dark">
                    <h5 class="modal-title" id="archiveEmergencyModalLabel">Warning!</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <p>Are you sure you want to archive this emergency number?</p>
                    <input type="hidden" id="archiveEmergencyIdEmNumber"> <!-- Hidden input for emergencyId -->
                    <div class="mt-3">
                        <button id="confirmArchive-btn-number" class="btn btn-danger">Yes</button>
                        <button class="btn btn-secondary" data-bs-dismiss="modal">No</button>
                    </div>
                </div>
            </div>
        </div>
    </div> 


<!-- Success Archive Emergency Number Modal -->
    <div class="modal fade" id="successArchiveEmergencyIdEmNumber" tabindex="-1" aria-labelledby="successArchiveEmergencyIdEmNumberLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="successArchiveEmergencyIdEmNumberLabel">Success</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <h2 class="text-success">Emergency Number Archived Successfully! ✅</h2>
                </div>
            </div>
        </div>
    </div>
