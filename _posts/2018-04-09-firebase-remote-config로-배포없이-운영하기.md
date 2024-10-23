---
layout: "post"
title: "Firebase Remote Config로 배포없이 운영하기"
author: "rfrost"
date: "2018-04-09"
categories: 
  - "develop"
---

라이브로 운영하는 서비스는 항상 운영이슈가 존재합니다. 운영이슈는 사용자의 요구를 최대한 실시간으로 대응하여 불편함을 줄이고 만족도를 높이는 것을 의미합니다. 예를 들어 CS, 공지사항 부터 장애 모니터링 및 대응, 피드백 수집 후 개선까지도 모두 운영이슈로 볼 수 있습니다. 이 때 운영팀에서 가장 중요하게 생각하는 것은 실시간 입니다. 운영팀은 공지사항, 장애 등 이슈가 있을 때 원하는 시간에 바로바로 대응할 수 있는 시스템을 원합니다.

하지만 앱은 개발, 리뷰, 테스트, 스토어 업로드 등 여러 과정을 거쳐야 하므로 변경사항을 바로 반영하기가 힘듭니다. 이는 운영팀이 원하는 실시간과 거리가 멉니다. 운영팀이 원하는 것은 다음과 같습니다.

1. 개발자를 통하지 않고 스스로 변경 가능하다.
2. 코드를 손대지 않고 안전하게 변경한다.
3. 배포하지 않고 변경사항을 적용한다.
4. 원하는 사용자에게만 변경사항을 적용한다.

어떻게 운영팀이 원하는 이것을 이룰 수 있을까요?

\[caption id="" align="aligncenter" width="1600"\]![](https://cdn-images-1.medium.com/max/1600/1*tadpqGa9KjLphMZYo6WgRA.jpeg) 해답은... 리모트 컨피그\[/caption\]

리모트 컨피그는 사용자가 앱 업데이트를 통하지 않고 동작을 변경할 수 있는 실시간 클라우드 서비스 입니다. 사용 시나리오는 다음과 같습니다.

1. Firebase에 앱의 동작을 제어하는 값을 정의한다.
2. 앱에서 Firebase에 정의된 값을 가져와 적용한다.
3. 배포 없이 업데이트 된 새로운 동작을 확인하다.

2,3번의 작업을 미리 앱에 배포해 놓으면, 운영팀에서 1번의 작업을 통해 배포 없이 자동으로 앱 업데이트가 가능합니다. 그러면 이제 사용법을 익혀봅시다.

### 1\. Firebase, 리모트 컨피그 설치하기

Gradle에 의존성을 정의하고, Firebase Console에서 google-services.json을 받아와 app module에 추가합니다.

```
dependencies {
    classpath 'com.google.gms:google-services:3.0.0'
}
```

```
dependencies {
    compile 'com.google.firebase:firebase-core:10.2.0'
    compile 'com.google.firebase:firebase-config:10.2.0'
}

// Add this at the bottom of build.gradle in app module
apply plugin: 'com.google.gms.google-services'
```

\[caption id="" align="aligncenter" width="1600"\]![](https://cdn-images-1.medium.com/max/1600/1*HwLZ93J-UwQSFGclrLbQkA.png) google-services.json을 다운로드 후 app module에 위치\[/caption\]

### 2\. 구글 플레이 서비스 설치 체크

리모트 컨피그는 구글 플레이 서비스가 기기에 설치되어 있어야 사용 가능합니다. 앱을 시작할 때 구글 플레이 서비스 설치 여부를 확인하고, 안되어있다면 사용자에게 설치를 유도할 수 있도록 에러 팝업을 띄어줍니다.

```
private void checkGooglePlayServices() {
    GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
    int status = googleApiAvailability.isGooglePlayServicesAvailable(context);

    if (status != ConnectionResult.SUCCESS) {
        Dialog dialog = googleApiAvailability.getErrorDialog(activity, status, -1);
        dialog.setOnDismissListener(dialogInterface -> finish());
        dialog.show();

        googleApiAvailability.showErrorNotification(context, status);
    }
}
```

 

### 3\. 어드민에 값 추가하기

이제 운영팀이 자유롭게 변경하고 싶은 값을 정의해봅시다. 값 정의는 Fireabse 콘솔에 있는 리모트 컨피그 어드민에서 가능합니다.

<figure>

\[caption id="" align="aligncenter" width="1600"\]![](https://cdn-images-1.medium.com/max/1600/1*Sc1x-W2LSitCNELLgqvqhQ.png) 리모트 컨피그 어드민에서 매개변수를 key, value 형태로 추가할 수 있습니다.\[/caption\]

<figcaption>



\[caption id="" align="aligncenter" width="1600"\]![](https://cdn-images-1.medium.com/max/1600/1*eujrvHoc_GAhs4BFdi3J6g.png) 추가된 값들은 다음과 같이 보여집니다.\[/caption\]



</figcaption>



</figure>

### 4\. 리모트 컨피그 초기화하기

어드민에서 정의한 값들을 받아오기 위해 리모트 컨피그 객체를 초기화 합니다.

```
public static void initialize() {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance();
    FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings.Builder()
            // Debug일 때 Developer Mode를 enable 하여 캐쉬 설정을 변경한다.
            .setDeveloperModeEnabled(BuildConfig.DEBUG)
            .build();

    remoteConfig.setConfigSettings(configSettings);
    // 로컬 기본값을 저장한 xml을 설정한다.
    remoteConfig.setDefaults(R.xml.remote_config_defaults);

    // 기본 캐쉬 만료시간은 12시간이다. Developer Mode 여부에 따라 fetch()에 적설한 캐시 만료시간을 넘긴다.
    remoteConfig.fetch(0).addOnCompleteListener(task -> {
        if (task.isSuccessful()) remoteConfig.activateFetched();
    });
}
```

setDefaults()로 설정한 remote\_config\_defaults.xml 에서는 어드민에서 값을 못받아올 경우 사용할 로컬 기본값들을 정의합니다.

```
<?xml version="1.0" encoding="utf-8"?>
<defaultsMap>
<entry>
    <key>example_key</key>
    <value>example local default value</value>
</entry>
<entry>
    <key>condition_example_key</key>
    <value>condition example local default value</value>
</entry>
</defaultsMap>
```

 

### 5\. 어드민에서 값 가져오기

리모트 컨피그 객체의 getString() 메소드를 활용하여 넘겨준 key의 value를 가져옵니다.

```
public static String getConfigValue(String key) {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance();
    return remoteConfig.getString(key);
}
```

### 리멤버에서의 활용 예시

현재 리멤버에서는 다음과 같은 시나리오에서 리모트 컨피그를 활용하고 있습니다.

#### 1\. 메인 공지사항 팝업 이미지 및 액션

![](https://cdn-images-1.medium.com/max/1600/1*4Nke7QJjcHtVrY00oAhbVw.png)

#### 2\. Drawer 추천유도 텍스트

![](https://cdn-images-1.medium.com/max/1600/1*51OLlpcxdoQJPc_onVu6gQ.png)

#### 3\. 촬영 후 추천유도 텍스트, 이미지 및 액션

![](https://cdn-images-1.medium.com/max/1600/1*woMr0GB9XjTCdekR66V3lQ.png)

#### 4\. FAB 가이드 이미지 및 액션

![](https://cdn-images-1.medium.com/max/1600/1*AUIopIeFfevdP0Px7YrpFw.png)

#### 5\. 대기명함 가이드 텍스트

![](https://cdn-images-1.medium.com/max/1200/1*MF3mZlOk0oOnyPjK6RWfYw.png)

![](https://cdn-images-1.medium.com/max/1200/1*zeFioOHYR16x_LutWWkWqQ.png)

### 리모트 컨피그의 장점

#### 1\. 실시간 운영변수 변경 시스템 구축이 쉽다.

보통 라이브로 운영하는 서비스는 이러한 실시간 운영변수 변경 시스템을 직접 구축하여 사용합니다. 리멤버 또한 리모트 컨피그를 사용하기 전까지는 자체 시스템이 있었습니다. 하지만 직접 구현하는 것은 많은 리소스가 필요합니다. 리모트 컨피그를 사용하면 이런 시스템을 쉽게 갖출 수 있습니다.

#### 2\. 값을 단순히 변경하는 것 뿐만 아니라 대상을 선택하여 배포할 수 있다.

사용자 또는 기기 속성에 따라 값을 분기하여 배포하는 것은 유용한 기능이지만 개발하려면 손이 많이 가는 일입니다. 리모트 컨피그를 사용하면 쉽게 대상을 선택하여 배포할 수 있습니다.

### 마무리

리모트 컨피그는 라이브 서비스에게 매우 중요한 기능을 쉽고 빠르게 적용할 수 있도록 돕습니다. 저는 Firebase에서 가장 가성비가 좋은 기능이 리모트 컨피그가 아닌가 생각합니다. 이제 리모트 컨피그로 운영팀의 걱정을 덜어주세요.

> \- 이 글에 첨부된 코드는 [https://github.com/rfrost77/DroidKnights-RemoteConfig](https://github.com/rfrost77/DroidKnights-RemoteConfig) 에 있습니다.

> \- 이 글은 미디엄에 쓴 포스팅을 옮겨왔습니다. [http://bit.ly/2usHPvs](http://bit.ly/2usHPvs)
