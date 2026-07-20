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
  static const String getPaymentMethodsActive = 'payment-methods/config/active';
  static const String getPaymentMethodsAll = 'payment-methods/config';
  static const String updatePaymentMethod = 'payment-methods/config'; // /config/{method}

  // Transactions
  static const String getTransactionTypes = 'transactions/types';
  static const String createTransaction = 'transactions/create';
  static const String getTransactionInvoice = 'transactions'; // /:id/invoice

  // Tables
  static const String getAvailableTables = 'tables/by-status/AVAILABLE';
  static const String getTablesAll = 'tables/all';
  static const String getTableById = 'tables/get-by-id'; // /:id
  static const String getTablesByStatus = 'tables/by-status'; // /:status
  static const String getTablesByLocation = 'tables/by-location'; // /:location
  static const String createTables = 'tables/create';
  static const String updateTable = 'tables/update'; // /:id
  static const String deleteTable = 'tables/delete'; // /:id
  static const String getTableStatuses = 'tables/statuses';
  static const String reserveTables = 'tables/reserve';
  static const String releaseTables = 'tables/release';

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
  static const String updateCategoryPrinter = 'categories'; // /:id/printer

  // Print Zones
  static const String getPrintZones = 'print-zones/all';
  static const String createPrintZone = 'print-zones/create';
  static const String updatePrintZone = 'print-zones/update'; // /:id
  static const String deletePrintZone = 'print-zones/delete'; // /:id

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
  static const String resetPassword = 'users'; // /{id}/reset-password
  static const String toggleUserStatus = 'users'; // /{id}/toggle-status
  static const String changeMyPassword = 'users/me/change-password';

  // Roles
  static const String getRoles = 'roles/all';
  static const String getTerminals = 'terminals/all';
  static const String openCashierShift = 'cashier-shifts/open';
  static const String closeCashierShift = 'cashier-shifts/close/cashier';

  // Cashier Shifts
  static const String getCashierShift = 'cashier-shifts'; // /{id}
  static const String getAllCashierShifts = 'cashier-shifts/all';
  static const String getCashierShiftsByStatus = 'cashier-shifts/by-status'; // /{status}
  static const String getCashierShiftsByCashier = 'cashier-shifts/by-cashier'; // /{cashierId}
  static const String getActiveShiftByTerminal = 'cashier-shifts/active/terminal'; // /{terminalId}
  static const String getCashierShiftSummary = 'cashier-shifts'; // /{id}/summary
  static const String reconcileCashierShift = 'cashier-shifts'; // /{id}/reconcile
  static const String getCashierShiftStatuses = 'cashier-shifts/statuses';

  // Cash Withdrawals
  static const String getCashWithdrawalReasons = 'cash-withdrawals/reasons';
  static const String getCashWithdrawalPaymentSources =
      'cash-withdrawals/payment-sources';
  static const String createCashWithdrawal = 'cash-withdrawals/register';
  static const String getCashWithdrawalsByShift = 'cash-withdrawals/by-shift'; // /{shiftId}
  static const String getAllCashWithdrawals = 'cash-withdrawals/all';
  static const String getCashWithdrawalHistory = 'cash-withdrawals/history';
  static const String exportCashWithdrawals = 'cash-withdrawals/export';

  // Fiscal Data
  static const String fiscalDataCreate = 'fiscal-data/create';
  static const String fiscalDataUpdate = 'fiscal-data'; // put /id
  static const String fiscalDataActive = 'fiscal-data/active'; // ?branchId=
  static const String fiscalDataGet = 'fiscal-data'; // get /id
  static const String fiscalDataAll = 'fiscal-data/all'; // ?branchId=
  static const String fiscalDataDeactivate = 'fiscal-data'; // patch /id/deactivate
  // Reports
  static const String getSalesReport = 'reports/sales';
  static const String getSalesReportByDateTime = 'reports/sales/datetime';
  static const String getSalesReportByShift = 'reports/sales/shift';

  // Branches
  static const String updateBranch = 'branches'; // put /{id}
  static const String updateBranchWaiterFilter = 'branches'; // patch /{id}/waiter-filter

  // Inventory
  static const String inventoryItems = 'inventory/items';
  static const String inventoryAlerts = 'inventory/items/alerts';
  static const String inventoryRecipes = 'inventory/recipes';
  static const String inventoryMovements = 'inventory/movements';
  static const String inventoryItemProducts = 'inventory/items'; // GET /{id}/products
  static const String exportInventoryItems = 'inventory/items/export';
  static const String exportInventoryMovements = 'inventory/movements/export';

  // Combos
  static const String addComboOption = 'combos/groups'; // /{groupId}/options
  static const String removeComboOption = 'combos/options'; // /{optionId}
  static const String toggleComboOption = 'combos/options'; // /{optionId}/toggle
}
