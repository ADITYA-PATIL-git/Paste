import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  FlatList,
  ToastAndroid,
  BackHandler,
  Platform,
  Alert,
  ActivityIndicator
} from 'react-native';
import commonStyles from './CommonCSS';
import Icon1 from 'react-native-vector-icons/MaterialCommunityIcons';
import Icon2 from 'react-native-vector-icons/MaterialIcons';
import Icon3 from 'react-native-vector-icons/Ionicons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { CallAPI } from './FetchHTTP/FetchHttpRequest';
import { Appbar, IconButton } from 'react-native-paper';
import { TokenFetchHttpGet } from './FetchHTTP/FetchHttpRequest';

function POWorkflow({ navigation, route }) {


  const { data: groupItems } = route.params;
  console.log("reaching POWorkflow, grouped items received:", groupItems);

  const [isPageLoading, setisPageLoading] = useState(false);
  const initialData = {
    Data: [],
    TotalPages: 1,
    TotalRecords: 0,
    PageSize: 10,
    PageIndex: 1,
  };
  const [data, setData] = useState(initialData.Data);
  const [TotalRecords, setTotalRecords] = useState(initialData.TotalRecords);
  const [PageIndex, setPageIndex] = useState(initialData.PageIndex);
  const [TotalPages, setTotalPages] = useState(initialData.TotalPages);
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);

  useEffect(() => {
    // console.log("reaching useEffect at Approval Detail", groupItems)
    const fetchData = async () => {
      await callPendingApprovalsList();
    };
    fetchData();
    BackHandler.addEventListener('hardwareBackPress', handleBackButton);
    return () => {
      BackHandler.addEventListener('hardwareBackPress', handleBackButton);
    };
  }, []);

  // function VendorInvoiceWorkflow({ navigation, route }) {

  //   const entryData = route.params;
  //   console.log("reaching ApprovedDetail", entryData)
  //   const [isPageLoading, setisPageLoading] = useState(false);
  //   const initialData = {
  //     Data: [],
  //     TotalPages: 1,
  //     TotalRecords: 0,
  //     PageSize: 10,
  //     PageIndex: 1,
  //   };
  //   const [data, setData] = useState(initialData.Data);
  //   const [TotalRecords, setTotalRecords] = useState(initialData.TotalRecords);
  //   const [PageIndex, setPageIndex] = useState(initialData.PageIndex);
  //   const [TotalPages, setTotalPages] = useState(initialData.TotalPages);
  //   const [refreshing, setRefreshing] = useState(false);
  //   const [loadingMore, setLoadingMore] = useState(false);

  //   const handleAcceptBTN2 = () => {
  //     getDecline();
  //   };

  //   const handleCancel = () => {
  //     setVisible(false);
  //   };


  //   useEffect(() => {
  //     console.log("reaching useEffect at Approval Detail", entryData)
  //     const fetchData = async () => {
  //       await callPendingApprovalsList();
  //     };
  //     fetchData();
  //     BackHandler.addEventListener('hardwareBackPress', handleBackButton);
  //     return () => {
  //       BackHandler.addEventListener('hardwareBackPress', handleBackButton);
  //     };
  //   }, []);

  const callPendingApprovalsList = async () => {
    console.log("reaching callPendingApprovalsList")
    setisPageLoading(true);

    try {
      const transactionId = groupItems?.[0]?.TransactionId;   // UPDATED

      let Config = {
        Url: `MobPurchaseOrder/GetWorkflowDetails`,
        method: 'POST',
        body: {
          TransactionId: transactionId,
        }
      };

      console.log("callPendingApprovalsList-body===>", Config)

      const response = await TokenFetchHttpGet(Config);
      console.log("callPendingApprovalsList-response===>", response)

      if (Array.isArray(response) && response.length > 0) {
        setData(response);
        setisPageLoading(false);
      } else {
        Platform.OS === 'android'
          ? ToastAndroid.show('No Data Found', ToastAndroid.SHORT)
          : Alert.alert('No Data Found');
        setisPageLoading(false);
      }
    } catch (error) {
      console.log('error ----> ', error);
      setisPageLoading(false);
    }
  };


  // const callPendingApprovalsList = async () => {
  //   console.log("reaching callPendingApprovalsList")

  //   try {
  //     // const loginData = await AsyncStorage.getItem('LoginData');
  //     const transactionId = entryData?.data.TransactionId;
  //     let Config = {
  //       Url: `MobVendorInvoice/GetWorkflowDetails`,
  //       method: 'POST',
  //       body: {
  //         TransactionId: transactionId,
  //       }
  //     };
  //     console.log("callPendingApprovalsList-body===>", Config)
  //     const response = await TokenFetchHttpGet(Config);
  //     console.log("callPendingApprovalsList-response===>", response)
  //     if (response !== 'error' && response.length != 0) {

  //       console.log("response.WorkflowHistory", response?.WorkflowHistory)
  //       setData(response);

  //     } else {
  //       ToastAndroid.show('Server Error!', ToastAndroid.SHORT);
  //     }
  //   } catch (error) {
  //     console.log('error ----> ', error);
  //   }
  // };



  const handleBackButton = () => {
    navigation.goBack();
    return true;
  };

  const getStatusColor = (ActionStatus, Status) => {
    const as = ActionStatus.toLowerCase();
    const s = Status.toLowerCase();
    if (s.includes("approved")) return "#20bf6b";
    if (as.includes("approved")) return "#20bf6b";
    if (as.includes("rejected")) return "#ff4d4d";
    if (as.includes("pending")) return "#ffcc00";
    // if (s.includes("submitter")) return "#2C61F3";
    // if (s.includes("history")) return "#2C61F3";
    return "#2C61F3"; // default blue if nothing matches
  };


  return (
    <View style={{ flex: 1, backgroundColor: '#FFFFFF' }}>

      {isPageLoading ? (
        <ActivityIndicator
          // animating = {animating}
          color="#1165AE"
          size="large"
          style={styles.activityIndicator}
        />
      ) : (
        <View style={{ flex: 1 }}>
          <Appbar.Header style={commonStyles.AppbarHeader}>
            <IconButton
              onPress={() => {
                navigation.goBack();
              }}
              icon={() => (
                <Icon3 name="chevron-back" color="#000" size={30} />
              )}
            />

            <Appbar.Content
              title={
                <Text
                  style={commonStyles.AppbarTitle}>
                  Approval Details
                </Text>
              }
            />
          </Appbar.Header>

          <FlatList
            showsVerticalScrollIndicator={false}
            data={data}
            keyExtractor={(item, index) =>
              item?.Id?.toString() ?? index.toString()
            }
            ListFooterComponent={<View style={{ height: 200 }} />}
            renderItem={({ item, index }) => (
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'flex-start',
                }}>
                <View
                  style={{
                    flexDirection: 'column',
                    alignItems: 'center',
                  }}>
                  {/* <View
                        style={[
                          styles.profileImgContainer,
                          { backgroundColor: getStatusColor(item?.Status) },
                        ]}
                      >
                        <Icon1 name="check" color="#fff" size={23} />
                      </View> */}
                  <View
                    style={[
                      styles.profileImgContainer,
                      { backgroundColor: getStatusColor(item?.ActionStatus, item?.Status) },
                    ]}
                  >
                    {item?.ActionStatus?.toLowerCase().includes("rejected") ? (
                      <Icon1 name="close" color="#fff" size={23} />
                    ) : item?.ActionStatus?.toLowerCase().includes("pending") ? (
                      <Icon1 name="minus" color="#fff" size={23} />
                    ) : (
                      <Icon1 name="check" color="#fff" size={23} />
                    )}

                  </View>
                  <View style={styles.verticleLine}></View>
                </View>

                <View style={styles.buttonStyle}>
                  {item?.Status == 'Approved By Approver' ? (
                    <Text
                      style={[
                        styles.container5,
                        { color: '#20bf6b', paddingTop: 10 },
                      ]}>
                      {item?.Status}
                    </Text>
                  ) : item?.Status == 'Rejected By Approver' ? (
                    <Text
                      style={[
                        styles.container5,
                        { color: '#ff4d4d', paddingTop: 10 },
                      ]}>
                      {item?.Status}
                    </Text>
                  ) : (
                    <Text
                      style={[
                        styles.container5,
                        { color: '#2C61F3', paddingTop: 10 },
                      ]}>
                      {item?.Status}
                    </Text>
                  )}

                  <Text
                    style={
                      {
                        color: '#000',
                        paddingRight: 10,
                        fontSize: 16,
                        fontFamily: 'Poppins Regular 400',
                        includeFontPadding: false,
                        color: '#2D2C2D',
                        paddingHorizontal: 0,
                      }
                    }>
                    {item?.ApproverName}
                  </Text>
                  {item?.Status?.toLowerCase().includes("approved") ||
                    item?.Status?.toLowerCase().includes("submitter") ? (
                    <Text style={commonStyles.registersubheadertyle}>
                      {item?.ApproveDate}
                    </Text>
                  ) : null}
                  {item?.Remarks &&
                    <Text style={commonStyles.registersubheadertyle}>
                      Remarks : {item?.Remarks}
                    </Text>
                  }
                </View>
              </View>
            )}
            contentContainerStyle={{ margin: 30 }}
          ></FlatList>
        </View>
      )}

    </View>
  );
}

export default POWorkflow;

const styles = StyleSheet.create({
  verticleLine: {
    flex: 1,
    width: 1,
    backgroundColor: '#999999',
  },
  profileImgContainer: {
    borderRadius: 60,
    padding: 8,
  },
  container5: {
    fontSize: 18,
    fontFamily: 'Poppins Medium 500',
    includeFontPadding: false,
  },
  buttonStyle: {
    flexDirection: 'column',
    marginBottom: 30,
    justifyContent: 'center',
    alignItems: 'flex-start',
    paddingLeft: 15,
    flex: 1,
  },
  activityIndicator: {
    paddingTop: 30,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    height: 150,
  },
});
