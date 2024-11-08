---
layout: "post"
title: "Java&Spring 개발자가 Ruby on Rails 를 해보고 마주친 생각들"
author: "hb.lee"
date: "2020-11-16"
categories: 
  - "develop"
tags: 
  - "backend"
  - "java"
  - "ruby"
  - "ruby-on-rails"
  - "spring"
  - "springboot"
---

안녕하세요? 리멤버를 개발하는 드라마앤컴퍼니 서버/웹팀의 서버 개발자 이한별입니다.

저는 Spring Framework 로 제품 개발을 3년 정도를 했습니다. 이후 최근 11개월동안은 Rails 로 제품 개발을 하고 있습니다.

## Spring 개발자가 왜 Rails 에 관심을 갖게 됐는가?

Spring, 특히 Spring Boot 라는 Framework 에 부족함을 느끼지 못했습니다.

그런데 왜 지금 리멤버를 서비스하고 있는 드라마앤컴퍼니에 와서 Rails 로 개발을 하고 있는지를 떠올려봅니다.

언제인지 정확한 기억은 나지 않지만, Ruby 의 기초를 공부한 적이 있었는데 문법이 저랑 잘 맞을 것 같단 느낌과 함께 마냥 긍정적인 시각이 생겼습니다. 많은 현대 Web Framework 들에 영감을 준 Ruby on Rails 에 대해서도 궁금증이 생겼습니다.

그 이후, 기회가 되면 Ruby 로 개발해보면 재밌겠다라는 생각이 들었고, 드라마앤컴퍼니로 이직하는 것이 계기가 되어 Rails 로 개발을 하고 있습니다.

* * *

이 글에서는 Spring 으로 개발하던 사람이 Ruby on Rails 로 개발을 해보고 난 후 드는 생각들을 정리해봤습니다.

## Ruby on Rails 프레임워크의 철학

Ruby on Rails 는 MVC 패턴 기반의 개발을 빠르고 편리하게 해주는 Web Framework 이며, Rails 의 철학은 아래 두가지의 주요한 가이딩 원칙을 바탕으로 하고 있습니다.

\- DRY(Don't Repeat Yourself)

\- CoC(Convention over Configuration)

    - Spring Boot 가 나오게 된 배경도 Spring MVC 만을 사용할때 비즈니스 로직보다 설정에 관련된 코드를 많이 작성해야했기 때문인 점과 일맥상통하다고 볼 수 있습니다.

```
The Rails philosophy includes two major guiding principles:
Don't Repeat Yourself:
DRY is a principle of software development which states that "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system." By not writing the same information over and over again, our code is
Convention Over Configuration:
Rails has opinions about the best way to do many things in a web application, and defaults to this set of conventions, rather than require that you specify minutiae through endless configuration files.

```

_from [Ruby on Rails 공식 가이드](https://guides.rubyonrails.org/getting_started.html)_

## Ruby on Rails 의 강점

위 가이딩 원칙을 포함하는 철학을 바탕으로 Rails 는 확실하게 아래와 같은 강점이 있다고 느꼈습니다.

### 낮은 진입 장벽

\- Ruby 는 프로그래밍을 해보지 않은 사람에게 입문용으로 추천해줄 수 있을 정도로 쉬운 문법을 채택하였고, Rails 는 러닝 커브가 가파르지 않은 Web Framework 입니다.

\- Spring 도 완전 초기 진입 장벽 자체는 낮다고 볼 수 있으나, 주요 개념인 IoC, DI, Container 등에 대한 이해가 매우 중요합니다. Rails 에서도 이 개념들에 대해 알아야 하지만, Spring 에서 보다는 천천히 알아가도 괜찮다고 생각합니다.

\- Rails 를 전혀 해보지 않은 상태인 저도 Ruby 문법 책(a.k.a. 곡괭이 책) 1독과 좋은 튜토리얼 하나로 금방 Rails 에 대해 어느정도 이해가 생겼습니다.

\- 리멤버에 합류할 때도 3개월 내에 프로젝트에 투입되는 것을 목표로 삼았는데, 불과 2~3주 만에 프로젝트에 투입될 수 있었습니다. 물론 다른 동료분들의 도움이 필요했지만, 반대로 Rails 를 했다가 Spring 을 하게 됐을 때 과연 제가 2~3주 만에 프로젝트에 투입될 수 있었을까? 를 생각해보면 좀 더 많은 시간을 필요로 했을 것 같습니다.

\- Rails 는 웹 애플리케이션을 쉽게 만들어주는 Framework 이긴 하지만, Ruby 언어의 확장판 정도로 이해하는 관점도 있습니다. 그 말은, Ruby 언어에 대한 기초 지식이 있으면 별도의 프로그래밍 언어 자체에 대한 공부를 타언어에 비해 많이 요구하지 않습니다. Rails 를 공부하는 것이 곧 Ruby 를 공부하는 것이죠.

\- Spring 을 개발할 때는 Java 나 Kotlin 언어의 특징이 Ruby 에 비해서는 알아야 할 것들이 많다는 점과 비교된다고 할 수 있습니다.

### Ruby 언어의 강력함

\- Ruby 는 정말 인간 중심으로 설계된 언어라는 것을 체감하였습니다. Ruby world 에서는 모든 것이 Object 인 점을 만족하는 순수 객체지향 언어인 점은 Rails 라는 Framework 로 확장하는데 아주 큰 역할을 하였습니다.

\- 새로운 클래스, 메소드를 만들지 않고 기존 클래스의 기능을 손쉽게 확장 가능합니다. (meta programming)

    - Kotlin 을 활용하여 Spring 으로 개발하면 이 장점을 활용할 것 같기도 합니다.

\- 이를 바탕으로 만들어진 여러 메소드들은 실제 Rails 에서 개발할 때 아주 활용도가 높습니다.

\- 이 점은 Java 에서 각종 Util 성 메소드를 모아놓은 class 를 별도로 만들어 쓰는 것과 대조적입니다.

\- 그리고 duck typing 이 가능하기 때문에 좀 더 간결하게 코드를 작성하는데도 도움이 됩니다.

### rails console

\- IRB(Interactive Ruby) 와 같이 Rails 에서 제공하고 있는 REPL(Read-Evaluate-Print-Loop) 도구인 rails console 을 통해 방금 작성한 코드의 실제 실행 결과를 바로바로 눈으로 확인할 수 있습니다. 이 점은 개발 과정에서도 아주 유용하게 사용됩니다. 특히, 저는 환경 설정 파일에 설정해놓은 key,value 값들이 실제로 잘 로드되었는지 확인하는데 많이 쓰고 있습니다. 그리고 TDD 로 개발한다고 하더라도 복잡한 계산을 요하는 로직을 개발하다보면, Java + Spring 에서는 debug 모드로 중간 중간 값들을 확인/변경하면서 잘 된 것인지, 잘못됐다면 어디가 잘못된 것인지 확인하게 되는데, rails console 을 이용하면 debug 모드로 확인하는 것보다 훨씬 빠르게 작업을 마칠 수 있습니다.

\- 그리고 운영 업무 시 아주 막강한 힘을 발휘합니다. Java + Spring 의 경우에는 실행이 필요한 코드 스니펫을 작성해놓으면 서버에 배포를 해야만, 코드 실행이 가능한데 rails console 을 이용하면 실행 전에 sandbox 모드를 이용하여 미리 dry-run 에 가깝게 실행 과정을 예상해볼 수 있고, 코드를 배포하지 않고도 원하는 코드 스니펫을 실행시킬 수 있습니다.

\- 이 점은 어떤 관점에서 보면 단점이 될 수 있기도 합니다. rails console 을 실행할 수 있는 권한이 있는 누군가가 알아차리기 힘든 실수를 할 가능성도 함께 있기 때문입니다. 그렇지만 rails console 은 rails 로 개발하는 데 있어 아주 편리한 도구인 것은 틀림없는 사실입니다.

<figure>

[![]{{ site.baseurl }}/images/qx8ik6hos3.png)](https://blog.dramancompany.com/wp-content/uploads/2021/02/rails-console-example-1.png)

<figcaption>

rails console 실행 예시

</figcaption>

</figure>

\- spring-shell 이라는 프로젝트도 있고, Java 9 부터 도입된 JShell 이라는 REPL 도 있지만, rails console 에서 제공하는 편의성과는 결이 다르고 목적이 다릅니다.

### 테스트 코드 작성의 편리성

\- Rails 를 처음 입문했을 때 가장 충격받았던 점은 테스트 코드를 작성하기가 너무 쉽고, 편해서 TDD 를 학습하는 게 너무 자연스러웠던 것이었습니다.

\- 웬만한 Rails tutorial 코드를 봐도 테스트를 가장 먼저 작성합니다.

\- RSpec 이라는 테스팅 라이브러리가 가장 많이 사용되고 있는데, 사람이 작성하고 읽기 편한 테스트를 작성하도록 자연스럽게 이끌고 있습니다.

\- 그리고 테스트에 필요한 여러 Fixture 를 편리하게 만들어주는 Faker, FactoryBot 등은 접해보지 않은 사람들은 놀랄 정도로 테스트 작성에 부스터 역할을 하고 있습니다.

\- 이렇게 테스트 코드 작성이 편리하니, 테스트 작성을 통해 얻을 수 있는 장점을 모두 쉽게 얻을 수 있으며 리멤버 커리어 서비스의 API 프로젝트의 테스트 커버리지를 분석해보면 85% 이상을 유지하고 있습니다.

<figure>

[![]({{ site.baseurl }}/images/DawhJOxgQZ.png)](https://blog.dramancompany.com/wp-content/uploads/2021/02/test-coverage-example.png)

<figcaption>

리멤버 API 테스트 커버리지

</figcaption>

</figure>

\- 개인적으로 Java, spring boot 로 개발할 때 테스트 코드를 작성하긴 했지만, 지금 와서 생각해보면 Rails 에서 작성하고 있는 테스트에 비하면 작성했다고 말하기 부끄러울 정도입니다.

### 날짜 관련

\- 한 마디로 정의하기 어려운 Rails way 를 나날이 습득하다보면서 생산성이 증가함을 느낄 수 있었습니다.

\- 언어 차원에서 단수/복수를 고려하고 있다는 자체가 사람 중심의 언어라는 증거 중 하나입니다.

\- 그 중 날짜/시간 관련 클래스의 강력한 메소드들이 기본적으로 사람이 이해하기 쉬운 메소드 이름으로 표현되어 있습니다.

```
1.day.ago.all_day
2.months.ago.all_quarter
3.days.from_now
Time.current.yesterday.beginning_of_day
```

\- Java 에서도 1.8 버전 이전에는 날짜관련 API 가 매우 빈약하여, Joda 라는 라이브러리를 사용하기도 했는데, 1.8버전 이후로는 개선된 API 가 나와서 편리해지긴 했지만 여전히 Rails way 로 구현된 Rails 의 API 에 비하면 많이 부족한 것 같습니다.

### DB 스키마 관리

\- Rails 에서는 DB 스키마가 code level 에서 관리되고 있습니다. Java + Spring Boot 의 경우에는 이를 개발자가 별도의 노력으로 관리를 해야만 code level 에서 확인하고 유지보수를 할 수 있는 반면, Rails 에서는 DB 스키마 변화에 대한 이력 관리가 거의 강제됩니다. 그래서 현재 상태만 표현하는 DB 의 이력 변화 내용을 code level 에서 확인할 수 있습니다.

\- DB 스키마 관리 방법도 2가지 이상 제공되고 있어서, 개발자(팀)의 선호도에 따라 그 방법을 선택할 수 있게 해준 점도 Rails 에서 잘 한 점이라고 생각합니다.

    - strucuture.sql, schema.rb, db/migration

\- 한 가지 아쉬운점으로는, 이 스키마 파일을 바탕으로 Rails 에서 알아서 column 값에 대한 getter, setter 메소드를 자동으로 만들어주기 때문에 ActiveModel 클래스만 보고 어떤 필드를 갖고 있는지 확인하기 어렵고, 스키마 파일을 봐야만 한다는 점은 다소 아쉽긴 합니다.

\- Spring 에서 거의 de facto 로 사용되고 있는 JPA 를 이용한 코드를 보면 Entity class 에서 애플리케이션에 필요한 컬럼이 무엇인지 모두 확인이 가능한 부분은 명시적인 코드 측면에서 더 좋았다고 느꼈습니다.

### 이메일 발송 Preview

\- Rails 에서는 기본적으로 이메일 발송 기능도 내장되어 있고, template 으로 작성된 이메일을 미리 볼 수 있는 Preview 를 제공합니다.

\- Spring Boot 에서도 개발자가 그런 기능을 만들어서 활용할 수도 있겠지만, 제 경험으로는 그 목적으로 작성된 코드를 못봤고, Spring Framework 자체에서 지원하지 않습니다. 모를 땐 괜찮았는데, 알고 나니 Preview 가 없이는 작업하기가 매우 번거로울 것 같다는 생각이 들었습니다.

<figure>

[![]{{ site.baseurl }}/images/q1nT2naYJx.png)](https://blog.dramancompany.com/wp-content/uploads/2021/02/email-preview-example.png)

<figcaption>

rails email preview exmaple

</figcaption>

</figure>

### 비동기 로직 처리를 위한 sidekiq

\- 서버 코드를 작성하다보면 시간이 오래 걸리거나, 비즈니스 로직과 직접적인 관련이 없지만 실행되어야 하는 로직들이 종종 있는데, 이를 비동기로 처리하는 경우가 많이 있습니다.

\- Rails 진영에서는 sidekiq 이라는 Backgroud Processing 도구를 많이 쓰는 것 같습니다.

\- sidekiq 에서는 여러 작업 queue 를 제공하고 있고, 각 qeuue 에 작업(Job)을 넣는 것 만으로도 안정적으로 해당 비동기 작업이 정상처리될 것임을 보장받을 수 있습니다.

\- Spring 에서는 비동기 로직을 처리하기 위해 메소드에 @Async 라는 어노테이션을 지정하는 방식을 많이 쓰고 있고, 또는 Future, CompletableFuture 의 API 를 활용하는 경우가 많은데 이 땐 실제로 잘 처리 중인지, 아닌지 확인하기가 많이 어렵습니다. 코드에 버그라도 있으면 실패를 알아차리지도 못하고, 실행되어야 하는 로직은 실행이 되지 못하고 종료처리되는 경우도 생길 수 있습니다.

\- 반면 sidekiq 에서는 Web UI 를 제공하여 실패한 Job 목록을 볼 수도 있고 재시도 알고리즘에 의해 한 번 실패했더라도 여러번 재시도를 통해 실행될 것임을 확인할 수 있습니다.

\- 또한 cron 으로 표현되는 Scheduled Job 도 손쉽게 스케줄링할 수 있습니다.

\- Spring 진영에서도 Spring Batch, Spring Quartz 라는 대안이 있긴 있지만, 약간의 러닝 커브가 있고 단순 비동기 로직을 실행시키기 위한 Framework 로서는 너무 비대합니다.

여기까지 Ruby on Rails 의 강점에 대해 정리해봤습니다. 다음으로 Spring 의 강점을 정리해보겠습니다.

* * *

## Spring 의 강점

### 선언적인 API endpoints routing

\- Rails 에서는 routes.rb 파일에 웹 어플리케이션의 모든 API endpoint 들을 정의하게 되어있습니다. Spring 에서는 Controller 클래스들과 Controller 의 메소드들에 개별적으로 어노테이션을 이용하여 선언하도록 되어있습니다. 선호도의 차이가 있을 수는 있지만, 선언적인 방식을 사용하는 Spring 의 방식이 훨씬 좋다고 생각합니다.

\- rotues.rb 에 모든 endpoints 를 정의했다고 하더라도, 연결된 controller 코드를 보면 어떤 endpoint 에 연결되어있는지 찾기가 쉽지 않습니다. 이를 보완하기 위해 컨트롤러 메소드 위에 endpoint 를 주석으로 달아놓기도 하지만, 그런다는 자체가 Spring 의 선언적인 방식을 쓰는 것이 더 좋다는 것을 인정하는 것처럼 느껴지기도 합니다. 주석으로 달아놓은 것은 실제로 실행되는 코드와는 무관하고, 틀릴 수도 있어서 팀에서 잘 관리하지 않으면 안 됩니다.

\- 그리고 특정 오류가 생긴 API 를 로그 시스템으로부터 발견하여 어떤 컨트롤러의 어떤 메소드에서 실행되는 코드인 것인지 찾기 위해 들이는 시간이 Spring 의 선언적인 방법으로 했을 때가 훨씬 적게 듭니다.

```
  class UserController {
    @GetMapping("/users/{userId}")
    ResponseEntity getUser(@PathVariable("userId") Long userId) {
      // ...
      return ...;
    }
  }

```

```
  # in routes.rb
  resources :users
  # in user_controller.rb
  class UsersController < ApplicationController
    # GET /users/:id       # <-- 이것처럼 주석으로 작성해둬야 찾기가 편합니다.
    def show
      # ...
    end
  end

```

\- 또한, 점점 더 많은 endpoint 가 필요할 수록, Rails 의 routes.rb 를 이용한 방식은 routes.rb 자체에 대한 도메인 지식도 요구하고 복잡해지는 경향이 있습니다.

### 선언적인 DB 트랜잭션 관리

\- Rails 에서도 DB 트랜잭션 관리를 위한 API 가 있습니다. Spring 의 그것에 비하면 기능이 너무 제한적입니다. 그리고 트랜잭션 관리를 하기 위해 개발자가 직접 트랜잭션을 여는 코드를 비즈니스 로직 내에 작성하도록 되어 있습니다.

\- Spring 에서는 아래와 같이 @Transactional 을 메소드 바깥에 선언하므로서 비즈니스 로직과 분리하여 생각할 수 있게 해줍니다.

```
    @Transactional
    public List saveUser(User user) {
      return userRepository.save(user);
    }

```

\- Rails 에서는 아래와 같이 비즈니스 로직(메소드) 안에서 작성해야 합니다.

```
    def save_user(user)
      User.transaction do
        user.save!
      end
    end

```

### Container 와 DI

\- Spring 에서 Container, DI, IoC 에 대해 얘기해보자면 끝이 없는 이야기가 될 정도로 중요한 개념일 것입니다. 이 글은 그걸 설명하기 위한 글은 아니라 Spring 의 강점으로 Container 와 DI 를 떠올린 이유 정도만 얘기해보겠습니다.

\- Spring 에서 넘어와 Rails 를 하면서 가장 큰 충격을 받았던 부분 중 하나로 비즈니스 로직 처리를 담당하는 Service Layer 를 구성하고 있는 클래스의 인스턴스들을 직접 new 키워드를 통해 생성하고 있던 부분이었습니다. 그러다 보니 상태를 갖는 객체들을 개발자가 직접 컨트롤 해야하는 위험에 빠지기 쉬운 것 같습니다. 이를 조금이나마 방지하기 위해 class method (루비에서 모든 것은 객체이기 때문에 진정한 의미에서의 class method 는 아니지만) 를 정의하는 방법을 사용하기도 합니다.

\- Spring 에서는 Bean 이라고 부르는 객체들의 라이프 사이클을 관리해주는 Container 가 있습니다. Bean 객체들은 이 Container 가 생성해주고 해당 Bean 들이 필요한 곳에서는 의존성을 주입(DI) 받아서 사용하는 형태가 일반적이기 때문이었습니다.

\- 상태(변경이 가능한 인스턴스 변수)를 갖는 객체들이 많다보면 코드의 흐름을 파악하는데 있어서 매우 복잡해짐을 느끼는데, Rails 에서는 Framework 차원에서 이를 방지하기 위한 장치가 없다는 것이 아쉬웠습니다.

### DB Entity layer 와 Query layer 의 명확한 분리

\- Spring 에서는 DB Entity 를 표현하는 class 와 Query 실행을 담당하는 class 가 명확하게 나뉘어져 있습니다. 굳이 분리하지 않고 개발하려면 불가능하진 않겠지만요.

\- Rails 에서도 이를 분리하기 위해 layer 를 만들어 관리할 수 도 있지만, 태생적으로 모든 곳에서 접근이 가능한 ActiveModel 특성이 있기 때문에 그렇게 한다 하더라도 코드가 복잡해지면 코드를 읽거나 작성하는데 어려움이 생기게 됩니다.

\- Spring 에서는 아주 일부 케이스를 제외하고는, 실행해야하는 쿼리를 명시적으로 선언을 해야만 쿼리를 실행시킬 수 있습니다. 동적인 쿼리가 필요해서 별도의 코드(Predicate, query-dsl 등)를 작성하더라도 Query layer 에서만 살펴보면 됩니다.

\- Rails 에서는 그냥 쿼리가 필요한 어느 곳에서든 ActiveModel 을 이용하여 자유롭게 쿼리를 생성할 수 있는데, 이는 하나의 클래스가 여러 역할을 하므로서 복잡도가 매우 커진다는 느낌을 받고 있습니다. ActiveModel 의 높은 자유도는 작은 웹 애플리케이션인 경우에는 괜찮을 수도 있지만, 점점 커지는 웹 애플리케이션이라면 관리하기가 어려워지는 것 같습니다.

\- 한편, Rails 의 ActiveModel 은 Java 진영의 SQL Framework 인 jooq 와 비슷한 것 같다는 생각도 들었지만, jooq 를 잘 써본 것은 아니라 충분히 다른 견해가 있을 수 있습니다.

### cloud platform, MSA

\- Spring 진영에는 분산 시스템의 공통된 패턴을 빠르게 구축하기 위한 도구를 제공하는 spring cloud 라는 Framework 가 마련되어 있습니다.

\- 외부 서비스를 사용하지 않고도 손쉽게 Service Discovery(Eureka) 와 Feign 이라는 선언적인 Rest Client 만으로도 작은 MSA 를 구축할 수 있었습니다. (꼭 Feign 을 써야할 필요는 없습니다.)

\- 또한 복잡하고 큰 MSA 를 구현함에 있어서도 spring cloud 의 여러 도구들을 활용하면 분산 시스템을 구축하기가 쉽고 편합니다.

```
  // Eureka Server
  @SpringBootApplication
  @EnableEurekaServer // Eureka 서버로 사용할 애플리케이션에 이 어노테이션만 달아주면 기본적인 설정은 끝
  public class Application {
      public static void main(String[] args) {
          new SpringApplicationBuilder(Application.class).web(true).run(args);
      }
  }
  // Feign
  @FeignClient("stores") // Service Discovery(Spring Eureka) 를 통해 stores 라는 서비스를 이용하는 Client 로 선언
  public interface StoreClient {
      @RequestMapping(method = RequestMethod.GET, value = "/stores")
      List getStores();
      @RequestMapping(method = RequestMethod.POST, value = "/stores/{storeId}", consumes = "application/json")
      Store update(@PathVariable("storeId") Long storeId, Store store);
  }

```

### Static Type (Java, Kotlin)

\- Spring 을 개발할 때 주로 사용하는 언어인 Java 와 Kotlin 은 static type 을 채택하였습니다.

\- 최근 TypeScript 의 성장세, Ruby 도 3.0 버전 이후부터는 static type 을 지원하는 추세로 봐서는 엔터프라이즈 웹 어플리케이션을 개발할 때는 static type 이 더 유리하다는 쪽으로 점점 기울고 있다는 생각이 듭니다.

### 개발 생태계

\- Java 는 Oracle, Spring 은 Pivotal 이라는 기업에서 governorship 을 가지고 유지보수를 하고 있습니다.

\- 반면에 Ruby 와 Rails 모두 오픈 커뮤니티에 의존하고 있습니다.

\- 각 언어, 프레임워크의 발전 속도, 안정성 측면에서 본다면, 아무래도 Java, Spring 쪽의 미래가 더 밝을 것이라고 예상해봅니다.

### openapi 문서 작성의 편의성

\- Rails 에서도 API 문서를 작성하기 위해 직접 openapi.json(yml) 을 코드에서 관리할 수도 있고, 이를 편리하게 작성할 수 있도록 한 여러 시도들이 있습니다. 하지만 개발자가 신경을 써야하는 부분이 많다고 느꼈습니다.

\- 저희 리멤버에서도 openapi.yaml 파일로 API 문서를 관리하고 있습니다.

\- Spring 진영에서는 springfox 라는 오픈소스 커뮤니티에서 제공하는 swagger-ui 라이브러리를 이용하면 Java 어노테이션을 이용하여 보다 더 쉽게 작성을 할 수가 있습니다. Static Type 을 자동으로 읽어서 처리되기 때문에 개발자가 직접 properties 를 나열할 필요가 없습니다. 파라미터에 대한 세부 설명 또한 어노테이션으로 표현이 가능합니다.

```
  @ApiOperation(value = "Find pet by Status",
                notes = "${SomeController.findPetsByStatus.notes}"...)
  @RequestMapping(value = "/findByStatus", method = RequestMethod.GET, params = {"status"})
  public Pet findPetsByStatus(
    @ApiParam(value = "${SomeController.findPetsByStatus.status}",
              required = true,...)
    @RequestParam("status", defaultValue="${SomeController.findPetsByStatus.status.default}") String status) {
       //...
   }
  @ApiOperation(notes = "Operation 2", value = "${SomeController.operation2.value}"...)
  @ApiImplicitParams(
      @ApiImplicitParam(name="header1", value="${SomeController.operation2.header1}", ...)
  )
  @RequestMapping(value = "operation2", method = RequestMethod.POST)
  public ResponseEntity operation2() {
     return ResponseEntity.ok("");
  }

```

_from [springfox 공식 문서](https://springfox.github.io/springfox/docs/current/)_

\- 이걸 더 복잡하다고 생각하시는 분들도 계시겠지만, 저는 별도의 openapi.yml 파일을 직접 관리하는 것보다 더 좋았다고 느꼈습니다.

\- springfox 에서 webflux, Kotlin 에 대한 대응이 늦는 등의 문제가 있어서 최근에는 [springdoc](https://springdoc.org) 을 더 많이 사용하는 추세라고 하네요.

여기까지 제가 생각한 'Spring 이 Rails 에 비해 더 강점인 부분들' 을 정리해봤습니다.

* * *

## 다른 이야기

### 생산성

\- Rails 는 생산성이 좋은 Web Application Framework 로 유명합니다. Spring 진영에서도 Spring Boot 가 나온 이래로 생산성은 Rails 못지 않다고 생각합니다. 단순히 생산성 측면 때문에 Spring 이 아니라 Rails 를 선택하는 일은 더 이상 존재하지 않는다고 생각합니다.

\- 오히려 IDE 에서 제공하는 강력한 기능과 관련해서는 static typing 을 하고 있는 언어인 Java, Kotlin 을 사용할 때가 더 유리하다고 생각합니다.

### Case convention

\- Ruby 는 snake\_case 를, Java 에서는 camelCase 를 변수명, 메소드명을 지을 때의 관례로 사용하고 있습니다.

\- 개인적으로는 snake\_case 보다 camelCase 가 가독성이 더 좋다고 생각하기도 하며, snake\_case 를 사용할 때는 언더스코어라는 문자를 하나 더 입력해야하기 때문에 변수명, 메소드명이 좀 더 길어질 수 있는데 사소하지만, 언더스코어 문자 때문에 길어지는 것 자체는 다소 불편하다고 생각했습니다.

## 마무리

이전에는 Rails 만이 갖고 있던 강점들이 두드러졌으나, 시간이 지나면서 Spring 진영이 매우 빠른 속도로 진보하여 Rails 의 강점이 더 이상 Rails 만의 강점이라고 하기 어려워 진 것 같습니다.

하지만 Ruby on Rails 도 Spring 만큼 성숙한 Framework 이며 오픈소스 커뮤니티만으로도 지속적인 진보를 이뤄내고 있습니다.

지금 저희 개발팀은 Ruby on Rails로 리멤버라는 서비스를 빠르고 안정적으로 서비스를 확장해나가고 있습니다.

Spring 을 했다가 지금은 Rails 로 개발하고 있는 저로서는 **Rails 도 만족스러운 Framework 이며 실제로 저희 개발팀 내부 설문조사에서도 만족도가 높다는 결과가 나왔습니다.**

하지만 대규모 채용, 서비스 확장을 준비하는 과정에서 Spring Framework 등 새로운 기술 스택을 도입하는 것에 검토하고 있습니다.

새로운 기술 스택을 도입하려면 매우 큰 비용을 지불해야하는 일이기도 하고 단순히 개발자의 새로운 것에 대한 호기심/갈망만으로 새로운 기술 스택 도입을 하는 실수를 범하지 않기 위해 신중히 논의중에 있습니다.

팀에서 필요성에 대한 공감대가 충분히 형성되면 머지 않은 미래에 점진적으로 도입을 시도해볼 것이라 예상해봅니다.

**Rails 에 대한 경험이 없는 개발자들도 Rails 로 개발해보며 강점들을 느껴보면 시니어 개발자가 되기 위한 시야와 지식의 폭이 더 넓어지지 않을까요?**

읽어주셔서 감사합니다.
