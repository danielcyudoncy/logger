import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'myapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('https://aupqpqgdchwwmgdwdjdd.supabase.co'),
    anonKey: const String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1cHFwcWdkY2h3d21nZHdkamRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5OTA3NDQsImV4cCI6MjA1NTU2Njc0NH0.CwJGsPSQpFcPjmo5XnOIsznyXJopJiUFVsiHqxKbIo8'),
  );

  runApp(const MyApp());
}

