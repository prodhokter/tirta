import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/core/config/env_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  static GoTrueClient get auth => client.auth;
  static User? get currentUser => auth.currentUser;
  static Session? get currentSession => auth.currentSession;
  static String? get accessToken => currentSession?.accessToken;
}
