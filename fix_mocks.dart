import "dart:io";

void main() {
  var files = [
    "test/app/modules/home/controllers/home_controller_test.dart",
    "test/app/modules/cash_register/controllers/close_shift/close_shift_controller_test.dart",
    "test/app/modules/cash_register/controllers/cash_register_controller_test.dart",
    "test/app/modules/take_order/controllers/take_order_controller_test.dart",
    "test/app/modules/fiscal_data/controllers/fiscal_data_controller_test.dart",
    "test/app/modules/orders/controllers/orders_controller_test.dart",
    "test/app/modules/auth/controllers/login_controller_test.dart",
    "test/app/modules/commands/controllers/commands_controller_test.dart",
  ];
  for (var f in files) {
    var text = File(f).readAsStringSync();
    var start = text.indexOf("class MockStorageService");
    var finalEnd = start;
    var depth = 0;
    var found = false;
    for (var i = start; i < text.length; i++) {
      if (text[i] == "{") {
        depth++;
        found = true;
      }
      if (text[i] == "}") depth--;
      if (found && depth == 0) {
        finalEnd = i;
        break;
      }
    }
    var newText =
        "${text.substring(0, finalEnd)}  @override\n  Future<void> saveServerUrl(String url) async {}\n  @override\n  Future<String?> getServerUrl() async => \"http://192.168.0.103:8093\";\n  @override\n  Future<void> deleteServerUrl() async {}\n}${text.substring(finalEnd + 1)}";
    File(f).writeAsStringSync(newText);
    ("Fixed $f");
  }
}
