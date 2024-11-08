---
layout: "post"
title: "리멤버는 서비스 모니터링을 어떻게 하고 있을까?"
author: "hb.lee"
date: "2022-06-21"
categories: 
  - "develop"
tags: 
  - "aws"
  - "rails"
  - "ruby"
  - "ruby-on-rails"
  - "리멤버"
---

안녕하세요? 리멤버를 서비스하고 있는 드라마앤컴퍼니의 플랫폼 서버 파트 테크리드 이한별 ⭐ 입니다. 😂

리멤버는 명함 관리부터 시작하여 인재 검색(다이렉트 소싱), 채용 공고, 헤드헌팅을 비롯한 채용 사업 뿐 아니라 주요 경제 소식을 매일 큐레이션 및 정리해주는 리멤버 나우, 회원들끼리 직장 관련 고민을 털어놓고 해결하기 위한 리멤버 커뮤니티, 전국의 일하는 사람들에게 설문 조사를 가능하게 한 리멤버 서베이 등 다양한 서비스를 하고 있습니다.

다양한 서비스를 하고 있고, 대규모 트래픽을 안정적으로 잘 처리할 수 있으려면 개발자로서 신경써야할 것들이 상당히 많은데요.

이번에는 그 중에서 모니터링에 초점을 맞춰, 리멤버는 서비스 모니터링을 어떻게 하고 있는지에 대해서 소개하려고 합니다.

#### 리멤버에서 사용하는 모니터링 도구 : AWS CloudWatch 와 New Relic

저희 리멤버 서비스는 대부분 AWS 위에 구축해놓은 infrastructure 를 기반으로 운영되고 있습니다.

따라서 AWS CloudWatch 를 적극적으로 활용하여 적절한 지표 및 Alarm/Alert 를 설정하는 것이 중요합니다.

또한, AWS CloudWatch 만으로는 서비스에서 발생하는 모든 이벤트들에 대해 파악하기가 쉽지 않기 때문에, APM 등을 도입하여 모니터링하는 것도 중요합니다.

이를 위해 리멤버에서는 모니터링 플랫폼으로써 New Relic 을 오래전부터 사용해오고 있었습니다.

https://blog.dramancompany.com/2015/12/%ec%95%88%ec%a0%95%ec%a0%81%ec%9d%b8-%ec%84%9c%eb%b9%84%ec%8a%a4-%ec%9a%b4%ec%98%81%ec%9d%84-%ec%9c%84%ed%95%9c-%ec%84%9c%eb%b2%84-%eb%aa%a8%eb%8b%88%ed%84%b0%eb%a7%81-1/

#### 리멤버에서 모니터링하는 것들

##### Application Performance

New Relic 을 이용하여 서버의 처리량(throughput), 평균 응답 시간, 오류 발생율(Error rate), Slow transactions 가 있는지, Host 의 CPU/Memory 사용율 등을 주로 확인합니다. Error rate 가 0% 초과라면 어떤 Error 가 발생했는지, 해당 Error 가 발생했던 thread 의 stack trace 도 확인하며, 관련 logs 도 조회하면서 어떤 문제가 있는지 진단합니다.

<figure>

[![]{{ site.baseurl }}/images/VtPVIhpj3G.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image.png)

<figcaption>

Application Performance Monitoring

</figcaption>

</figure>

##### Infrastructure Metrics

서비스를 위한 프로세스가 실행중인 서버(EC2, ECS 등)는 하나의 애플리케이션 서버만을 실행하긴 하지만, 애플리케이션 서버 프로세스가 아닌 다른 요인으로 서버에 문제가 발생할 수도 있습니다. 애플리케이션의 트래픽은 낮은데 IO가 높을 수도 있고, Disk Usage 가 100% 가 돼 서비스 불능 상태에 이를 수 있는 등 APM 뿐 아니라 Infrastructure 관점에서의 여러 metrics 도 봐야합니다. 리멤버에서는 이 또한 주로 New Relic 을 활용하여 모니터링하고 있습니다.

여기서 Load average, CPU 사용율을 중심으로 어떤 서버에 부하가 쏠리는지, 어떤 프로세스가 문제가 되고 있는지 등을 파악할 수 있습니다.

여러 지표를 확인 후 문제가 발견됐다면 조치를 취하고 앞으로는 동일한 문제가 발생하지 않도록 하기 위해 취한 조치를 자동화하고 있습니다. 개발자들이 알게 모르게 시간을 많이 쏟고 있는 반복 작업들([Toil](https://sre.google/sre-book/eliminating-toil/)) 들을 자동화하기 위해 꼭 필요한 지표들입니다.

<figure>

[![]{{ site.baseurl }}/images/FkatkB5oKL.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-1.png)

<figcaption>

Infrastructure Metrics - System

</figcaption>

</figure>

<figure>

[![]({{ site.baseurl }}/images/OHTUUKaiHF.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-2.png)

<figcaption>

Infrastructure Metrics - Storage

</figcaption>

</figure>

##### SLI/SLO

서비스에 문제가 있는지 없는지 현황을 한 눈에 파악하기위해서 적절한 SLI 와 SLO 를 설정하고, 이를 모니터링하는 것이 가장 기본적인 방법입니다.

<figure>

[![]({{ site.baseurl }}/images/nchGEUPkiY.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-5.png)

<figcaption>

Service Levels

</figcaption>

</figure>

리멤버는 아직 별도의 SRE 또는 DevOps 포지션이 없는 형태의 조직 구조이기 때문에, 이 SLI/SLO 를 설정하고 모니터링하기 시작한 건 얼마 되지 않았습니다.

이 글을 쓰는 시점 기준 아직 SLI/SLO 설정을 하지 못한 서비스들도 있습니다. 점진적으로 하나씩 하나씩 저희 서비스의 상태를 가장 빠르게 확인할 수 있도록 필요한 SLI/SLO 를 추가하고 있습니다. 혹시, 독자분들 중에서 이에 대해 관심을 가지신 분이 계시다면, 리멤버에 합류하셔서 함께 만들어 나가보는 것은 어떨까요? 🤣

SLI/SLO 설정을 하고 이를 볼 수 있는 페이지를 만드는 것도 자체적으로 할 수도 있고, 3rd party saas 등을 이용할 수도 있는데, 저희는 이미 사용하고 있는 New Relic 에서 제공해주고 있는 Service Levels 기능을 통해 최소한의 리소스 투입으로 만들어가고 있습니다.

##### 특정 서비스의 health 를 나타내는 지표

애플리케이션의 도메인 특성상 관리해야하는 지표가 있을 수 있습니다. 예를 들어, 리멤버에 있는 명함을 구글 연락처로 동기화하는 기능을 제공하고 있습니다. 사용자의 행태에 따라 동기화해야할 명함 수가 급격하게 늘어나는 때가 종종 생기는데, 그런 경우 개발자들이 인지하고 적절한 조치를 취하거나 개선할 수 있도록 CloudWatch 에 custom metric 을 전송하고, Alarm 을 만들어 관찰하고 있습니다.

<figure>

[![]{{ site.baseurl }}/images/Mh6xBrxdtU.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-3.png)

<figcaption>

CloudWatch 의 custom metric 및 이에 대한 alarm

</figcaption>

</figure>

물론, 이렇게 설정해놓은 Alarm 이 자주 발생하거나 어떻게 조치를 취해야하는지에 대해 명확하게 알고 있다면, 아래의 스크린샷과 같이 자동화하여 더 이상 중요하지 않은 이유로 Alarm 이 오지 않도록 개선하는 것도 중요합니다.

<figure>

[![]({{ site.baseurl }}/images/jMRJjjsNUR.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-4.png)

<figcaption>

Alarm 을 확인 하고 더 이상 같은 Alarm 이 오지 않도록 개선 및 자동화 예시

</figcaption>

</figure>

이러한 것들 외에도 Distributed traces, Service Map 등 다양한 관점에서 저희 서비스가 안정적으로 운영이 되고 있는지, 새로운 병목 구간이 생기지는 않았는지 등을 끊임없이 모니터링하고 있습니다. :D

다음으로는 이렇게 갖춰놓은 모니터링 시스템을 활용한 예시 몇가지를 소개드리겠습니다.

#### 모니터링 시스템 활용 사례

##### 리멤버에서 이상 징후를 발견하는 방법

주로 문제가 생겼을 때 Slack 의 특정 채널(장애 알림 전용 채널)에 메시지가 게시되는 것으로부터 가장 빠르게 인지를 합니다. Slack 에 장애가 발생하면 리멤버 서비스에 발생하는 장애를 인지하기 어려워지기 때문에 극소수이긴 하지만 일부 구성원들, 일부 지표에 한해서는 이메일로도 받도록 돼있는 부분도 있습니다.

Slack 으로 인지하게 되는 것과 별개로 위 문단에 적어놓은 것과 같이 모니터링을 하다가 발견하는 경우도 있습니다. 모니터링 중 특별히 튀는 지표가 눈에 띄면 Alert 와 무관하게 원인 파악을 하며 문제인지 아닌지 판단을 하고 문제 상황이라면 triage(심각도 정도에 따른 우선 순위 분류)부터 시작하여 Troubleshooting 을 시작하기도 합니다.

- New Relic 에서 제공하는 terraform 모듈을 이용하여 각 애플리케이션 마다 Slack 으로 알람 메시지가 오도록 하는 Alert 를 생성/관리하고 있습니다.
    - New Relic 은 글로벌 서비스인만큼 사용자도 많고, 이를 활용한 오픈 소스도 많은데요. 저도 [New Relic 에서 제공해주는 매뉴얼](https://developer.newrelic.com/automate-workflows/get-started-terraform/)을 참고하는 것은 물론, github 에서 오픈 소스를 검색해 참고하여 저희만의 terraform 코드를 만들어 IaC 로 New Relic Alert 를 관리하고 있습니다.

<figure>

[![]{{ site.baseurl }}/images/kK7WOP1qCh.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-9.png)

<figcaption>

실제로 리멤버에서 사용하고 있는 newrelic terraform module 코드 조각

</figcaption>

</figure>

- 이렇게 설정해놓은 New Relic Alert 의 조건이 발동되면 아래와 같이 Slack 에서 어떤 문제가 있는지 확인할 수 있습니다.
    - Slack 으로 Alert 가 오는 것을 확인하면 즉시 확인하여 원인이 무엇인지 파악하고 해결을 하면서 그 과정을 thread 로 기록하고 있습니다. thread 로 기록하는 이유는 재발 방지를 도모하고, 이런 문제가 있었다는 것을 다른 분들도 다 확인하실 수 있도록 하고 있습니다. 다른 사람들이 thread 로 기록해놓은 해결 과정을 따라가보면 새로운 인사이트를 얻게 되는 경우도 많답니다. 😂

<figure>

[![]({{ site.baseurl }}/images/kfKhyLvHro.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-10.png)

<figcaption>

New Relic Alert 가 Slack 으로 게시된 모습

</figcaption>

</figure>

- 또한 AWS CloudWatch + SNS 를 이용하여 Slack 으로 알람 메시지가 오도록 연동하여 사용하고 있는 것도 많이 있습니다.
    - 이 글을 작성하고 있는 시간 기준으로 AWS CloudWatch 에는 411개의 Alarm 이 있습니다. 이 중에는 더 이상 무의미하여 삭제해도 되는데 삭제하지 못하고 있는 Alarm 도 다수 포함이 돼있습니다.
    - Alarm 이 슬랙으로 전송되면 아래와 같은 형태로 확인할 수 있습니다.

<figure>

[![]{{ site.baseurl }}/images/P8CoHQWdCC.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-11.png)

<figcaption>

DLQ(Dead Letter Queue) 로 설정해놓은 특정 SQS queue 에 메시지가 전송됐을 때 Alarm 이 Slack 으로 게시된 모습

</figcaption>

</figure>

#### 모니터링 시스템 활용 troubleshooting 사례

여기서 말하는 troubleshooting 이라 함은 크게 특정 사용자에게 어떤 문제가 생겨 문의를 주신 경우에 대응하여 처리하는 것과 서비스의 지표에 이상징후가 생겨 대응하는 것으로 나눌 수 있습니다.

어떤 문제가 생겨 유저께서 문의를 하신 경우에는 가장 먼저 Logs 에서 해당 유저가 요청한 API 목록을 가장 먼저 확인하여, 어떤 일들이 있었는지 파악하고 해결해드리고 있습니다.

<figure>

[![]({{ site.baseurl }}/images/KkTQvMYSvu.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-6.png)

<figcaption>

New Relic 에서 본 Logs

</figcaption>

</figure>

서비스의 지표에 이상징후가 생겨 대응할 때에는 그 종류에 따라 달라지겠지만, CloudWatch, NewRelic 등 수단과 방법을 가리지 않고 원인 파악을 위해 적절한 지표와 로그를 찾고 Troubleshooting 을 하고 있습니다.

아래는 특정 서비스에서 Errors 가 동시 다발적으로 발생하여, 모니터링 시스템을 이용하여 원인을 파악하고 개선하기 위해 커뮤니케이션 했던 흔적입니다.

<figure>

[![]{{ site.baseurl }}/images/lGW7m4PDxb.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-7.png)

<figcaption>

Error rate 지표를 확인하고 개선하고 있는 예시

</figcaption>

</figure>

### 부록 - 리멤버에서는 왜 이렇게 모니터링을 하고 있을까

위 본문에서 소개드린 것 외에도 모니터링은 곳곳에서 다양한 도구와 방법을 통해서 하고 있습니다. 예를 들어, Monyog 을 이용하여 데이터베이스를 모니터링하고 있기도 하고요.

결국 모니터링 하는 이유는 사용자에게 안정적인 서비스를 제공하기 위함이기 때문에 저희가 현재 모니터링을 하고 있지 않은 영역을 찾아서 모니터링 범위에 포함시키고 지속적으로 개선하기 위해 노력하고 있습니다. 특정 모니터링 시스템/플랫폼에 종속되거나 스스로 locked-in 될 필요는 없지만, 모니터링을 잘 하려면(=안정적인 서비스를 제공하려면) 사내에서 사용하고 있는 모니터링 시스템/플랫폼에 대해 익숙해지고 잘 사용할 줄 아는 것도 중요합니다.

그렇기 때문에 우리 회사에서의 모니터링 시스템은 왜 이런 모습이 됐을까를 이해하는 것도 모니터링 시스템/플랫폼에 익숙해지는 데 큰 도움이 될 것이란 생각이 들었기 때문에 부록으로 "리멤버에서는 왜 이렇게 모니터링을 하고 있을까"라는 질문에 대해 일부 답변이 될 만한 내용들을 정리해보려 합니다. :)

#### 입사 당시의 상황

2019년 12월, 제가 리멤버에 합류할 때 당시를 떠올려보면 그 때도 안정적인 서비스를 위해 모니터링을 잘 하고 있었습니다. 하지만 직접 개발, 운영하면서 느꼈던 부족한점, 아쉬운 점들이 있기도 했습니다.

###### 다원화된 로그(logs)와 지표(metrics) 데이터

- ElasticSearch 로 전송하고 ElasticSearch 에서 로그를 저장/인덱싱을 하면 Kibana 에서 로그를 조회하는 일반적인 구성이었습니다. 이 시스템 자체는 문제가 없었지만, 일부 서비스는 ELK 연동이 안 돼있어서 AWS 의 CloudWatch 에서 로그를 보거나 EC2 에 직접 SSH 접속을 해서 봐야 하는 경우도 있었습니다. 또한 직접 EC2 에 구성하고 운영하고 있던 ElasticSearch 는 가끔씩이지만 인덱싱 문제를 일으켰고, 그 때마다 일부 로그 유실이 발생했고 자주 발생하는 일이 아니었기 때문에 노하우가 없어 문제가 생기면 복구를 위한 시간이 상당히 많이 소요됐습니다.
- 로그는 ELK 에서 보면 되는데, 로그와 연관된 서버의 상태(CPU, memory 사용율 등)는 AWS console 에서 보거나 당시에도 연동돼 있던 NewRelic 에서 확인해야만 했습니다. 이렇게 이원화가 돼있다 보니 개발자가 무언가를 파악해야할 때마다 확인해봐야 하는 데이터들이 흩어져있어 신경쓰고 있어야 하는 컨텍스트가 많아져 비효율이 있었습니다. 특히 새로 합류하는 개발자 입장에서는 어떤 것은 여기서 보고, 어떤 것은 저기서 봐야하는 암묵지처럼 돼버린 것을 이해하고 활용하기까지는 시간이 적지 않게 걸렸습니다.

##### 이상 징후에 대한 alert/alarm 이 구성돼있지만, 뭘 해야할 지 판단하기 어려움

- 오래전 AWS Cloudwatch 및 NewRelic 에서 설정해놓은 Alert 가 있어서 서비스에 문제가 생기거나 생길 것으로 예상될 때마다 슬랙으로 Alarm 이 오긴 왔지만, 해당 Alarm 을 본 개발자가 어떤 문제가 있는 것인지, 어떤 조치를 해야하는지에 대한 파악이 쉽지 않았습니다. 문제가 생기면 그때 그때 특별한 컨벤션, 규칙, 기준없이 alert 를 만들어왔던 것들이 꽤 많았었고, alert 가 있었기 때문에 문제가 발생했다는 사실은 쉽게 인지할 수 있었는데, 그 alert 를 보고 원인 분석을 위해서 어떻게 시작해야하는 지에 대해서는 회사에서 일정 기간 이상 근무를 한 개발자가 아닌 이상 파악하기가 쉽지 않았습니다.

##### service map 파악의 어려움

- 기존에 monolithic 한 하나의 서비스에서 벗어나, 여러 신규 서비스들은 소스코드부터 인프라까지 별도로 구축하고 있었습니다. 이 때, 서비스들 간의 통신이 어떻게 되고 있는지 등을 파악하려면 지속적으로 업데이트되는 Service Map 을 쉽게 볼 수 있는 것이 중요한데, 이때까지는 사람이 수작업으로 위키(컨플루언스) 문서로 관리하고 있었습니다. 결국 사람이 하는 문서 관리이다 보니, 현행화가 잘 이뤄지지 않게 되거나 문서의 존재조차 모르고 우리 서비스들의 Service Map 을 그려달라고 하는 개발자분들이 생길 수 밖에 없었습니다.

##### 웹, 모바일 애플리케이션에서 일어나는 이벤트(에러, 버그 등)들에 대한 파악의 어려움

- 이건 이 글을 쓰고 있는 현재 시점 기준으로도 아직 잘 하고 있지 못한 부분입니다. 😭😭

#### 문제점 인식

사내에 개발자가 늘어남에 따라 서버의 상태나 애플리케이션의 지표, 로그를 한 군데에서 보는 것이 더욱 중요해지고 있었습니다. 새로 합류하시는 개발자에게 모니터링 현황 및 배경에 대해 설명해드리는 것조차 각오하고 해야하는 큰 일이 되고 있었습니다. 문서로 커뮤니케이션 하는 것의 한계가 느껴지기 시작하기도 했습니다.

"모든 로그를 하나의 시스템으로 모아서 보자. 로그와 여러 지표도 하나의 시스템에서 확인할 수 있게 하자." 를 달성하기 위해 이미 많은 비용을 지불하고 있던 NewRelic 을 잘 활용해보자고 의사 결정이 2021년 6월쯤 이뤄졌습니다.

#### New Relic 을 사용하는 이유

##### 비용

기존에도 비용을 지불하며 New Relic 의 APM 기능을 연동하여 사용하고 있었습니다.

기존에 로그를 쌓고 조회하기 위해 자체적으로 ELK 를 운영하던 것에도 적지 않은 비용이 발생하고 있었습니다. 데이터의 다원화 등으로 인해 발생하는 눈에 보이지 않는 생산성 저하 등의 비용도 무시할 수 없었습니다. New Relic 이 아니더라도 기존에 ELK 에 통합하든, 새로운 모니터링 시스템을 자체적으로 구축하든 큰 비용이 필요했습니다. 이 중에서 New Relic 을 선택하는 것이 그 당시 가장 합리적인 것이었습니다.

[과거에 ELK 로 선택한 것과 관련한 블로그 포스트](https://blog.dramancompany.com/2015/12/%EC%95%88%EC%A0%95%EC%A0%81%EC%9D%B8-%EC%84%9C%EB%B9%84%EC%8A%A4-%EC%9A%B4%EC%98%81%EC%9D%84-%EC%9C%84%ED%95%9C-%EC%84%9C%EB%B2%84-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-2/)

##### 생산성

애플리케이션과 연결된 Database layer 까지 포함한 여러 지표를 확인할 수 있습니다. 이를 통해 trace 의 여러 spans 중 어디가 병목인지 쉽게 분류할 수 있습니다. 또한, 별도의 시스템을 구축하지 않아도 APM 기능 안에서 N+1 쿼리 발생 여부, slow query 발생한 trace 등을 쉽게 파악할 수 있습니다. 이것들이 쉽게 파악이 되며, 계속 눈에 띈다면 개발자로서 조치를 취하지 않을 수 없게 됩니다. :D

그래프, 차트 등 데이터 시각화가 잘 돼있어, 개발자가 현황을 파악하거나 문제의 원인 분석 등을 빠르게 할 수 있습니다.

##### 분산 트레이싱 환경

Prometheus + Grafana, Sentry 같은 오픈소스 제품이나 New Relic, DataDog, Dynatrace 등 3rd party SaaS 를 사용하면 분산 트랜잭션 환경에서 유저 관점에서 하나의 trace 와 관련한 logs, traces, error 를 seamless 하게 확인할 수 있습니다.

여러 부분, 여러 관점에서 꼭 New Relic 이 아니더라도 같은 수준 혹은 더 높은 수준의 요구 사항을 만족시켜주는 좋은 제품들도 많이 있는 것으로 알고 있습니다.

하지만 현재 New Relic 을 사용하고 있는 리멤버의 개발자들과 앞으로 합류해주실 분들께 지금 New Relic 을 사용하는 이유에 대해 설명을 드리고 공감을 얻는 것이 중요하기 때문에 제가 알고 있는 배경에 대해 정리해봤습니다.

배경과 더불어 실제로 사용해보면서 개인적으로 느꼈던 장점과 단점에 대해서도 정리를 해보면, New Relic 또는 기타 제품들을 고민하고 있는 단계에 있는 분들께 도움이 될 것 같아서 아래에 간략하게 정리해보려고 합니다. 다시 한 번 말씀드리지만, 이 글을 쓰고 있는 제 개인적인 느낀점일 뿐인 점을 감안하고 봐주시길 부탁 드립니다. 😊

#### New Relic 의 단점

- 애플리케이션에서 의존성으로 설치하는 APM agent 와는 별개로 infrastructure agent 를 설치해야했으며(소스 코드로 관리하기가 다소 번거로운 점), EC2 로 운용하는 경우 agent 버전 업데이트, 설정 변경 등 필요하면 AMI 를 새로 생성하는 작업 등 관리 포인트가 증가했습니다.
    - 애플리케이션 서버의 로그를 New Relic 으로 전송하기 위해 별도의 Log forwarder 도 설정을 해줘야만 했던 점도 불편한 점이었습니다.
        - 2022년 5월 이후 애플리케이션 서버 로그는 최신 버전의 APM agent 를 의존성으로 추가하는 것만으로 자동으로 수집이 되게 업데이트 된 것을 확인하긴 했습니다.
- 서버에 설치된 보안 프로그램(trend micro 사의 deep security) 또는 aws-ssm-agent 프로세스와의 충돌 이슈로 인해 트래픽이 적은데도 CPU 100% 이슈가 생기는 EC2 들이 가끔 발생했습니다. deep security 의 특정 rule 때문에 발생하는 것인지, New Relic 의 infrastructure agent 작동 방식 때문에 발생하는 것인지 정확한 진단이 어려웠습니다. 하지만 이런 일이 생길 때마다 적극적으로 지원해주시기 때문에 큰 걱정은 하지 않지만, 정확한 원인 진단은 잘 되지 않았기 때문에 아쉬움이 생기긴 했습니다.
- NRQL(New Relic Query Language) 을 학습해야 활용도가 매우 커지는데, 학습 곡선의 초반부 기울기가 낮습니다.
    - 즉, NRQL 을 일정 수준 이상 학습하기 전까지는 잘 활용하기가 어렵습니다.
    - 학습 곡선은 가로축이 시간/노력/누적 경험수이고, 세로축이 달성도, 성취, 습득 정도인 곡선입니다. 기울기가 낮다는 의미가 초반에는 들이는 노력에 비해 일정 수준 이상 학습(성취)되기 까지 시간이 오래 걸린다는 의미입니다.

##### New Relic 의 장점

여기 나열한 것들은 New Relic 만의 장점은 아닐 것입니다. 그렇지만, 연동부터 운영까지 해보며 장점으로 느껴진 부분들을 정리해보았습니다.

- 애플리케이션의 의존성으로 APM agent 를 추가하기만 하면 각종 지표를 손쉽게 확인할 수 있습니다.
- New Relic 의 여러 리소스들(eg. Alert)을 생성/수정/관리를 API, terraform 모듈로 제공해주고 있어 한 번 구성해놓으면 편리합니다.
- 원하는 데이터를 보기 위한 dashboard 를 자유자재로 만들 수 있습니다.
- Service Map 을 쉽게 확인할 수 있습니다.
- SRE 를 위한 SLI/SLO 정의가 쉽고 한 눈에 보기 쉬운 페이지를 제공합니다.
    - 이 기능은 최근에 업데이트 된 것으로 알고 있는데, 하나씩 추가해보고 있습니다. SLI/SLO 설정 및 대시보드를 만들기 위해 자체적으로 개발을 해야하나 고민을 하던 찰나에 이 기능을 발견해서 써보고 있는데, 아직까지는 만족스럽습니다.
- 제품 업데이트가 빠르고 많습니다.
    - 실제로 작년에 처음 사용을 본격적으로 시작할 때를 떠올려보면 지금은 정말 많은 기능 추가/개선이 생겼음을 느낍니다.
- 브라우저 및 모바일 애플리케이션에 대해서도 모니터링이 가능합니다.
    - 하지만 리멤버에서는 아직 이 장점을 잘 활용하고 있지는 않습니다.
- Synthetics 를 활용하여 실제 사용자가 사용하는 시나리오대로 테스트를 구성하고 원할 때 테스트가 실행되도록 하여 사용자가 실제 문제를 겪기 전에 사전에 개발자들이 문제를 파악할 수 있습니다. 이 또한 아직 리멤버에서는 잘 활용하고 있지 않습니다.

<figure>

[![]({{ site.baseurl }}/images/sHZdEqBLiK.png)](https://blog.dramancompany.com/wp-content/uploads/2022/06/image-8.png)

<figcaption>

New Relic 에서 자동으로 만들어 준 Service Map 중 하나

</figcaption>

</figure>

이것으로 리멤버에서는 어떻게 모니터링을 하고 있는지에 대해 소개드리는 글을 마치겠습니다.

개인적으로 아직도 모니터링이 필요한데 하지 않고 있는 영역도 존재하고, 현재 모니터링 시스템을 더 잘 활용할 수 있는 여지가 한참 남아있다고 생각합니다. 그러나 이 일은 혼자 또는 일부 구성원들의 의지만으로는 잘 되기 어려울 것이라고 생각하기 때문에, 같은 뜻을 가지고 함께 해주실 동료분이 매우 중요합니다.

여느 대다수 회사 기술 블로그 포스트들의 결론이 그러하듯 저 또한 채용 홍보를 함으로써 마무리 지으려고 합니다.

현재 저희 상황을 최대한 자세하게 공유드림으로써 "이거 이렇게 하는 거 아닌데.." 라고 생각하시거나 🤣 "내 경험을 기반으로 기여할 수 있는 것이 많겠다" 😮 와 같은 생각을 가지신 분들께서 저희 리멤버에 합류해주시기를 간절히 기원합니다! 🙏🙏🙏

[리멤버팀에 합류하세요!!!](https://hello.remember.co.kr/)

긴 글 끝까지 읽어주셔서 감사합니다.
