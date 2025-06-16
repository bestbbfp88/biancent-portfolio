function calculateAge() {
    const birthdateInput = document.getElementById("ticketBirthdate").value;
    if (!birthdateInput) {
        document.getElementById("ticketAge").value = "";
        return;
    }

    const birthdate = new Date(birthdateInput);
    const today = new Date();
    let age = today.getFullYear() - birthdate.getFullYear();
    const monthDiff = today.getMonth() - birthdate.getMonth();

    // Adjust age if birthday hasn't occurred yet this year
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthdate.getDate())) {
        age--;
    }

    document.getElementById("ticketAge").value = age;
}

// ✅ Function to Calculate Distance (Haversine Formula)
function calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Radius of Earth in km
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLng = (lng2 - lng1) * (Math.PI / 180);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return (R * c).toFixed(2); // Distance in km
}

function getTownFromCoordinates(lat, lng, callback) {
    console.log("📡 Performing OSM reverse geocoding for coordinates:", { lat, lng });

    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=10&addressdetails=1`;

    fetch(url, {
        method: "GET",
        headers: {
            "Accept": "application/json",
            // Optional: Identify your app (required for public Nominatim usage)
            "User-Agent": "BERS-Emergency-System/1.0"
        }
    })
    .then(response => response.json())
    .then(data => {
        console.log("✅ OSM Reverse Geocoding Result:", data);

        const address = data.address || {};

        // Try to extract municipality or city-level info
        let town = address.city || address.town || address.village || address.municipality || address.county;

        if (town) {
            console.log("🏘️ Raw OSM town name:", town);
            town = town.toLowerCase().replace(/\b(city|municipality|town)\b/gi, "").trim();
            town = town.charAt(0).toUpperCase() + town.slice(1);
            console.log("🏙️ Normalized town name:", town);
        } else {
            console.warn("⚠️ Could not resolve town from OSM address.");
        }

        callback(town);
    })
    .catch(error => {
        console.error("❌ Error during OSM reverse geocoding:", error);
        callback(null);
    });
}


