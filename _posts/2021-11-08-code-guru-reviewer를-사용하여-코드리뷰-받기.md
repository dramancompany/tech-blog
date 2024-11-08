---
layout: "post"
title: "CODE GURU REVIEWER를 사용하여 코드리뷰 받기"
author: "sj.sa"
date: "2021-11-08"

tags: 
  - "aws"
  - "code-review"
  - "개발문화"
  - "코드리뷰"
---

안녕하세요. 리멤버 서버/웹 팀 서버 개발자 사승준입니다.

얼마 전에 AWS에 CodeGuru라는 기능이 새롭게 나왔습니다.

Amazon CodeGuru는 코드 품질을 높이고 애플리케이션에서 가장 비경제적인 코드 줄을 찾아낼 수 있도록 지원하는 권장 사항을 제공하는 지능형 개발자 도구입니다. CodeGuru 기능 안에서도 프로덕션에서 애플리케이션을 모니터링하여 CPU를 많이 차지하고 있는 메서드, latency가 오래 걸리는 등 비경제적인 코드를 찾아내는 CodeGuru Profiler와 기계 학습 및 자동화된 추론을 사용하여 애플리케이션 개발 중 심각한 문제, 보안 취약성 및 찾기 힘든 버그를 식별하고 코드 품질을 높일 수 있도록 코드리뷰를 제공하는 CodeGuru Reviewer가 있는데요. 이 글에서는 CodeGuru Reviewer에 관해서 이야기해보려고 합니다.

## **CodeGuru Reviewer는 어떤 기능인가요?**

**기계 학습 및 자동화된 추론, AWS 및 보안 모범 사례, 그리고 수천 개의 오픈 소스 및 Amazon 리포지토리에서 수백만 건의 코드 검토을 통해 학습한 트레이닝 데이터 기반으로 코드 리뷰를 자동화합니다. 코드에서 찾기 어려운 결함과 취약성을 탐지하고 코드 품질 개선을 위해 실행할 수 있는 권장 사항을 제공합니다.**

위 설명은 AWS에서 공식적으로 설명하고 있는 내용입니다. 나와 있는 것처럼 말 그대로 코드 리뷰를 자동화해주는 기능입니다. 기계학습을 한 똑똑한 프로그래밍 언어의 전문가가 한 명 더 있어 Pull Request 단계에서 코드 리뷰를 해준다고 생각하시면 됩니다. 현재는 Java와 Python만 지원하고 있습니다.

![AWS CI/CD pipeline with CodeGuru & UnitTest - DEV Community](/images/125892722-da641d48-e54a-4f4e-8303-8b09d99167bf.png)

## **왜 필요한가요?**

대부분의 모든 개발자는 기능을 머지하기 전 버그, 코드 퀄리티 등의 이유로 리뷰를 진행합니다. 저희 팀에서도 기능을 개발하고 나면 슬랙을 통해 적극적으로 코드 리뷰를 요청하고 있는데요.

[![]{{ site.baseurl }}/images/cy6jbxh9F7.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/리뷰_요청.png)

CodeGuru Reviewer를 사용했을 때 제가 생각하는 장점은 아래와 같습니다.

### **1\. 수백만 개의 코드 검토를 한 기계 학습의 리뷰**

개발하면서 좋은 코드를 개발하기 위해 다들 노력하지만, 이 코드가 Best Practice인지 판단을 명확하게 하지 못하는 경우가 많습니다. 하지만 이 기능은 수천 개의 오픈소스 및 Amazon 리포지토리에서 수백만 개의 코드를 기계 학습하였고 앞으로도 더 많은 코드를 학습할 것이기 때문에 CodeGuru Reviewer가 리뷰해주는 게 100% 정답은 아니겠지만 정답에 가까운 권장 사항을 남겨줄 수 있습니다.

### **2.** **코드 기능의 정확성 및 결함을 찾기 어려운 부분을 보완**

보통의 코드 리뷰를 할 때는 비즈니스 로직에 대한 피드백이 많다고 생각합니다. CodeGuru Reviewer는 프로그래밍 언어의 전문가가 있는 거와 다름이 없으므로 기능의 정확성 및 결함 측면의 초점을 둔 리뷰를 받을 수 있습니다.

알고리즘 및 비즈니스 로직에 대한 리뷰는 CodeGuru Reviewer에서 하지 않습니다.

### **3\. 보안 취약성 해결**

프로덕션에 보안이 취약한 코드가 배포가 나가기 전에 예방하는 게 가장 좋겠지만 자신이 짠 코드가 보안 취약성이 있는지 확인하기에는 어렵다고 생각합니다. 하지만 이 기능을 사용하면 해소할 수 있습니다. CodeGuru Reviewer는 보안 탐지기가 있어서 KMS, EC2 API, Java 암호화, 웹앱 보안취약점 등 보안 문제에 관한 모범 사례를 따르는지 확인 후 문제가 있을 때 권장 사항을 알려줍니다.  
  
AWS의 보안 경험을 바탕으로 코드 보안을 개선한다고 합니다.

## **어떤 것들을 리뷰해주나요?**

AWS 공식 문서에 따르면 대표적으로 다음과 같은 항목에 대해서 리뷰를 해준다고 합니다.

- **AWS 모범 사례(AWS API의 올바른 사용, 오래된 API를 사용하는지 등)**
- **동시성**
- **보안 분석**
- **리소스 누출**
- **민감한 정보 유출(키값이 코드에 하드코딩 되어있는지 등)**
- **코딩 모범 사례**
- **리팩토링**
- **입력 유효성 검사**
- **코드 유지보수 감지 (메서드 라인 수, 불필요하게 다른 모듈을 불필요하게 많이 호출하는지 등)**

## **실습**

해당 내용은 결함이 있는 코드를 이미 브랜치에 push 했다고 가정하고 진행합니다. CodeGuru Reviewer를 테스트하기 위해 AWS에서는 Sample App를 제공합니다. 만약 해당 기능을 사용하는데 테스트할 리포지토리가 존재하지 않는다면 아래 링크의 리포지토리를 fork 하여 테스트해 보시면 좋을 것 같습니다.

**참고: 아래 실습도 Sample App를 기반으로 작성하였습니다.**  
[https://github.com/aws-samples/amazon-codeguru-reviewer-sample-app](https://github.com/aws-samples/amazon-codeguru-reviewer-sample-app)

### **1\. 리포지토리 연결**

CodeGuru 서비스에 들어간 후 Reviewer → Repository 탭에 들어간 후 리포지토리 연결 버튼을 눌러줍니다.

[![]{{ site.baseurl }}/images/04rxbBI42m.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/레포지토리-연결전.png)

현재는 BitBucket, CodeCommit, Github, Gihub Enterprise Sever 총 네 가지의 소스 공급자를 제공하고 있습니다. 자신에게 맞는 소스 공급자를 선택 후에 연결 버튼을 눌러줍니다.

실습에서는 Github 기준으로 작성하였습니다.

[![]{{ site.baseurl }}/images/rzkdcKr8mA.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/레포지토리-연결.png)

연결되기까지는 평균 1분 정도의 시간이 걸리며 아래와 같이 연결된 걸 확인하실 수 있습니다.

[![]{{ site.baseurl }}/images/qMrFdeD029.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/연결완료-사진.png)

### **2\. Pull Request 생성**

연결이 완료된 후 Pull Request를 생성합니다. CodeGuru Reviewer에 레포지토리를 연결하면 해당 Pull Request 요청 알림을 구독합니다. 개발자가 Pull Request 요청했을시 요청 알림이 CodeGuru Reviewer로 전송되고 해당 서비스를 스캔 후 분석합니다.  

[![]{{ site.baseurl }}/images/RqfMLJF23n.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/image.png)

### **3\. 리뷰 확인**

리뷰가 달리기까지에는 코드의 양에 비례해서 시간이 소요되겠지만 평균 5분 정도 걸린다고 합니다. 분석이 완료되면 아래 사진에 보시는 것과 같이 Lamda 함수의 성능을 향상하게 하기 위한 방법이나 AWS의 오래된 API를 사용하지 말라는 등 문제가 될 수 있는 코드에 리뷰가 달린 걸 확인하실 수 있습니다.

[![]{{ site.baseurl }}/images/EEYpPSxB3b.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/코드그루_리뷰1.png)[![]{{ site.baseurl }}/images/566mN5JZTo.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/코드그루_리뷰2.png)

Github의 Pull Request 말고도 CodeGuru Reviewer에 코드 검토 탭에서도 리뷰 결과를 확인하실 수 있습니다.

[![]{{ site.baseurl }}/images/vpW4PjoRWg.png)](https://blog.dramancompany.com/wp-content/uploads/2021/11/코드검토_탭.png)

## **마무리**

해당 기능을 사용할 때 여러모로 이점이 많아 보인다고 생각합니다. 앞으로도 계속해서 기계학습을 통해 더 발전된 리뷰를 남겨줄 수 있을 테고 위에 언급한 것처럼 팀 내에서 코드에 대해서 어떤 코드가 더 좋은 코드인지에 대한 고민이 있을 때 큰 도움을 줄 수 있을 것 같습니다.

완전히 해당 기능으로 사람이 하는 코드리뷰를 대체할 수는 없겠지만 리뷰에 대한 리소스와 부담을 줄일 수 있다고 기대합니다. Java나 Python을 사용한다면 사용 가치가 있을 것 같습니다.

## **참고**

- [](https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/welcome.html)[https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/welcome.html](https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/welcome.html)
