@extends('layouts.app')

@section('content')
<div class="container text-center">
    <h2>Email Verification Required</h2>
    <p>We have sent a verification email to your registered email address.</p>
    <p>Please check your inbox and click the verification link.</p>

    @if (session('message'))
        <p class="alert alert-success">{{ session('message') }}</p>
    @endif

    <form method="POST" action="{{ route('admin.resend.verification') }}">
        @csrf
        <input type="hidden" name="email" value="{{ old('email') }}">
        <button type="submit" class="btn btn-primary">Resend Verification Email</button>
    </form>
</div>
@endsection
