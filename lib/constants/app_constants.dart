class AppConstants {
  // Nombres de las colecciones en Supabase
  static const String inventarioTable = 'inventario';
  static const String marcasTable = 'marcas';
  static const String clientesTable = 'clientes';
  static const String medidasCompatiblesTable = 'medidas_compatibles';
  static const String redFavoritosTable = 'red_favoritos';
  static const String serviciosTable = 'servicios';
  
  // Nombres de los buckets en Supabase Storage
  static const String tirePhotosBucket = 'tire_photos';
  static const String profilePhotosBucket = 'profile_photos';
  
  // Formatos de fecha
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Prefijos para códigos QR
  static const String qrPrefix = 'REDLLANTERA:';
  
  // Límites y configuraciones
  static const int maxSearchResults = 50;
  static const int maxImageSize = 1200; // píxeles
  static const int imageQuality = 85; // porcentaje
  
  // Mensajes de error comunes
  static const String errorGenerico = 'Ha ocurrido un error. Por favor, inténtalo de nuevo.';
  static const String errorConexion = 'Error de conexión. Verifica tu conexión a internet.';
  static const String errorAutenticacion = 'Error de autenticación. Por favor, inicia sesión nuevamente.';
  static const String errorPermisosCamara = 'Se requieren permisos de cámara para esta función.';
  static const String errorPermisosGaleria = 'Se requieren permisos de galería para esta función.';
  
  // Rutas de navegación
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String qrScannerRoute = '/qr-scanner';
  static const String inventorySearchRoute = '/inventory-search';
  static const String tireDetailRoute = '/tire-detail';
  static const String networkRoute = '/network';
  
  // Valores por defecto
  static const double defaultTireDepth = 0.0;
  static const double defaultTirePrice = 0.0;
}