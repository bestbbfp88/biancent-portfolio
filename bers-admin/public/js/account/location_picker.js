import { postalCodeToTown } from "./postal-mapping.js"; 
document.addEventListener("DOMContentLoaded", function () {
    
    let map;
    let marker;
    let geocoder = L.Control.Geocoder.nominatim();
    const searchInput = document.getElementById("map-search");

    const addressInput = document.getElementById("address");
    const latitudeInput = document.getElementById("latitude");
    const longitudeInput = document.getElementById("longitude");
    const mapModal = document.getElementById("map-modal-location");

    // 📍 Show modal and initialize map
    addressInput.addEventListener("click", () => {
        mapModal.style.display = "flex";

        // Wait for modal to render before initializing or resizing map
        setTimeout(() => {
            if (!map) {
                initializeMap();
            } else {
                map.invalidateSize();
                map.setView(marker.getLatLng(), 15);
            }
        }, 300);
    });

    // 🗺️ Initialize Leaflet map with draggable marker
    function initializeMap() {
        // 👇 Check if lat/lng inputs already have values
        const inputLat = parseFloat(latitudeInput.value);
        const inputLng = parseFloat(longitudeInput.value);
        const validCoords = !isNaN(inputLat) && !isNaN(inputLng);
    
        const startCoords = validCoords ? [inputLat, inputLng] : [9.84999, 124.1435]; // Use input or fallback to Bohol
    
        map = L.map("map-location").setView(startCoords, 15);
    
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map);
    
        marker = L.marker(startCoords, { draggable: true }).addTo(map);
    
        // 🔁 Sync address on drag or click
        marker.on("dragend", (e) => {
            const { lat, lng } = e.target.getLatLng();
            updateAddress(lat, lng);
        });
    
        map.on("click", (e) => {
            marker.setLatLng(e.latlng);
            updateAddress(e.latlng.lat, e.latlng.lng);
        });
    
        // 🔍 Nominatim search
        searchInput.addEventListener("input", () => {
            const query = searchInput.value.trim();
            if (query.length < 3) return;
    
            fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&addressdetails=1&limit=5&countrycodes=PH`)
                .then(res => res.json())
                .then(data => {
                    if (data.length > 0) {
                        const place = data[0];
                        const latlng = [parseFloat(place.lat), parseFloat(place.lon)];
                        map.setView(latlng, 15);
                        marker.setLatLng(latlng);
                        window.updateAddress(latlng[0], latlng[1], place.display_name);
                    }
                })
                .catch(err => console.error("❌ Nominatim search failed:", err));
        });
    
        // 💡 Fill address on init
        window.updateAddress(startCoords[0], startCoords[1]);
    }
    

    // 📦 Updates form inputs and runs reverse geocoding if needed
    window.updateAddress = function (lat, lng, manualAddress = null) {
        console.log("🛰️ [GLOBAL] updateAddress() called with:", { lat, lng, manualAddress });
    
        const addressInput = document.getElementById("address");
        const latitudeInput = document.getElementById("latitude");
        const longitudeInput = document.getElementById("longitude");
    
        if (!addressInput || !latitudeInput || !longitudeInput) {
            console.warn("❌ Address or lat/lng inputs not found.");
            return;
        }
    
        latitudeInput.value = lat;
        longitudeInput.value = lng;
    
        if (manualAddress) {
            addressInput.value = manualAddress;
            console.log("📦 Manual address set:", manualAddress);
        } else {
            console.log("🌍 Attempting reverse geocode...");
            console.log("🧪 geocoder:", geocoder);
            console.log("🧪 typeof geocoder.reverse:", typeof geocoder.reverse);
    
            const zoom = typeof map !== "undefined" && map.getZoom ? map.getZoom() : 15;
    
            if (!geocoder || typeof geocoder.reverse !== "function") {
                console.warn("❌ Geocoder not ready.");
                return;
            }
    
            console.log("🌐 Fetching address via direct Nominatim reverse geocoding...");

            // Example inside updateAddress(lat, lng)
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`)
            .then(res => res.json())
            .then(data => {
                console.log("📬 Reverse geocode response:", data);
                const addr = data.address || {};
                const street = addr.road || "";
                const brgy = addr.suburb || addr.village || "";
                const province = addr.state || "Bohol";
                const country = addr.country || "Philippines";
                const postcode = addr.postcode || "";

                // 🧠 Use Nominatim town, or fallback from postal code
                let town = addr.town || addr.city || addr.municipality || postalCodeToTown[postcode] || "Unknown Town";

                const fullAddress = [street, brgy, town, province, country].filter(Boolean).join(", ");

                addressInput.value = fullAddress;
                latitudeInput.value = lat;
                longitudeInput.value = lng;

                console.log("📦 Full formatted address:", fullAddress);
            })
            .catch(err => {
                console.error("❌ Reverse geocode error:", err);
                addressInput.value = `${lat}, ${lng}`;
            });

        }
    };
    
    
    

    // ✅ Modal controls
    document.getElementById("confirm-location").addEventListener("click", () => {
        mapModal.style.display = "none";
    });

    document.getElementById("close-map").addEventListener("click", () => {
        mapModal.style.display = "none";
    });

    // ✅ If latitude and longitude already exist, reverse geocode on load
    const initialLat = parseFloat(latitudeInput.value);
    const initialLng = parseFloat(longitudeInput.value);

    if (!isNaN(initialLat) && !isNaN(initialLng)) {
        updateAddress(initialLat, initialLng);
    }

    window.addEventListener("locationConfirmed", (e) => {
        const { lat, lng } = e.detail;
        updateAddress(lat, lng);
    });
    

});
