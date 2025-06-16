<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <link rel="stylesheet" href="{{ asset('css/registration.css') }}">
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</head>
<body>
    <div class="full-width-container">
        <div class="signup-container">
            <div class="signup-left">
                <h1>Rapid Response, Saving Lives!</h1>
            </div>

            <div class="signup-right">
                <h2>Create an Account</h2>

                <form id="registration-form" action="/admin/register" method="POST">
                    @csrf

                    <div class="form-row">
                        <div class="form-group">
                            <label>First Name</label>
                            <input type="text" name="fname" id="fname" placeholder="First Name" required>
                            <span class="error" id="fnameError"></span>
                        </div>
                        <div class="form-group">
                            <label>Last Name</label>
                            <input type="text" name="lname" id="lname" placeholder="Last Name" required>
                            <span class="error" id="lnameError"></span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" id="email" placeholder="Email" required>
                        <span class="error" id="emailError"></span>
                    </div>

                    <div class="form-group">
                        <label>Address</label>
                        <input type="text" name="address" id="address" placeholder="Address" required>
                        <span class="error" id="addressError"></span>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Birthdate</label>
                            <input type="date" name="birthdate" id="birthdate" required>
                            <span class="error" id="birthdateError"></span>
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="gender" id="gender" required>
                                <option value="">Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                            <span class="error" id="genderError"></span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Contact Number</label>
                        <input type="text" name="user_contact" id="user_contact" placeholder="Contact Number" required>
                        <span class="error" id="contactError"></span>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Create Password</label>
                            <input type="password" name="password" id="password" placeholder="Password" required>
                            <span class="error" id="passwordError"></span>
                        </div>
                        <div class="form-group">
                            <label>Confirm Password</label>
                            <input type="password" name="password_confirmation" id="password_confirmation" placeholder="Confirm Password" required>
                            <span class="error" id="passwordConfirmError"></span>
                        </div>
                    </div>


                    <button type="submit" class="btn-primary">Create Account</button>

                   
                </form>
            </div>
        </div>
    </div>

    <div id="loadingModal" class="modal" style="display: none; position: fixed; z-index: 1200; left: 0; top: 0; width: 100%; height: 100%; overflow: hidden; background: rgba(0, 0, 0, 0.5);">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);">
            <div class="spinner-border text-light" role="status">
                <span class="sr-only"></span>
            </div>
        </div>
    </div>

    <script src="{{ asset('js/essentials/registration.js') }}"></script>
</body>
</html>
