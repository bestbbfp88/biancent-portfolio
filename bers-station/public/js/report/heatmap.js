(function () {
  let localMap;
  let heatmapLayer;

  window.heatmap = {
    getMapInstance: () => localMap, 
    initMapHeat: function (rawData, center = [9.8, 124.2], zoom = 10) {
      console.log("🗺️ Initializing heatmap from filtered report...");
    
      const mapContainer = document.getElementById("heatmapContainer");
      if (!mapContainer) {
        console.error("❌ heatmapContainer element not found.");
        return;
      }
    
      if (localMap) {
        localMap.remove();
      }
    
      localMap = L.map("heatmapContainer").setView(center, zoom);
    
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 18,
        attribution: '© OpenStreetMap contributors'
      }).addTo(localMap);
    
      const heatmapPoints = [];
    
      for (let key in rawData) {
        const incident = rawData[key];
        const lat = parseFloat(incident.live_es_latitude);
        const lng = parseFloat(incident.live_es_longitude);
        if (!isNaN(lat) && !isNaN(lng)) {
          heatmapPoints.push([lat, lng]);
        }
      }
    
      if (heatmapPoints.length > 0) {
        console.log(`✅ ${heatmapPoints.length} valid heatmap points from filtered report.`);
        this.generateHeatmap(heatmapPoints);
      } else {
        console.warn("⚠️ No valid coordinates for heatmap.");
      }
    },
    

    generateHeatmap: function (data) {
      console.log("🔥 Generating heatmap layer...", data);
    
      if (!localMap) {
        console.error("❌ Map is not initialized.");
        return;
      }
    
      if (heatmapLayer) {
        heatmapLayer.remove();
      }
    
      // 🛠️ Invalidate map size to ensure canvas is sized
      localMap.invalidateSize();
    
      // ✅ Delay heatmap layer creation to allow layout to settle
      setTimeout(() => {
        heatmapLayer = L.heatLayer(data, {
          radius: 25,
          blur: 15,
          maxZoom: 17,
          gradient: {
            0.0: 'blue',
            0.5: 'lime',
            1.0: 'red'
          }
        }).addTo(localMap);
      }, 100); // 100–300ms depending on UI animation
    },

    // fetchHeatmapDataFromFirebase: function () {
    //   console.log("📦 Fetching heatmap data from Firebase...");
    //   const dbRef = firebase.database().ref("emergencies");

    //   dbRef.once("value").then(snapshot => {
    //     const data = snapshot.val();
    //     const heatmapPoints = [];

    //     if (data) {
    //       for (let key in data) {
    //         const incident = data[key];
    //         const lat = parseFloat(incident.live_es_latitude);
    //         const lng = parseFloat(incident.live_es_longitude);

    //         if (!isNaN(lat) && !isNaN(lng)) {
    //           heatmapPoints.push([lat, lng]);
    //         }
    //       }
    //     }

    //     if (heatmapPoints.length > 0) {
    //       console.log(`✅ ${heatmapPoints.length} valid points loaded`);
    //       this.initMapHeat(heatmapPoints);
    //     } else {
    //       console.warn("⚠️ No valid coordinates found for heatmap.");
    //     }
    //   }).catch(error => {
    //     console.error("❌ Error loading Firebase heatmap data:", error);
    //   });
    // }
  };

  // ✅ Optional: auto-load on page load
  document.addEventListener("DOMContentLoaded", () => {
    if (typeof firebase !== "undefined") {
      window.heatmap.fetchHeatmapDataFromFirebase();
    } else {
      console.warn("⚠️ Firebase is not initialized.");
    }
  });

  document.addEventListener("DOMContentLoaded", () => {
    const reportModal = document.getElementById("generateReportModal");
  
    reportModal.addEventListener("shown.bs.modal", () => {
      setTimeout(() => {
        const map = window.heatmap.getMapInstance();
        if (map) {
          map.invalidateSize();
        }
      }, 300); // wait a bit for the modal animation to settle
    });
  });
  
})();
