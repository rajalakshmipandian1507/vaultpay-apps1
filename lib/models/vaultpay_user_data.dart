class VaultPayUserData {
  static String name = "";
  static String mobile = "";
  static String password = "";
  static String aadhaar = "";
  static String accountNumber = "";
  static String bankName = "";
  static String ifsc = "";
  static String pin = "";

  static bool isRegistered = false;

  static void clear() {
    name = "";
    mobile = "";
    password = "";
    aadhaar = "";
    accountNumber = "";
    bankName = "";
    ifsc = "";
    pin = "";
    isRegistered = false;
  }
}