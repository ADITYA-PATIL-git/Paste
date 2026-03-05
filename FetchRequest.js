import {Alert} from 'react-native';

export const FetchHttpRequest = async Config => {
  try {
    let Fetch = await fetch(
      // `https://sit.osourceglobal.com/UAT_API_REWARD_LOYALTY/api/${Config.Url}`, // UAT link
      `https://onexcloud.osourceglobal.com/REWARD_LOYALTY_API/api/${Config.Url}`,
      {
        method: Config.method ? Config.method : 'POST',
        body: Config.body ? JSON.stringify(Config.body) : null,

        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      },
    );
    const Data = await Fetch.json();
    // console.log('Data in FetchHttpRequest ---------------------', Data)

    if (
      Fetch?.status == '500' &&
      Config.Url == 'Login/GetUser' &&
      Data == 'MembershipType'
    ) {
      return Fetch;
    } else {
      // console.log('Fetch in FetchHttpRequest ----+++++++++++++++++++----------------- ELSEEEEEEEEEEEE',)
      return Data;
    }
    // return Data;
    // console.log('Config in FetchHttpRequest ---------=====================------------', Config)
  } catch (error) {
    console.log(
      'catch Error in Fetch SSSSSSSSSSSSSSSSSS ---------------------',
      error,
    );
    Alert.alert('Error', error?.message ?? 'Network request failed'); //------- Added by vinit 15/09/2025 --->

    return null;
  }
};
export const FetchHttpRequestMeeting = async Config => {
  try {
    let Fetch = await fetch(
      `https://sit.osourceglobal.com/UAT_PENTHOUSE_API/api/${Config.Url}`,
      {
        method: Config.method || 'POST',
      },
    )
      .then(resp => resp?.json())
      .catch(error => {
        console.log('Error ------- --- ------- ----', error);
      });
    console.log('Config  :----', Config);
    return Fetch;
  } catch (error) {
    console.log('catch Error in Fetch ---------------------', error);
    if (error.toLowerCase().include('network request failed')) {
      console.log('Network Problem');
    }
  }
};

export const FetchHttpRequestMeetingPost = async Config => {
  try {
    const isFormData = Config.body instanceof FormData;

    const response = await fetch(
      `https://sit.osourceglobal.com/UAT_PENTHOUSE_API/api/${Config.Url}`,
      {
        method: Config.method || 'POST',
        headers: isFormData ? undefined : Config.headers || {},
        body: Config.body || null,
      },
    );

    const result = await response.json();

    console.log('Fetch Config:', Config);
    console.log('Fetch Response:', result);

    return result;
  } catch (error) {
    console.log('Catch Error in Fetch:', error);
    throw error;
  }
};

export const FetchHttpRequestAI = async Config => {
  try {
    let Fetch = await fetch(
      //   `https://uat-api.osourceglobal.com/INT_UAT_HOTEL_INVOICE_PARSER/${Config.Url}`, // UAT Link
      `https://api.osourceglobal.com/Hotel_Invoice_Parser/${Config.Url}`,
      {
        method: Config.method ? Config.method : 'POST',
        body: Config.body ? JSON.stringify(Config.body) : null,

        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      },
    )
      .then(resp => resp?.json())
      .catch(error => {
        console.log('Error ---------------------', error);
      });
    console.log(
      'Config  :----',
      Config,
      // "\nResponce :---", Fetch
    );
    return Fetch;
  } catch (error) {
    console.log('catch Error in Fetch ---------------------', error);
  }
};
