import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/take_order/bindings/take_order_binding.dart';
import '../modules/take_order/views/take_order_view.dart';
import '../modules/cash_register/bindings/open_shift_binding.dart';
import '../modules/cash_register/views/open_shift_view.dart';
import '../modules/cash_register/bindings/close_shift/close_shift_binding.dart';
import '../modules/cash_register/views/close_shift/close_shift_view.dart';
import '../modules/cash_register/bindings/expenses/expenses_binding.dart';
import '../modules/cash_register/views/expenses/expenses_view.dart';
import '../modules/cash_register/bindings/pending_closes/pending_closes_binding.dart';
import '../modules/cash_register/views/pending_closes/pending_closes_view.dart';
import '../modules/cash_register/bindings/withdrawals_history/withdrawals_history_binding.dart';
import '../modules/cash_register/views/withdrawals_history/withdrawals_history_view.dart';
import '../modules/customers/bindings/customer_binding.dart';
import '../modules/customers/views/customer_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/tables/bindings/tables_binding.dart';
import '../modules/tables/views/tables_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/users_view.dart';
import '../modules/printer_settings/bindings/printer_settings_binding.dart';
import '../modules/printer_settings/views/printer_settings_view.dart';
import '../modules/fiscal_data/bindings/fiscal_data_binding.dart';
import '../modules/fiscal_data/views/fiscal_data_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/subscription/bindings/subscription_binding.dart';
import '../modules/subscription/views/subscription_view.dart';
import '../modules/order_settings/bindings/order_settings_binding.dart';
import '../modules/order_settings/views/order_settings_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/payment_methods/bindings/payment_methods_binding.dart';
import '../modules/payment_methods/views/payment_methods_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/app_update/bindings/app_update_binding.dart';
import '../modules/app_update/views/app_update_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.MENU,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: Routes.TABLES,
      page: () => const TablesView(),
      binding: TablesBinding(),
    ),
    GetPage(
      name: Routes.USERS,
      page: () => const UsersView(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.TAKE_ORDER,
      page: () => const TakeOrderView(),
      binding: TakeOrderBinding(),
    ),
    GetPage(
      name: Routes.OPEN_SHIFT,
      page: () => const OpenShiftView(),
      binding: OpenShiftBinding(),
    ),
    GetPage(
      name: Routes.CLOSE_SHIFT,
      page: () => const CloseShiftView(),
      binding: CloseShiftBinding(),
    ),
    GetPage(
      name: Routes.EXPENSES,
      page: () => const ExpensesView(),
      binding: ExpensesBinding(),
    ),
    GetPage(
      name: Routes.PENDING_CLOSES,
      page: () => const PendingClosesView(),
      binding: PendingClosesBinding(),
    ),
    GetPage(
      name: Routes.WITHDRAWALS_HISTORY,
      page: () => const WithdrawalsHistoryView(),
      binding: WithdrawalsHistoryBinding(),
    ),
    GetPage(
      name: Routes.CUSTOMERS,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: Routes.PRINTER_SETTINGS,
      page: () => const PrinterSettingsView(),
      binding: PrinterSettingsBinding(),
    ),
    GetPage(
      name: Routes.FISCAL_DATA,
      page: () => const FiscalDataView(),
      binding: FiscalDataBinding(),
    ),
    GetPage(
      name: Routes.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_METHODS,
      page: () => const PaymentMethodsView(),
      binding: PaymentMethodsBinding(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.APP_UPDATE,
      page: () => const AppUpdateView(),
      binding: AppUpdateBinding(),
    ),
    GetPage(
      name: Routes.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: Routes.ORDER_SETTINGS,
      page: () => const OrderSettingsView(),
      binding: OrderSettingsBinding(),
    ),
  ];
}
