// import {fetch} from 'react-native-ssl-pinning';
import { alertAndResetToRegistration } from '../RootNavigation';
import AsyncStorage from '@react-native-async-storage/async-storage';
import NetInfo from '@react-native-community/netinfo';
export const BaseURL =
  // 'https://sit.osourceglobal.com/INT_UAT_BAJAJFINSERV_AMC_API/api/'; // INT LINK
  'https://invoice.bajajamc.com/ONEXSMS_API_BAJAJFINSERV_AMC/api/'; // LIVE LINK

// 'https://sit.osourceglobal.com/uat_sms_demo_core_api/api/';
// 'https://sit.osourceglobal.com/INT_UAT_API_SMS_AXIS_SECURITY/api/';
// 'https://sit.osourceglobal.com/INT_UAT_SMS_AXIS_SECURITY_API/api/';
// 'https://onexuat.bfsamc.in/UAT_API_BAJAJFINSERV_AMC/api/';

// 'https://sit.osourceglobal.com/INT_UAT_BAJAJFINSERV_AMC/Login/Login';

const waitForInternet = () =>
  new Promise(resolve => {
    const unsubscribe = NetInfo.addEventListener(state => {
      if (state.isConnected === true) {
        unsubscribe && unsubscribe();
        resolve();
      }
    });
  });

const wait = ms => new Promise(r => setTimeout(r, ms));

export const TokenFetchHttpGet = async (Config, retries = 5, delay = 1000) => {
  const UserId = await AsyncStorage.getItem('UserId');
  const SessionId = await AsyncStorage.getItem('SessionId');

  console.log(
    'Check UserId & SessionId at TokenFetchHttpGet---------->',
    UserId,
    SessionId,
  );

  try {
    const response = await fetch(BaseURL + Config.Url, {
      method: Config.method || 'GET',
      headers: {
        // ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==', INT
        ClientID:
          'u8QRhB3GLld2eaIuSHqt1LFA53jcMC/1Xd30Txzl0M4xBsGk1bWvjqmB+FAzDZIl',
        AuthID: UserId,
        AuthToken: SessionId,
        'Content-Type': 'application/json',
      },
      body:
        Config.method === 'POST' && Config.body
          ? JSON.stringify(Config.body)
          : undefined,
    });
    console.log(
      'CHECK----------------------------------------------',
      response,
    );

    console.log('TokenFetchHttpGet config -------------->', {
      url: BaseURL + Config.Url,
      method: Config.method || 'GET',
      headers: {
        ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
        AuthID: UserId,
        AuthToken: SessionId,
        'Content-Type': 'application/json',
      },
      body:
        Config.method === 'POST' && Config.body
          ? JSON.stringify(Config.body)
          : undefined,
    });

    const text = await response.text();
    const parsed = text ? JSON.parse(text) : null;

    console.log('TokenFetchHttpGet response.status -------->', response.status);

    // 401 handling
    if (response.status === 401) {
      await AsyncStorage.multiRemove([
        'UserId',
        'SessionId',
        'keyId',
        'publicKey',
        'encrPass',
        'encrKeyId',
        'userImageUri',
        'EmployeeIdentity',
      ]);
      await AsyncStorage.setItem('forceLogout', 'true');
      alertAndResetToRegistration();
      return;
    }

    //  Preserve array OR object exactly
    if (Array.isArray(parsed)) {
      parsed._ok = response.ok;
      parsed._status = response.status;
      return parsed;
    }

    if (parsed && typeof parsed === 'object') {
      return {
        ...parsed,
        _ok: response.ok,
        _status: response.status,
      };
    }

    // Empty body (200 with no JSON)
    return {
      _ok: response.ok,
      _status: response.status,
    };
  } catch (error) {
    if (retries <= 0) throw error;

    await waitForInternet();
    await wait(delay);

    return TokenFetchHttpGet(Config, retries - 1, Math.min(delay * 2, 30000));
  }
};

// export const TokenFetchHttpGet = async (Config, retries = 5, delay = 1000) => {
//   const UserId = await AsyncStorage.getItem('UserId');
//   const SessionId = await AsyncStorage.getItem('SessionId');

//   try {
//     const response = await fetch(BaseURL + Config.Url, {
//       method: Config.method || 'GET',
//       headers: {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//         'Content-Type': 'application/json',
//       },
//       body:
//         Config.method === 'POST' && Config.body
//           ? JSON.stringify(Config.body)
//           : undefined,
//     });

//     const text = await response.text();
//     const parsed = text ? JSON.parse(text) : {};

//     if (response.status === 401) {
//       await AsyncStorage.setItem('forcedLogout', 'true');
//       await AsyncStorage.multiRemove([
//         'UserId',
//         'SessionId',
//         'keyId',
//         'publicKey',
//         'encrPass',
//         'encrKeyId',
//       ]);
//       alertAndResetToRegistration();
//       return;
//     }

//     if (!response.ok) {
//       return {
//         ...parsed,
//         _httpError: true,
//         _httpStatus: response.status,
//       };
//     }

//     return parsed;
//   } catch (error) {
//     if (retries <= 0) {
//       throw error;
//     }

//     console.log('Network error, retrying...', error);

//     await waitForInternet();
//     await wait(delay);

//     return TokenFetchHttpGet(Config, retries - 1, Math.min(delay * 2, 30000));
//   }
// };

// export const TokenFetchHttpGet = async (Config, retries = 5, delay = 1000) => {
//   const UserId = await AsyncStorage.getItem('UserId');
//   const SessionId = await AsyncStorage.getItem('SessionId');

//   const headers = {
//     ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//     'Content-Type': 'application/json',
//   };

//   // Only attach auth headers if not disabled
//   if (!Config.skipAuth) {
//     headers.AuthID = UserId;
//     headers.AuthToken = SessionId;
//   }

//   try {
//     const response = await fetch(BaseURL + Config.Url, {
//       method: Config.method || 'GET',
//       headers,
//       body:
//         Config.method === 'POST' && Config.body
//           ? JSON.stringify(Config.body)
//           : undefined,
//     });

//     const text = await response.text();
//     const parsed = text ? JSON.parse(text) : {};

//     // if (response.status === 401) {
//     //   alertAndResetToRegistration();
//     //   return;
//     // }

//     if (!response.ok) {
//       return {
//         ...parsed,
//         _httpError: true,
//         _httpStatus: response.status,
//       };
//     }

//     return parsed;
//   } catch (error) {
//     if (retries <= 0) {
//       throw error;
//     }

//     console.log('Network error, retrying...', error);

//     await waitForInternet();
//     await wait(delay);

//     return TokenFetchHttpGet(Config, retries - 1, Math.min(delay * 2, 30000));
//   }
// };

// export const TokenFetchHttpGet = async (
//   Config,
//   retries = Infinity,
//   delay = 1000,
// ) => {
//   const UserId = await AsyncStorage.getItem('UserId');
//   const SessionId = await AsyncStorage.getItem('SessionId');

//   try {
//     const response = await fetch(BaseURL + Config.Url, {
//       method: Config.method || 'GET',
//       headers: {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//         'Content-Type': 'application/json',
//       },
//       body:
//         Config.method === 'POST' && Config.body
//           ? JSON.stringify(Config.body)
//           : undefined,
//     });

//     const text = await response?.text();
//     const parsed = text ? JSON.parse(text) : {};

//     if (!response.ok) {
//       parsed._httpError = true;
//       parsed._httpStatus = response?.status;
//       return parsed;
//     }

//     return parsed;
//   } catch (error) {
//     console.log('Network error, retrying...', error);

//     await waitForInternet(); // wait till online
//     await wait(delay); // backoff

//     return TokenFetchHttpGet(
//       Config,
//       retries,
//       Math.min(delay * 2, 30000), // cap at 30s
//     );
//   }
// };

// export const TokenFetchHttpGet = async (Config) => {
//   const UserId = await AsyncStorage.getItem('UserId');
//   const SessionId = await AsyncStorage.getItem('SessionId');

//   try {
//     const response = await fetch(BaseURL + Config.Url, {
//       method: Config.method || 'GET',
//       headers: {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//         'Content-Type': 'application/json',
//         'X-IBM-Client-Id': '8d906658-12d1-45ad-8c73-8bcc751334d7',
//         'X-IBM-Client-Secret': 'A1aT6dP0nQ4vX5fK4xB0rL5tI6bO1wH5uH8aH6nP4iI8fP2rX8',
//       },
//       body: Config.body ? JSON.stringify(Config.body) : undefined,
//     });

//     if (!response.ok) {
//       throw new Error(`HTTP_${response.status}`);
//     }

//     const text = await response.text();

//     // ✅ Handle EMPTY response properly
//     if (!text) {
//       throw new Error('EMPTY_RESPONSE');
//     }

//     return JSON.parse(text);

//   } catch (error) {
//     console.log('TokenFetchHttpGet error ===', error);
//     if (error.message === 'HTTP_401' || error.message === 'HTTP_400') {
//       alertAndResetToRegistration();
//     }
//     throw error;
//   }
// };

// export const OtpVerificationHttpGet = async Config => {
//   try {
//     const UserId = await AsyncStorage.getItem('UserId');
//     const SessionId = await AsyncStorage.getItem('SessionId');

//     console.log("Headers being sent: ",
//       {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//       });

//     const Resp = await fetch(BaseURL + Config.Url, {
//       method: Config.method ? Config.method : 'GET',
//       body: Config.body ? JSON.stringify(Config.body) : null,
//       headers: {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//       },
//     },
//     );

//     console.log("HTTP Status:", Resp.status);

//     const raw = await Resp.text();
//     console.log("Raw Response Text:", raw);

//     try {
//       const json = JSON.parse(raw);
//       console.log("Parsed JSON:", json);
//       return json;
//     } catch {
//       // Not JSON
//       return raw;
//     }
//   } catch (error) {
//     console.log("TokenFetchHttpGet ERROR ===>", error);
//     return undefined;
//   }
// };

// export const OtpVerificationHttpGet = async Config => {
//   try {
//     const UserId = await AsyncStorage.getItem('UserId');
//     const SessionId = await AsyncStorage.getItem('SessionId');

//     const resp = await fetch(BaseURL + Config.Url, {
//       method: Config.method ? Config.method : 'GET',
//       body: Config.body ? JSON.stringify(Config.body) : null,
//       headers: {
//         ClientID: 'qN5jT7+X5LI8S0aZT7Zvz50SvSEN9BoOtF3isKoryQtkM4HizLqrXw==',
//         AuthID: UserId,
//         AuthToken: SessionId,
//         'Content-Type': 'application/json',
//       },
//     });
//     console.log("Getting here at OtpVerificationHttpGet")

//     const text = await resp.text();   // read raw text first

//     // If response is JSON, parse it, otherwise return raw string
//     try {
//       return JSON.parse(text);
//     } catch {
//       return text;
//     }
//   } catch (error) {
//     console.log("OtpVerificationHttpGet ERROR ===>", error);
//     return undefined;
//   }
// };

// To call Api
export const CallAPI = async (Url, method, body = null, headers = {}) => {
  try {
    console.log('Url ----> ', Url);
    const response = await fetch(BaseURL + Url, {
      method,
      // timeoutInterval: 10000,
      // sslPinning: {
      //   certs: ['SMS'],
      // },
      // enableSSLPinning: true,
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        ...headers,
      },
      body: method == 'POST' ? JSON.stringify(body) : null,
    })
      .then(res => res.json())
      .catch(err => {
        console.log('---err', err);
        const errorMessage =
          typeof err === 'string' || err instanceof String ? err : err.message;
        console.log('Fetch Error Response-------------');
        alert(errorMessage);
        console.log(errorMessage);
        return 'error';
      });
    console.log('Response-------------', response);
    return response;
  } catch (error) {
    console.log('error ----> ', error);
    return 'error';
  }
};
