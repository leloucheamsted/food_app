// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:slike/pages/bottombar.dart';
import 'package:slike/provider/generalprovider.dart';
import 'package:slike/provider/latestfeedprovider.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/customwidget.dart';
import 'package:slike/utils/dimens.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers for carousel
  late GeneralProvider generalProvider;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 5;

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  late LatestFeedProvider latestFeedProvider;
  late ScrollController _categoryScrollController;

  // Date of birth
  DateTime? _selectedDate;

  // Selected country
  Country? _selectedCountry;

  // Password visibility
  bool _isPasswordVisible = false;

  // Terms and conditions
  String feature = '';

  @override
  void initState() {
    super.initState();
    latestFeedProvider = Provider.of<LatestFeedProvider>(
      context,
      listen: false,
    );
    _categoryScrollController = ScrollController();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryController.dispose();
    super.dispose();
    super.dispose();
  }

  Future<void> _fetchCategory(int? nextPage) async {
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await latestFeedProvider.getCategory((nextPage ?? 0) + 1);
    await latestFeedProvider.setCategoryLoadMore(false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: colorAccent,
              onPrimary: colorPrimary,
              surface: colorPrimary,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: colorPrimary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      if (_currentPage < _numPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitSignUp();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return true;

      case 1:
        if (feature.isEmpty) {
          Utils.showSnackbar(context, "Please select a feature", false);
          return false;
        }
        return true;

      case 2:
        // Profile details validation username , first name, secon name , email and password
        if (_userNameController.text.isEmpty) {
          Utils.showSnackbar(context, "Please enter a username", false);
          return false;
        }
        if (_firstNameController.text.isEmpty) {
          Utils.showSnackbar(context, "Please enter your first name", false);
          return false;
        }
        if (_lastNameController.text.isEmpty) {
          Utils.showSnackbar(context, "Please enter your last name", false);
          return false;
        }
        if (_emailController.text.isEmpty) {
          Utils.showSnackbar(context, "Please enter your email", false);
          return false;
        }
        if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(_emailController.text)) {
          Utils.showSnackbar(
            context,
            "Please enter a valid email address",
            false,
          );
          return false;
        }
        if (_passwordController.text.isEmpty) {
          Utils.showSnackbar(context, "Please enter a password", false);
          return false;
        }
        if (_passwordController.text.length < 8) {
          Utils.showSnackbar(
            context,
            "Password must be at least 8 characters",
            false,
          );
          return false;
        }

        if (_selectedDate == null) {
          Utils.showSnackbar(
            context,
            "Please select your date of birth",
            false,
          );
          return false;
        }
        return true;

      case 3:
        return true;
      case 4:
        return true;

      default:
        return true;
    }
  }

  void _submitSignUp() async {
    final generalProvider = Provider.of<GeneralProvider>(
      context,
      listen: false,
    );

    generalProvider.setLoading(true);

    // This would normally call the API to register the user
    // For now, we'll just simulate a successful signup with a delay

    await Future.delayed(const Duration(seconds: 2));

    generalProvider.setLoading(false);
    //  show all the data
    printLog("Username: ${_userNameController.text}");
    printLog("Email: ${_emailController.text}");
    printLog("Password: ${_passwordController.text}");
    printLog("First Name: ${_firstNameController.text}");
    printLog("Last Name: ${_lastNameController.text}");
    printLog("Email: ${_emailController.text}");
    printLog("Password: ${_passwordController.text}");
    printLog(
      "Date of Birth: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
    );
    printLog("Country: ${_selectedCountry?.name}");
    printLog("Feature: $feature");
    printLog("Bio: ${_bioController.text}");
    printLog("Selected Categories: ${latestFeedProvider.selectedCategoryIds}");
    printLog("Selected Country: ${_selectedCountry?.name}");
    // singup
    // get device type
    // get device token
    late int deviceType;
    if (Platform.isAndroid) {
      deviceType = 0;
    } else if (Platform.isIOS) {
      deviceType = 1;
    } else {
      deviceType = 2;
    }
    // get device token
    await generalProvider
        .signupProvider(
          _emailController.text,
          _firstNameController.text,
          _lastNameController.text,
          _userNameController.text,
          _selectedCountry?.countryCode ?? "",
          _passwordController.text,
          deviceType,
          'device-token',
          DateFormat('yyyy-MM-dd').format(_selectedDate!).toString(),
          _selectedCountry?.name ?? "",
        )
        .then((value) {
          if (value.status == 200) {
            // Show success message
            // Navigate to the bottom bar (home)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Bottombar()),
              (route) => false,
            );
          } else {
            // Show error message
          }
        })
        .catchError((error) {
          generalProvider.setLoading(false);
          Utils.showSnackbar(context, error.toString(), false);
        });

    // Show success message
    // Utils.showSnackbar(context, "Account created successfully!", false);

    // // Navigate to the bottom bar (home)
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const Bottombar()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                _currentPage == 0
                    ? const AssetImage("assets/images/singup1.png")
                    : _currentPage == 1
                    ? const AssetImage("assets/images/signup2.png")
                    : _currentPage == 2
                    ? const AssetImage("assets/images/signup3.png")
                    : _currentPage == 3
                    ? const AssetImage("assets/images/signup4.png")
                    : const AssetImage("assets/images/signup5.png"),
            fit: BoxFit.cover,
          ),
          color: const Color.fromRGBO(0, 0, 0, 0.5),
        ),
        child: Stack(
          children: [
            // Back button
            Column(
              children: [
                const SizedBox(height: 20),
                // Carousel
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Page 1: Basic Information
                      _showGetStatingPage(),
                      _builFeaturesSlikePage(),
                      _buildBasicInfoPage(),
                      _buildChoiceCategoryPage(),
                      _showEndStepPage(),
                      // Page 4: Food Preferences
                    ],
                  ),
                ),

                // Next button

                // Page indicator
              ],
            ),
            Positioned(
              bottom: 30,
              left: MediaQuery.of(context).size.width / 2 - 50,
              right: 0,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _numPages,
                effect: const ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 8,
                  spacing: 8,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                ),
              ),
            ),
            // Loading indicator
            Positioned(
              top: 50,
              left: 16,
              child: SizedBox(
                child:
                    _currentPage > 1
                        ? IconButton(
                          onPressed: () => _previousPage(),

                          icon: SvgPicture.asset(
                            "assets/icons/back.svg",
                            height: 24,
                            width: 24,
                            colorFilter: const ColorFilter.mode(
                              colorAccent,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
            Consumer<GeneralProvider>(
              builder: (context, provider, child) {
                return provider.isProgressLoading
                    ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(color: colorAccent),
                      ),
                    )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 3,
        maxItemsPerRow: 3,
        horizontalGridSpacing: 15,
        verticalGridSpacing: 15,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
        children: List.generate(18, (index) {
          return const CustomWidget.roundrectborder(height: 40, width: 90);
        }),
      ),
    );
  }

  Widget categoryChipList() {
    _fetchCategory(0);
    return Consumer<LatestFeedProvider>(
      builder: (context, categoryProvider, child) {
        if (latestFeedProvider.categoryloading &&
            !latestFeedProvider.categoryloadMore) {
          return categoryShimmer();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _categoryScrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                (latestFeedProvider.categorydataList != null &&
                        (latestFeedProvider.categorydataList?.length ?? 0) > 0)
                    ? Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      alignment: WrapAlignment.start,
                      children:
                          latestFeedProvider.categorydataList!.map((category) {
                            final isSelected = categoryProvider
                                .selectedCategoryIds
                                .contains(category.id);

                            return ChoiceChip(
                              showCheckmark: false,
                              surfaceTintColor: colorPrimary,
                              disabledColor: colorPrimary,
                              label: MyText(
                                color: isSelected ? Colors.black : white,
                                text: category.name.toString().toUpperCase(),
                                fontwaight: FontWeight.w400,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                              side: const BorderSide(
                                color: colorAccent,
                                width: 1,
                              ),
                              selected: isSelected,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              selectedColor: white,
                              backgroundColor: colorAccent,
                              color: WidgetStatePropertyAll(
                                isSelected ? colorAccent : colorPrimary,
                              ),
                              elevation: 0,
                              pressElevation: 0,
                              autofocus: false,
                              onSelected: (bool selected) async {
                                categoryProvider.toggleCategory(
                                  category.id ?? 0,
                                );
                              },
                            );
                          }).toList(),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _showGetStatingPage() {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: ColoredBox(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  "WELCOME TO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto",
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/images/appicon.png",
                      height: 250,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: colorAccent, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 0
                                ? 'Get started'
                                : _currentPage < _numPages - 1
                                ? "Next"
                                : "Create Account",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (_currentPage < _numPages - 1) ...[
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              "assets/icons/next.svg",
                              height: 18,
                              width: 18,
                              colorFilter: const ColorFilter.mode(
                                colorAccent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showEndStepPage() {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: ColoredBox(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // insert app image here
                Image.asset(
                  "assets/images/appicon.png",
                  height: 90,
                  fit: BoxFit.fitHeight,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'It’s Your Turn!'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,

                            // make my text  uppercase
                          ),
                        ),

                        const Text(
                          'Join the community and start sharing your sports moments. This is where it all begins!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,

                            // make my text  uppercase
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: colorAccent, width: 1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Validate",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _builFeaturesSlikePage() {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "FEATURES OF SLIKE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Join a sports community',

                                  // wrap text
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                    // wrap text
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      feature = 'Join a sports community';
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/people.svg",
                                        height: 80,
                                        width: 80,
                                        colorFilter: const ColorFilter.mode(
                                          colorAccent,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Discover sports content',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      feature = 'Discover sports content';
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/discover_sport.svg",
                                        height: 80,
                                        width: 80,
                                        colorFilter: const ColorFilter.mode(
                                          colorAccent,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Go live',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      feature = 'Go live';
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/go_live.svg",
                                        height: 80,
                                        width: 80,
                                        colorFilter: const ColorFilter.mode(
                                          colorAccent,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Earn rewards',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      feature = 'Earn rewards';
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/earn.svg",
                                        height: 80,
                                        width: 80,
                                        colorFilter: const ColorFilter.mode(
                                          colorAccent,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(color: colorAccent, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 28),
                        SvgPicture.asset(
                          "assets/icons/next.svg",
                          height: 18,
                          width: 18,
                          colorFilter: const ColorFilter.mode(
                            colorAccent,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          // insert app image here
          Image.asset(
            "assets/images/appicon.png",
            height: 90,
            fit: BoxFit.fitHeight,
          ),

          const SizedBox(height: 10),

          // Full Name
          MyText(
            text: "Username",
            maxline: 1,
            fontwaight: FontWeight.w500,
            fontsizeNormal: 16,
            color: Colors.white,
            textalign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            multilanguage: false,
          ),
          _buildInputField(
            controller: _userNameController,
            hint: "Ex. jhonedoe",
            iconAsset: "assets/icons/profile.svg",
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "First Name",
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: 16,
                      color: Colors.white,
                      textalign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                      multilanguage: false,
                    ),
                    _buildInputField(
                      controller: _firstNameController,
                      hint: "First Name",
                      iconAsset: "assets/icons/profile.svg",
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "Last Name",
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: 16,
                      color: Colors.white,
                      textalign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                      multilanguage: false,
                    ),
                    _buildInputField(
                      controller: _lastNameController,
                      hint: "Last Name",
                      iconAsset: "assets/icons/profile.svg",
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: "Date Birth",
                maxline: 1,
                fontwaight: FontWeight.w500,
                fontsizeNormal: 16,
                color: Colors.white,
                textalign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
                multilanguage: false,
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1,
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/calendar.svg",
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFD700),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          _selectedDate != null
                              ? DateFormat(
                                'MMM dd, yyyy',
                              ).format(_selectedDate!)
                              : "Date of Birth",
                          style: TextStyle(
                            color:
                                _selectedDate != null
                                    ? Colors.white
                                    : Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // country picker
          MyText(
            text: "Country",
            maxline: 1,
            fontwaight: FontWeight.w500,
            fontsizeNormal: 16,
            color: Colors.white,
            textalign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            multilanguage: false,
          ),
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode:
                    true, // optional. Shows phone code before the country name.
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFFFFD700), width: 1),
                color: Colors.black.withOpacity(0.3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedCountry?.name ?? "Country",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 15),
                    SvgPicture.asset(
                      "assets/icons/arrow-down.svg",
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFFD700),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Email
          const SizedBox(height: 20),

          MyText(
            text: "Email",
            maxline: 1,
            fontwaight: FontWeight.w500,
            fontsizeNormal: 16,
            color: Colors.white,
            textalign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            multilanguage: false,
          ),
          _buildInputField(
            controller: _emailController,
            hint: "Ex. jhonedoe@gmail.com",
            iconAsset: "assets/icons/profile.svg",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          MyText(
            text: "Password",
            maxline: 1,
            fontwaight: FontWeight.w500,
            fontsizeNormal: 16,
            color: Colors.white,
            textalign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            multilanguage: false,
          ),
          // Password
          _buildPasswordField(
            controller: _passwordController,
            hint: "***********",
            isVisible: _isPasswordVisible,
            toggleVisibility: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: colorAccent, width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VALIDATE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCategoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          // insert app image here
          Image.asset(
            "assets/images/appicon.png",
            height: 90,
            fit: BoxFit.fitHeight,
          ),

          const SizedBox(height: 10),

          // Full Name
          const Text(
            "SELECT YOUR FAVORITES SPORTS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Text(
            "Choose the sports you’re most passionate about to personalize your experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 400, child: categoryChipList()),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: colorAccent, width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VALIDATE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),

        border: Border.all(color: const Color(0xFFFFD700), width: 1),
        color: Colors.black.withOpacity(0.3),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              iconAsset,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFD700),
                BlendMode.srcIn,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
        color: Colors.black.withOpacity(0.3),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              "assets/icons/lock.svg",
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFD700),
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: IconButton(
            icon: SvgPicture.asset(
              "assets/icons/eye-slash.svg",
              height: 18,
              colorFilter: ColorFilter.mode(
                isVisible ? const Color(0xFFFFD700) : Colors.white70,
                BlendMode.srcIn,
              ),
            ),
            onPressed: toggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
