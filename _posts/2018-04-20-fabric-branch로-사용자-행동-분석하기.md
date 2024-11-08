---
layout: "post"
title: "Fabric Branch로 사용자 행동 분석하기"
author: "rfrost"
date: "2018-04-20"

---

# Fabric Branch 사용 배경

대부분의 회사는 마케팅을 합니다. 그리고 서비스를 운영하는 회사는 퍼포먼스 마케팅을 합니다.

![]{{ site.baseurl }}/images/Sb2hKh39o0.jpeg)

### 퍼포먼스 마케팅이란?

홍보뿐만 아니라 원하는 행동을 유도하는 마케팅 입니다. 퍼포먼스 마케팅에서 중요한 것은 캠페인을 통해 원하는 행동을 얼마나 잘 유도하였나 측정하는 것입니다. 측정을 어떤식으로 하는지, 마케팅 채널 별 신규유입을 측정 하는 것으로 예시를 들어보겠습니다.

(1) 마케팅으로 사용할 스토어 링크에 레퍼러를 삽입합니다.

<caption id="" align="aligncenter" width="1600">![]{{ site.baseurl }}/images/qcgAUMeBG5.png) 스토어 링크에 utm 속성을 붙입니다.</caption>

(2) 레퍼러가 삽입된 링크를 통해 스토어에 들어오면 콘솔에 레퍼러 속성이 기록됩니다.

(3) 기록된 레퍼러를 필터로 구분하여 마케팅 채널 별 신규유입을 측정할 수 있습니다.

<caption id="" align="aligncenter" width="1600">![]({{ site.baseurl }}/images/seZJcFhiTc.png) 콘솔에서 레퍼러로 구분된 숫자들을 확인할 수 있습니다.</caption>

### 하지만…

하지만 우리는 단순 다운로드를 넘어 가입, 결제 등의 행동까지 유도하고, 앱 내에서 행동을 수행한 숫자를 알고 싶습니다. 하지만 이것은 위 스토어 레퍼러로는 불가능합니다. 레퍼러 값이 스토어까지는 유지되지만 앱을 다운로드 받고 진입한 후에는 사라지기 때문입니다. 행동을 측정하기 위해서는 레퍼러 구분값이 앱에 들어와서도 유지되어야 합니다. 이것은 어떻게 구현할까요?

<caption id="" align="aligncenter" width="350">![]{{ site.baseurl }}/images/fXec1sTFM9.png) 우리는 앱에 들어온 후에도 특정 행동을 유도하고, Step에 따라 측정하고 싶습니다.</caption>

### Deeplink로 앱 진입을 유도하자

행동을 유도하기 위해서는 스토어로만 보내는 링크보다는 Deeplink가 필요합니다. Deeplink는 앱이 설치되어 있다면 앱을, 없다면 Failover가 동작하는 링크입니다. Failover는 보통 스토어를 열어줍니다. Deeplink로 자연스럽게 행동을 위한 앱 진입을 유도할 수 있습니다. 하지만 Deeplink 또한 레퍼러 값이 앱에 진입하면 소실됩니다.

![]({{ site.baseurl }}/images/iEQofyJMjq.png)

### Deferred Deeplink로 레퍼러를 유지하자

Deferred Deeplink는 기본적으로 Deeplink와 똑같이 동작하지만 링크 속성이 앱에 들어와서도 유지됩니다. 어떤 마케팅 캠페인으로부터 왔는지 구분할 수 있기 때문에 행동을 직접 유도하고, 실제로 도달하였는지 측정할 수 있습니다.

<caption id="" align="aligncenter" width="864">![]{{ site.baseurl }}/images/0pAM8YcbOh.jpeg) Deeplink는 단순히 앱에 진입시키지만, Deferred Deeplink는 유지되는 레퍼러 값을 이용하여 행동을 유도할 수 있습니다.</caption>

### Deferred Deeplink를 어떻게 구현하지?

Deferred Deeplink를 이용하면 우리가 원하는 행동 유도 및 분석이 가능함을 알아보았습니다. 그렇다면 Deferred Deeplink는 어떻게 구현할까요? Firebase DynamicLink 등 다양한 라이브러리가 있지만 저는 Fabric의 Branch를 소개하려고 합니다. (이 시점에는 Fabric이 Twitter 소속이였는데 지금은 Firebase와 같은 Google 소속이네요!)

![]({{ site.baseurl }}/images/iZccMvPSAX.png)

# Branch 사용하기

Branch는 대시보드에서 대부분의 작업을 할 수 있습니다. 대시보드를 활용하여 Branch를 사용하는 것을 하나씩 살펴보겠습니다.

### (1) 대시보드 메인화면

대시보드에서 링크 생성, 설정 그리고 분석까지 모두 할 수 있습니다. 메인화면에 각 기능으로 이어지는 메뉴들이 있습니다.

<caption id="" align="aligncenter" width="1600">![]{{ site.baseurl }}/images/jT15vgQrkY.png) Create Link, Link Settings, Sources 등의 메뉴에서 생성, 설정, 분석을 할 수 있습니다.</caption>

### (2) 링크 생성

Create Link 기능으로 링크를 생성할 때 Deeplink Path, Failover link, Custom Tag, OG title 등의 설정을 함께 할 수 있습니다.

<caption id="" align="aligncenter" width="1600">![]{{ site.baseurl }}/images/p9psvMmQ8O.png) 링크를 생성 할 때 기본적인 설정을 함께 할 수 있습니다.</caption>

### (3) 링크 설정

Link Settings 메뉴에서 생성할 링크의 기본 설정을 정의할 수 있습니다.

<caption id="" align="aligncenter" width="1600">![]({{ site.baseurl }}/images/mLwjaMcbQn.png) Deeplink Path의 Scheme, Failover URL 등을 정의할 수 있습니다.</caption>

### (4) 데이터 분석

Sources 메뉴에서 사용자들이 Deeplink를 이용한 데이터를 분석할 수 있습니다. 링크를 생성할 때 설정한 Custom Tag까지 측정이 가능합니다. 여기서 Custom Tag는 우리가 유도하려는 행동을 의미할 것입니다. 아래 그림에서는 SIGNUP 이라는 Tag가 있습니다.

<caption id="" align="aligncenter" width="1600">![]({{ site.baseurl }}/images/EDLiRTdRTf.png) 단계별 수치 및 Custom Tag가 불린 수치까지 한눈에 볼 수 있습니다. 필터 또한 제공됩니다.</caption>

하지만 Deeplink는 어떤 행동이 일어났는지를 스스로 알 수 없습니다. Custom Tag 수치를 측정하기 위해서는 앱에서 넘어온 링크 데이터로 시점을 판단하고, 적절한 시점에서 행동이 일어났을 때 Custom Tag에 해당하는 이밴트를 호출해주어야 합니다. 그러면 먼저 시점을 판단하기 위한 Deferred Link 데이터를 받는 방법을 알아보겠습니다.

# Deferred Link에서 데이터 받아오기

Branch SDK를 이용해 Intent로 넘어오는 Deferred Link 데이터를 Json 형태로 넘겨받습니다. initSession() 메소드에 콜백을 등록해 받을 수 있습니다.

```
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        // Intent로 넘어오는 Deferred Deeplink를 받기위해 호출합니다.
        setIntent(intent);
    }
    @Override
    protected void onStart() {
        super.onStart();
        // onNewIntent()가 호출된 후 Branch Session을 초기화 합니다.
        initializeBranch();
    }
}

private void initializeBranch() {
    Branch branch = Branch.getInstance(this);
    branch.initSession(new Branch.BranchReferralInitListener() {
        @Override
        public void onInitFinished(JSONObject referringParams, BranchError error) {
            if (error != null) return;
            // Parse and Deep Link Parameters from referringParams
        }
    });
}
```

Json 형태로 넘어오는 Deferred Deeplink 데이터를 파싱하면 앱 세션이 어디에서 왔는지를 구분할 수 있습니다. 이제 이밴트를 보내야 합니다.

```
Branch branch = Branch.getInstance(this);
branch.userCompletedAction("sign_up");
```

userCompletedAction()를 Tag와 함께 호출하면 이밴트를 보낼 수 있습니다. 성공적으로 userCompletedAction()가 호출되면 대시보드에서 Tag에 해당하는 수치가 올라갑니다.

### (부록) 앱에서 Deferred Link 만들기

추천하기 등의 기능은 앱에서 마케팅 링크를 생성해 공유할 수 있어야 합니다. Branch는 앱에서도 Deferred Link를 만들 수 있도록 SDK를 제공합니다.

```
public void createDeferredDeepLinkWithBranch() {
    BranchUniversalObject branchUniversalObject = new BranchUniversalObject();
    LinkProperties linkProperties = new LinkProperties();

    // 링크 속성 설정
    linkProperties.setChannel("facebook");
    linkProperties.setFeature("invite");
    linkProperties.setCampaign("teambook");
    linkProperties.addTag("inapp");

    linkProperties.addControlParameter("$og_title", "리멤버 팀 명함첩에 초대합니다.");
    linkProperties.addControlParameter("$og_description", "어서오세요.");

    // 링크 생성
    branchUniversalObject.generateShortUrl(this, linkProperties, new BranchLinkCreateListener() {
        @Override
        public void onLinkCreate(String url, BranchError error) {
            if (error != null) return;
            // Share url to marketing channel
        }
    });
}
```

LinkProperties 객체에 속성을 설정하고, generateShortUrl() 메소드로 대시보드에서 만드는 것과 같은 Deferred Deeplink를 생성할 수 있습니다. 만들어진 링크의 활용, 분석은 위에서 설명한 것과 같습니다.

# Branch Deferred Deeplink 활용 Flow

지금까지 설명드린 링크 생성, 활용, 분석은 다음 그림 하나로 요약할 수 있습니다.

<caption id="" align="aligncenter" width="1600">![]{{ site.baseurl }}/images/wI7LQ9jxyu.png) 단계별 도달율이 대시보드에 모두 기록됩니다.</caption>

# 마무리

저는 다음과 같은 순서로 Branch를 성공적으로 도입하였습니다.

(1) 측정하고 싶은 데이터 결정 — 마케팅 채널 별로 가입자 수를 알고 싶다.

(2) 측정 방법 조사 — Deferred Deeplink가 필요하다.

(3) 측정 수단 결정, 적용 및 분석 — Fabric Branch 적용

Branch 자체를 이해하는 것도 좋지만, 더 중요한 것은 데이터의 중요성을 이해하고 적설한 수단을 찾아 적용하려는 마음가짐이라고 생각합니다. Branch 보다 좋은 방법도 분명히 많이 있을 것입니다. 각자 상황에 맞는 수단을 찾아 원하는 데이터를 반드시 측정하며 좋은 서비스를 만들어가시기를 바랍니다.

> 이 글은 미디엄에 쓴 포스팅을 옮겨왔습니다. [http://bit.ly/2usHPvs](http://bit.ly/2HMW4hE)
