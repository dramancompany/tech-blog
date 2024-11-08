---
layout: "post"
title: "Rails Engine을 이용한 Zeus 프로젝트"
author: "sid"
date: "2016-03-18"
categories: 
  - "develop"
---

### 1\. Problem

드라마앤컴퍼니에서는 리멤버 서비스를 위해 다양한 서버 애플리케이션들을 운용하고 있습니다. 일부 데이터 분석을 위한 소프트웨어를 제외하고는 모두 Ruby on Rails를 사용하여 작성되었고, 크게 아래와 같은 것들이 있습니다.

- API 서버 애플리케이션: 리멤버 앱 등 클라이언트에서 발생하는 모든 요청을 처리합니다.
- Typist 서버 애플리케이션: 사용자가 등록한 명함 요청을 타이피스트가 확인하고 입력하는 시스템입니다.
- Admin 서버 애플리케이션: 운영자가 명함을 검토, 검수하는 등 다양한 운영 작업을 수행하는 시스템입니다.

그런데 여기에는 한 가지 큰 문제가 있었습니다. 바로 동일한 업무 로직이 여러 애플리케이션에 중복되어 들어간다는 겁니다. 예를 들어 명함과 명함 요청에 대한 도메인 모델은 위의 세 가지 애플리케이션에서 모두 참조합니다.

[![duplicate_domain_model]({{ site.baseurl }}/images/kaTlvXoJlZ.png)](https://blog.dramancompany.com/wp-content/uploads/2016/03/duplicate_domain_model.png)

위의 그림에서 보듯이, 명함 요청과 명함 도메인은 전체 라이프사이클에 걸쳐 다양한 애플리케이션에 의해 생성, 수정, 조회와 같은 작업이 일어납니다. 따라서 애플리케이션마다 동일한 명함과 명함 요청의 모델 코드가 들어가 있습니다.

[![duplicate_rails_model](/images/9ewUHgMDkx.png)](https://blog.dramancompany.com/wp-content/uploads/2016/03/duplicate_rails_model.png)

### 2\. Don't Repeat Yourself

이러한 상황에 대한 대처 방법은 크게 3가지가 있을 것 같습니다. 첫 번째는 그냥 놔두는 것입니다. 사실 코드베이스의 크기가 그렇게 크지 않고, 중복되는 모델이 많지 않다면 그대로 유지를 하는 것도 나쁘지 않다고 생각합니다. 유지보수에 드는 비용이 그리 크지 않기 때문입니다.

하지만, 리멤버의 경우 서비스에 점점 많은 기능이 추가되면서 중복되는 모델도 많아지기 시작했고, 기능의 변경도 잦아지면서 점점 더 유지보수하기가 힘들어졌습니다. 따라서 중복되는 모델 코드를 한 군데 모아놓을 필요성이 생겼습니다.

이 때 두 번째로 검토할 수 있는 방법이 바로 [Microservice](http://martinfowler.com/articles/microservices.html) architecture입니다.

### 3\. Microservices

[![microservice](/images/Ctcmq9aiB8.png)](https://blog.dramancompany.com/wp-content/uploads/2016/03/microservice.png)

도메인 업무를 수행하는 모델을 별도의 Internal API 서버로 구성하고 각 애플리케이션은 Internal API를 호출합니다. 이렇게 하면 중복 코드를 제거하게 되어 도메인 모델 코드의 유지 보수가 용이해집니다. 그러나 고려해야 할 단점도 많습니다. 사실 Microservice나 그 전신(?)인 SOA Architecture가 고스란히 가지고 있는 단점이기도 합니다.

- 성능 저하가 일어납니다. 당연한 이야기지만, 하나의 서버에서 처리할 수 있는 일을 별도의 API 호출을 하게 되면 그만큼 비용이 늘어납니다(네트워크 통신 비용, Internal API 호출 시 들어가는 parameter parsing/binding, 비즈니스 로직 수행 후 response를 만들고 가공하는 일 등등..)
- 시스템 전체적으로 보면 유지보수 비용이 늘어납니다. Internal API 서버를 별도의 서버로 구성한다면 서버 운영 비용이 증가합니다. 그리고 Internal API 애플리케이션도 하나의 애플리케이션이기 때문에 소스 코드 관리, Model과 Controller들에 대한 테스트 작성 등 해주어야 할 것들이 많습니다.
- 기능을 빨리 추가하거나 변경하지 못합니다. 기능의 추가/수정에 대한 요구사항이 발생하면 먼저 API 명세를 설계하고, 이를 문서로 작성해야 하는 등 부가적으로 해야 할 작업들이 적지 않습니다.
- 여기에 API Gateway가 들어가고 어쩌고 하면 시스템 복잡성이 더욱 증가할 수 있습니다.

Microservice는 시스템의 크기가 크고, 팀/조직/프로세스가 잘 정비되어 있는 경우 상당한 장점이 있다고 생각합니다. 하지만, 저희 같이 빠르게 움직여야 하고 시스템의 크기가 아직 크지 않은 상황에서는 장점보다 단점이 더 클 것이라고 판단하였습니다.

그래서 마지막으로 세 번째 대안을 고려하여 보았습니다. 바로 [Rails Engine](http://guides.rubyonrails.org/engines.html)을 사용하여 모델 layer만 들어내어 중복을 제거하는 것입니다.

### 4\. Rails Engine

[![rails_engine](/images/I9YQipTCCY.png)](https://blog.dramancompany.com/wp-content/uploads/2016/03/rails_engine.png)

언뜻 보면, 첫 번째 방법인 중복 모델을 그대로 유지하는 것과 별반 다를 게 없어 보이지만 여기에는 아주 중요한 차이가 있습니다. Rails Engine은 별도의 애플리케이션으로 관리되지만, Ruby 라이브러리인 Gem(Java에서는 jar)의 형태로 각 애플리케이션에 import 될 수 있습니다. 따라서 모든 도메인 모델 코드는 Rails Engine 애플리케이션에 작성하고, 각 애플리케이션에서는 라이브러리 클래스를 사용하듯이 이를 가져다가 사용하면 됩니다. 아래는 API 애플리케이션에서 실제로 Rails Engine을 사용하는 예시 코드입니다.

```
Gemfile.rb

...
gem 'zeus', git: '...', tag: '0.0.6'


```

```
user_controller.rb

...
def create
  user = Zeus::User::Entity.new(params)
  user.save

  ...
end
```

저희는 리멤버 서비스에서 공통적으로 사용되는 도메인 모델을 담은 Rails Engine 애플리케이션의 이름을 Zeus라 명명했습니다. 위의 코드에서 보듯이 Gemfile에 보통 gem을 import하는 것처럼 Zeus를 선언하였습니다. 그러면 API 애플리케이션에서는 Zeus에서 제공하는 모든 도메인 모델 클래스를 사용할 수 있습니다. Rails Engine은 보통 namespace를 정의하기 때문에 저희도 Zeus라는 namespace를 사용하고 있습니다.  따라서 UserController 클래스에서 zeus의 사용자 모델 클래스인  Zeus::User::Entity 클래스를 사용하여 회원 가입을 처리하고 있습니다.

Java에서는 Maven이 multi module이라는 이름으로 비슷한 기능을 제공하고 있습니다(실제로 몇 년 전에  multi module을 사용하여 프로젝트 구성을 한 적이 있었는데 설정 잡아주는 것이라던지, 빌드하는 게 완전 hell이었습니다... 요새는 시간이 지나서 잘 되는지 모르겠네요).

Zeus도 하나의 별도 애플리케이션이기 때문에 Microservice처럼 유지보수가 필요합니다. 하지만 그 비용은 상대적으로 매우 작습니다. 또 소스 코드에 태깅이 가능하기 때문에, 기능의 변경이나 추가가 용이합니다. Microservice의 경우, API 인터페이스에 변경이 일어나면 매우 골치가  아픕니다.

- Internal API 배포 시, 여기에 의존하고 있는 모든 클라이언트 애플리케이션도 같이 수정하여 한 방에 배포하거나
- Internal API를 versioning하여 순차적으로 migration시키거나

인데, 이게 아시다시피 엄청 짜증나고 귀찮은 일입니다.

그렇지만 Zeus의 경우 수정이 가해지면 버전을 하나 올리고, 각 애플리케이션에서 테스트를 돌려본 후 이상이 없으면 Gemfile만 업데이트해주면 됩니다. 만약 문제가 생기면 한 줄만 고쳐서 다시 원복시킬 수도 있습니다.

### 5\. Wrap-up

지금까지 리멤버 서비스 애플리케이션 간의 코드 중복을 해결하기 위해 여러 방법을 검토했고, 어떻게 해서 Rails Engine을 이용한 방법을 채택했는지를 설명하였습니다. Rails Engine은 생각보다 적용하기 쉽고, 잘만 사용하면 아주 유용한 도구라 생각됩니다. Rails guide에도 설명이 자세히 나와있어서 정보를 구하는 것도 어렵지는 않습니다.

코드 중복이라는 bad smell을 제거하기 위해 오늘도 노력을 게을리하지 않으시는 많은 개발자 분들께 조금이나마 도움이 되기를 바라면서 이 글을 마칠까 합니다.
