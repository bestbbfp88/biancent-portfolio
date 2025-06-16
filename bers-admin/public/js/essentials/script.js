document.addEventListener("DOMContentLoaded", function () {
    const menuBtn = document.getElementById("menu-btn");
    const closeBtn = document.getElementById("close-btn");
    const sidebar = document.getElementById("sidebar");

    // ✅ Toggle Sidebar + body class
    menuBtn.addEventListener("click", function () {
        const isActive = sidebar.classList.toggle("active");

        // Add or remove 'menu-open' on body based on sidebar state
        if (isActive) {
            document.body.classList.add("menu-open");
        } else {
            document.body.classList.remove("menu-open");
        }
    });

    // ✅ Close Sidebar + remove from body
    closeBtn.addEventListener("click", function () {
        sidebar.classList.remove("active");
        document.body.classList.remove("menu-open");
    });

    // ✅ Dropdown Functionality
    document.querySelectorAll('.nav-item.has-dropdown > a').forEach(link => {
        link.addEventListener("click", function (e) {
            e.preventDefault();
            this.parentElement.classList.toggle("active");
        });
    });
});
