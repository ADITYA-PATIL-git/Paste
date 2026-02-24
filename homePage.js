import React, { useState, useRef, useEffect, useContext } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  ScrollView,
  Dimensions,
  ActivityIndicator,
  FlatList,
  RefreshControl,
  ToastAndroid,
  BackHandler,
  Alert,
  PermissionsAndroid,
} from 'react-native';
import commonStyles from './CommonCSS';
// import Icon from 'react-native-vector-icons/MaterialIcons';
// import Icon1 from 'react-native-vector-icons/MaterialCommunityIcons';
import Icon1 from '@react-native-vector-icons/material-design-icons';
// import Carousel, {Pagination} from 'react-native-snap-carousel';
import usePaginationProperty from './UsePagination';
import CustomLoader from './Common/CustomLoader';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { CallAPI, TokenFetchHttpGet } from './FetchHTTP/FetchHttpRequest';
import Dialog from 'react-native-dialog';
// import DocumentPicker from 'react-native-document-picker';
import { pick, types, errorCodes } from '@react-native-documents/picker';
import { launchCamera, launchImageLibrary } from 'react-native-image-picker';
import Icon2 from '@react-native-vector-icons/ionicons';
import Icon3 from '@react-native-vector-icons/fontawesome';
import { useFocusEffect, useIsFocused } from '@react-navigation/native';
import RNFS from 'react-native-fs';
import { DashboardContext } from './context/DashboardContext';
import { ImageContext } from './UserImageContext';
import ImagePicker from 'react-native-image-crop-picker';

const { width } = Dimensions.get('window');

function HomePage({ navigation }) {
  const { setDashboardData } = useContext(DashboardContext);
  const cardColors = ['#FBE1D4', '#E6E0FC', '#DFEFFF', '#E5F6E3'];
  const cardIconImages = [
    require('./images/InvoiceApproval.png'),
    require('./images/AdvanceApproval.png'),
    require('./images/POApproval.png'),
    require('./images/VendorApproval.png'),
  ];

  const maxFileSize = 4 * 1024 * 1024; // 1 MB
  const [loginData, setLoginData] = useState('');
  const [activeIndex, setActiveIndex] = React.useState(0);
  const [totalPending, setTotalPending] = useState(0);
  const [pendingActionData, setPendingActionData] = useState([]);
  const [visibleProfile, setVisibleProfile] = useState(false);
  const [isValidLogin, setIsValidLogin] = useState(false);
  const [ssoCheckbox, setSsoCheckbox] = useState(false);
  const [FileName, setFileName] = useState(null);
  const [MongoId, setMongoId] = useState('');
  const [singleFile, setSingleFile] = useState(null);
  // const [Base64string, setBase64string] = useState('');
  const [totalCount, setTotalCount] = useState('');
  const [cameraimg, setcameraImg] = useState(null);
  const [ImagValue, setImagValue] = useState(null);

  const [initialLoader, setInitialLoader] = useState(true);
  const [userImageLoader, setUserImageLoader] = useState(false);
  const isFocused = useIsFocused();
  // const [imageUri, setImageUri] = useState(null);
  const { imageUri, setImageUri } = useContext(ImageContext);

  const handleCancel1 = () => {
    setVisibleProfile(false);
  };

  const loadImage = async () => {
    const uri = await AsyncStorage.getItem('userImageUri');
    if (uri) {
      setImageUri(uri);
    }
  };

  useFocusEffect(
    React.useCallback(() => {
      loadImage();
    }, []),
  ); ////////////////////

  useEffect(() => {
    if (isFocused) {
      setTotalCount('');
      const fetchData = async () => {
        setInitialLoader(true);
        const uploadedlocal = await AsyncStorage.getItem('Localbase64');

        // setBase64string(uploadedlocal);
        // const dataForDashboard = await AsyncStorage.getItem('dataForDashboard');
        // const parseData = JSON.parse(dataForDashboard);
        // await AsyncStorage.setItem('EmpId', parseData.EmployeeIdentity);
        // setLoginData(parseData);
        // await fetchDashboardData(parseData.EmployeeIdentity);
        const dataForDashboard = await AsyncStorage.getItem('dataForDashboard');

        if (!dataForDashboard) {
          console.log('No dashboard data found. Redirecting to login.');
          navigation.reset({
            index: 0,
            routes: [{ name: 'Registration' }],
          });
          return;
        }

        const parseData = JSON.parse(dataForDashboard);

        if (!parseData?.EmployeeIdentity) {
          Alert.alert('Cache not found! Please log in again');
          await AsyncStorage.multiRemove([
            'UserId',
            'SessionId',
            'keyId',
            'publicKey',
            'encrPass',
            'encrKeyId',
          ]);
          await AsyncStorage.setItem('forceLogout', 'true');
          navigation.reset({
            index: 0,
            routes: [{ name: 'Registration' }],
          });
          return;
        }

        await AsyncStorage.setItem('EmpId', parseData.EmployeeIdentity);
        setLoginData(parseData);
        await fetchDashboardData(parseData.EmployeeIdentity);

        setInitialLoader(false);
      };

      fetchData();
    }
  }, [isFocused]);

  useFocusEffect(
    React.useCallback(() => {
      const handleBackButton = () => {
        console.log('BackHandler---------');
        // BackHandler.exitApp()
        Alert.alert('LOGOUT', 'Do you want to Logout?', [
          {
            text: 'CANCEL',
            onPress: () => {},
            style: 'cancel',
          },
          {
            text: 'OK',
            onPress: () => {
              navigation.navigate('Registration');
            },
          },
        ]);
        return true;
      };
      const subscription = BackHandler.addEventListener(
        'hardwareBackPress',
        handleBackButton,
      );
      return () => subscription.remove();
    }, []),
  );

  // const requestCameraPermission = async () => {
  //   setVisibleProfile(false);
  //   try {
  //     const granted = await PermissionsAndroid.request(
  //       PermissionsAndroid.PERMISSIONS.CAMERA,
  //       {
  //         title: 'Cool Photo App Camera Permission',
  //         message:
  //           'Cool Photo App needs access to your camera ' +
  //           'so you can take awesome pictures.',
  //         buttonNeutral: 'Ask Me Later',
  //         buttonNegative: 'Cancel',
  //         buttonPositive: 'OK',
  //       },
  //     );
  //     if (granted === PermissionsAndroid.RESULTS.GRANTED) {
  //       console.log('You can use the camera');
  //       const result = await launchCamera({
  //         includeBase64: true,
  //         mediaType: 'photo',
  //         quality: 0.5,
  //       });
  //       if (!result || result.didCancel || !result.assets?.length) {
  //         return;
  //       }
  //       console.log('Press---', result?.assets[0]?.fileSize);
  //       const file = result.assets[0];
  //       // const filenamesplit = result.assets[0].fileName;
  //       const filenamesplit =
  //         result.assets[0].fileName || `camera_${Date.now()}.jpg`;

  //       // const fileext = filenamesplit.split('.')[1];
  //       const fileext = filenamesplit.split('.').pop().toLowerCase();
  //       console.log('filename-----', fileext);
  //       if (['jpg', 'jpeg', 'png'].includes(fileext)) {
  //         if (file.fileSize && file.fileSize > maxFileSize) {
  //           console.log('File size exceeds the limit of 1 MB');
  //           Alert.alert('File size exceeds the limit of 1 MB');
  //         } else {
  //           setcameraImg(result?.assets[0]);
  //           setImagValue(result?.assets[0]?.fileName);
  //           var URL = result?.assets[0]?.base64;
  //           // console.log('selected img base64 --->', URL);
  //           // setBase64string(URL);
  //           const fullName = result?.assets[0]?.fileName;
  //           const fileNameOnly = fullName.substring(
  //             0,
  //             fullName.lastIndexOf('.'),
  //           );
  //           // AsyncStorage.setItem('Localbase64', base64String);
  //           await AsyncStorage.setItem('LocalFileName', fileNameOnly);
  //           await AsyncStorage.setItem(
  //             'LocalFileExtension',
  //             result?.assets[0]?.fileName.split('.').pop(),
  //           );
  //           // await AsyncStorage.setItem('Localbase64', URL);
  //           const path = `${RNFS.CachesDirectoryPath}/user_profile.jpg`;
  //           await RNFS.writeFile(path, URL, 'base64');
  //           const newUri = `file://${path}?t=${Date.now()}`;
  //           await AsyncStorage.setItem('userImageUri', newUri);
  //           setImageUri(newUri);
  //           // await loadImage();
  //           await UploadImage(URL);
  //         }
  //       } else {
  //         ToastAndroid.show(
  //           'Please select proper file format',
  //           ToastAndroid.SHORT,
  //         );
  //       }
  //     } else {
  //       console.log('Camera permission denied');
  //     }
  //   } catch (err) {
  //     console.warn(err);
  //   }
  // };

  // const selectFile = async () => {
  //   setVisibleProfile(false);
  //   try {
  //     const res = await pick({
  //       presentationStyle: 'fullScreen',
  //       type: [types.images],
  //     });
  //     const filenamesplit = res[0].name;
  //     // const fileext = filenamesplit.split('.')[1];
  //     const fileext = filenamesplit.split('.').pop().toLowerCase();
  //     console.log('filename-----', fileext);
  //     if (['jpg', 'jpeg', 'png'].includes(fileext)) {
  //       if (res[0].size > maxFileSize) {
  //         console.log('File size exceeds the limit of 1 MB');
  //         Alert.alert('File size exceeds the limit of 1 MB');
  //       } else {
  //         // console.log('res : ' + JSON.stringify(res));
  //         console.log('res : ' + JSON.stringify(res[0].name));
  //         var filenamevalue = res[0].name;
  //         setSingleFile(res);
  //         setFileName(res[0].name);
  //         var Querydata = res.map(obj => obj?.name);
  //         // console.log('OpenData===', Querydata);
  //         var URL = res[0].uri;
  //         console.log('URL===', URL);
  //         //added by Priya
  //         const base64String = await RNFS.readFile(URL, 'base64');
  //         // console.log(base64String);
  //         // setBase64string(base64String);
  //         const fullName = res[0].name;
  //         const fileNameOnly = fullName.substring(0, fullName.lastIndexOf('.'));
  //         // AsyncStorage.setItem('Localbase64', base64String);
  //         await AsyncStorage.setItem('LocalFileName', fileNameOnly);
  //         await AsyncStorage.setItem(
  //           'LocalFileExtension',
  //           res[0].name.split('.').pop(),
  //         );
  //         const path = `${RNFS.CachesDirectoryPath}/user_profile.jpg`;
  //         await RNFS.writeFile(path, base64String, 'base64');
  //         const newUri = `file://${path}?t=${Date.now()}`;
  //         await AsyncStorage.setItem('userImageUri', newUri);
  //         setImageUri(newUri);
  //         // await loadImage();
  //         await UploadImage(base64String);
  //         // getUploadDocumentMobile(filenamevalue, base64String);
  //       }
  //     } else {
  //       setSingleFile(null);
  //       ToastAndroid.show(
  //         'Please select proper file format',
  //         ToastAndroid.SHORT,
  //       );
  //     }
  //   } catch (err) {
  //     setSingleFile(null);
  //     if (errorCodes.OPERATION_CANCELED) {
  //       ToastAndroid.show('Canceled', ToastAndroid.SHORT);
  //     } else {
  //       ToastAndroid.show(
  //         'Unknown Error: ' + JSON.stringify(err),
  //         ToastAndroid.SHORT,
  //       );
  //       throw err;
  //     }
  //   }
  // };

  const requestCameraPermission = async () => {
    setVisibleProfile(false);
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.CAMERA,
        {
          title: 'Cool Photo App Camera Permission',
          message:
            'Cool Photo App needs access to your camera ' +
            'so you can take awesome pictures.',
          buttonNeutral: 'Ask Me Later',
          buttonNegative: 'Cancel',
          buttonPositive: 'OK',
        },
      );
      if (granted === PermissionsAndroid.RESULTS.GRANTED) {
        console.log('You can use the camera');
        const res = await ImagePicker.openCamera({
          width: 400,
          height: 400,
          cropping: true,
        });
        console.log('camera result--------->', res);
        const fileName = res.filename || `camera_${Date.now()}.jpg`;
        const fileext = fileName.split('.').pop().toLowerCase();
        console.log('filename ext-----', fileext);
        if (['jpg', 'jpeg', 'png'].includes(fileext)) {
          if (res.size > maxFileSize) {
            console.log('File size exceeds the limit of 4 MB');
            Alert.alert('File size exceeds the limit of 4 MB');
          } else {
            setSingleFile(res);
            setFileName(res.filename);
            var URL = res.path;
            console.log('URL===', URL);
            const base64String = await RNFS.readFile(URL, 'base64');
            const fullName = res.filename;
            const fileNameOnly = fullName.substring(
              0,
              fullName.lastIndexOf('.'),
            );
            await AsyncStorage.setItem('LocalFileName', fileNameOnly);
            await AsyncStorage.setItem(
              'LocalFileExtension',
              res.filename.split('.').pop(),
            );
            const path = `${RNFS.CachesDirectoryPath}/user_profile.jpg`;
            await RNFS.writeFile(path, base64String, 'base64');
            const newUri = `file://${path}?t=${Date.now()}`;
            await AsyncStorage.setItem('userImageUri', newUri);
            setImageUri(newUri);
            await UploadImage(base64String);
          }
        } else {
          ToastAndroid.show(
            'Please select proper file format',
            ToastAndroid.SHORT,
          );
        }
      } else {
        console.log('Camera permission denied');
      }
    } catch (error) {
      if (error.code === 'E_PICKER_CANCELLED') {
        console.log('User cancelled image picker');
      } else {
        console.log('Other error:', error);
      }
    }
  };

  const selectFile = async () => {
    setVisibleProfile(false);
    try {
      const res = await ImagePicker.openPicker({
        width: 400,
        height: 400,
        cropping: true,
      });
      console.log('res-----', res);
      const fileName = res.filename;
      const fileext = fileName.split('.').pop().toLowerCase();
      if (['jpg', 'jpeg', 'png'].includes(fileext)) {
        if (res.size > maxFileSize) {
          console.log('File size exceeds the limit of 1 MB');
          Alert.alert('File size exceeds the limit of 1 MB');
        } else {
          setSingleFile(res);
          setFileName(res.filename);
          var URL = res.path;
          console.log('URL===', URL);
          const base64String = await RNFS.readFile(URL, 'base64');
          const fullName = res.filename;
          const fileNameOnly = fullName.substring(0, fullName.lastIndexOf('.'));
          await AsyncStorage.setItem('LocalFileName', fileNameOnly);
          await AsyncStorage.setItem(
            'LocalFileExtension',
            res.filename.split('.').pop(),
          );
          const path = `${RNFS.CachesDirectoryPath}/user_profile.jpg`;
          await RNFS.writeFile(path, base64String, 'base64');
          const newUri = `file://${path}?t=${Date.now()}`;
          await AsyncStorage.setItem('userImageUri', newUri);
          setImageUri(newUri);
          await UploadImage(base64String);
        }
      } else {
        setSingleFile(null);
        ToastAndroid.show(
          'Please select proper file format',
          ToastAndroid.SHORT,
        );
      }
    } catch (error) {
      setSingleFile(null);
      if (error.code === 'E_PICKER_CANCELLED') {
        console.log('User cancelled image picker');
      } else {
        console.log('Other error:', error);
      }
    }
  };

  const UploadImage = async selectedImage => {
    setUserImageLoader(true);
    // const selectedImage = await AsyncStorage.getItem('Localbase64');
    const selectedImageName = await AsyncStorage.getItem('LocalFileName');
    const empId = await AsyncStorage.getItem('EmpId');
    const selectedImageExtension =
      await AsyncStorage.getItem('LocalFileExtension');
    try {
      if (
        selectedImage &&
        selectedImageName &&
        empId &&
        selectedImageExtension
      ) {
        let Config = {
          Url: `MobLoginApi/SaveEmployeeImageDate`,
          method: 'POST',
          body: {
            Image: selectedImage,
            ImageName: selectedImageName,
            ImageExt: selectedImageExtension,
            EmployeeIdentity: empId,
          },
        };
        // console.log('UploadImage-body====>', Config);
        const response = await TokenFetchHttpGet(Config);
        console.log('response UploadImage--------->', response);
        if (!response) return null;
        if (response?._ok) {
          Alert.alert('Profile image set successfully');
          setUserImageLoader(false);
          return null;
        } else {
          Alert.alert('Server Error!', 'Please try again');
          setUserImageLoader(false);
        }
      } else {
        Alert.alert('Please select an image');
        setUserImageLoader(false);
        return null;
      }
    } catch (error) {
      console.error('UploadImage error:', error);
      Alert.alert('Network error!');
      setUserImageLoader(false);
    }
  };

  // const UploadImage = async () => {
  //   const selectedImage = await AsyncStorage.getItem('Localbase64');
  //   const selectedImageName = await AsyncStorage.getItem('LocalFileName');
  //   const empId = await AsyncStorage.getItem('EmpId');
  //   const selectedImageExtension = await AsyncStorage.getItem(
  //     'LocalFileExtension',
  //   );

  //   if (
  //     !selectedImage ||
  //     !selectedImageName ||
  //     !empId ||
  //     !selectedImageExtension
  //   ) {
  //     Alert.alert('Please select an image');
  //     return;
  //   }

  //   // const cleanBase64 = selectedImage.replace(/\n/g, '').replace(/\r/g, '');

  //   // const normalizedExt =
  //   //   selectedImageExtension.toLowerCase() === 'jpg'
  //   //     ? 'jpeg'
  //   //     : selectedImageExtension.toLowerCase();

  //   let Config = {
  //     Url: 'MobLoginApi/SaveEmployeeImageDate',
  //     method: 'POST',
  //     body: {
  //       Image: selectedImage,
  //       ImageName: selectedImageName,
  //       ImageExt: selectedImageExtension,
  //       EmployeeIdentity: empId,
  //     },
  //   };
  //   console.log('UploadImage-body====>', Config);
  //   const response = await TokenFetchHttpGet(Config);
  //   console.log('response UploadImage--------->', response);

  //   if (response?._ok) {
  //     Alert.alert('Profile image set successfully');
  //   } else {
  //     Alert.alert('Server Error!', response?.Message || 'Please try again');
  //   }
  // };

  const fetchDashboardData = async employeeId => {
    console.log('Reaching fetchDashboardData');

    if (!employeeId) {
      setInitialLoader(false);
      ToastAndroid.show('SOMETHING WENT WRONG', ToastAndroid.SHORT);
      return;
    }

    try {
      const Config = {
        Url: 'MobVendorInvoice/GetDashboard',
        method: 'POST',
        body: {
          EmployeeId: employeeId,
        },
      };

      console.log('fetchDashboardData-body===>', Config);

      const response = await TokenFetchHttpGet(Config);
      console.log('response fetchDashboardData----> ', response);

      if (response?._httpError) {
        if (response._httpStatus === 400) {
          ToastAndroid.show('Server Error!', ToastAndroid.SHORT);
        }
        return;
      }

      if (
        response?.OutcomeDetail === 'Please enter valid User Name and Password'
      ) {
        ToastAndroid.show(response.OutcomeDetail, ToastAndroid.SHORT);
        return;
      }

      if (response?.OutcomeDetail === 'Invalid Captcha Text') {
        ToastAndroid.show(response.OutcomeDetail, ToastAndroid.SHORT);
        return;
      }

      // if (!Array.isArray(response)) {
      //   ToastAndroid.show('Invalid response format', ToastAndroid.SHORT);
      //   return;
      // }

      setPendingActionData(response);
      setDashboardData(response);

      const sumCount = response.reduce(
        (sum, item) => sum + Number(item?.Count || 0),
        0,
      );

      setTotalCount(sumCount);
    } catch (error) {
      console.error('fetchDashboardData error:', error);
    } finally {
      setInitialLoader(false);
    }
  };

  return initialLoader ? (
    <View style={{ flex: 1, backgroundColor: '#fff' }}>
      <CustomLoader color="#2C61F3" />
    </View>
  ) : (
    <ScrollView style={{ flex: 1, backgroundColor: '#fff' }}>
      <>
        <View style={commonStyles.headercontainer}>
          <View style={{ width: '70%' }}>
            <Text style={commonStyles.Textstyle}>Hello,</Text>
            <Text
              numberOfLines={3}
              style={[commonStyles.homenametext, { letterSpacing: 0.3 }]}
            >
              {loginData?.EmployeeName || 'EMPLOYEE NAME'}
            </Text>
            <Text style={[commonStyles.homesubname, { letterSpacing: 0.3 }]}>
              {loginData?.DepartmentName || 'Designation'}
            </Text>
          </View>
          {userImageLoader ? (
            <ActivityIndicator size={30} style={{ flex: 1 }} />
          ) : (
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {/* <Image
              source={
                Base64string != '' && Base64string != null
                  ? {uri: `data:image/jpeg;base64,${Base64string}`}
                  : require('./images/sms-profile.png')
              }
              style={commonStyles.image1}
            /> */}

              <Image
                source={
                  imageUri
                    ? { uri: imageUri }
                    : require('./images/sms-profile.png')
                }
                style={commonStyles.image1}
              />

              <TouchableOpacity
                onPress={() => {
                  setVisibleProfile(true);
                }}
              >
                <Icon1
                  style={{
                    position: 'absolute',
                    bottom: -10,
                    right: -12,
                    backgroundColor: '#fff',
                    padding: 5,
                    borderRadius: 20,
                    borderColor: 'gray',
                    borderWidth: 0.5,
                  }}
                  name="camera"
                  color="#1a55e3"
                  size={13}
                />
              </TouchableOpacity>
            </View>
          )}
        </View>
        <View style={commonStyles.purplebanner}>
          <Text
            style={[
              commonStyles.homenametext,
              {
                fontSize: 18,
                fontFamily: 'Poppins Bold 700',
                letterSpacing: 0.5,
              },
            ]}
          >
            Total Pending Approval
          </Text>
          <Text
            style={[
              commonStyles.homenametext,
              {
                fontSize: 22,
                fontFamily: 'Poppins Bold 700',
                color: '#2C61F3',
              },
            ]}
          >
            {totalCount}
          </Text>
        </View>
        <View style={commonStyles.container}>
          {Array.isArray(pendingActionData) && pendingActionData.length > 0 ? (
            <>
              <View
                style={{
                  justifyContent: 'center',
                  flexDirection: 'row',
                  rowGap: 20,
                  gap: 20,
                  flexWrap: 'wrap',
                  marginTop: 20,
                }}
              >
                {pendingActionData.map((item, index) => (
                  <TouchableOpacity
                    key={index}
                    // onPress={() => navigation.navigate(item.ScreenName, { screenInfo: item })}
                    onPress={() => {
                      if (Number(item.Count) === 0) {
                        Alert.alert('No Data Available', '', [{ text: 'OK' }]);
                        return;
                      }

                      navigation.navigate(item.ScreenName, {
                        screenInfo: item,
                      });
                    }}
                    style={{
                      height: 240,
                      borderRadius: 30,
                      backgroundColor: cardColors[index] || 'pink',
                      width: '40%',
                      padding: 20,
                      justifyContent: 'space-between',
                    }}
                  >
                    {/* {console.log('print here------', cardIconImages[index])} */}
                    <Image
                      style={{ height: 40, width: 40 }}
                      source={cardIconImages[index] || null}
                    />
                    <View
                      style={{
                        marginTop: 20,
                        flexDirection: 'column',
                        height: '75%',
                      }}
                    >
                      <Text
                        style={{
                          includeFontPadding: false,
                          fontFamily: 'Poppins Regular 400',
                          fontSize: width * 0.1,
                          color: 'black',
                        }}
                      >
                        {item?.Count}
                      </Text>
                      <Text
                        numberOfLines={3}
                        style={{
                          includeFontPadding: false,
                          fontFamily: 'Poppins Regular 400',
                          fontSize: width * 0.038,
                          color: 'black',
                        }}
                      >
                        {item?.ScreenName}
                      </Text>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            </>
          ) : (
            <Text style={{ textAlign: 'center', marginTop: 20 }}>
              No pending data
            </Text>
          )}
        </View>
        <Dialog.Container
          contentStyle={[commonStyles.dialogBox]}
          visible={visibleProfile}
          onBackdropPress={handleCancel1}
        >
          <Dialog.Title
            style={{
              fontFamily: 'Poppins SemiBold 600',
              color: '#000',
              fontSize: 14,
            }}
          >
            Choose any
          </Dialog.Title>
          <View style={{ flexDirection: 'row' }}>
            <View
              style={{
                marginHorizontal: 14,
                flexDirection: 'column',
                alignItems: 'center',
              }}
            >
              <TouchableOpacity onPress={requestCameraPermission}>
                <Icon1
                  style={commonStyles.chooseiconstyle}
                  name="camera"
                  color="#1a55e3"
                  size={18}
                />
              </TouchableOpacity>
              <Text
                style={{
                  fontFamily: 'Poppins Medium 500',
                  color: '#000',
                  fontSize: 14,
                }}
              >
                Camera
              </Text>
            </View>
            <View
              style={{
                marginHorizontal: 14,
                flexDirection: 'column',
                alignItems: 'center',
              }}
            >
              <TouchableOpacity onPress={selectFile}>
                <Icon2
                  style={commonStyles.chooseiconstyle}
                  name="images"
                  color="#1a55e3"
                  size={18}
                />
              </TouchableOpacity>
              <Text
                style={{
                  fontFamily: 'Poppins Medium 500',
                  color: '#000',
                  fontSize: 14,
                }}
              >
                Gallery
              </Text>
            </View>
          </View>
        </Dialog.Container>
        <></>
      </>
    </ScrollView>
  );
}

export default HomePage;
