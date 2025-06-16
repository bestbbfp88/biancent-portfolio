<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Email Verification</title>
</head>
<body>
    <h2>Hello, {{ $name }}!</h2>
    <p>Thank you for registering. Please click the button below to verify your email:</p>
    <a href="{{ $verificationLink }}" style="padding: 10px 20px; background: #007BFF; color: white; text-decoration: none; border-radius: 5px;">
        Verify Email
    </a>
    <p>If you did not create an account, no action is required.</p>
</body>
</html>
