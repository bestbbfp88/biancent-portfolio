let map;
let previousEmergencies = new Set();
let userHasInteracted = false;
let markers = [];
let responderMarkers = {}; 
let knownEmergencies = new Map();

let isMonitoring = false;

let defaultCenter = null;
let defaultBounds = null;
const DEFAULT_ZOOM_LEVEL = 13; // Same as in zoomToResponderStation
const MIN_ZOOM_THRESHOLD = 12; // If user zooms out more than this, reset
const BOUNDS_TOLERANCE_METERS = 5000; // If user pans far from center, reset


document.addEventListener("click", enableAudio);
document.addEventListener("keydown", enableAudio);
document.addEventListener("scroll", enableAudio);


function enableAudio() {
    userHasInteracted = true;
    console.log("✅ User has interacted. Audio playback is now allowed.");
    document.removeEventListener("click", enableAudio);
    document.removeEventListener("keydown", enableAudio);
    document.removeEventListener("scroll", enableAudio);
}

window.addEventListener("DOMContentLoaded", () => {
    const mapElement = document.getElementById("map");

    if (!mapElement) {
        console.error("❌ Error: #map element not found.");
        return;
    }

    map = L.map(mapElement).setView([9.90, 124.2], 10.5);

    L.tileLayer('https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=jd2AEjGrt9Hd159cJ4E3', {
        attribution: '&copy; <a href="https://www.maptiler.com/copyright/">MapTiler</a>',
        tileSize: 512,
        zoomOffset: -1, // Needed for MapTiler's 512px tiles
        maxZoom: 20,
    }).addTo(map);

    firebase.auth().onAuthStateChanged(user => {
        if (user) {
            zoomToResponderStation(user.uid);
        }
    });

        loadEmergencyLocationsRealtime();
        listenForEmergencyStatusUpdates();
        loadEmergencyRespondersRealtime();
        loadEmergencyResponderStationsRealtime();
});


function zoomToResponderStation(uid) {
    const userRef = firebase.database().ref("users/" + uid);

    userRef.once("value").then(snapshot => {
        if (!snapshot.exists()) return;
        const userData = snapshot.val();
        const stationID = userData.station_id;

        if (!stationID) {
            console.warn("⚠️ No assigned station for this user.");
            return;
        }

        const stationRef = firebase.database().ref("emergency_responder_station/" + stationID);
        stationRef.once("value").then(stationSnapshot => {
            if (!stationSnapshot.exists()) return;
            const stationData = stationSnapshot.val();

            // If station has polygonCoordinates, zoom to polygon
            if (stationData.polygonCoordinates) {
                const polygonCoords = stationData.polygonCoordinates.map(coord => [parseFloat(coord.lat), parseFloat(coord.lng)]);
                const bounds = L.latLngBounds(polygonCoords);
                map.fitBounds(bounds);
                
                // Optionally draw the polygon
                L.polygon(polygonCoords, { color: 'red' }).addTo(map);

            } else {
                // Fallback: center on station's lat/lng
                const lat = parseFloat(stationData.latitude);
                const lng = parseFloat(stationData.longitude);

                if (isValidLatLng(lat, lng)) {
                    defaultCenter = L.latLng(lat, lng);
                    map.setView(defaultCenter, 14); // or any default zoom level you prefer

                    reverseGeocodeTown(lat, lng);
                    monitorMapView();
                }
            }
        });
    });
}


function isValidLatLng(lat, lng) {
    return !isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0;
}


function reverseGeocodeTown(lat, lng) {
    fetch(`https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json`)
        .then(res => res.json())
        .then(data => {
            const townName = data.address?.town || data.address?.city || data.address?.municipality;
            if (townName) {
                console.log(`✅ Town: ${townName}`);
                fetchTownBoundary(townName, lat, lng);
            } else {
                console.warn("⚠️ Town name not found.");
            }
        });
}

function fetchTownBoundary(townName, lat, lng) {
    const overpassUrl = `https://overpass-api.de/api/interpreter?data=[out:json];area[name="Bohol"]->.searchArea;(relation["boundary"="administrative"](area.searchArea););out body geom;`;

    fetch(overpassUrl)
        .then(res => res.json())
        .then(data => {
            const boundary = data.elements.find(el =>
                el.type === "relation" && el.tags?.name === townName
            );

            if (!boundary) {
                console.warn(`⚠️ No boundary found for ${townName}.`);
                return;
            }

            const coords = boundary.members
                .filter(member => member.type === "way" && member.geometry)
                .flatMap(member => member.geometry.map(pt => [pt.lat, pt.lon]));

            if (coords.length > 0) {
                drawTownBoundaryWithDarkenedOutside(coords);
                defaultBounds = L.latLngBounds(coords);
                defaultCenter = defaultBounds.getCenter();
                map.fitBounds(defaultBounds);
                monitorMapView();
            }
        });
}

function drawTownBoundaryWithDarkenedOutside(coordinates) {
    const worldBounds = [
        [85, -180],
        [85, 180],
        [-85, 180],
        [-85, -180]
    ];

    // Reverse town coordinates to create a "hole"
    const reversedInner = [...coordinates].reverse();

    const darkOverlay = L.polygon([worldBounds, reversedInner], {
        color: "#000",
        fillColor: "#000",
        fillOpacity: 0.1  ,
        stroke: false
    }).addTo(map);

    // Optional: show town boundary visibly
    const townBoundary = L.polygon(coordinates, {
        color: "red",
        weight: 2,
        fillColor: "#fff",
        fillOpacity: 0
    }).addTo(map);

    console.log("✅ Darkened entire world outside town boundary.");
}



function monitorMapView() {
    if (!map || !defaultCenter || isMonitoring) return;
    isMonitoring = true;

    map.on("moveend", () => {
        const currentCenter = map.getCenter();
        const currentZoom = map.getZoom();
        const distance = currentCenter.distanceTo(defaultCenter);

        console.log("🛰️ Viewport check → Zoom:", currentZoom, "| Distance:", distance);

        if (currentZoom < MIN_ZOOM_THRESHOLD || distance > BOUNDS_TOLERANCE_METERS) {
            console.warn("🔄 Auto-reset triggered.");
            resetToDefaultMapView();
        }
    });
}

function resetToDefaultMapView() {
    console.log("🔁 Resetting map view...");
    if (defaultBounds) {
        map.fitBounds(defaultBounds);
    } else if (defaultCenter) {
        map.setView(defaultCenter, DEFAULT_ZOOM_LEVEL);
    }
}

function addDefaultTaRSIERMarker() {
    const lat = 9.657415836849156;
    const lng = 123.86536345330173;

    const icon = L.icon({
        iconUrl: "../images/operations_center.png",
        iconSize: [50, 50],       // Width and height
        iconAnchor: [25, 50],     // Point of the icon which will correspond to marker's location
        popupAnchor: [0, -50]     // Where the popup opens relative to the iconAnchor
    });

    const marker = L.marker([lat, lng], { icon: icon, title: "TaRSIER 117 Operation Center" }).addTo(map);

    const popupContent = `
        <div style="text-align: center; padding: 10px; max-width: 250px;">
            <strong style="color: green; font-size: 18px;">🏢 TaRSIER 117 Operation Center</strong><br>
            <hr style="margin: 5px 0;">
            <strong>📍 Location:</strong> (${lat}, ${lng})<br>
            <strong>📞 Contact:</strong> N/A<br>
            <strong>📧 Email:</strong> N/A<br>
        </div>`;

    marker.bindPopup(popupContent);

    markers.push(marker); // Optional if you're using markers for later removal
}


// Validate Latitude & Longitude
function isValidLatLng(lat, lng) {
    return (
        typeof lat === "number" &&
        typeof lng === "number" &&
        !isNaN(lat) &&
        !isNaN(lng) &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180
    );
}

function formatDateTime(dateTimeString) {
    if (!dateTimeString) return "Unknown";

    const date = new Date(dateTimeString);
    if (isNaN(date.getTime())) return "Invalid Date";

    return date.toLocaleString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: true
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

// Function to Make a Modal Movable Within Fixed Boundaries
function dragElement(modalDialog, modalHeader) {
    let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

    if (modalHeader) {
        // ✅ Make the header draggable
        modalHeader.style.cursor = "move";
        modalHeader.onmousedown = dragMouseDown;
    } else {
        // ✅ Otherwise, drag the whole modal
        modalDialog.onmousedown = dragMouseDown;
    }

    function dragMouseDown(e) {
        e.preventDefault();
        // ✅ Get the initial cursor position
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
    }

    function elementDrag(e) {
        e.preventDefault();
        
        // ✅ Calculate new cursor position
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;

        // ✅ Get the modal's current position
        let modalRect = modalDialog.getBoundingClientRect();

        // ✅ Screen boundaries
        let screenWidth = window.innerWidth;
        let screenHeight = window.innerHeight;

        // ✅ Prevent dragging out of bounds
        let newTop = modalRect.top - pos2;
        let newLeft = modalRect.left - pos1;

        if (newTop < 0) newTop = 0; // Prevent moving above screen
        if (newLeft < 0) newLeft = 0; // Prevent moving too far left
        if (newTop + modalRect.height > screenHeight) newTop = screenHeight - modalRect.height; // Prevent moving below screen
        if (newLeft + modalRect.width > screenWidth) newLeft = screenWidth - modalRect.width; // Prevent moving too far right

        // ✅ Set new position
        modalDialog.style.position = "fixed";
        modalDialog.style.top = `${newTop}px`;
        modalDialog.style.left = `${newLeft}px`;
    }

    function closeDragElement() {
        // ✅ Stop movement on mouse release
        document.onmouseup = null;
        document.onmousemove = null;
    }
}

// Enable Dragging for Both Modals After Page Load
document.addEventListener("DOMContentLoaded", function () {
    dragElement(document.getElementById("callRecommendationModalDialog"), document.getElementById("callRecommendationModalHeader"));
    dragElement(document.getElementById("webrtcModalDialog"), document.getElementById("webrtcModalHeader"));
});

window.addEventListener("load", () => {
    document.getElementById("callingStatusIndicator").style.display = "none";
    document.getElementById("noAnswerStatusIndicator").style.display = "none";
    document.getElementById("endStatusIndicator").style.display = "none";
    document.getElementById("declineStatusIndicator").style.display = "none";
    document.getElementById("webrtcModal").style.display = "none";
});

