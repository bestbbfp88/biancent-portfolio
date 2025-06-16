<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Landing Page</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <!-- <script src="https://cdn.tailwindcss.com"></script> -->
  
    <link rel="stylesheet" href="../css/styles.css">
    <link rel="stylesheet" href="../css/advisory-modal.css">
    <link rel="stylesheet" href="../css/hospital.css">

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-database-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-storage-compat.js"></script> 
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

  <!-- Leaflet CSS -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.heat/dist/leaflet-heat.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- Leaflet Geocoder (for reverse geocoding) -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet-control-geocoder/dist/Control.Geocoder.css" />
    <script src="https://unpkg.com/leaflet-control-geocoder/dist/Control.Geocoder.js"></script>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <!-- SmoothMarkerBouncing Plugin -->
    <script src="https://cdn.jsdelivr.net/gh/maximeh/leaflet.bouncemarker/leaflet.smoothmarkerbouncing.js"></script>
<!-- SmoothMarkerBouncing (CDN) -->
    <script
    type="text/javascript"
    src="https://cdn.jsdelivr.net/gh/hosuaby/Leaflet.SmoothMarkerBouncing@v3.0.3/dist/bundle.js"
    crossorigin="anonymous"
    ></script>

 
  <!--  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script> -->
    <script>
        window.firebaseCustomToken = "{{ $firebaseCustomToken }}";
    </script>

    <script src="{{ asset('js/essentials/firebase-init.js') }}"></script>
    <script src="{{ asset('js/essentials/script.js') }}" defer></script>
    <script src="{{ asset('js/essentials/profile.js') }}"></script>
    <script src="{{ asset('js/essentials/error-success.js') }}"></script>

    <script src="{{ asset('js/landingview/maps.js') }}"></script>
    <script src="{{ asset('js/landingview/emergencies.js') }}"></script>
    <script src="{{ asset('js/landingview/emergency-responder.js') }}"></script>
    <script src="{{ asset('js/landingview/emergency-responder-station.js') }}"></script>

    
    <script src="{{ asset('js/advisory/create-advisory.js') }}"></script> 
    <script src="{{ asset('js/advisory/active-advisories.js') }}"></script> 
    <script src="{{ asset('js/advisory/deactivated-advisory.js') }}"></script> 
    <script src="{{ asset('js/advisory/approval-advisories.js') }}"></script> 

    <script src="{{ asset('js/webrtc/webrtc.js') }}"></script> 
    <script src="{{ asset('js/webrtc/call-buttons.js') }}"></script> 
    <script src="{{ asset('js/webrtc/receive-call.js') }}"></script> 


    <script src="{{ asset('js/ticket/assign_responder.js') }}"></script> 
    <script src="{{ asset('js/ticket/navigation.js') }}"></script> 
    <script src="{{ asset('js/ticket/fetch-data.js') }}"></script> 
    <script src="{{ asset('js/ticket/calculations.js') }}"></script> 
    <script src="{{ asset('js/ticket/event-listener.js') }}"></script> 
    <script src="{{ asset('js/ticket/call-recommendation.js') }}"></script>
    <script src="{{ asset('js/ticket/ticket.js') }}"></script>  
    <script src="{{ asset('js/ticket/location-ticket.js') }}"></script> 
    <script src="{{ asset('js/ticket/new-ticket.js') }}"></script> 
    <script src="{{ asset('js/ticket/sub-options.js') }}"></script>  

    <script src="{{ asset('js/account/create-account.js') }}"></script>  
    <script src="{{ asset('js/account/deactivated-account.js') }}"></script>  
    <script src="{{ asset('js/account/active-accounts.js') }}"></script>  
    <script src="{{ asset('js/account/approval-account.js') }}"></script>  
    <script src="{{ asset('js/account/notification.js') }}"></script>

    <script src="{{ asset('js/emergency-request/emergency-request.js') }}"></script>
    <script src="{{ asset('js/emergency-request/ambulance.js') }}"></script>

    <script src="{{ asset('js/emergency-personnel/emergency-personnel.js') }}"></script>

    <script src="{{ asset('js/assign-responder-unit/archived-unit.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/assign-personnel.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/assign-responder-unit.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/edit-unit.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/responder-select.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/responder-station-fetch.js') }}"></script>
    <script src="{{ asset('js/assign-responder-unit/responder-unit-modal.js') }}"></script>

    <script src="{{ asset('js/report/generate_report.js') }}"></script>
    <script src="{{ asset('js/report/heatmap.js') }}"></script>
    
    
</head>

<body class="h-screen flex bg-gray-100">

    <!-- ✅ Sidebar -->
    <div id="sidebar" class="sidebar">
        <div class="sidebar-header">
            <h5> <i class="fas fa-users-cog"></i> Station Panel</h5>
            <button id="close-btn" class="close-btn"><i class="fas fa-bars"></i></button>
        </div>

        <ul class="sidebar-menu">
            <li class="nav-item has-dropdown" id="user-account-btn">
                <a href="#" class="nav-link">
                    <i class="fas fa-user" ></i> User Accounts
                </a>
                <ul class="custom-dropdown">
                    <li><a href="#" class="custom-dropdown-item" id="open-modal-btn"><i class="fas fa-user-plus"></i> Create Account</a></li>
                    <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#deactivatedModal"> <i class="fas fa-user-slash"></i> Deactivated Accounts</a></li>
                    <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#userManagementModal"> <i class="fas fa-user-check"></i> Active Accounts</a></li>
                    <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#approvalModal"> <i class="fas fa-user-shield"></i> Approval Accounts</a></li>
                </ul>
            </li>

            <li class="nav-item has-dropdown">
                <a href="#" class="nav-link">
                    <i class="fas fa-rss"></i> Advisory Feed
                </a>
                <ul class="custom-dropdown">
                <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#advisoryModal"> <i class="fas fa-plus-circle"></i> Create Advisory</a></li>
                <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#deactivatedAdvisoryModal"> <i class="fas fa-archive"></i> Archive Advisory</a></li>
                <li><a href="#" class="custom-dropdown-item" data-bs-toggle="modal" data-bs-target="#activeAdvisoryModal"> <i class="fas fa-bullhorn"></i> Active Advisory</a></li>
                
                </ul>
            </li>
            
            <li class="nav-item">
                <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#emergencyRequestHistoryModal">
                    <i class="fas fa-history"></i> Emergency Request History
                </a>
            </li>


            <li class="nav-item">
                <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#responderPersonnelModal">
                    <i class="fas fa-user-md"></i> Emergency Responder Personnel
                </a>
            </li>
            
            <li class="nav-item" id="generate-report">
                <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#generateReportModal">
                    <i class="fas fa-chart-line"></i> Generate Report
                </a>
            </li>

            
        </ul>
    </div>

    <!-- ✅ Main Content -->
    <div class="main-content">
        <!-- ✅ Top Bar -->
        <div class="top-bar d-flex align-items-center justify-content-between">

            <div class="d-flex align-items-center">
                <button id="menu-btn" class="menu-btn me-3">
                    <i class="fas fa-bars"></i> Menu
                </button>

                <!-- 🔔 Notification Bell -->
                <div class="dropdown">
                    <button class="btn btn-light position-relative" id="notificationBell" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-bell"></i>
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" id="notificationCount" style="display: none;">0</span>
                    </button>

                    <ul class="dropdown-menu shadow dropdown-menu-start" style="min-width: 300px; max-height: 400px; overflow-y: auto;" id="notificationList">
                        <li class="dropdown-header fw-bold">Notifications</li>
                        <!-- JS inserts notifications here -->
                    </ul>
                </div>
            </div>

            <!-- 🏷️ Title -->
            <h1 class="top-title text-center m-0 flex-grow-1">Bohol Emergency Response System</h1>

            <!-- 👤 Profile Dropdown -->
            <div class="dropdown" id="profileDropdownContainer">
                <button class="btn btn-light dropdown-toggle d-flex align-items-center" id="profileDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="fas fa-user-circle me-2"></i> Profile
                </button>

                <ul class="dropdown-menu dropdown-menu-end shadow text-wrap" aria-labelledby="profileDropdown"
                    style="min-width: 250px; max-width: 350px; word-break: break-word;">

                    <!-- Name & Role -->
                    <li class="px-3 py-2 text-center border-bottom">
                        <div class="fw-bold" id="dropdownProfileName">Loading...</div>
                        <small class="text-muted" id="dropdownProfileRole">Role</small>
                    </li>

                    <!-- Contact Info -->
                    <li class="px-3 pt-2">
                        <div class="small"><strong>📧 Email:</strong> <br> <span id="dropdownProfileEmail"></span></div>
                        <div class="small mt-2"><strong>📞 Phone:</strong> <br> <span id="dropdownProfileContact"></span></div>
                    </li>

                    <!-- Edit Buttons -->
                    <li class="px-3 py-2 text-center">
                        <button class="btn btn-sm w-100 btn-outline-darkblue" onclick="openEditProfileModal()">
                            <i class="fas fa-user-edit me-1"></i> Update Profile
                        </button>
                    </li>

                    <li class="px-3 py-2 text-center">
                        <button class="btn btn-sm w-100 btn-outline-darkblue" onclick="openUpdatePasswordModal()">
                            <i class="fas fa-user-edit me-1"></i> Update Password
                        </button>
                    </li>

                    <li><hr class="dropdown-divider"></li>

                    <!-- Logout -->
                    <li>
                        <button class="dropdown-item text-danger" onclick="logout()">
                            <i class="fas fa-sign-out-alt me-2"></i> Log Out
                        </button>
                    </li>
                </ul>
            </div>
            </div>

        
            <div id="callingStatusIndicator" class="calling">
            <span id="callingText">Calling...</span>
            <button class="btn btn-sm " onclick="cancelOutgoingCall()">
                <img src="/images/endcall.png" alt="End Call" style="width: 30px; height: 30px;">
            </button>
        </div>

        <div id="noAnswerStatusIndicator" class="noAnswer">
            <span id="callingText">No Answer</span>
        </div>

        <div id="endStatusIndicator" class="noAnswer">
            <span id="callingText">Cancelling...</span>
        </div>

        <div id="declineStatusIndicator" class="noAnswer">
            <span id="callingText">Decline</span>
        </div>

        <div id="webrtcModal" class="calling-ui">
            <div class="call-info"id="webrtcModalHeader">
                <span id="callingTextIncall">In Call</span>
                <span id="callTimerCaller">00:00</span>
            </div>

            <div class="call-controls">
                <button class="call-btn" onclick="toggleMute()">
                    <img id="muteIconCaller" src="/images/mic.png" alt="Mute" />
                </button>
                <button class="call-btn" onclick="toggleSpeaker()">
                    <img id="muteIconCaller" src="/images/speaker.png" alt="Speaker" />
                </button>
                <button class="call-btn end-btn" onclick="endCall()">
                    <img src="/images/endcall.png" alt="End Call" />
                </button>
            </div>
        </div>

        <div id="webrtcModalReceiver" class="calling-ui">
            <div class="call-info" id="webrtcModalReceiverHeader">
                <span id="callingTextIncallReceiver">In Call</span>
                <span id="callTimerReceiver">00:00</span>
            </div>

            <div class="call-controls">
                <button class="call-btn" onclick="toggleMute()">
                    <img id="muteIconReceiver" src="/images/mic.png" alt="Mute" />
                </button>
                <button class="call-btn" onclick="toggleSpeaker()">
                    <img id="speakerIconReceiver" src="/images/speaker.png" alt="Speaker" />
                </button>
                <button class="call-btn end-btn" onclick="endCallAsReceiver()">
                    <img src="/images/endcall.png" alt="End Call" />
                </button>
            </div>
        </div>


        <!-- ✅ Google Maps -->
        <div id="map" class="map-container"></div>

    </div>

    <div id="loadingModal" class="modal" style="display: none; position: fixed; z-index: 1500; left: 0; top: 0; width: 100%; height: 100%; overflow: hidden; background: rgba(0, 0, 0, 0.5);">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">
            <div class="spinner-border text-light" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
    </div>
    <!-- 🔊 Audio for declined call -->
    <audio id="declineAudio" src="/audio/decline.mp3" preload="auto"></audio>

    <!-- 🔊 Audio for timeout -->
    <audio id="timeoutAudio" src="/audio/timeout.mp3" preload="auto"></audio>

    <!-- 🔊 Audio for call cancelled -->
    <audio id="cancelAudio" src="/audio/cancel.mp3" preload="auto"></audio>

    <audio id="ringingAudio" src="/audio/ringing.mp3" preload="auto" loop></audio>

    <audio id="ringtoneAudio" src="/audio/ringtone.mp3" preload="auto" loop></audio>

    <audio id="remoteAudio" autoplay playsinline></audio>

    @include('modals.success-modal')

    @include('modals.ticket-modal')
    @include('modals.user-account')

 
    @include('modals.advisoryfeed')

    @include('modals.hospital')
    @include('modals.emergency_number')
    @include('modals.edit-profile-password')
    @include('modals.emergency-request')
    @include('modals.emergency-responder-personnel')
    @include('modals.emergency-responder-unit')
    @include('modals.generate_report')
    @include('modals.ambulance')


</body>
</html>


