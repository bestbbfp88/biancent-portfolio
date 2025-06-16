// ✅ Next & Back Navigation
// ✅ Navigate to Section 2, and hide the "Next" button if Responding
function showNextSection2() {
    const modalElement = document.getElementById("createTicketModal");
    const emergencyID = modalElement?.getAttribute("data-emergency-id");

    if (!emergencyID) {
        console.warn("⚠️ Emergency ID missing.");
        return;
    }

    // ✅ Fetch emergency status
    firebase.database().ref(`emergencies/${emergencyID}`).once("value")
        .then(snapshot => {
            const emergencyData = snapshot.val();
            const reportStatus = emergencyData?.report_Status || "Unknown";

            if (reportStatus === "Responding") {
                // ✅ Skip Section 2, go to submission section and hide "Next" button
                document.getElementById("section1").style.display = "none";
                document.getElementById("section2").style.display = "block";
                document.getElementById("section3").style.display = "none";
                document.getElementById("submit-btn").style.display = "inline-block";

                // ✅ Hide "Next" button when status is Responding
                document.getElementById("nextBtn").style.display = "none";
            } else {
                // ✅ Normal navigation to Section 2
                document.getElementById("section1").style.display = "none";
                document.getElementById("section2").style.display = "block";
                document.getElementById("section3").style.display = "none";
                document.getElementById("submit-btn").style.display = "none";

                // ✅ Show "Next" button when status is not Responding
                document.getElementById("nextBtn").style.display = "inline-block";
            }
        })
        .catch(error => {
            console.error("❌ Error fetching emergency status:", error);
        });
}


function showNextSection3() {
    document.getElementById("section1").style.display = "none";
    document.getElementById("section2").style.display = "none";
    document.getElementById("section3").style.display = "block";

    document.getElementById("submit-btn").style.display = "inline-block"; // ✅ Show Update
    document.getElementById("nextBtn").style.display = "none";            // ✅ Hide Next
}


function showPreviousSection2() {
    document.getElementById("section3").style.display = "none";
    document.getElementById("section2").style.display = "block";
    document.getElementById("section1").style.display = "none";

    document.getElementById("submit-btn").style.display = "none"; // ✅ Hide Update again
    document.getElementById("nextBtn").style.display = "inline-block"; // ✅ Show Next again
}


function showPreviousSection1() {
    document.getElementById("section3").style.display = "none";
    document.getElementById("section2").style.display = "none";
    document.getElementById("section1").style.display = "block";
}

