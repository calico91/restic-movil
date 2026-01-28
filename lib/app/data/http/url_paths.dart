class UrlPaths {
  const UrlPaths._();

  // Authentication
  static const String signIn = 'authentication/login';

  // Orders
  static const String getOriginTypes = 'orders/origin-types';
  static const String createOrder = 'orders/create';
  static const String getOrdersByStatus = 'orders/by-status';
  static const String getOrderStatuses = 'orders/statuses';
  static const String getOrderDetailStatuses = 'order-details/statuses';
  static const String updateOrderDetailStatus = 'order-details/update-status';
  static const String updateOrderStatus = 'orders/update-status';
  static const String updateOrder = 'orders/update';

  // Tables
  static const String getAvailableTables = 'tables/by-status/AVAILABLE';

  // Categories
  static const String getCategories = 'categories/all';
}
