class UrlPaths {
  const UrlPaths._();

  // Authentication
  static const String signIn = 'authentication/login';

  // Orders
  static const String getOriginTypes = 'orders/origin-types';
  static const String createOrder = 'orders/create';
  static const String getOrdersByStatus = 'orders/by-status';

  // Tables
  static const String getAvailableTables = 'tables/by-status/AVAILABLE';

  // Categories
  static const String getCategories = 'categories/all';
}
