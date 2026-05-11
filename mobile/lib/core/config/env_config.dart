class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  static const String vpsApiBaseUrl = String.fromEnvironment(
    'VPS_API_BASE_URL',
    defaultValue: 'https://your-vps-domain.com/api',
  );
}
