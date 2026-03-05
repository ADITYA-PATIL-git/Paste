import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/FontAwesome';
import {
  Animated,
  Dimensions,
  Image,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {useEffect, useRef, useState} from 'react';
import Privileges from './Privileges';
import TC from './TC';
import FAQ from './FAQ';
import ContactUs from './ContactUS';
import commonStyles from '../../commonComponent/CommonCss';
import LandingPage from '../LandingPage';
import LoginPage from './LoginPage';
import {useIsFocused} from '@react-navigation/native';
import React from 'react';
import {
  TourGuideProvider, // Main provider
  TourGuideZone, // Main wrapper of highlight component
  TourGuideZoneByPosition, // Component to use mask on overlay (ie, position absolute)
  useTourGuideController, // hook to start, etc.
} from 'rn-tourguide';

const InvestTab = createBottomTabNavigator();
const {width: screenWidth, height} = Dimensions.get('window');
const ITEM_WIDTH = screenWidth; // Width of each item to cover the full screen
const SPACING = 10; // Horizontal spacing between items
const sliderData = [
  {source: require('../../images/koishii-01.png')},
  {source: require('../../images/koishii-02.png')},
  {source: require('../../images/koishii-03.png')},
  {source: require('../../images/koishii-04.png')},
  {source: require('../../images/koishii-05.png')},
  {source: require('../../images/koishii-06.png')},
];

const TabNavigation = ({navigation}) => {
  const [IslandingPage, setLandingPageShown] = useState(true);
  const [activeIndex, setActiveIndex] = useState(0);
  const flatListRef = useRef(null); // Ref for the FlatList

  const userController = useTourGuideController('user');
  const adminController = useTourGuideController('admin');

  const UserTourZone = userController.TourGuideZone;
  const AdminTourZone = adminController.TourGuideZone;

  useEffect(() => {
    const autoRotate = setInterval(() => {
      if (IslandingPage) {
        setActiveIndex(prevIndex => {
          const nextIndex = (prevIndex + 1) % sliderData.length;
          // Scroll to the next item smoothly while preserving animation
          if (nextIndex === 0) {
            flatListRef.current?.scrollToIndex({
              index: nextIndex,
              animated: true,
            });
            setTimeout(() => {
              flatListRef.current?.scrollToIndex({
                index: nextIndex,
                animated: true,
              });
            }, 200); // brief delay for smoothness
          } else {
            flatListRef.current?.scrollToIndex({
              index: nextIndex,
              animated: true,
            });
          }

          return nextIndex;
        });
      }
    }, 5000);

    return () => clearInterval(autoRotate); // Cleanup on unmount
  }, []);
  // --------------------- Slider Images ---------------------------
  const handleScroll = event => {
    const contentOffsetX = event.nativeEvent.contentOffset.x;
    const newIndex = Math.round(contentOffsetX / (ITEM_WIDTH + SPACING));
    if (newIndex !== activeIndex) {
      setActiveIndex(newIndex);
    }
  };
  const SliderRender = ({item}) => (
    <View style={styles.slide}>
      <Image source={item.source} style={styles.image} />
    </View>
  );
  const renderDots = () => {
    return (
      <View style={styles.dotContainer}>
        {sliderData.map((_, index) => (
          <View
            key={index}
            style={[activeIndex === index ? styles.activeDot : styles.dot]}
          />
        ))}
      </View>
    );
  };
  //----------------------------- Tab Navigation Label ------------------------
  function MyTabBarLabel({focused, label, color}) {
    return (
      <Text
        style={[
          styles.tabBarLabel,
          {color: focused ? '#fff' : 'gray'}, // Example: Gray for inactive
          {lineHeight: 16}, // Adjust line height as needed
        ]}>
        {label}
      </Text>
    );
  }
  return (
    <SafeAreaView style={commonStyles.SafeAreaContainer}>
      {IslandingPage ? (
        <View>
          <View
            style={{
              height: '100%',
              width: '100%',
              backgroundColor: commonStyles.screenBackgroundColor,
            }}>
            <Text style={styles.headerText}>Penthouse</Text>
            <View style={styles.sliderContainer}>
              <Animated.FlatList
                ref={flatListRef} // Assign the ref here
                data={sliderData}
                keyExtractor={(item, index) => index.toString()}
                horizontal
                showsHorizontalScrollIndicator={false}
                snapToInterval={ITEM_WIDTH} // Snap to item width + spacing
                snapToAlignment="start"
                decelerationRate="normal"
                bounces={false}
                onScroll={handleScroll} // Handle scroll to update index
                renderItem={SliderRender}
              />
              {renderDots()}
            </View>
          </View>
        </View>
      ) : null}

      <InvestTab.Navigator
        initialRouteName="LoginPage"
        screenOptions={({route}) => ({
          headerShown: false,
          tabBarStyle: {
            borderTopWidth: 0,
            backgroundColor: commonStyles.screenBackgroundColor,
            position: 'absolute',
            bottom: 0,
            height: 65, // if we change this it will effect the all five tabs screen  // i give command  heighteffect by Tabbar
            paddingTop: 3,
          },
        })}>
        <InvestTab.Screen
          name="Privileges"
          component={Privileges}
          options={{
            tabBarLabel: ({focused, color}) => (
              <MyTabBarLabel
                focused={focused}
                label="Privileges"
                color={color}
              />
            ),
            tabBarIcon: ({focused}) => (
              <Image
                source={require('../../images/Privileges-Icon.png')}
                style={[styles.tabIcon, {opacity: focused ? 1 : 0.5}]}
              />
            ),
            tabBarButton: props => (
              // <TourGuideZone
              //   zone={2}
              //   tooltipBottomOffset={20}
              //   text="Tap here to view privileges"
              //   // borderRadius={12}
              //   style={{flex: 1}}>
              <TouchableOpacity
                {...props}
                onPress={() => {
                  setLandingPageShown(false);
                  props.onPress?.();
                }}>
                <View
                  style={{
                    flex: 1,
                    alignItems: 'center',
                  }}>
                  {props.children}
                </View>
              </TouchableOpacity>
              // </TourGuideZone>
            ),
          }}
        />
        <InvestTab.Screen
          name="TC"
          component={TC}
          options={{
            tabBarLabel: ({focused, color}) => (
              <MyTabBarLabel focused={focused} label="T&C" color={color} />
            ),
            tabBarIcon: ({focused}) => (
              <Image
                source={require('../../images/T&C-Icon.png')}
                style={[styles.tabIcon, {opacity: focused ? 1 : 0.5}]}
              />
            ),
            tabBarButton: props => (
              // <TourGuideZone
              //   zone={3}
              //   tooltipBottomOffset={20}
              //   text="Tap here to view terms & conditions"
              //   // borderRadius={12}
              //   style={{flex: 1}}>
              <TouchableOpacity
                {...props}
                onPress={() => {
                  setLandingPageShown(false);
                  props.onPress?.();
                }}>
                <View
                  style={{
                    flex: 1,
                    alignItems: 'center',
                  }}>
                  {props.children}
                </View>
              </TouchableOpacity>
              // </TourGuideZone>
            ),
          }}
        />
        <InvestTab.Screen
          name="LoginPage"
          children={props => (
            <LoginPage
              {...props}
              isLandingVisible={IslandingPage}
              UserTourZone={UserTourZone}
              AdminTourZone={AdminTourZone}
              canStartUser={userController.canStart}
              canStartAdmin={adminController.canStart}
              startUser={userController.start}
              startAdmin={adminController.start}
            />
          )}
          options={{
            tabBarLabel: ({focused, color}) => (
              <MyTabBarLabel focused={focused} label="" color={color} />
            ),
            tabBarIcon: () => (
              <View
                style={{
                  backgroundColor: '#fff',
                  height: 38,
                  width: 38,
                  alignItems: 'center',
                  marginTop: 3,
                  justifyContent: 'center',
                  borderRadius: 25,
                }}>
                <Icon name="user-o" color={'black'} size={22} />
              </View>
            ),
            tabBarButton: props => (
              <TouchableOpacity
                {...props}
                onPress={() => {
                  setLandingPageShown(false);
                  console.log('Tab pressed!');
                  props.onPress();
                }}
              />
            ),
          }}
        />
        <InvestTab.Screen
          name="FAQ"
          component={FAQ}
          options={{
            tabBarLabel: ({focused, color}) => (
              <MyTabBarLabel focused={focused} label="FAQ" color={color} />
            ),
            tabBarIcon: ({focused}) => (
              <Image
                source={require('../../images/FAQ.png')}
                style={[styles.tabIcon, {opacity: focused ? 1 : 0.5}]}
              />
            ),
            tabBarButton: props => (
              // <TourGuideZone
              //   zone={4}
              //   tooltipBottomOffset={20}
              //   text="Tap here to view frequently asked questions"
              //   // borderRadius={12}
              //   style={{flex: 1}}>
              <TouchableOpacity
                {...props}
                onPress={() => {
                  setLandingPageShown(false);
                  props.onPress?.();
                }}>
                <View
                  style={{
                    flex: 1,
                    alignItems: 'center',
                  }}>
                  {props.children}
                </View>
              </TouchableOpacity>
              // </TourGuideZone>
            ),
          }}
        />
        <InvestTab.Screen
          name="ContactUs"
          component={ContactUs}
          options={{
            tabBarLabel: ({focused, color}) => (
              <MyTabBarLabel
                focused={focused}
                label="ContactUs"
                color={color}
              />
            ),
            tabBarIcon: ({color, size, focused}) => (
              <Image
                source={require('../../images/Contact-Us.png')}
                style={[styles.tabIcon, {opacity: focused ? 1 : 0.5}]}
              />
            ),
            tabBarButton: props => (
              // <TourGuideZone
              //   zone={5}
              //   tooltipBottomOffset={20}
              //   text="Tap here for Penthouse contact information"
              //   // borderRadius={12}
              //   style={{flex: 1}}>
              <TouchableOpacity
                {...props}
                onPress={() => {
                  setLandingPageShown(false);
                  props.onPress?.();
                }}>
                <View
                  style={{
                    flex: 1,
                    alignItems: 'center',
                  }}>
                  {props.children}
                </View>
              </TouchableOpacity>
              // </TourGuideZone>
            ),
          }}
        />
      </InvestTab.Navigator>
    </SafeAreaView>
  );
};

export default TabNavigation;

const styles = StyleSheet.create({
  tabContainer: {
    flex: 1,
    alignItems: 'center',
  },
  tabBarLabel: {
    fontSize: 11,
  },
  tabIcon: {
    height: 18,
    width: 18,
    resizeMode: 'center',
    // marginVertical: 5,
  },
  tabText: {
    color: '#fff',
    fontSize: 13,
    textAlign: 'center',
    fontFamily: 'Poppins Regular 400',
  },
  headerText: {
    fontSize: 30,
    color: 'grey',
    fontFamily: 'Poppins Medium 500',
    marginTop: 25,
    marginLeft: 20,
  },
  sliderContainer: {
    marginTop: 5,
    marginHorizontal: 20,
  },
  slide: {
    width: ITEM_WIDTH,
    height: '94%', //height - 200, // Adjust as needed
    // backgroundColor: 'red',
    marginTop: 10,
  },
  image: {
    width: '90%',
    height: '90%',
    borderRadius: 20, // Set borderRadius for rounded corners
    resizeMode: 'stretch', // Use 'cover' as needed
  },
  dotContainer: {
    position: 'absolute',
    bottom: 60,
    alignSelf: 'center',
    flexDirection: 'row',
  },
  dot: {
    width: 7,
    height: 7,
    borderRadius: 5,
    backgroundColor: '#fff',
    opacity: 0.7,
    marginHorizontal: 5,
  },
  activeDot: {
    backgroundColor: '#fff', // Active dot color
    width: 18,
    height: 7,
    borderRadius: 5,
  },
  bottomTabContainer: {
    height: 80,
    width: '100%',
    position: 'absolute',
    bottom: 0,
    left: 0,
    flexDirection: 'row',
    paddingTop: 8,
    paddingHorizontal: 5,
    backgroundColor: commonStyles.screenBackgroundColor,
  },
});
