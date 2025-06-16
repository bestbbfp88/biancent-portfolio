(function () {
  let localMap;
  let heatmapLayer;

  const boholBounds = [
    [9.3000, 123.7000], // Southwest (lat, lng)
    [10.2000, 124.8000] // Northeast (lat, lng)
  ];

  window.heatmap = {
    getMapInstance: () => localMap,

    initMapHeat: function (rawData, center = [9.8, 124.2], zoom = 10, onReady) {
      console.log("🗺️ Initializing heatmap from filtered report...");

      const mapContainer = document.getElementById("heatmapContainer");
      if (!mapContainer) {
        console.error("❌ heatmapContainer element not found.");
        return;
      }

      if (localMap) {
        localMap.remove();
      }

      localMap = L.map("heatmapContainer", {
        maxBounds: boholBounds,
        maxBoundsViscosity: 1.0
      }).setView(center, zoom);

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 18,
        attribution: '© OpenStreetMap contributors',
        crossOrigin: true
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
        this.generateHeatmap(heatmapPoints, onReady);
      } else {
        console.warn("⚠️ No valid coordinates for heatmap.");
        localMap.fitBounds(boholBounds);
      }
    },

    generateHeatmap: function (data, onReady) {
      console.log("🔥 Generating heatmap layer...", data);

      if (!localMap) {
        console.error("❌ Map is not initialized.");
        return;
      }

      if (heatmapLayer) {
        heatmapLayer.remove();
      }

      localMap.invalidateSize();

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

        if (typeof onReady === 'function') {
          console.log("✅ Heatmap rendered. Executing callback...");
          setTimeout(onReady, 500);
        }
      }, 200);
    }
  };

  document.addEventListener("DOMContentLoaded", () => {
    const reportModal = document.getElementById("generateReportModal");
    if (reportModal) {
      reportModal.addEventListener("shown.bs.modal", () => {
        setTimeout(() => {
          const map = window.heatmap.getMapInstance();
          if (map) {
            map.invalidateSize();
          }
        }, 300);
      });
    }
  });
})();
