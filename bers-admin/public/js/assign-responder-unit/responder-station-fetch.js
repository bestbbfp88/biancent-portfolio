document.addEventListener("DOMContentLoaded", () => {
  console.log("✅ Loaded Responder Unit Script");

  // 🔥 Check DOM references
  const unitAssignSelect = document.getElementById("unitAssign");
  const erStationSelect = document.getElementById("erStation");
  const responderUserSelect = document.getElementById("responderUser");
  const erStationGroup = document.getElementById("erStationGroup");

  console.log("📥 DOM References:", {
      unitAssignSelect,
      erStationSelect,
      responderUserSelect,
      erStationGroup
  });

  // ✅ Verify elements exist before adding listeners
  if (!unitAssignSelect || !erStationSelect || !responderUserSelect || !erStationGroup) {
      console.error("❌ Missing DOM elements.");
      return;
  }

  unitAssignSelect.addEventListener("change", async () => {
      console.log("🔄 Unit assignment changed.");
      
      const selectedType = unitAssignSelect.value;
      const isTarsierUnit = selectedType === "TaRSIER Unit";

      console.log("📌 Selected Unit:", selectedType);

      if (isTarsierUnit) {
          console.log("✅ TaRSIER Unit selected. Hiding station group.");
          
          erStationGroup.style.display = "none";
          erStationSelect.disabled = true;
          erStationSelect.innerHTML = `<option value="">Not required</option>`;
          
          await loadRespondersForTarsier();
          return;
      }

      console.log("🔄 Loading stations...");
      erStationGroup.style.display = "block";
      erStationSelect.disabled = false;
      erStationSelect.innerHTML = `<option value="">Loading stations...</option>`;
      responderUserSelect.innerHTML = `<option value="">Select Responder</option>`;

      try {
          console.log("📥 Fetching Firebase data...");
          
          const usersSnapshot = await firebase.database().ref("users").once("value");
          const stationsSnapshot = await firebase.database().ref("emergency_responder_station").once("value");

          console.log("✅ Fetched data:", {
              users: usersSnapshot.val(),
              stations: stationsSnapshot.val()
          });

          erStationSelect.innerHTML = `<option value="">Select Station</option>`;

          let foundStations = false;

          usersSnapshot.forEach((userSnap) => {
              const user = userSnap.val();
              const userUID = userSnap.key;

              console.log(`👤 Checking User: ${userUID}`, user);

              if (user.user_role === "Emergency Responder Station") {
                  const stationId = user.station_id;
                  const stationData = stationsSnapshot.child(stationId).val();

                  console.log(`📌 Station Data for ${stationId}:`, stationData);

                  if (!stationData) return;

                  if (stationData.station_type === selectedType) {
                      foundStations = true;
                      const option = document.createElement("option");
                      option.value = userUID;
                      option.textContent = `${stationData.station_name} - ${stationData.station_type}`;
                      erStationSelect.appendChild(option);
                      console.log(`✅ Added station: ${stationData.station_name}`);
                  }
              }
          });

          if (!foundStations) {
              console.warn("⚠️ No matching stations found.");
              erStationSelect.innerHTML = `<option value="">No stations found</option>`;
          }

      } catch (error) {
          console.error("❌ Error loading stations:", error);
          erStationSelect.innerHTML = `<option value="">Error loading stations</option>`;
      }
  });
});
