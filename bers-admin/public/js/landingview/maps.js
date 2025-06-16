let map;
    let previousEmergencies = new Set();
    let userHasInteracted = false;
    let markers = [];
    let responderMarkers = {};
    let knownEmergencies = new Map();

document.addEventListener("DOMContentLoaded", function () {
    
    // ✅ Enable audio on any user interaction
    function enableAudio() {
        userHasInteracted = true;
        console.log("✅ User has interacted. Audio playback is now allowed.");
        document.removeEventListener("click", enableAudio);
        document.removeEventListener("keydown", enableAudio);
        document.removeEventListener("scroll", enableAudio);
    }

    document.addEventListener("click", enableAudio);
    document.addEventListener("keydown", enableAudio);
    document.addEventListener("scroll", enableAudio);

    // ✅ Initialize the Leaflet map
    const mapElement = document.getElementById("map");

    if (!mapElement) {
        console.error("❌ Error: #map element not found in HTML.");
        return;
    }

    // Define Bohol boundaries
    const boholBounds = L.latLngBounds(
        L.latLng(9.45, 123.75),  // Southwest corner
        L.latLng(10.3, 124.5)    // Northeast corner
    );

    map = L.map(mapElement, {
        center: [9.90, 124.2],
        zoom: 10.5,
        minZoom: 9,
        maxBounds: boholBounds,
        maxBoundsViscosity: 1.0  // Prevents dragging out
    });


    L.tileLayer('https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=jd2AEjGrt9Hd159cJ4E3', {
        attribution: '&copy; <a href="https://www.maptiler.com/copyright/">MapTiler</a>',
        tileSize: 512,
        zoomOffset: -1, // Needed for MapTiler's 512px tiles
        maxZoom: 20,
    }).addTo(map);

    // Snap back to center if zoomed too far or dragged out
    map.on("moveend zoomend", () => {
        if (!boholBounds.contains(map.getCenter()) || map.getZoom() < 9) {
            console.warn("📍 Map moved too far. Resetting view to Bohol...");
            map.setView([9.90, 124.2], 10.5);
        }
    });

 


    // Load real-time systems
    loadEmergencyLocationsRealtime();
    console.log("Load Locations");

    listenForEmergencyStatusUpdates();
    console.log("Load Emergency");

    loadEmergencyRespondersRealtime();
    console.log("Load Responder");

    loadEmergencyResponderStationsRealtime();
    console.log("Load Station");

    // ✅ Modal drag behavior
   

 
});


function isValidLatLng(lat, lng) {
    return typeof lat === "number" && typeof lng === "number" &&
        !isNaN(lat) && !isNaN(lng) &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180;
}

function formatDateTime(dateTimeString) {
    if (!dateTimeString) return "Unknown";
    const date = new Date(dateTimeString);
    return date.toLocaleString("en-US", {
        year: "numeric", month: "long", day: "numeric",
        hour: "2-digit", minute: "2-digit", hour12: true
    });
}

function clearMarkers() {
    markers.forEach(marker => map.removeLayer(marker));
    markers = [];
}

function playAlarm() {
    const alarmAudio = new Audio("../audio/alarm.mp3");

    if (userHasInteracted) {
        alarmAudio.play().catch(error => {
            console.warn("⚠️ Cannot play sound: ", error);
            setTimeout(() => {
                if (userHasInteracted) alarmAudio.play();
            }, 2000);
        });
    } else {
        console.warn("⚠️ Waiting for user interaction before playing sound.");
    }
}


function addDefaultTaRSIERMarker() {
    const lat = 9.657415836849156;
    const lng = 123.86536345330173;

    const icon = L.icon({
        iconUrl: "../images/operations_center.png",
        iconSize: [50, 50],
        iconAnchor: [25, 50]
    });

    const marker = L.marker([lat, lng], { icon: icon })
        .addTo(map)
        .bindPopup(`
            <div style="text-align: center; padding: 10px; max-width: 250px;">
                <strong style="color: green; font-size: 18px;">🏢 TaRSIER 117 Operation Center</strong><br>
                <hr style="margin: 5px 0;">
                <strong>📍 Location:</strong> (${lat}, ${lng})<br>
                <strong>📞 Contact:</strong> N/A<br>
                <strong>📧 Email:</strong> N/A<br>
            </div>`);

    markers.push(marker);
}


   // ✅ Drag Modals on Load
   dragElement(document.getElementById("callRecommendationModalDialog"), document.getElementById("callRecommendationModalHeader"));
   dragElement(document.getElementById("webrtcModalDialog"), document.getElementById("webrtcModalHeader"));

   // ✅ Hide WebRTC status indicators on page load
   window.addEventListener("load", () => {
       document.getElementById("callingStatusIndicator").style.display = "none";
       document.getElementById("noAnswerStatusIndicator").style.display = "none";
       document.getElementById("endStatusIndicator").style.display = "none";
       document.getElementById("declineStatusIndicator").style.display = "none";
       document.getElementById("webrtcModal").style.display = "none";
   });
