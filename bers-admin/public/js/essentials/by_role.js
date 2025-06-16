document.addEventListener('DOMContentLoaded', () => {
    const menuButton = document.querySelector(".menu-btn"); 
    const userAccountBtn = document.querySelector("#user-account-btn")?.closest('li');
    const generateReportBtn = document.querySelector("#generate-report")?.closest('li');
    const filterButton = document.querySelector(".filter-menu-container");
    const topBar = document.getElementById("topBar");
    const notificationContainer = document.getElementById("notificationContainer");
    const editAddress = document.getElementById("editAddress");
    const ticket = document.getElementById("createTicketLanding");

    // ✅ Hide top bar until we're ready
    topBar.style.display = "none";

    // ✅ Firebase Auth Listener
    firebase.auth().onAuthStateChanged(async (user) => {
        if (user) {
            const userId = user.uid;  
            const db = firebase.database();

            try {
                const snapshot = await db.ref(`users/${userId}`).once('value');
                const userData = snapshot.val();

                if (userData && userData.user_role) {
                    const role = userData.user_role.trim();
                    applyRoleRestrictions(role);  // 🚨 Only show topBar after this!
                    showTopBar(); // ✅ Call after restrictions applied
                } else {
                    console.error('❌ No user role found');
                }
            } catch (error) {
                console.error('❌ Error fetching user role:', error);
            }
        } else {
            console.error('❌ No authenticated user found');
        }
    });

    // ✅ Function to apply role restrictions
    function applyRoleRestrictions(role) {
        if (!menuButton || !userAccountBtn || !filterButton) {
            console.error('❌ Missing DOM elements');
            return;
        }

        if (role === 'Communicator') {
            filterButton.style.left = "5%";
            editAddress.style.display = 'none';
            menuButton.style.display = 'none';
            if (notificationContainer) notificationContainer.style.display = 'none';
        } else if (role === 'Resource Manager') {
            filterButton.style.display = 'none'; 
            generateReportBtn.style.display = 'none';
            editAddress.style.display = 'none';
            userAccountBtn.style.display = 'none';
            ticket.style.display = 'none';
            if (notificationContainer) notificationContainer.style.display = 'none';
        } else {
            menuButton.style.display = 'block';       
            filterButton.style.left = "5%";
            if (notificationContainer) notificationContainer.style.display = 'block';
        }
    }

    // ✅ Function to show top bar cleanly after role setup
    function showTopBar() {
        const topBar = document.getElementById("topBar");
    
        topBar.style.display = "flex";
        topBar.style.opacity = "0";
        topBar.style.transform = "translateY(-10px)";
        topBar.style.pointerEvents = "none"; // prevent interaction during fade-in
    
        setTimeout(() => {
            topBar.style.transition = "opacity 0.3s ease, transform 0.3s ease";
            topBar.style.opacity = "1";
            topBar.style.transform = "translateY(0)";
            topBar.style.pointerEvents = "auto"; // ✅ allow clicks after visible
        }, 50);
    }
    
});
