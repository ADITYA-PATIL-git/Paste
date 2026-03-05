import React, {useRef, useEffect, useState} from 'react';
import {
  View,
  Text,
  Animated,
  Dimensions,
  StyleSheet,
  TouchableOpacity,
  Image,
  Alert,
  TextInput,
  ToastAndroid,
  ScrollView,
  Modal,
  Linking,
  KeyboardAvoidingView,
  Platform,
  SafeAreaView,
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import Icon1 from 'react-native-vector-icons/FontAwesome6';
import Icon2 from 'react-native-vector-icons/Ionicons';
import {SelectList} from 'react-native-select-bottom-list';
import commonStyles from '../../commonComponent/CommonCss';
import {FetchHttpRequest} from '../../FetchRequest/FetchRequest';
import {getItem, setItem} from '../../commonComponent/Store';
import CountryPicker from 'react-native-country-picker-modal';
import Dialog from 'react-native-dialog';
import {ScreenLoader} from '../../commonComponent/CommonLoader';
import DeviceInfo from 'react-native-device-info';
import {useSafeAreaInsets} from 'react-native-safe-area-context';
import {useIsFocused} from '@react-navigation/native';
import {CommonAlert} from '../../commonComponent/CommonAlert';
import {useRoute} from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {useBottomTabBarHeight} from '@react-navigation/bottom-tabs';
import {Keyboard} from 'react-native';
import WalkthroughOverlay from '../../commonComponent/WalkthroughOverlay';
import Tooltip from 'react-native-walkthrough-tooltip';
import {
  TourGuideProvider, // Main provider
  TourGuideZone, // Main wrapper of highlight component
  TourGuideZoneByPosition, // Component to use mask on overlay (ie, position absolute)
  useTourGuideController, // hook to start, etc.
} from 'rn-tourguide';
import {InteractionManager} from 'react-native';

const {width, height} = Dimensions.get('window');
const slides = [
  {
    key: '1',
    image: require('../../images/Login-BG1.png'),
    title: 'Welcome to our App!',
  },
  {
    key: '2',
    image: require('../../images/Admin-Login-BG.png'),
    title: 'Admin Login',
  },
];

const LoginPage = ({
  route,
  navigation,
  isLandingVisible,
  UserTourZone,
  AdminTourZone,
  canStartUser,
  canStartAdmin,
  startUser,
  startAdmin,
}) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [country, setCountry] = useState(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isUserView, setUserView] = useState(true);
  const [dropDownData, setDropdownData] = useState();
  const [dropDownFullData, setDropdownFullData] = useState();
  const [selectedOutletValue, setSelectedOutletValue] = useState();
  const [userName, setUserName] = useState('');
  const [password, setpassword] = useState('');
  const [mobileNumber, setMobileNumber] = useState('');
  const [androidVersion, setAndroidVersion] = useState('');
  const [bottomPadding, setBottomPadding] = useState('');
  const [hidePass, setHidePass] = useState(true);
  const [OtpModalVisible, setOtpModalVisible] = useState(false);
  const [isLoading, setloading] = useState(false);
  const [totalSeconds, setTotalSeconds] = useState(30); // Set initial countdown time (in seconds)
  const [isActive, setIsActive] = useState(true);
  const [OTP, setOTP] = useState(true);
  const [AppUpdateForce, setAppUpdateForce] = useState('');
  const [AppVerVisible, setAppVerVisible] = useState(false);
  const [isMargin, setMargin] = useState(false);
  const [safeAreaHeight, setSafeAreaHeight] = useState();
  const [loginAlert, setLoginAlert] = useState(false); // ------- Added by vinit 15/09/2025 --->
  const [loginAlertMess, setLoginAlertMess] = useState(''); // ------- Added by vinit 15/09/2025 --->
  const isFocused = useIsFocused();
  const SID = useRef('');
  const Outlet = useRef('');
  const countryMobile = useRef('');
  const callingCode = useRef('');
  const animatedValue = useRef(new Animated.Value(0)).current;
  const tabBarHeight = useBottomTabBarHeight();

  const [keyboardVisible, setKeyboardVisible] = useState(false);

  useEffect(() => {
    const showSub = Keyboard.addListener('keyboardDidShow', () =>
      setKeyboardVisible(true),
    );
    const hideSub = Keyboard.addListener('keyboardDidHide', () =>
      setKeyboardVisible(false),
    );

    return () => {
      showSub.remove();
      hideSub.remove();
    };
  }, []);

  const [layoutReady, setLayoutReady] = useState(false);

  useEffect(() => {
    let isMounted = true;

    const startTourSafely = async () => {
      const userTourDone = await AsyncStorage.getItem('userTourDone');

      if (userTourDone !== 'true' && isMounted) {
        await AsyncStorage.setItem('userTourDone', 'true');

        InteractionManager.runAfterInteractions(() => {
          requestAnimationFrame(() => {
            setTimeout(() => {
              if (isMounted) {
                startUser();
              }
            }, 300);
          });
        });
      }
    };

    if (!isLandingVisible && isUserView && layoutReady && isFocused) {
      startTourSafely();
    }

    return () => {
      isMounted = false;
    };
  }, [isLandingVisible, layoutReady, isUserView, isFocused]);

  useEffect(() => {
    let isMounted = true;

    const startAdminTourSafely = async () => {
      const adminTourDone = await AsyncStorage.getItem('adminTourDone');

      if (adminTourDone !== 'true' && isMounted && canStartAdmin) {
        await AsyncStorage.setItem('adminTourDone', 'true');

        InteractionManager.runAfterInteractions(() => {
          requestAnimationFrame(() => {
            setTimeout(() => {
              if (isMounted) {
                startAdmin();
              }
            }, 300);
          });
        });
      }
    };

    if (
      !isLandingVisible &&
      !isUserView &&
      layoutReady &&
      isFocused &&
      canStartAdmin // 👈 IMPORTANT
    ) {
      startAdminTourSafely();
    }

    return () => {
      isMounted = false;
    };
  }, [isLandingVisible, isUserView, layoutReady, isFocused, canStartAdmin]);

  //------------------------------- Animation UseEffect ------------------------------
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex(prevIndex => (prevIndex + 1) % slides.length);
    }, 5000); // Change the image every 5 seconds

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    Animated.timing(animatedValue, {
      toValue: currentIndex,
      duration: 500,
      useNativeDriver: true,
    }).start();
  }, [currentIndex]);
  const backgroundInterpolate = animatedValue.interpolate({
    inputRange: [0, 1],
    outputRange: [0, -width * (slides.length - 1)], // Move images in one direction
  });

  useEffect(() => {
    if (isFocused) {
      getData();
    }
  }, [isFocused]);

  useEffect(() => {
    setBottomPadding(0);
    const unsubscribe = navigation.addListener('tabPress', e => {
      let ABC = getItem('SafeAreHeight');
      setSafeAreaHeight(ABC);
      if (ABC === height) {
        setBottomPadding(120);
      } else {
        setBottomPadding(0);
      }
      console.log(ABC, 'HEIGHT :', height, '--------------------', navigation);
    });

    return unsubscribe; // cleanup
  }, [navigation]);

  // ---------------- for getting device Info Name , Model, Brand , AndroidId-------------------//
  const getDeviceName = async () => {
    try {
      const deviceName = await DeviceInfo.getDeviceName(); // user define name  ex. MyDevice
      const androidId = await DeviceInfo.getAndroidId(); // it is unique id for device and it is remains same unless the device is factory reset or the OS is reinstalled.
      const model = await DeviceInfo.getModel(); // model name ex.V2356
      const androidV = await DeviceInfo.getSystemVersion();
      const getUniqueId = await DeviceInfo.getUniqueId();
      setAndroidVersion(androidV);
      console.log('======================================= ::::::', deviceName);
      console.log('======================================= ::::::', androidId);
      console.log('======================================= ::::::', model);
      console.log('======================================= ::::::', brand);
      console.log(
        '================getUniqueId======================= ::::::',
        getUniqueId,
      );
    } catch (error) {}
  };

  const formatTime = seconds => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(
      remainingSeconds,
    ).padStart(2, '0')}`;
  };
  const getData = () => {
    getDeviceName();
    setloading(false);
    let val = {
      cca2: 'IN',
      currency: ['INR'],
      callingCode: ['91'],
      region: 'Asia',
      subregion: 'Southern Asia',
      flag: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAeCAMAAABpA6zvAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAqZQTFRF53MA5HIC43ID53MB9XcA+3oA9ngA53QB83cA6XMCpV8oX0hPR0RkSUVlXkdPpF8o53EA428B9ncArmIkL0OAG02vZo3TfJ3agqLcZYzTJFSzLkJ/6X0R6X0S5XsS+IQOl2E+BDqjgJ7X5eny5enz5uv05er05OjyjancCD6llmE+/fXu+/Ps///zvMPUCDefqbre8fP32ODwyNPpwMzmwc3mxNDo1N3u8fL3v8znEj+kucHS/////v//NVuwf5bK9/n7vcrkma3WgZnMf5fLlKnUusjjzdfr+Pn7iZ/OOmCz/f7///7+/Pz9tcPgGUWh4efz2eDwvMrkf5nMXH2+aojDa4jEW3y9gJnMuMbi6u/3Jk+ms8Hf+/z9aofDXn2+9ff70Nrsm6/XXHy+jKPRxNDnxdHol6vVWXq8kqfTz9ns9vj7co3Ga4fD/P3+UHK5dZDI8fT5w8/ngpvNaIbDxM/nvMnku8jkcIzGfZfLws7m8/b6iaDQU3W6dI/H8vT6aIbCu8nkucfjydTpepXK9Pb6UnS67vL4ztfrmKzWWnu9kKbTmK3WW3u9kqjTy9Xq8PP5cY3GbIjD/v/+GEWh4ujz1t7ugZrNbInEfJbL7fH4JlCns8LgOVuxfpbKzNbqlqrUfpbLe5TKytTqj6XRPWCz/v7/8fju7vXt/v/zssXUCTigs8Hi8fT309zuxtHo0Nns7vL2wMznFECkr8LT///0QJkUQJoUPpcVSKIRKHVADDqki6DY4+ny4ujy4Oby4ejyl6ndEj+mJ3Q/LpAAL5AALI4BNZgAJHomD0iAJk6xd47Uip7bjqHceI7VLlW0LY4BM5IEM5MEMZEFNZcAMpMDIXUqDFZQDE9lDlBmDFVQMpIDNpgAOJsANpkAOZsAMZEGMpEFwJ5XlQAAAAFiS0dEPKdqYc8AAAAJcEhZcwAAAEgAAABIAEbJaz4AAAGtSURBVDjLY2AY1oCRiRGICCtjZmFlY2NlYcZQyo4CGDk4ubh5ePn4OTkYUWUYBJCBoJCwiKiYuISklLSwkCCKFIMMAsjKySsoKimrqKqpq2toasnLySJJMmgjgI6unr6BoZGxiamZuYWllbWuDpIkgw0c2NrY2tk7mDk6Obu4url7eHp5A4XggMEHDnxt/PwDAoOCQ0LDwiMi3aOiY2x8EbJIJsbaxMUnJCYlp6SmpWdkZmXn5AKFECYimHk2+QWFRcUlpWXlxhWVVdU1tUAhHArr6k0jGooam5orWkxaa9pwKIy1yY1v7+js6k4t6unt658wcRKK1ZPhINbGb8rUaeXTw0NndM1sMp81e45NLEIWJXhs5s5zmF+2YOGivsjFDkuWLkMJnuUIsGLlqtVr1q5bXxZUumHjps1btq5AkmTYhgDbd+zctXvP3n1T9x/Ye/DQ4Z07tiNJMhxBAkePHT9x8tTpM2fPnT954viFo8hyDBeRwKVLl69cvXb9xs1b125fuXzpErIcw21UcPn2nbv37t2/A2SgAnSFQKUPHj58cBlDGFMhDjAUFAIALMfjyKVz+egAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTMtMTAtMDdUMTM6MTQ6MzQrMDI6MDDj9ijFAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDEzLTEwLTA3VDEzOjE0OjM0KzAyOjAwkquQeQAAAABJRU5ErkJggg==',
      name: 'India',
    };
    callingCode.NO = '91';
    setCountry(val);
    setUserView(true);
    setSelectedOutletValue('');
    setOTP('');
    setUserName(''); // Pankaj
    setpassword(''); // Pass@123
    // setMobileNumber('8879307023')   // pooja
    setMobileNumber(''); // lalit sir 7000433771
    Outlet.Id = '';
    OutletDropDownAPI();
    setLoginAlert(false); // ------- Added by vinit 15/09/2025 ---> For Invalid Password
    setLoginAlertMess(''); // ------- Added by vinit 15/09/2025 ---> For Invalid Password
  };
  // --------------------------------------------------
  const handleUserView = () => {
    setUserView(!isUserView);
  };
  // ------------------- Country Function ---------------
  const onSelect = country => {
    callingCode.NO = country?.callingCode[0];
    setCountry(country);
    setModalVisible(false);
  };
  //---------------------------- Outlet DropDown API -----------------------
  const OutletDropDownAPI = () => {
    const apiParamter = {
      sOperationType: 'GetOutletType',
    };
    let Config = {
      Url: 'Login/GetOutletType',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        let parse = JSON.parse(resp);
        let parseData = parse?.data;
        var count = parseData?.length;
        let result = [];
        for (var i = 0; i < count; i++) {
          result[i] = parseData[i]?.sOutLetName;
        }
        setDropdownData(result);
        setDropdownFullData(parseData);
      })
      .catch(error => {
        console.log(error);
      });
  };
  const handleSelection = value => {
    const Filter = dropDownFullData.filter(row => row.sOutLetName == value);
    Outlet.Id = Filter?.sOutletId;
    setItem('AdminOutletNamefromLogin', value);
    setSelectedOutletValue(value);
  };
  //----------------------------- Force Update API --------------------------
  const handleforceUpdate = value => {
    setloading(true);
    const apiParamter = {
      sOperationType: 'GetAPIVersion',
      sBrowserType: 'ANDROID', // ===> for Android use this}
      // sBrowserType: "IOS"                                     // ===> for IOS use this
    };
    let Config = {
      Url: 'Login/GetApiVersion',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        let isForceFlag = resp?.data[0]?.sIsForceUpgrage;
        let localAppversion = '2.0';
        let APIVersion = resp?.data[0]?.sVersionNo;
        setAppUpdateForce(isForceFlag);
        if (APIVersion) {
          let old = localAppversion.split('.')[0];
          let newversion = APIVersion.split('.')[0];
          let old2 = localAppversion.split('.')[1];
          let newversion2 = APIVersion.split('.')[1];
          if (parseInt(old) == parseInt(newversion)) {
            if (parseInt(old2) < parseInt(newversion2)) {
              setAppVerVisible(true);
              setloading(false);
            } else {
              setAppVerVisible(false);
              if (value == 'USER') {
                handleUserLogin();
              } else {
                handleAdminLogin();
              }
            }
          } else if (parseInt(old) < parseInt(newversion)) {
            setAppVerVisible(true);
            setloading(false);
          } else {
            setAppVerVisible(false);
            if (value == 'USER') {
              handleUserLogin();
            } else {
              handleAdminLogin();
            }
          }
        } else {
          setAppVerVisible(false);
          if (value == 'USER') {
            handleUserLogin();
          } else {
            handleAdminLogin();
          }
        }
      })
      .catch(error => {
        Alert.alert('Error', error);
        setloading(false);
      });
  };
  const AppVerAppUpdate = () => {
    setAppVerVisible(false);
    Linking.openURL(
      `https://play.google.com/store/apps/details?id=com.onexerp&hl=en`,
    );
  };
  // --------------------------- Admin Login  -------------------------------
  const handleAdminLogin = () => {
    try {
      setloading(false);
      if (!selectedOutletValue) {
        ToastAndroid.show('Please Select Outlet Name.', ToastAndroid.SHORT);
        // Alert.alert(' ', 'Please Select Outlet Name.')
        return;
      }
      if (!userName) {
        ToastAndroid.show(
          'Enter valid username and password',
          ToastAndroid.SHORT,
        );
        // Alert.alert(' ', 'Enter valid username and password')
        return;
      }
      if (!password) {
        ToastAndroid.show(
          'Enter valid username and password',
          ToastAndroid.SHORT,
        );
        // Alert.alert(' ', 'Enter valid username and password')
        return;
      }
      setloading(true);
      const apiParamter = {
        sOperationType: 'GuestLoginValidation',
        sType: '1',
        sUserName: userName, // "Pankaj",
        sPassWord: password, //"Pass@123"
      };
      let Config = {
        Url: 'Login/GetUser',
        body: apiParamter,
      };
      FetchHttpRequest(Config)
        .then(async resp => {
          setloading(false);

          // ------- Added by vinit 15/09/2025 ---> For Invalid Password
          if (resp?.status == '500') {
            setLoginAlertMess('Invalid Password');
            setLoginAlert(true);
            setloading(false);
          } else {
            if (resp?.statusCode == '300') {
              // Alert.alert("Alert", resp?.statusMsg)
              setLoginAlertMess(resp?.statusMsg);
              setLoginAlert(true);
              setloading(false);
            } else {
              setloading(false);
              let Response = JSON.parse(resp);
              setItem('GuestId', Response?.data?.sGuestId);
              setItem('sId', Response?.data?.sId);
              setItem('UserName', Response?.data?.sName);
              setItem('membershipType', Response?.data?.sMembershipType);
              console.log(
                'Response?.data ------=-=================--------------',
                Response?.data,
              );
              SID.val = Response?.data?.sId;
              getSideMenu('ADMINLOGIN');
            }
          }
          // ------- --------------------------- -------------------------
        })
        .catch(error => {
          setloading(false);
          Alert.alert('Error', error);
        });
    } catch (error) {
      console.warn('Error ------------------', error);
    }
  };
  // --------------------------- User Login  -------------------------------
  const handleUserLogin = () => {
    if (!mobileNumber) {
      ToastAndroid.show(
        'Please enter valid mobile number.',
        ToastAndroid.SHORT,
      );
      setloading(false);
      return;
    }
    let mNO = '+' + callingCode.NO + '' + mobileNumber;
    const apiParamter = {
      sOperationType: 'GuestLoginValidation',
      sMobile: mNO, //"+918879307023",
      sType: '0',
    };
    let Config = {
      Url: 'Login/GetUser',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        if (resp?.statusCode == '300') {
          setloading(false);
          Alert.alert('Alert', resp?.statusMsg);
        } else {
          let Response = JSON.parse(resp);
          console.log('Response :-----------', Response);
          setItem('GuestId', Response?.data?.sGuestId);
          setItem('sId', Response?.data?.sId);
          setItem('UserName', Response?.data?.sName);
          setItem('membershipType', Response?.data?.sMembershipType);
          setItem('MobileNumber', mNO);
          SID.val = Response?.data?.sId;
          countryMobile.Number = mNO;
          handleOtpGenerate();
          // getSideMenu(Response?.data?.sId)
        }
      })
      .catch(error => {
        setloading(false);
        Alert.alert('Error', error);
      });
  };
  // ===================== CownDown  ====================
  useEffect(() => {
    let interval = null;

    if (isActive && totalSeconds > 0) {
      interval = setInterval(() => {
        setTotalSeconds(prev => prev - 1);
      }, 1000);
    } else if (!isActive || totalSeconds === 0) {
      clearInterval(interval);
    }

    return () => clearInterval(interval);
  }, [isActive, totalSeconds]);
  const resetTimer = () => {
    setIsActive(false);
    setTotalSeconds(30); // Reset to initial time
    handleOtpGenerate();
    setOTP('');
  };

  const handleOtpGenerate = () => {
    const apiParamter = {
      sOperationType: 'GENOTP',
      sIsGenerated: '1',
      sMobile: countryMobile.Number,
      sFromMobile: '1',
      type: 'login',
      sIpAddress: '192.168.67.58',
    };
    let Config = {
      Url: 'Login/OtpGenerate',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        if (resp?.data?.iOutComeId == '1') {
          console.log('IN LOGIN PAGE __----------------', resp?.data?.iOtp);
          setOtpModalVisible(true);
          setloading(false);
          setTotalSeconds(30);
          setItem('iOtp', resp?.data?.iOtp);
        } else {
          setloading(false);
          ToastAndroid.show(resp?.data?.sOutcome, ToastAndroid.SHORT);
        }
      })
      .catch(error => {
        setloading(false);
        Alert.alert('Error', error);
      });
  };

  const handleOtpValidate = () => {
    if (OTP.length < 4) {
      ToastAndroid.show('Please Enter Valid OTP', ToastAndroid.SHORT);
      return;
    }

    const apiParamter = {
      sOperationType: 'VerifyOtp',
      sOtp: OTP,
      sMobile: countryMobile.Number,
    };
    let Config = {
      Url: 'Login/ValidateOtp',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        if (resp?.data?.iOutComeId == '1') {
          setOtpModalVisible(false);
          setOTP('');
          getSideMenu('USERLOGIN');
        } else {
          setOTP('');
          ToastAndroid.show(resp?.data?.sOutcome, ToastAndroid.SHORT);
        }
      })
      .catch(error => {
        Alert.alert('Error', error);
      });
  };
  // ------ ------- --- ----- ------ Get Side menu ----- -------- ---- ------- -------
  const getSideMenu = value => {
    const apiParamter = {
      sOperationType: 'MobileApiMenu',
      sId: SID.val,
    };
    let Config = {
      Url: 'Login/GetSideMenuBar',
      body: apiParamter,
    };
    FetchHttpRequest(Config)
      .then(async resp => {
        try {
          let parse = JSON.parse(resp);
          if (parse?.statusCode == 200) {
            console.log('getSideMenu parsed resp------------->', parse);
            // hardcode for Hudle
            // let menuData = parse?.data || [];
            // const HudleExists = menuData.some(
            //   item => item.sMenuDesc === 'Hudle',
            // );
            // if (!HudleExists) {
            //   menuData.push({sMenuDesc: 'Hudle'});
            // }
            // hardcode for Hudle
            setItem('sideMenuData', parse?.data);
            if (value == 'ADMINLOGIN') {
              setloading(false);
              setItem('LoginBy', 'ADMIN');
              navigation.navigate('DrawerNavigation');
            } else {
              setloading(false);
              setItem('LoginBy', 'USER');
              navigation.navigate('DrawerNavigation');
            }
            setloading(false);
          }
        } catch (error) {
          setloading(false);
        }
      })
      .catch(error => {
        Alert.alert('Error', error);
      });
  };

  const insets = useSafeAreaInsets();
  return (
    <>
      <SafeAreaView
        style={[commonStyles.SafeAreaContainer, {paddingTop: insets.top}]}
        onLayout={event => {
          const heights = event.nativeEvent.layout;
          // setSafeAreaHeight(heights.height)
        }}>
        <KeyboardAvoidingView
          style={[commonStyles.SafeAreaContainer]}
          behavior={Platform.OS === 'ios' ? 'padding' : 'padding'}
          keyboardVerticalOffset={0}>
          {/*  -------------------- added ScrollView if we needed ScrollView   if remove Scroll View then remove marginTop 600 from below  */}
          <Animated.View
            style={[
              styles.backgroundContainer,
              {
                transform: [{translateX: backgroundInterpolate}],
              },
            ]}>
            {slides.map(slide => (
              <Animated.Image
                key={slide.key}
                source={slide.image}
                style={styles.backgroundImage}
                resizeMode="stretch"
              />
            ))}
          </Animated.View>
          {/* //change by aditya */}
          {/* <ScrollView
          contentContainerStyle={{flexGrow: 1}}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}> */}
          {/* <View style={{height: height}}> */}
          {/* end */}
          <View style={{flex: 1}}>
            {/* <View style={{ height: safeAreaHeight ? safeAreaHeight - (90 + bottomPadding) : height - (90 + bottomPadding), marginBottomBottom: 50 }}> */}
            <View style={{flex: 2}}>
              <View
                style={{
                  marginTop: 30,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}>
                <Image
                  source={require('../../images/Penthouse-Logo.png')}
                  style={{
                    height: 70,
                    width: 70,
                    resizeMode: 'center',
                  }}
                />
              </View>

              <View style={{}}>
                <View style={styles.overlay}>
                  {
                    isUserView ? (
                      // -------------------------------- USER LOGIN ------------------------------
                      <Text style={commonStyles.TitleText}>
                        A Manor For The Tastemaker
                      </Text>
                    ) : (
                      <Text style={commonStyles.TitleText}>
                        Spark Your Imagination
                      </Text>
                    )
                    // --------------------------------ADMIN LOGIN--------------------------------
                  }
                </View>
              </View>
            </View>
            {/*  -------------------- added MarginTop if we needed ScrollView  */}
            <View
              style={{
                flex: 5,
                justifyContent: 'flex-end',
                // position: 'absolute',
                //   bottom: androidVersion > 14 ? 170 : 110,
                paddingBottom: keyboardVisible ? 0 : tabBarHeight + 10, //change by aditya
                // backgroundColor: 'red's
                // backgroundColor: 'red'
              }}>
              {/* <View style={[styles.BottomView]}> */}
              <UserTourZone
                zone={1}
                shape="circle"
                text={'Welcome to Penthouse App!'}
              />

              <View style={{width: width, alignSelf: 'center'}}>
                {isUserView ? (
                  // -------------------------------- USER LOGIN ------------------------------ */}
                  <UserTourZone
                    // style={{
                    //   marginTop: 20,
                    // }}
                    // maskOffset={-20}
                    // tooltipBottomOffset={20}
                    zone={6}
                    text={'Here you can enter your mobile number'}
                    borderRadius={16}>
                    <View
                      style={{
                        color: 'black',
                        backgroundColor: 'white',
                        height: 42,
                        marginHorizontal: 20,
                        paddingLeft: 15,
                        borderRadius: 8,
                        marginVertical: 12,
                        flexDirection: 'row',
                        alignItems: 'center',
                      }}>
                      <CountryPicker
                        visible={modalVisible}
                        onSelect={onSelect}
                        onClose={() => setModalVisible(false)}
                        withFilter
                        withFlag
                        withCallingCode
                        placeholder=""
                        country
                        // withCloseButton={false}
                      />
                      <TouchableOpacity
                        onPress={() => {
                          setModalVisible(true);
                        }}
                        style={{flexDirection: 'row', alignItems: 'center'}}>
                        <Image
                          source={{uri: country?.flag}}
                          style={{
                            height: 20,
                            width: 20,
                            borderRadius: 50,
                            marginRight: 7,
                            marginLeft: -5,
                          }}
                        />
                        <Text
                          style={{
                            marginRight: 5,
                            color: commonStyles.textColor,
                          }}>
                          +{country?.callingCode[0]}{' '}
                        </Text>
                        <Icon
                          name={'sort-down'}
                          color={commonStyles.textColor}
                          size={16}
                          style={{marginTop: -5}}
                        />
                      </TouchableOpacity>
                      {/* <TextInput
                                        style={{ flex: 1 }}
                                        // style={[commonStyles.textInputOtherScreen,]}
                                        keyboardType='number-pad'
                                        placeholder=''
                                    /> */}

                      <TextInput
                        style={{flex: 1}}
                        placeholder=""
                        onFocus={() => setMargin(true)}
                        onChangeText={value => setMobileNumber(value)}
                        placeholderTextColor="#7B7F89"
                        keyboardType="number-pad"
                        value={mobileNumber}
                        maxLength={10}
                      />
                    </View>
                  </UserTourZone>
                ) : (
                  // --------------------------------ADMIN LOGIN--------------------------------
                  <AdminTourZone
                    zone={1}
                    text={'This is admin login window'}
                    borderRadius={16}>
                    <View>
                      <AdminTourZone
                        style={{
                          marginTop: 20,
                        }}
                        zone={2}
                        text={'Here you can select outlet type'}
                        borderRadius={16}>
                        <SelectList
                          style={{
                            color: 'black',
                            backgroundColor: 'white',
                            height: 42,
                            marginHorizontal: 20,
                            marginVertical: 6,
                            paddingLeft: 15,
                            borderRadius: 8,
                          }}
                          onSelect={async (selectedItem, index) => {
                            handleSelection(selectedItem);
                          }}
                          headerTitle={'Select Outlet Name'}
                          headerTextStyle={commonStyles.dropDownTextStyle}
                          placeHolder="Select Outlet Name"
                          value={selectedOutletValue}
                          data={dropDownData}
                          textStyle={[commonStyles.dropdownTxtStyle1]}
                          itemTextStyle={commonStyles.dropDownTextStyle}
                          renderIcon={isOpened => {
                            return (
                              <Icon
                                name={'chevron-down'}
                                color={'gray'}
                                size={15}
                              />
                            );
                          }}
                        />
                      </AdminTourZone>
                      <AdminTourZone
                        zone={3}
                        text={'Enter your username'}
                        borderRadius={16}>
                        <TextInput
                          style={{
                            color: 'black',
                            backgroundColor: 'white',
                            height: 42,
                            marginHorizontal: 20,
                            marginVertical: 6,
                            paddingLeft: 15,
                            borderRadius: 8,
                          }}
                          placeholder="Please Enter Name"
                          onChangeText={value => setUserName(value)}
                          placeholderTextColor="#7B7F89"
                          value={userName}
                          maxLength={50}
                        />
                      </AdminTourZone>
                      <AdminTourZone
                        zone={4}
                        text={'Enter your password'}
                        borderRadius={16}>
                        <View
                          style={{
                            color: 'black',
                            backgroundColor: 'white',
                            height: 42,
                            marginHorizontal: 20,
                            marginVertical: 6,
                            paddingLeft: 15,
                            borderRadius: 8,
                            flexDirection: 'row',
                          }}>
                          <TextInput
                            style={{flex: 1, color: 'black'}}
                            secureTextEntry={hidePass ? true : false}
                            placeholder="Please Enter Password"
                            onChangeText={value => setpassword(value)}
                            placeholderTextColor="#7B7F89"
                            value={password}
                            maxLength={50}
                          />

                          <TouchableOpacity
                            onPress={() => {
                              setHidePass(!hidePass);
                            }}
                            style={{
                              flex: 0.2,
                              justifyContent: 'center',
                              alignItems: 'flex-end',
                              marginRight: 8,
                            }}>
                            <Icon2
                              // style={styles.iconstyle}
                              name={
                                hidePass ? 'eye-off-outline' : 'eye-outline'
                              }
                              color="#1a1a1a"
                              size={25}
                            />
                          </TouchableOpacity>
                        </View>
                      </AdminTourZone>
                    </View>
                  </AdminTourZone>
                )}
                {isUserView ? (
                  <UserTourZone
                    zone={7}
                    text={'Please click on Discover'}
                    borderRadius={16}>
                    <TouchableOpacity
                      style={{
                        backgroundColor: '#282828',
                        borderRadius: 8,
                        marginHorizontal: 20,
                        alignItems: 'center',
                        justifyContent: 'center',
                        borderColor: 'grey',
                        borderWidth: 1,
                        marginVertical: 6,
                        height: 42,
                      }}
                      onPress={() => {
                        if (isUserView) {
                          handleforceUpdate('USER');
                        } else {
                          handleforceUpdate('ADMIN');
                        }
                      }}>
                      <Text
                        style={{
                          color: '#fff',
                          fontSize: 14,
                          fontFamily: 'Poppins Regular 400',
                        }}>
                        Discover
                      </Text>
                    </TouchableOpacity>
                  </UserTourZone>
                ) : (
                  <AdminTourZone
                    zone={5}
                    text={'Press here to login'}
                    borderRadius={16}>
                    <TouchableOpacity
                      style={{
                        backgroundColor: '#282828',
                        borderRadius: 8,
                        marginHorizontal: 20,
                        alignItems: 'center',
                        justifyContent: 'center',
                        borderColor: 'grey',
                        borderWidth: 1,
                        marginVertical: 6,
                        height: 42,
                      }}
                      onPress={() => {
                        if (isUserView) {
                          handleforceUpdate('USER');
                        } else {
                          handleforceUpdate('ADMIN');
                        }
                      }}>
                      <Text
                        style={{
                          color: '#fff',
                          fontSize: 14,
                          fontFamily: 'Poppins Regular 400',
                        }}>
                        Discover
                      </Text>
                    </TouchableOpacity>
                  </AdminTourZone>
                )}

                <UserTourZone
                  // maskOffset={-20}
                  // tooltipBottomOffset={20}
                  zone={8}
                  text={'Press here to switch to admin mode'}
                  borderRadius={16}>
                  <View
                    onLayout={() => {
                      setLayoutReady(true);
                    }}
                    style={{flexDirection: 'row', paddingVertical: 15}}>
                    <View style={styles.greyHorizantalLine} />

                    <TouchableOpacity
                      onLayout={() => {}}
                      style={styles.iconContainer}
                      onPress={() => {
                        handleUserView();
                        startAdmin();
                      }}>
                      {isUserView ? (
                        // -------------------------------- USER LOGIN ------------------------------
                        <Icon name="user-o" color={'#e1e1e3'} size={18} />
                      ) : (
                        // --------------------------------ADMIN LOGIN--------------------------------
                        <Icon1
                          name="arrow-left-long"
                          color={'#e1e1e3'}
                          size={18}
                        />
                      )}
                    </TouchableOpacity>
                    <View style={styles.greyHorizantalLine} />
                  </View>
                </UserTourZone>
              </View>
              {/* </View> */}
            </View>
          </View>

          <Dialog.Container
            contentStyle={{
              padding: 5,
              marginHorizontal: 10,
              backgroundColor: '#fff',
              borderRadius: 12,
              justifyContent: 'center',
              alignItems: 'center',
            }}
            visible={AppVerVisible}
            onBackdropPress={() => {
              setAppVerVisible(true);
            }}>
            <Dialog.Description
              style={{
                fontFamily: 'Poppins Medium 500',
                color: '#000',
                fontSize: 14,
                includeFontPadding: false,
              }}>
              Dear user, thank you for choosing Penthouse Mumbai. We Noticed
              that you are currently using an outdated version of our app,
              please update to the latest version of Penthouse Mumbai.
            </Dialog.Description>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                marginBottom: 18,
              }}>
              <Dialog.Button
                style={{
                  width: 120,
                  borderWidth: 1,
                  borderColor: '#9BB0C1',
                  padding: 10,
                  backgroundColor: '#1a55e3',
                  color: 'white',
                  borderRadius: 4,
                }}
                label="Update"
                onPress={() => AppVerAppUpdate()}
              />
              <View style={{padding: 8}}></View>
              {AppUpdateForce == 'N' ? (
                <Dialog.Button
                  style={{
                    width: 120,
                    borderWidth: 1,
                    borderColor: '#9BB0C1',
                    padding: 10,
                    borderRadius: 4,
                    backgroundColor: '#dcdde1',
                    color: '#000',
                  }}
                  label="No"
                  onPress={() => {
                    if (isUserView) {
                      handleUserLogin();
                    } else {
                      handleAdminLogin();
                    }
                    setAppVerVisible(false);
                  }}
                />
              ) : null}
            </View>
          </Dialog.Container>

          {OtpModalVisible ? (
            <View>
              <Modal transparent animationType="fade">
                <View
                  style={{
                    flex: 1,
                    justifyContent: 'center',
                    alignItems: 'center',
                    backgroundColor: 'rgba(59, 59, 59, 0.5)',
                  }}>
                  <View style={commonStyles.AlerModalContainer}>
                    <TouchableOpacity
                      style={styles.crossBG}
                      onPress={() => {
                        setOtpModalVisible(false);
                      }}>
                      <Image
                        source={require('../../images/cross.png')}
                        style={{height: 15, width: 15}}
                        resizeMode="contain"
                      />
                    </TouchableOpacity>
                    <View style={commonStyles.ArrowImage}>
                      <Image
                        source={require('../../images/logout.png')}
                        style={{height: 50, width: 50}}
                        resizeMode="contain"
                      />
                    </View>
                    <Text style={commonStyles.OTPTitle}>OTP Verification</Text>
                    <View>
                      <Text
                        style={{
                          fontSize: 14,
                          color: 'grey',
                          marginTop: 10,
                          marginHorizontal: 30,
                          textAlign: 'center',
                        }}>
                        Please enter verification code which is sent to Member's
                        email & Whatsapp
                      </Text>
                    </View>
                    <View>
                      <TextInput
                        style={[
                          commonStyles.PTSTextInput,
                          {
                            width: 150,
                            marginTop: 20,
                            color: 'black',
                            textAlign: 'center',
                            paddingLeft: 0,
                          },
                        ]}
                        placeholder=""
                        onChangeText={value => setOTP(value)}
                        placeholderTextColor="#7B7F89"
                        keyboardType="number-pad"
                        value={OTP}
                        maxLength={4}
                      />
                    </View>
                    <View style={{marginLeft: 150, marginBottom: 10}}>
                      <Text
                        style={{
                          fontSize: 12,
                          color: 'grey',
                          textAlign: 'right',
                          lineHeight: 10,
                        }}>
                        {OTP?.length}/4
                      </Text>
                    </View>
                    <View style={styles.secContainer}>
                      <View style={{flex: 1}}>
                        <Text style={styles.timerText}>
                          {formatTime(totalSeconds)}
                        </Text>
                      </View>
                      {totalSeconds == 0 ? (
                        <TouchableOpacity
                          onPress={() => {
                            resetTimer();
                          }}
                          style={{flex: 1}}>
                          <Text style={{color: 'black', textAlign: 'right'}}>
                            Resend
                          </Text>
                        </TouchableOpacity>
                      ) : (
                        <View style={{flex: 1}}>
                          <Text style={{color: 'grey', textAlign: 'right'}}>
                            Resend
                          </Text>
                        </View>
                      )}
                    </View>

                    <TouchableOpacity
                      onPress={() => {
                        handleOtpValidate();
                      }}
                      style={[commonStyles.buttonStyle, styles.extraButton]}>
                      <Text style={[commonStyles.ButtonText]}>Verify</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </Modal>
            </View>
          ) : null}

          {isLoading ? <ScreenLoader /> : null}

          {/* // ------- Added by vinit 15/09/2025 ---> For Invalid Password */}
          {loginAlert && (
            <CommonAlert
              TitleName="Alert"
              Message={loginAlertMess}
              onPress={() => {
                setLoginAlertMess('');
                setLoginAlert(false);
              }}
            />
          )}
          {/* </ScrollView> */}
        </KeyboardAvoidingView>
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  secContainer: {
    flexDirection: 'row',
    marginHorizontal: 35,
    justifyContent: 'center',
    // alignItems: 'center',
  },
  timerText: {
    fontSize: 14,
    color: 'red',
    textAlign: 'left',
  },
  crossBG: {
    alignSelf: 'flex-end',
    borderRadius: 8,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#b6b8b6',
    height: 30,
    width: 30,
  },
  extraButton: {
    width: 150,
    borderColor: '#2e2e2dff',
    borderWidth: 1.5,
    marginHorizontal: 0,
    borderRadius: 10,
    marginTop: 25,
  },
  container: {
    flex: 1,
    overflow: 'hidden',
  },
  greyHorizantalLine: {
    flex: 1,
    marginHorizontal: 20,
    height: 1.5,
    backgroundColor: 'grey',
    marginTop: 20,
  },
  iconContainer: {
    height: 40,
    width: 40,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 12,
    borderColor: 'grey',
    borderWidth: 1,
  },
  backgroundContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: width * slides.length,
    height: height,
    flexDirection: 'row', // Add this to position images horizontally
  },
  backgroundImage: {
    width: width,
    height: height - 50, // heighteffect by Tabbar   chnage it ---> 50
  },
  BottomView: {
    position: 'absolute',
    bottom: 30, // heighteffect by Tabbar
  },
  overlay: {
    padding: 20,
  },
});

export default LoginPage;
