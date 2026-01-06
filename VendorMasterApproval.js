import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TextInput,
  FlatList,
  BackHandler,
  RefreshControl,
  ActivityIndicator
} from 'react-native';
import commonStyles from './CommonCSS';
import { useIsFocused } from '@react-navigation/native';
import Icon1 from 'react-native-vector-icons/MaterialCommunityIcons';
import Icon2 from 'react-native-vector-icons/Ionicons';
import Icon3 from 'react-native-vector-icons/Feather';
import RBSheet from 'react-native-raw-bottom-sheet';
import AsyncStorage from '@react-native-async-storage/async-storage';
import CustomLoader from './Common/CustomLoader';
import { useFocusEffect } from '@react-navigation/native';
import { TokenFetchHttpGet } from './FetchHTTP/FetchHttpRequest';


function VendorMasterApproval({ navigation, route }) {
  const isFocused = useIsFocused();
  const skipResetRef = useRef(false);
  const pageSizeRef = useRef(null);
  const { screenInfo } = route.params;
  console.log("received screenInfo: ", screenInfo);
  // const previousScreenData = route.params;
  const [initialLoader, setInitialLoader] = useState(true);
  const DeclineBottomsheet = useRef();
  const [searchType, setSearchType] = useState('ClaimNumber');
  const [searchInput, setSearchInput] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [data, setData] = useState([]);
  const [refreshing, setRefreshing] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const SEARCH_TYPES = [
    { label: 'Claim Number', value: 'ClaimNumber' },
    { label: 'Vendor Name', value: 'VendorName' },
  ];
  const searchTypeLabel =
    SEARCH_TYPES.find(item => item.value === searchType)?.label ?? 'Search';

  // Function to handle pull-to-refresh
  const handleRefresh = useCallback(() => {
    setRefreshing(true);
    console.log("Page before refresh:", page)
    GetTransactionSearchPage(page);
  }, [page]);
  const searchTimeoutRef = useRef(null);

  const searchFilter = (text) => {
    setSearchInput(text);

    if (searchTimeoutRef.current) {
      clearTimeout(searchTimeoutRef.current);
    }

    searchTimeoutRef.current = setTimeout(() => {
      setPage(1);
      setSearchQuery(text);
    }, 300);
  };

  useFocusEffect(
    React.useCallback(() => {
      return () => {
        if (skipResetRef.current) {
          skipResetRef.current = false;
          return;
        }

        setSearchInput("");
        setSearchQuery("");
        setPage(1);
        setData([]);
        pageSizeRef.current = null;
      };
    }, [])
  );

  useEffect(() => {
    if (!isFocused) return;
    setInitialLoader(true);
    GetTransactionSearchPage(page, searchQuery);
  }, [page, searchQuery, searchType, isFocused]);

  const flatListRef = useRef(null);

  useEffect(() => {
    flatListRef.current?.scrollToOffset({
      offset: 0,
      animated: true,
    });
  }, [page]);

  const GetTransactionSearchPage = async (page, searchText = "") => {
    console.log("REACHING HERE");
    // const parsedData = JSON.parse(screenInfo);
    const employeeId = await AsyncStorage.getItem('EmployeeIdentity');
    const screenId = screenInfo.ScreenId;
    const departmentId = await AsyncStorage.getItem('DepartmentId');

    const Config = {
      Url: 'MobVendorMaster/GetTransactionSearchPage',
      method: 'POST',
      body: {
        EmployeeId: employeeId,
        ScreenId: screenId,
        DepartmentId: departmentId,
        Page: page,
        SearchType: searchType,
        SearchValue: searchText,
      }
    };

    try {
      console.log('GetTransactionSearchPage Params:', Config.body);
      const response = await TokenFetchHttpGet(Config);
      console.log('response GetTransactionSearchPage:', response);
      const sortedResponse = response.sort(
        (a, b) => Number(b.Ageing) - Number(a.Ageing)
      )
      const grouped = groupByClaimNumber(sortedResponse);
      if (grouped.length === 0 && page > 1) {
        setPage(prev => prev - 1);
        return;
      }
      setData(grouped);
      // setData(response);
      console.log("Grouped list here ----------->", grouped)
      if (page === 1 && !pageSizeRef.current) {
        pageSizeRef.current = response.length;
      }

      const PAGE_SIZE = pageSizeRef.current || response.length;
      const totalCount = Number(response[0]?.TotalCount || 0);
      const pages =
        PAGE_SIZE > 0 && totalCount > 0
          ? Math.ceil(totalCount / PAGE_SIZE)
          : 1;
      setTotalPages(pages);
      return;
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setRefreshing(false);
      setInitialLoader(false);
    }
  };

  const groupByClaimNumber = (arr) => {
    const groups = arr.reduce((acc, item) => {
      const key = item.ClaimNumber;

      if (!acc[key]) {
        acc[key] = [];
      }

      acc[key].push(item);
      return acc;
    }, {});

    // convert object → array
    return Object.keys(groups).map((key) => ({
      claimNumber: key,
      items: groups[key]
    }));
  };

  useFocusEffect(
    React.useCallback(() => {
      const handleBackButton = () => {
        navigation.navigate('Dashboard');
        return true;
      };
      const subscription = BackHandler.addEventListener('hardwareBackPress', handleBackButton);
      return () => subscription.remove();
    }, [])
  )

  const onClickDetailsApproval = (item, screenInfo) => {
    skipResetRef.current = true;
    navigation.navigate('VendorMasterApprovalDetail', { data: item, data2: screenInfo });
  };

  const workflow = item => {
    skipResetRef.current = true;
    navigation.navigate('VendorMasterWorkflow', { data: item });
  };

  const Pagination = ({ currentPage, totalPages, onPageChange }) => {
    const pages = Array.from({ length: totalPages }, (_, i) => i + 1);

    return (
      <View
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "center",
          paddingVertical: 8,
        }}
      >
        {/*  First Page */}
        <TouchableOpacity
          onPress={() => onPageChange(1)}
          disabled={currentPage === 1}
          style={{
            marginHorizontal: 12,
          }}
        >
          <Icon1 name={'skip-previous'} color={'gray'} size={36} />
        </TouchableOpacity>

        {/*  Previous Page */}
        <TouchableOpacity
          onPress={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          style={{
            marginHorizontal: 12,
          }}
        >
          <Icon1 name={'play'} color={'gray'} size={32} style={{ transform: [{ scaleX: -1 }] }} />
        </TouchableOpacity>

        {/* Page Numbers */}
        <Text style={{ color: "#000" }}>
          Page{" "}
          <Text style={{ fontWeight: "bold" }}>{currentPage}</Text>
          {" "}of{" "}
          <Text style={{ fontWeight: "bold" }}>{totalPages}</Text>
        </Text>

        {/*  Next Page */}
        <TouchableOpacity
          onPress={() => {
            if (currentPage < totalPages) {
              onPageChange(currentPage + 1);
            }
          }}
          disabled={currentPage === totalPages}
          style={{
            marginHorizontal: 12,
          }}
        >
          <Icon1 name={'play'} color={'gray'} size={32} />
        </TouchableOpacity>

        {/*  Last Page */}
        <TouchableOpacity
          onPress={() => onPageChange(totalPages)}
          disabled={currentPage === totalPages}
          style={{
            marginHorizontal: 12,
          }}
        >
          <Icon1 name={'skip-next'} color={'gray'} size={36} />
        </TouchableOpacity>
      </View>
    );
  };

  return (
    <View style={{ flex: 1, backgroundColor: '#FFFFFF' }}>

      <View
        style={{
          backgroundColor: 'white',
          width: '100%',
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          borderColor: '#E2E2E2',
          borderWidth: 1,
          marginTop: 10,
        }}>
        <View
          style={{
            marginLeft: 20,

            flexDirection: 'row',
            alignItems: 'center'
          }}>
          <Icon3 name="search" color="#2D2C2D" size={23} />
          {/* <Text style={commonStyles.EduCtextSt}>Search</Text> */}
          <TextInput
            style={[commonStyles.TextInput, { paddingLeft: 10, width: '80%' }]}
            // placeholder="Vendor Name / Claim ID"
            placeholder={searchTypeLabel}
            value={searchInput}
            placeholderTextColor={'#000'}
            onChangeText={searchFilter}
          />

        </View>
        <View>
          <TouchableOpacity
            onPress={() => {
              DeclineBottomsheet.current.open();
            }}>
            <Icon2
              name="options-outline"
              color="#2D2C2D"
              size={22}
              style={{ paddingRight: 26 }}
            />
          </TouchableOpacity>
        </View>
      </View>
      <RBSheet
        ref={DeclineBottomsheet}
        useNativeDriver={true}
        height={200}
        customStyles={{
          wrapper: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
          },
          draggableIcon: {
            backgroundColor: '#000',
          },
        }}
        customModalProps={{
          animationType: 'slide',
          statusBarTranslucent: true,
        }}
        customAvoidingViewProps={{
          enabled: false,
        }}>
        <View style={{ padding: 20 }}>
          <Text style={{ fontSize: 16, fontWeight: '600', marginBottom: 15, color: "#000" }}>
            Select Search Type
          </Text>

          {SEARCH_TYPES.map(item => (
            <TouchableOpacity
              key={item.value}
              onPress={() => {
                setSearchType(item.value)
                DeclineBottomsheet.current.close();
              }}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                paddingVertical: 12,
              }}>

              {/* Radio circle */}
              <View
                style={{
                  height: 20,
                  width: 20,
                  borderRadius: 10,
                  borderWidth: 2,
                  borderColor: '#000',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginRight: 12,
                }}>
                {searchType === item.value && (
                  <View
                    style={{
                      height: 10,
                      width: 10,
                      borderRadius: 5,
                      backgroundColor: '#000',
                    }}
                  />
                )}
              </View>

              <Text style={{ fontSize: 15, color: "#000" }}>{item.label}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </RBSheet>

      {initialLoader ? (
        <CustomLoader color="#2C61F3" />
      ) : (
        <>
          <FlatList
            ref={flatListRef}
            data={data}   // grouped by ClaimNumber
            renderItem={({ item, index }) => {
              const subItem = item.items[0]; // show ONLY ONE ITEM per group

              return (
                <View
                  key={index}
                  style={[
                    commonStyles.vendorContainer,
                    { borderColor: '#E2E2E2', borderWidth: 1, paddingLeft: 15 },
                  ]}
                >

                  <TouchableOpacity
                    style={commonStyles.EduDirection}
                    onPress={() => {
                      if (!item?.items || !screenInfo) {
                        return;
                      } else {
                        onClickDetailsApproval(item?.items, screenInfo);
                      }

                    }}
                  >

                    <View
                      style={{
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                      }}>

                      <View style={{ flex: 1 }}>
                        <Text numberOfLines={2} style={[commonStyles.CommHeaderName]}>
                          {subItem?.VendorName}
                        </Text>

                        <Text
                          style={[
                            commonStyles.FamGenSty,
                            { textDecorationLine: 'underline' },
                          ]}>
                          {subItem?.ClaimNumber}
                        </Text>
                      </View>

                      <TouchableOpacity
                        onPress={() => workflow(item?.items)} // FULL GROUP
                        style={{ paddingRight: 15 }}>
                        <View
                          style={{
                            borderRadius: 100,
                            alignItems: 'center',
                            justifyContent: 'center',
                            borderWidth: 2,
                            borderColor: '#1165AE',
                          }}
                        >
                          <Icon1
                            style={{ position: 'relative', bottom: -1 }}
                            name="filter-variant"
                            color="#2D2C2D"
                            size={26}
                          />
                        </View>
                      </TouchableOpacity>

                    </View>

                    {/* DETAILS SECTION */}
                    <View style={{ paddingHorizontal: 0 }}>
                      <View style={{ flexDirection: 'row', paddingTop: 10, alignItems: 'flex-start' }}>
                        <View style={commonStyles.InsNameSty}>
                          <Text style={commonStyles.gridtitle}>Department</Text>
                          <Text style={[commonStyles.gridtext, { paddingTop: 6 }]}>
                            {subItem?.Department}
                          </Text>
                        </View>

                        {/* <View style={commonStyles.InsNameSty}>
                          <Text style={commonStyles.gridtitle}>Claim amount</Text>
                          <Text style={[commonStyles.gridtext, { paddingTop: 6 }]}>
                            {subItem?.ClaimAmount
                              ? Number(subItem?.ClaimAmount)
                                .toLocaleString('en-IN', { minimumFractionDigits: 0 })
                              : 'NA'}
                          </Text>
                        </View> */}

                        <View style={commonStyles.InsNameSty}>
                          <Text style={commonStyles.gridtitle}>Invoice Ageing</Text>
                          <Text style={[commonStyles.gridtext, { paddingTop: 6 }]}>
                            {subItem?.Ageing ? subItem?.Ageing : '--'}
                          </Text>
                        </View>
                      </View>
                    </View>

                  </TouchableOpacity>

                </View>
              );
            }}

            keyExtractor={(item, index) => item.claimNumber + index}
            refreshControl={
              <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
            }
            // onEndReached={loadMore}
            onEndReachedThreshold={0.1}
            ListFooterComponent={<View style={{ height: 40 }} />}
            ListEmptyComponent={() =>
              !initialLoader ? (
                <View style={{ flex: 1, alignItems: 'center', marginTop: 40 }}>
                  <Text style={{ fontSize: 16, color: '#7A7A7A', fontWeight: '500' }}>
                    No data available
                  </Text>
                </View>
              ) : null
            }
          />
        </>
      )}
      <Pagination
        currentPage={page}
        totalPages={totalPages}
        onPageChange={setPage}
      />
    </View>
  );
}


export default VendorMasterApproval;
