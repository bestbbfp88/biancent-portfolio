$(document).ready(function () {
    $("#registration-form").submit(async function (event) {
        event.preventDefault();
        $(".error").text("");
        let hasError = false;

        const fname = $("#fname").val().trim();
        const lname = $("#lname").val().trim();
        const birthdate = $("#birthdate").val().trim();
        const address = $("#address").val().trim();
        const gender = $("#gender").val();
        const user_contact = $("#user_contact").val().trim();
        const email = $("#email").val().trim();
        const password = $("#password").val();
        const passwordConfirm = $("#password_confirmation").val();

        if (fname === "") {
            $("#fnameError").text("First name is required.");
            hasError = true;
        }

        if (lname === "") {
            $("#lnameError").text("Last name is required.");
            hasError = true;
        }

        if (birthdate === "") {
            $("#birthdateError").text("Birthdate is required.");
            hasError = true;
        }

        if (address === "") {
            $("#addressError").text("Address is required.");
            hasError = true;
        }

        if (gender === "") {
            $("#genderError").text("Please select a gender.");
            hasError = true;
        }

        const contactRegex = /^[0-9]{10,15}$/;
        if (!contactRegex.test(user_contact)) {
            $("#contactError").text("Enter a valid contact number (10-15 digits).");
            hasError = true;
        }

        if (password.length < 6) {
            $("#passwordError").text("Password must be at least 6 characters.");
            hasError = true;
        }

        if (password !== passwordConfirm) {
            $("#passwordConfirmError").text("Passwords do not match.");
            hasError = true;
        }

        if (hasError) {
            hideLoadingModal();
            return;
        }

        showLoadingModal(); // Show modal just before AJAX

        try {
            const response = await $.ajax({
                url: "/check-email",
                method: "POST",
                data: {
                    email: email,
                    _token: $('meta[name="csrf-token"]').attr('content')
                }
            });

            if (!response.valid) {
                $("#emailError").text("Email is already in use.");
                hideLoadingModal();
                return;
            }
        } catch (e) {
            $("#emailError").text("Unable to verify email. Please try again.");
            hideLoadingModal();
            return;
        }

        // Everything validated: submit form
        $("#registration-form")[0].submit();
    });

    function showLoadingModal() {
        $("#loadingModal").fadeIn(200);
    }

    function hideLoadingModal() {
        $("#loadingModal").fadeOut(200);
    }
});
