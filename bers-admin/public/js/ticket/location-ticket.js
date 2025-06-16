let mapPicker, marker, geocoder;

function openMapLocationModal() {
  const modalEl = document.getElementById('mapLocationModal');
  const modal = new bootstrap.Modal(modalEl);
  modal.show();

  const emergencyID = document.getElementById("createTicketModal")?.getAttribute("data-emergency-id");

  if (!emergencyID) {
    alert("❌ Missing emergency ID!");
    modal.hide();
    return;
  }

  firebase.database().ref(`emergencies/${emergencyID}`).once("value").then(snapshot => {
    const data = snapshot.val();
    const lat = parseFloat(data?.live_es_latitude) || 9.6488;
    const lng = parseFloat(data?.live_es_longitude) || 123.8552;

    document.getElementById("update_latitude").value = lat.toFixed(6);
    document.getElementById("update_longitude").value = lng.toFixed(6);

    setTimeout(() => {
      maptilersdk.config.apiKey = 'FtNn7mdBcRizTRMTMnlT';

      if (!mapPicker) {
        mapPicker = new maptilersdk.Map({
          container: 'mapLocationPicker',
          style: `https://api.maptiler.com/maps/satellite-hybrid/style.json?key=FtNn7mdBcRizTRMTMnlT`,
          center: [lng, lat],
          zoom: 16
        });

        marker = new maptilersdk.Marker({ draggable: true })
          .setLngLat([lng, lat])
          .addTo(mapPicker);

        // 📍 Move marker when user selects a place
        marker.on('dragend', () => {
          const pos = marker.getLngLat();
          document.getElementById("update_latitude").value = pos.lat.toFixed(6);
          document.getElementById("update_longitude").value = pos.lng.toFixed(6);
        });

        try {
          geocoder = new maptilersdkMaptilerGeocoder.GeocodingControl({
            inputPlaceholder: "Search location in Bohol...",
            bbox: [123.67, 9.45, 124.57, 10.15],
            country: 'ph'
          });

          mapPicker.addControl(geocoder, 'top-left');

          // ✅ Move map & marker to selected location
          geocoder.on('select', (e) => {
            const { lat, lng } = e.detail.lngLat;
            marker.setLngLat([lng, lat]);
            mapPicker.flyTo({ center: [lng, lat], zoom: 17 });
          
            document.getElementById("update_latitude").value = lat.toFixed(6);
            document.getElementById("update_longitude").value = lng.toFixed(6);
          });
          

        } catch (err) {
          console.error("❌ Geocoder failed:", err);
        }
      } else {
        mapPicker.setCenter([lng, lat]);
        mapPicker.setZoom(16);
        marker.setLngLat([lng, lat]);
      }
    }, 300);
  }).catch(error => {
    console.error("❌ Failed to fetch emergency data:", error);
    alert("⚠️ Unable to load emergency location. Please try again later.");
    modal.hide();
  });
}


function confirmLocationUpdate() {
    const lat = document.getElementById("update_latitude").value;
    const lng = document.getElementById("update_longitude").value;
  
    if (!lat || !lng) {
      alert("⚠️ Please select a location on the map.");
      return;
    }
  
    // Reverse geocode using OpenStreetMap Nominatim
    const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`;
  
    fetch(url, {
      headers: {
        'User-Agent': 'bohol-emergency-response-admin/1.0'
      }
    })
      .then(response => response.json())
      .then(data => {
        const fullAddress = data.display_name || `Lat: ${lat}, Lng: ${lng}`;
        document.getElementById("ticketDescription").value = fullAddress;
  
        const emergencyID = document.getElementById("createTicketModal")?.getAttribute("data-emergency-id");
        if (emergencyID) {
          // ✅ Update all in Firebase
          firebase.database().ref(`emergencies/${emergencyID}`).update({
            live_es_latitude: parseFloat(lat),
            live_es_longitude: parseFloat(lng),
            location: fullAddress,
            last_updated: new Date().toISOString()
          }).then(() => {
            console.log("✅ Location and address updated in Firebase");
          }).catch(error => {
            console.error("❌ Firebase update failed:", error);
          });
        }
  
        bootstrap.Modal.getInstance(document.getElementById("mapLocationModal")).hide();
      })
      .catch(error => {
        console.error("❌ Reverse geocoding failed:", error);
        alert("Failed to fetch address. Please try again.");
      });
  }
  