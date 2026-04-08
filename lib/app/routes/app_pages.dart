import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
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
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
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
  ];
}
