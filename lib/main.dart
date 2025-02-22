import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'myapp.dart';

const supabaseUrl = 'https://aupqpqgdchwwmgdwdjdd.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1cHFwcWdkY2h3d21nZHdkamRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5OTA3NDQsImV4cCI6MjA1NTU2Njc0NH0.CwJGsPSQpFcPjmo5XnOIsznyXJopJiUFVsiHqxKbIo8';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const MyApp());
}
