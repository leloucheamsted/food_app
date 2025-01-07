import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_app/presentation/blocs/home/home_bloc.dart';
import 'package:food_app/presentation/widgets/app_bar_widget.dart';
import 'package:food_app/presentation/widgets/custom_card.dart';
import 'package:food_app/presentation/widgets/fake_box.dart';
import 'package:food_app/utilities/constants.dart';
import 'package:food_app/utilities/layout_constants.dart';
import 'package:wyatt_type_utils/wyatt_type_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  double _currentSliderValue = 10;
  String currenKey = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarwidget(),
        backgroundColor: ColorPalette.bgColor,
        body: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          if (state is HomeExceptionState) {
            return _buildErrorWidget();
          }

          if (state is HomeLoadedState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SvgPicture.asset(
                        IconsName.search,
                        height: 30,
                        width: 40,
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: TextField(
                          // DISABLED: autofocus: true AND INPUT
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Search for restaurants',
                            hintStyle: TextStyle(
                              color: ColorPalette.grey1,
                              fontSize: FontsSize.head6,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor: ColorPalette.bgColor,
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    height: 400,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            // create close button with  ripple effect
                                            Material(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    IconsName.close,
                                                    height: 25,
                                                    width: 30,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('',
                                                    style: TextStyle(
                                                        fontSize:
                                                            FontsSize.head6,
                                                        fontFamily:
                                                            Fonts.medium,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            )),
                                            // create outline button to reset filters
                                            OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  currenKey = '';
                                                  _currentSliderValue = 10;
                                                });
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(const InitHomeEvent());
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  const Text('Reset Filters'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Filter by Type of Restaurants',
                                          style: TextStyle(
                                              fontFamily: Fonts.regular,
                                              fontSize: FontsSize.large),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          height: 50,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: restaurantTypes.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ChoiceChip(
                                                  label: Text(
                                                      restaurantTypes[index]
                                                          ['name']!),
                                                  selected: currenKey ==
                                                      restaurantTypes[index]
                                                          ['key'],
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      currenKey = selected
                                                          ? restaurantTypes[
                                                              index]['key']!
                                                          : '';
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Add your distance filter options here
                                        const Text(
                                          'Filter by Distance Location',
                                          style: TextStyle(
                                              fontFamily: Fonts.regular,
                                              fontSize: FontsSize.large),
                                        ),
                                        Slider(
                                          value: _currentSliderValue,
                                          min: 0,
                                          max: 50,
                                          divisions: 10,
                                          label:
                                              '${_currentSliderValue.round()} km',
                                          onChanged: (value) {
                                            setState(() {
                                              _currentSliderValue = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        // apply button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize: const Size(
                                                      double.infinity, 50),
                                                  backgroundColor:
                                                      ColorPalette.red,
                                                  textStyle: const TextStyle(
                                                      fontSize: FontsSize.large,
                                                      color:
                                                          ColorPalette.white),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // call filter event
                                                  BlocProvider.of<HomeBloc>(
                                                          context)
                                                      .add(
                                                          FiltersRestaurantEvent(
                                                              type: currenKey));
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Apply Filters',
                                                  style: TextStyle(
                                                    fontSize: FontsSize.large,
                                                    color: ColorPalette.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              IconsName.filters,
                              height: 30,
                              width: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Text(
                        'Popular Restaurants',
                        style: TextStyle(
                          fontSize: FontsSize.head6,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: FontsSize.head6,
                          color: ColorPalette.grey2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.restaurants.length,
                      itemBuilder: (context, index) {
                        return state.restaurants[index].mediumPhoto.url
                                .isNullOrEmpty
                            ? const SizedBox()
                            : CustomCard(
                                imageUrl:
                                    state.restaurants[index].mediumPhoto.url,
                                rating: state.restaurants[index].ranking,
                                price: state.restaurants[index].price,
                                title: state.restaurants[index].name,
                                location: state.restaurants[index].location);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return lazyLoading();
        }));
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('An error occurred'),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<HomeBloc>(context).add(const InitHomeEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  Widget lazyLoading() {
    return ListView(
      children: [
        ...List.generate(8, (index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: FakeBox(
              width: double.infinity,
              height: 160,
            ),
          );
        })
      ],
    );
  }
}
