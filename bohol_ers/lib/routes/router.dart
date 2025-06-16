import 'package:auto_route/auto_route.dart';
import 'package:bohol_emergency_response_system/authentication/phone_log_in.dart';
import 'package:bohol_emergency_response_system/authentication/phone_otp_verification.dart';
import 'package:bohol_emergency_response_system/authentication/registration.dart';
import 'package:bohol_emergency_response_system/home_screen.dart';
import 'package:bohol_emergency_response_system/main_navigation/contact_page.dart';
import 'package:bohol_emergency_response_system/main_navigation/profile_page.dart';
import 'package:bohol_emergency_response_system/splash_screen.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
      //add routes
      AutoRoute(page: SplashRoute.page, initial: true),
      AutoRoute(page: ContactRoute.page),
      AutoRoute(page: HomeRoute.page),
      AutoRoute(page: LoginRoute.page),
      AutoRoute(page: OTPVerificationRoute.page),
      AutoRoute(page: RegistrationRoute.page),
      AutoRoute(page: ProfileRoute.page),
  ];
}