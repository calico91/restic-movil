class UrlPaths {
  const UrlPaths._();

  // Authentication
  static const String signIn = 'authentication/login';

  // Orders
  static const String getOriginTypes = 'orders/origin-types';
  static const String createOrder = 'orders/create';
  static const String getOrderStatuses = 'orders/statuses';
  static const String getOrderDetailStatuses = 'order-details/statuses';
  static const String updateOrderDetailStatus = 'order-details/update-status';
  static const String updateOrderStatus = 'orders/update-status';
  static const String updateOrder = 'orders/update';
  static const String addProductsToOrder = 'orders'; // /:id/add-products
  static const String getOrdersByStatuses = 'orders/by-statuses';

  // Payment Methods
  static const String getPaymentMethods = 'payment-methods/all';

  // Transactions
  static const String getTransactionTypes = 'transactions/types';
  static const String createTransaction = 'transactions/create';
  static const String getTransactionInvoice = 'transactions'; // /:id/invoice

  // Tables
  static const String getAvailableTables = 'tables/by-status/AVAILABLE';

  // Customers
  static const String getCustomers = 'customers/all';
  static const String createCustomer = 'customers/create';
  static const String updateCustomer = 'customers/update';
  static const String deleteCustomer = 'customers/delete';
  static const String getCustomerById = 'customers/get-by-id';

  // Categories
  static const String getCategories = 'categories/all';
  static const String createCategories = 'categories/create';
  static const String updateCategory = 'categories/update'; // /:id

  // Subcategories
  static const String createSubcategories = 'subcategories/create';
  static const String updateSubcategory = 'subcategories/update'; // /:id

  // Products
  static const String createProducts = 'products/create';
  static const String updateProduct = 'products/update'; // /:id

  // Cashier
  static const String getAdminAndCashierUsers = 'users/admin-and-cashier';
  static const String getUsers = 'users/all';
  static const String createUser = 'users/create';
  static const String updateUser = 'users/update';
  static const String getUserById = 'users/get-by-id';

  // Roles
  static const String getRoles = 'roles/all';
  static const String getTerminals = 'terminals/all';
  static const String openCashierShift = 'cashier-shifts/open';
  static const String closeCashierShift = 'cashier-shifts/close/cashier';

  // Cash Withdrawals
  static const String getCashWithdrawalReasons = 'cash-withdrawals/reasons';
  static const String getCashWithdrawalPaymentSources =
      'cash-withdrawals/payment-sources';
  static const String createCashWithdrawal = 'cash-withdrawals';

  // Fiscal Data
  static const String fiscalDataCreate = 'fiscal-data/create';
  static const String fiscalDataUpdate = 'fiscal-data'; // put /id
  static const String fiscalDataActive = 'fiscal-data/active'; // ?branchId=
  static const String fiscalDataGet = 'fiscal-data'; // get /id
  static const String fiscalDataAll = 'fiscal-data/all'; // ?branchId=
  static const String fiscalDataDeactivate = 'fiscal-data'; // patch /id/deactivate
}
