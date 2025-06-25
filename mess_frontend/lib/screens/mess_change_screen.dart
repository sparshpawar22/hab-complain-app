import 'package:flutter/material.dart';
import 'package:frontend1/apis/users/user.dart';
import 'package:frontend1/widgets/common/hostel_details.dart';
import 'package:frontend1/widgets/common/hostel_name.dart';
import 'package:frontend1/widgets/confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend1/widgets/common/name_trimmer.dart';
import 'package:frontend1/widgets/common/snack_bar.dart';
import 'package:frontend1/widgets/common/custom_linear_progress.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class MessChangeScreen extends StatefulWidget {
  const MessChangeScreen({super.key});

  @override
  State<MessChangeScreen> createState() => _MessChangeScreenState();
}

class _MessChangeScreenState extends State<MessChangeScreen> {
  String name = '';
  String email = '';
  String roll = '';
  String hostel = '';
  String currMess = '';
  String applyMess = '';
  String? newSelectedHostelfromList;
  String? selectedHostel;
  bool isSubmitted = false;
  bool correctDate = false;
  bool gotMess = false;
  bool _isloading = false;

  final List<String> hostels = [
    'Lohit',
    'Kapili',
    'Umiam',
    'Gaurang',
    'Manas',
    'Brahmaputra',
    'Dihing',
    'MSH',
    'Dhansiri',
    'Kameng',
    'Subansiri',
    'Siang',
    'Disang',
  ];

  final SingleSelectController<String> hostelController =
      SingleSelectController<String>(null);

  @override
  void initState() {
    super.initState();

    fetchUserData();
    getAllocatedHostel();
    // Reset state if it's a new week (Monday)
    _checkAllowedDays();
  }

  late String Message = 'You can apply for any Hostel';

  // Check if the button should be enabled
  Future<void> _checkAllowedDays() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final clicked = prefs.getBool('buttonpressed') ?? false;
    final gotMess1 = prefs.getBool('gotMess') ?? false;
    print("you pressed : $clicked");
    // Update the state based on the condition

    setState(() {
      correctDate =
          (now.day >= 25 && now.day <= 28);
      isSubmitted = clicked;
      gotMess = gotMess1;
    });
    print("isSubmitted is: $isSubmitted");
  }

  void getAllocatedHostel() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMess = prefs.getString('currMess');
    final hostel1 = prefs.getString('hostel');
    final appliedMess = prefs.getString('appliedMess');
    setState(() {
      currMess = currentMess ?? 'Not Assigned';
      applyMess = appliedMess ?? '';
      currMess = currentMess ?? 'Not Assigned';
      hostel = hostel1 ?? 'Not Assigned';
      selectedHostel = appliedMess ?? '';
      applyMess = appliedMess ?? '';
    });
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isloading = true; // Show the loading indicator
    });

    final userDetails = await fetchUserDetails();
    if (userDetails != null) {
      setState(() {
        name = userDetails['name'] ?? '';
        email = userDetails['email'] ?? '';
        roll = userDetails['roll'] ?? '';
        _isloading = false; // Hide the loading indicator imp
      });
    } else {
      print("Failed to load user details.");
      setState(() {
        _isloading = false; // Hide the loading indicator if data fetching fails need to keep track of stuff
      });
      showSnackBar('Something Went Wrong',Colors.black, context);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        onConfirm: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // Refresh function for pull-to-refresh
  Future<void> _onRefresh() async {
    await fetchUserData();
    getAllocatedHostel();
    // Reset state if it's a new date (i.e 25)
    _checkAllowedDays(); // Refresh data when pulled
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Change Mess",
          style: TextStyle(
              fontFamily: 'OpenSans_bold',
              fontWeight: FontWeight.w400,
              fontSize: 24),
        ),
      ),
      body: _isloading
          ? const CustomLinearProgress(
              text: 'Loading your details, please wait....')
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Mess",
                        style: TextStyle(
                            fontFamily: 'OpenSans_regular',
                            fontSize: 16,
                            color: Color.fromRGBO(0, 0, 0, 1)),
                      ),
                      Text(
                        calculateHostel(currMess),
                        style: const TextStyle(
                          fontFamily: 'OpenSans_bold',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(57, 77, 198, 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Name",
                        style: TextStyle(
                            fontFamily: 'OpenSans_regular',
                            fontSize: 16,
                            color: Color.fromRGBO(0, 0, 0, 1)),
                      ),
                      Text(
                        capitalizeWords(name),
                        style: const TextStyle(
                            fontFamily: 'OpenSans_regular',
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Roll Number",
                            style: TextStyle(
                                fontFamily: 'OpenSans_regular',
                                fontSize: 16,
                                color: Color.fromRGBO(0, 0, 0, 1)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right:
                                    10.0), // Adding padding only to the right
                            child: const Text(
                              "Hostel",
                              style: TextStyle(
                                fontFamily: 'OpenSans_regular',
                                fontSize: 16,
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            roll.isNotEmpty ? roll : 'Not provided',
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right:
                                    10.0), // Adding padding only to the right
                            child: Text(
                              calculateHostel(hostel),
                              style: const TextStyle(
                                fontFamily: 'OpenSans_regular',
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!isSubmitted && correctDate) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Change mess to:",
                          style: TextStyle(
                              fontFamily: 'OpenSans_regular',
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        CustomDropdown<String>(
                          controller: hostelController,
                          items: hostels
                              .where((hostelName) =>
                                  hostelName !=
                                  calculateHostel(
                                      hostel)) // Exclude the current hostel
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              newSelectedHostelfromList = value;
                              selectedHostel =
                                  newSelectedHostelfromList; // Update the selected hostel
                            });
                          },
                          hintText:
                              "Change Mess to: ${newSelectedHostelfromList ?? ''}",
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Reason for changing",
                          style: TextStyle(
                              fontFamily: 'OpenSans_regular',
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const TextField(
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: "Write your reason here",
                              contentPadding: EdgeInsets.all(16.0),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else if (!correctDate && isSubmitted && !gotMess) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      "Sorry!",
                                      style: TextStyle(
                                        fontFamily: 'OpenSans_reqular',
                                        fontSize: 20,
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "Apply again Next month",
                                      style: TextStyle(
                                        fontFamily: 'OpenSans_bold',
                                        fontSize: 16,
                                        color: Color.fromRGBO(57, 77, 197, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else if (!correctDate && isSubmitted && gotMess) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Your Allotted Mess for Next month is:",
                                      style: TextStyle(
                                        fontFamily: 'OpenSans_regular',
                                        fontSize: 16,
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "$applyMess",
                                      style: const TextStyle(
                                        fontFamily: 'OpenSans_bold',
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(57, 77, 197, 1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else if (correctDate && isSubmitted) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      "You have applied for the mess: ",
                                      style: TextStyle(
                                        fontFamily: 'OpenSans_regular',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "$selectedHostel",
                                      style: const TextStyle(
                                        fontFamily: 'OpenSans_regular',
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(57, 77, 197, 1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      "You can apply next month.",
                                      style: TextStyle(
                                        fontFamily: 'OpenSans_bold',
                                        fontSize: 16,
                                        color: Color.fromRGBO(57, 77, 198, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!isSubmitted && correctDate)
                        Center(
                          child: ElevatedButton(
                            onPressed: newSelectedHostelfromList == null || calculateHostel(hostel) != hostels
                                ? null // Disable the button if no hostel is selected
                                : () async {
                                    setState(() {
                                      isSubmitted = true; // Mark as submitted
                                    });
                                    selectedHostel = newSelectedHostelfromList;
                                    await fetchHostelData(
                                        selectedHostel!, roll);
                                    await fetchUserDetails();
                                    _showConfirmationDialog();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: newSelectedHostelfromList == null || calculateHostel(hostel) != hostels
                                  ? Colors
                                      .grey // Grey out the button if disabled
                                  : const Color.fromRGBO(57, 77, 198,
                                      1), // Enable button when selected
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Confirm Your Choice",
                              style: TextStyle(
                                  fontFamily: 'OpenSans_bold',
                                  color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
