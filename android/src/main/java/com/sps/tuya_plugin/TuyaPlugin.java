package com.sps.tuya_plugin;

import androidx.annotation.NonNull;

import android.app.Application;
import android.os.Handler;
import android.os.Message;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.alibaba.fastjson.JSON;
import com.tuya.smart.android.user.api.ILoginCallback;
import com.tuya.smart.android.user.bean.User;
import com.tuya.smart.sdk.api.ITuyaActivatorGetToken;
import com.tuya.smart.home.sdk.TuyaHomeSdk;
import com.tuya.smart.home.sdk.builder.ActivatorBuilder;
import com.tuya.smart.sdk.api.ITuyaActivator;
import com.tuya.smart.sdk.api.ITuyaSmartActivatorListener;
import com.tuya.smart.sdk.bean.DeviceBean;
import com.tuya.smart.sdk.enums.ActivatorAPStepCode;
import com.tuya.smart.sdk.enums.ActivatorEZStepCode;
import com.tuya.smart.sdk.enums.ActivatorModelEnum;

import static com.tuya.smart.sdk.enums.ActivatorModelEnum.TY_AP;
import static com.tuya.smart.sdk.enums.ActivatorModelEnum.TY_EZ;

/** TuyaPlugin */
public class TuyaPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  public static final String STATUS_FAILURE_WITH_NETWORK_ERROR = "1001";
  public static final String STATUS_FAILURE_WITH_BIND_GWIDS = "1002";
  public static final String STATUS_FAILURE_WITH_BIND_GWIDS_1 = "1003";
  public static final String STATUS_FAILURE_WITH_GET_TOKEN = "1004";
  public static final String STATUS_FAILURE_WITH_CHECK_ONLINE_FAILURE = "1005";
  public static final String STATUS_FAILURE_WITH_OUT_OF_TIME = "1006";
  public static final String STATUS_DEV_CONFIG_ERROR_LIST = "1007";
  public static final int WHAT_EC_ACTIVE_ERROR = 0x02;
  public static final int WHAT_EC_ACTIVE_SUCCESS = 0x03;
  public static final int WHAT_AP_ACTIVE_ERROR = 0x04;
  public static final int WHAT_AP_ACTIVE_SUCCESS = 0x05;
  public static final int WHAT_EC_GET_TOKEN_ERROR = 0x06;
  public static final int WHAT_DEVICE_FIND = 0x07;
  public static final int WHAT_BIND_DEVICE_SUCCESS = 0x08;
  private static final long CONFIG_TIME_OUT = 100;

  private ITuyaActivator mTuyaActivator;
  private ActivatorModelEnum mModelEnum;
  private MethodChannel channel;

  static int ERROR_CODE_TYPE_ERROR = -100; // 数据类型类型错误
  static int ERROR_CODE_NOT_LOGIN = -101; // 还未登录
  static int ERROR_CODE_PARAMS_ERROR = -502; // 参数错误
  static int SUCCESS_CODE = 200; // 执行成功

  protected android.content.Context mContext;
  private MethodChannel.Result result;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.mContext = flutterPluginBinding.getApplicationContext();
    TuyaHomeSdk.setDebugMode(true);
    TuyaHomeSdk.init((Application) flutterPluginBinding.getApplicationContext(),"e597q33jgr4tnm3fgj83","gdau9an95apxug4hc8xm53aftnugr3g5");
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuya_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    this.result = result;

    switch (call.method) {
      case "set_ec_net":
        this.setEC(call.argument("ssid").toString(), call.argument("password").toString(),call.argument("token").toString());
        break;
      case "set_ap_net":
        this.setAP(call.argument("ssid").toString(), call.argument("password").toString(),call.argument("token").toString());
        break;
      case "uid_login":
        this.uidLogin(call.argument("countryCode").toString(), call.argument("uid").toString(),call.argument("passwd").toString());
        break;
      case "destroy":
        System.out.println("销毁涂鸦插件实例");
        TuyaHomeSdk.onDestroy();
        break;
      case "stopAP":
        this.stopAP();
      default:
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // 快连（EZ）模式
  public void setEC(String ssid, String password, String token) {
    System.out.println("开始快连（EZ）模式配网");
    mModelEnum = TY_EZ;
    ITuyaActivator ECActivator =  TuyaHomeSdk.getActivatorInstance().newMultiActivator(new ActivatorBuilder()
            .setSsid(ssid)
            .setContext(mContext)
            .setPassword(password)
            .setActivatorModel(TY_EZ)
            .setTimeOut(CONFIG_TIME_OUT)
            .setToken(token).setListener(new ITuyaSmartActivatorListener() {
              @Override
              public void onError(String s, String s1) {
                System.out.println("快连（EZ）模式配网失败");
                callResult(ERROR_CODE_PARAMS_ERROR, "快连（EZ）模式配网失败");
              }

              @Override
              public void onActiveSuccess(DeviceBean deviceBean) {
                System.out.println("快连（EZ）模式配网成功");
                callResult(SUCCESS_CODE, "快连（EZ）模式配网成功");
              }

              @Override
              public void onStep(String s, Object o) {
                System.out.println("-----------配网Step--------");
              }
            })
    );
    ECActivator.start();
  }

  // 热点（AP）模式
  public void setAP(String ssid, String password, String token) {
    System.out.println("开始快连（AP）模式配网");
    mModelEnum = TY_AP;
    mTuyaActivator = TuyaHomeSdk.getActivatorInstance().newActivator(new ActivatorBuilder()
            .setSsid(ssid)
            .setContext(mContext)
            .setPassword(password)
            .setActivatorModel(TY_AP)
            .setTimeOut(CONFIG_TIME_OUT)
            .setToken(token).setListener(new ITuyaSmartActivatorListener() {
              @Override
              public void onError(String error, String s1) {
                //                resultError(WHAT_AP_ACTIVE_ERROR, error, s1);
                System.out.println("AP配网失败");
                System.out.println(error);
                callResult(WHAT_AP_ACTIVE_ERROR, error);
              }

              @Override
              public void onActiveSuccess(DeviceBean gwDevResp) {
                //                resultSuccess(WHAT_AP_ACTIVE_SUCCESS, gwDevResp);
                System.out.println("AP配网成功");
                callResult(WHAT_AP_ACTIVE_SUCCESS, gwDevResp.getDevId());
              }

              @Override
              public void onStep(String step, Object o) {
                switch (step) {
                  case ActivatorAPStepCode.DEVICE_BIND_SUCCESS:
                    //                    resultSuccess(WHAT_BIND_DEVICE_SUCCESS, o);
                    System.out.println("AP配网设备绑定成功");
                    callResult(WHAT_AP_ACTIVE_SUCCESS,"WHAT_BIND_DEVICE_SUCCESS");
                    break;
                  case ActivatorAPStepCode.DEVICE_FIND:
                    //                    resultSuccess(WHAT_DEVICE_FIND, o);
                    System.out.println("AP配网发现设备");
                    callResult(WHAT_DEVICE_FIND,"WHAT_DEVICE_FIND");

                    break;
                }
              }
            }));

    mTuyaActivator.start();

  }

  // 停止（AP）模式配网
  public void stopAP() {
    System.out.println("停止AP配网");
    try {
      mTuyaActivator.stop();
    }
    catch (Exception e) {

    }

  }

  //uid登陆
  public void uidLogin(String countryCode, String uid, String passwd) {
    System.out.println("开始uidLogin");
    TuyaHomeSdk.getUserInstance().loginOrRegisterWithUid(countryCode,uid,passwd, new ILoginCallback() {
      @Override
      public void onSuccess(User user) {
        System.out.println("登陆成功"+JSON.toJSONString(user));
        callResult(200, JSON.toJSONString(user));
      }

      @Override
      public void onError(String code, String error) {
        System.out.println("登陆错误，错误code " + code +"error"+error);
        callResult(400, error);
      }
    });
  }
  ////////////////////辅助方法//////////////////
  /*
   * 传递消息给Flutter层
   * */
  public void callResult(int code, String msg) {
    try {
      HashMap<String, String> map = new HashMap<>();
      map.put("code", String.format("%d", code));
      map.put("msg", msg);

      Message message = Message.obtain();
      message.obj = map;
      result.success(map);
    }
    catch (Exception e) {

    }
  }

  /*
   * 传递带data的消息给Flutter层
   * */
  public void callResult(int code, String msg, String data) {
    HashMap<String, String> map = new HashMap<>();
    map.put("code", String.format("%d", code));
    map.put("msg", msg);
    map.put("data", data);

    Message message = Message.obtain();
    message.obj = map;
    result.success(map);
  }
}
