<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication</title>
    <link rel="stylesheet" href="/css/loginstyle.css">
</head>
<body>
    <div class="container">
        <img src="/images/bers_logo.png" alt="Login Logo" class="login-image">
        
        {{-- Success message --}}
        @if(session('success'))
            <div class="alert alert-success">
                <div>{{ session('success') }}</div>
            </div>
        @endif

        {{-- Error messages --}}
        @if ($errors->any())
            <div class="alert alert-danger">
                @foreach ($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        @endif

        <form action="/admin/login" method="POST">
            @csrf
            <label for="email">Email</label>
            <input type="email" id="email" name="email" value="{{ old('email') }}" placeholder="email@address.com" required class="input-field">
            
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password" required class="input-field">

            <button type="submit" class="btn" id="login-btn">
                <span id="btn-text">Login</span>
                <span id="btn-spinner" class="spinner" style="display: none;"></span>
            </button>
        </form>

        @if(!$adminExists)
            <p class="register-link">No admin account exists!! <a href="{{ route('register') }}">Register Now</a></p>
        @endif
    </div>
</body>

<script>
document.getElementById('login-btn').addEventListener('click', function() {
    const btn = document.getElementById('login-btn');
    const btnText = document.getElementById('btn-text');
    const spinner = document.getElementById('btn-spinner');

    // Show spinner and hide login text
    btnText.style.display = 'none';
    spinner.style.display = 'inline-block';

    // Disable the button to prevent multiple submissions
    btn.disabled = true;

    // Submit the form
    btn.closest('form').submit();
});
</script>

</html>
