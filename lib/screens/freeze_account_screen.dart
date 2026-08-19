
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreezeAccountScreen extends StatefulWidget {
  const FreezeAccountScreen({super.key});

  @override
  State<FreezeAccountScreen> createState() => _FreezeAccountScreenState();
}

class _FreezeAccountScreenState extends State<FreezeAccountScreen> {
  String bankName = "";
  String accountNumber = "";
  bool isRegistered = false;
  bool isFrozen = false;
  bool loading = true;

  bool showVerification = false;
  bool obscurePin = true;

  final aadhaarController = TextEditingController();
  final mobileController = TextEditingController();
  final accountController = TextEditingController();
  final pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    aadhaarController.dispose();
    mobileController.dispose();
    accountController.dispose();
    pinController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD REGISTERED DATA
  // ------------------------------------------------------------

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      bankName = prefs.getString('registered_bank') ?? "";
      accountNumber = prefs.getString('registered_bank_account') ?? "";

      // Compatibility with your existing registration screen
      if (accountNumber.isEmpty) {
        accountNumber =
            prefs.getString('registered_account') ??
            prefs.getString('registered_account_number') ??
            "";
      }

      isRegistered =
          prefs.getString('registered_name') != null &&
          prefs.getString('registered_pin') != null;

      isFrozen = prefs.getBool('account_frozen') ?? false;

      loading = false;
    });
  }

  // ------------------------------------------------------------
  // FREEZE ACCOUNT
  // ------------------------------------------------------------

  Future<void> freezeAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('account_frozen', true);

    setState(() {
      isFrozen = true;
    });

    showMessage(
      "Your account has been frozen successfully.",
      Colors.red,
    );
  }

  // ------------------------------------------------------------
  // START UNFREEZE VERIFICATION
  // ------------------------------------------------------------

  void openVerification() {
    setState(() {
      showVerification = true;
    });
  }

  // ------------------------------------------------------------
  // VERIFY AND UNFREEZE
  // ------------------------------------------------------------

  Future<void> verifyAndUnfreeze() async {
    final aadhaar = aadhaarController.text.trim();
    final mobile = mobileController.text.trim();
    final account = accountController.text.trim();
    final pin = pinController.text.trim();

    if (aadhaar.isEmpty ||
        mobile.isEmpty ||
        account.isEmpty ||
        pin.isEmpty) {
      showMessage(
        "Please enter all verification details.",
        Colors.orange,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final registeredAadhaar =
        prefs.getString('registered_aadhaar') ?? "";

    final registeredMobile =
        prefs.getString('registered_mobile') ?? "";

    final registeredPin =
        prefs.getString('registered_pin') ?? "";

    String registeredAccount =
        prefs.getString('registered_bank_account') ?? "";

    if (registeredAccount.isEmpty) {
      registeredAccount =
          prefs.getString('registered_account') ??
          prefs.getString('registered_account_number') ??
          "";
    }

    // ----------------------------------------------------------
    // VERIFY EACH DETAIL
    // ----------------------------------------------------------

    if (aadhaar != registeredAadhaar) {
      showMessage(
        "Incorrect Aadhaar number.",
        Colors.red,
      );
      return;
    }

    if (mobile != registeredMobile) {
      showMessage(
        "Incorrect mobile number.",
        Colors.red,
      );
      return;
    }

    if (account != registeredAccount) {
      showMessage(
        "Incorrect bank account number.",
        Colors.red,
      );
      return;
    }

    if (pin != registeredPin) {
      showMessage(
        "Incorrect VaultPay PIN.",
        Colors.red,
      );
      return;
    }

    // ----------------------------------------------------------
    // ALL DETAILS CORRECT
    // ----------------------------------------------------------

    await prefs.setBool('account_frozen', false);

    setState(() {
      isFrozen = false;
      showVerification = false;
    });

    aadhaarController.clear();
    mobileController.clear();
    accountController.clear();
    pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Text("Account Unfrozen"),
            ],
          ),
          content: const Text(
            "Identity verification successful.\n\n"
            "Your VaultPay account has been unfrozen successfully.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("DONE"),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // ------------------------------------------------------------
  // MASK ACCOUNT NUMBER
  // ------------------------------------------------------------

  String maskedAccount() {
    if (accountNumber.isEmpty) {
      return "Account linked";
    }

    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    return "XXXX XXXX ${accountNumber.substring(accountNumber.length - 4)}";
  }

  // ------------------------------------------------------------
  // INPUT FIELD
  // ------------------------------------------------------------

  Widget verificationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isRegistered) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Freeze Account"),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              "Please complete VaultPay registration first.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Freeze Account"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 15),

            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            const Icon(
              Icons.security,
              size: 75,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            const Text(
              "Account Security",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isFrozen
                  ? "Your account is currently frozen."
                  : "Manage your linked bank account.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // ----------------------------------------------------
            // BANK CARD
            // ----------------------------------------------------

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: isFrozen ? openVerification : null,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isFrozen
                        ? Colors.red
                        : Colors.blue,
                    width: 1.5,
                  ),
                  color: isFrozen
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFrozen
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: isFrozen
                            ? Colors.red
                            : Colors.blue,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Linked Bank",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            bankName.isEmpty
                                ? "Bank Account"
                                : bankName,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            maskedAccount(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isFrozen)
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.red,
                        size: 30,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // STATUS
            // ----------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isFrozen
                    ? Colors.red.shade50
                    : Colors.green.shade50,
              ),

              child: Row(
                children: [

                  Icon(
                    isFrozen
                        ? Icons.lock
                        : Icons.lock_open,
                    color: isFrozen
                        ? Colors.red
                        : Colors.green,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      isFrozen
                          ? "ACCOUNT FROZEN"
                          : "ACCOUNT ACTIVE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isFrozen
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // FREEZE BUTTON
            // ----------------------------------------------------

            if (!isFrozen)
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            "Freeze Account?",
                          ),

                          content: const Text(
                            "Your account will be temporarily "
                            "blocked for payments and transactions.",
                          ),

                          actions: [

                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              child: const Text(
                                "CANCEL",
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                                freezeAccount();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "FREEZE",
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  icon: const Icon(Icons.lock),
                  label: const Text(
                    "FREEZE ACCOUNT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // ----------------------------------------------------
            // UNFREEZE VERIFICATION
            // ----------------------------------------------------

            if (isFrozen && showVerification) ...[

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Identity Verification",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter the details used during registration "
                  "to unfreeze your account.",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              verificationField(
                controller: aadhaarController,
                label: "Registered Aadhaar Number",
                icon: Icons.badge,
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),

              verificationField(
                controller: mobileController,
                label: "Registered Mobile Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),

              verificationField(
                controller: accountController,
                label: "Registered Account Number",
                icon: Icons.account_balance,
                keyboardType: TextInputType.number,
              ),

              verificationField(
                controller: pinController,
                label: "VaultPay PIN",
                icon: Icons.lock,
                keyboardType: TextInputType.number,
                obscureText: obscurePin,
                maxLength: 4,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePin = !obscurePin;
                    });
                  },
                  icon: Icon(
                    obscurePin
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: verifyAndUnfreeze,
                  icon: const Icon(
                    Icons.lock_open,
                  ),
                  label: const Text(
                    "VERIFY & UNFREEZE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  setState(() {
                    showVerification = false;
                  });
                },
                child: const Text(
                  "CANCEL",
                ),
              ),
            ],

            // ----------------------------------------------------
            // TAP BANK MESSAGE
            // ----------------------------------------------------

            if (isFrozen && !showVerification) ...[

              const SizedBox(height: 20),

              const Text(
                "Tap your bank account above to verify "
                "your identity and unfreeze the account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
