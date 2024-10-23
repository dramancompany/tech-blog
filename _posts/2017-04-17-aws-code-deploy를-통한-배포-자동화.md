---
layout: "post"
title: "AWS Code Deploy를 통한 배포 자동화"
author: "tom"
date: "2017-04-17"
categories: 
  - "develop"
tags: 
  - "aws"
  - "code-deploy"
  - "배포"
---

서버 배포는 단순하고 반복작업이지만 절차가 적지 않아 실수를 할 가능성이 높습니다. 또 한번의 실수는 커다란 시스템 장애로 이루어질 수 있기 때문에 많은 분들에게 배포란 꽤나 부담스럽고 큰 업무로 느껴집니다. 특히 하루에 여러번의 배포를 진행해야 하는 날이면 시간도 시간이지만 스트레스가 크죠.

드라마앤컴퍼니에서 이전까지는 서버 배포를 진행하는 개발자가 몇 없고 그들도 그 업무에 매우 익숙했기 때문에 큰 부담없이 진행할 수 있었지만, 배포를 진행해야 하는 개발자와 프로젝트의 수가 늘어남에 따라 배포로 인한 회사 전체의 업무 손실이 커졌습니다. 그래서 결국 계속 미뤄지던 배포 자동화의 첫 단계를 Code Deploy로 시작하기로 했습니다.

이번 글에서는 우선 Code Deploy가 생소한 분들을 위하여 개념을 쉽고 확실하게 설명드리고, 그 다음 최대한 삽질을 안하고 실제 적용을 하실 수 있도록 설명드리려고 합니다. 그리고 나서 저희는 어떻게 응용하여 사용하고 있는지, In-place와 새로 추가된 Blue/Green 배포 방식 등 이번에 알게 된 것들에 대하여 공유드리겠습니다.

 

# **1\. 개념**

Code Deploy를 정말 간단히 설명하면 다음과 같습니다.

> 서버에 코드를 자동으로 배포해주는 서비스

[https://aws.amazon.com/ko/codedeploy/](https://aws.amazon.com/ko/codedeploy/)

여기에 가보시면 친절한 설명 글과 멋져보이는 동영상 소개가 있습니다. 하지만 Code Deploy와 같은 개념이 생소하신 분들에게는 모호하게만 느껴질 수 있기 때문에 이 글에서는 천천히 설명드리려고 합니다.

 

Code Deploy를 이용할 경우 배포는 다음과 같이 이루어집니다.

1. 배포할 코드 준비
2. Code Deploy에게 특정 리비전의 코드를 배포해달라고 요청
3. Code Deploy가 미리 지정해놓은 설정에 따라 새로운 서버(EC2 instance) 준비
4. 새로운 서버에 설치되어있는 Code Deploy Agent 프로그램이 배포할 코드를 다운받음
5. 코드를 프로젝트 경로로 복사한 뒤 미리 정의된 스크립트 실행 (필요한 모듈, 라이브러리 설치 등등의 작업 수행)
6. 새로운 코드 준비가 완료되면 옛날 코드를 갖고 있는 서버들을 새로운 서버로 대체
7. 배포 끝!

![](/images/sds_architecture.png)

<[http://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)\>

큰 흐름은 위와 같고 각 프로젝트의 필요에 따라 여러 옵션들을 지원합니다.

- 코드를 Github에서 가져올지, S3에서 가져올지
- 기존에 실행되어있는 서버들에 배포를 진행(In-place deployment)할지 Blue/Green 방식으로 배포를 진행할지
- 실행되어있는 서버들이 여러개인 경우에 다양한 배포 전략 (한번에 하나씩 배포/절반씩 배포/전부 한꺼번에 배포)

이 외에도 AWS답게 많은 옵션들을 지원합니다.

 

그럼 저희가 Code Deploy를 도입하여 배포 과정이 어떻게 변경되는지 설명드리기 앞서 간략하게 저희의 배포 구조를 설명드리겠습니다. 드라마앤컴퍼니에서는 무중단 배포를 위하여 AWS Elastic Load Balancer(이하 ELB)와 AWS Auto Scaling Group(이하 ASG)을 이용한 Blue/Green 배포 방식을 사용하고 있습니다.

평소에는 클라이언트의 요청을 ELB에서 받고 1번 ASG로 요청을 보내줍니다. 배포를 하려고 하면 1번 ASG와 똑같은 크기와 설정을 갖는 2번 ASG를 만든 뒤에 ASG 내부에 새로운 코드를 갖고 있는 서버들을 추가합니다. 그리고 ELB에 새로 들어온는 요청들을 1번 ASG에서 2번 ASG로 보내게 하여 무중단 배포를 진행합니다.

[![](/images/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7-2015-09-25-16.17.37.png)](https://blog.dramancompany.com/wp-content/uploads/2015/09/스크린샷-2015-09-25-16.17.37.png)

기존에 저희가 사용하고 있던 운영 서버 배포 절차는 다음과 같습니다.

1. Github에 코드 push
2. AMI용 instance 실행
3. 코드 배포
4. 실서버 테스트
5. AMI용 instance 종료
6. AMI 생성
7. Lauch Configuration 생성
8. Blue/Green 방식의 배포를 위하여 현재 활성화되어있지 않은 ASG (B 그룹)의 설정 변경(lauch configuration, scheduled action 등)
9. B그룹에 instance들 추가
10. Instance가 모두 생성되어 준비되면 ELB를 B그룹에 연결
11. A, B 그룹 모두 동시에 request를 보내다가 문제가 없으면 A그룹의 ELB를 연결 해제
12. 모니터링을 진행하다가 문제가 없을 경우 A그룹의 instance 제거
13. A 그룹의 설정 변경 (scheduled action 등)

정말 세세하게 항목들을 나열해서 많긴 하지만... 실제로도 많습니다 😭

Code Deploy를 이용하여 배포를 진행하면 배포 단계는 다음과 같이 바뀌게 됩니다.

1. Github에 코드 push
2. AWS Code Deploy Console에서 새로운 배포 클릭
3. Git의 commit ID 입력
4. (자동으로) Auto Scaling Group 내부에 instance들이 하나씩 업데이트 되는 것을 지켜봄

매우 간단해졌죠?

 

# **2\. 실전**

[http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-codedeploy.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-codedeploy.html)

모든 과정은 이미 AWS에서 친절하고 자세하게 설명하고 있습니다. 이 글에서는 해당 문서에 숟가락만 얹어서 핵심 요약과 삽질 방지 팁을 알려드리도록 하겠습니다. 참고로 이 글은 Amazon Linux AMI, In-place 배포 방식을 기준으로 작성되었습니다.

 

## **2-1. Profile 등 기본 설정**

#### a. IAM User 생성

[http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-provision-user.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-provision-user.html)

사람이 하는 일을 프로그램이 대체하는 것이니 action을 대신하여 처리할 IAM user를 생성합니다.

 

#### b. Service Role 생성

[http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-service-role.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-service-role.html)

앞서 만든 user가 AWS의 모든 서비스에 접근가능하면 안되겠죠? user에게 부여할 role을 만들어서 접근 가능한 리소스들을 지정해둡니다.

 

#### c. IAM instance profile 생성

[http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html)

추후 해당 user가 Github이나 S3에서 코드를 가져올 때 필요한 profile을 생성합니다.

 

 

## **2.2 Instance 준비**

#### a. AMI용 instance 생성

앞으로 배포를 하게될 EC2 instance를 미리 만들어둬야 합니다. 새로운 instance를 생성할 때 IAM Role를 앞서 생성한 role로 지정해야 합니다. 그 다음은 이 instance에 Code Deploy를 연동하기 위한 환경을 구성해야 합니다.

 

#### b. Code Deploy Agent 준비

[http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent-install.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent-install.html)

서버가 실행됐을 때 우리가 지정한 코드를 불러와서 서버에 설치해주는 역할을 하는 Code Deploy Agent를 설치해둬야 합니다. Code Deploy Agent는 다음과 같이 동작합니다.

1. 서비스로 실행되어 서버가 시작될 때 같이 시작됨
2. 새로 배포할 코드가 있다면 사용자가 지정한 코드 리비전을 다운받아서 임시 폴더에 저장
3. 사용자가 정의해놓은 절차를 따라 script를 실행

Code Deploy Agent의 로그를 각 instance에서 보고 싶으시면 /var/log/aws/codedeploy-agent에서 확인할 수 있습니다.

 

#### c. Cloud Watch로 로그를 보내도록 처리

[https://aws.amazon.com/ko/blogs/devops/view-aws-codedeploy-logs-in-amazon-cloudwatch-console/](https://aws.amazon.com/ko/blogs/devops/view-aws-codedeploy-logs-in-amazon-cloudwatch-console/)

각 instance 내부에서 Code Deploy Agent의 로그를 볼 수 있습니다. 하지만 나중에 여러대의 서버에 배포를 진행하는데 문제가 생겼을 경우 모든 instance에 각각 들어가서 볼 수는 없겠죠? Cloud Watch로 모든 로그를 보내도록 처리합니다.

 

#### d. AMI 생성

준비가 완료된 instance를 이용하여 AMI 이미지를 생성합니다.

 

#### e. Launch Configuration 생성

Auto Scaling Group에서 새로운 instance를 추가할 때 어떤 instance를 생성할지 정의해놓는 launch configuration을 앞에서 만든 AMI 등을 이용하여 생성합니다.

##### Tip!

- 프로젝트 파일들이 존재해야 할 곳에는 배포될 파일과 같은 이름의 파일들은 모두 지워두셔야 합니다. dot-file(.으로 시작하는 파일들)까지도 잊지말고 지워주셔야 합니다! [http://docs.aws.amazon.com/ko\_kr/codedeploy/latest/userguide/troubleshooting-ec2-instances.html#troubleshooting-same-files-different-app-name](http://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/troubleshooting-ec2-instances.html#troubleshooting-same-files-different-app-name)
- 이 글을 쓰는 시점에서는 codedeploy-agent이 특정 버전 이하의 aws-sdk-core에서만 동작하도록 처리되어있어서 aws-sdk-core의 버전이 너무 높으면 다음과 같은 메시지와 함께 에러가 나는 경우가 있습니다. (_Plugin codedeploy could not be loaded: Unable to activate codedeploy-commands-1.0.0, because aws-sdk-core-2.8.4 conflicts with aws-sdk-core (~> 2.6.39)_) 이럴 경우 aws-sdk-core의 버전을 맞춰서 설치, 사용하면 됩니다.

 

## **2.3 Project 준비**

#### a. AppSpec.yml

[http://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)

Code Deploy Agent가 프로젝트 코드를 다운받은 뒤 서버에 제대로 설치할 수 있게 절차를 알려줘야 합니다.

해당 내용을 정의해두는 파일이 AppSpec.yml 파일입니다. 해당 파일은 크게 files, permissions, hooks 세 가지 section으로 나뉩니다.

##### **files**

Code Deploy Agent가 서버의 임시 폴더에 다운받은 코드 파일들을 서버의 어떤 위치로 이동할지 정의합니다. destination이 우리의 어플리케이션의 코드가 위치할 곳입니다.

##### **permissions**

우리의 코드가 서버에서 제 위치를 찾은 뒤 어떤 permission을 갖고 있어야할지 정의해주는 부분입니다.

##### **hooks**

코드만 제 위치에 둔다고 어플리케이션이 작동하지는 않겠죠? 필요한 라이브러리, 모듈 등을 업데이트 설치도하고 asset들도 precompile한다던지 다양한 일을 해야 합니다. 이런 작업들은 script들로 미리 정의해둔 뒤에 필요한 시점에 호출할 수 있게 정의합니다.

- hook 문서 [http://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html](http://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html)
- 예시 [https://github.com/awslabs/aws-codedeploy-samples](https://github.com/awslabs/aws-codedeploy-samples)

##### Tip!

- version은 무조건 0.0으로 고정해야 합니다. 실제 사용되는 값은 아니고 CodeDeploy에서 나중에 사용하려는 값으로 무조건 0.0을 입력하라고 하네요. 그러지 않을 경우 배포에 실패합니다.

 

#### b. Script

앞서 나온 AppSpec의 hooks 부분에서 호출할 스크립트들을 정의해둬야 합니다.

기호에 따라 두면 되겠지만 저는 project root에 scripts 디렉토리를 생성하여 내부에 shell script들을 작성해두었습니다.

저는 다음과 같은 script들을 사용합니다.

- 서비스 시작
- 서비스 중지
- 서비스 정상 설치 확인
    
    ```
    result=$(curl -s http://localhost:80/hello/)
    
    if [[ "$result" =~ "Success" ]]; then
        exit 0
    else
        exit 1
    fi
    ```
    
- Gem 설치
- 기타 등등

 

##### Tip!

- script 파일들은 실행 권한을 갖고 있는채로 Git에 업로드 되어야 합니다  chmod +x file\_name
- hook의 location은 프로젝트의 root 경로를 기준으로 상대 경로를 사용하면 됩니다.
- 해당 스크립트가 실행되는 경로는 프로젝트가 복사된 후의 경로가 아닌 Code Deploy Agent가 설치된 경로 입니다 /opt/codedeploy-agent. 따라서 프로젝트의 내부에 있는 파일들을 접근하고 싶으시다면 cd를 이용하여 디렉토리를 이동하시거나 절대경로로 사용하셔야 합니다
- script log 파일을 보면 script가 실행되면서 남긴 log를 볼 수 있습니다 /opt/codedeploy-agent/deployment-root/{deployment-group-ID}/{deployment-ID}/logs/scripts.log.

 

## **2.4 Auto Scaling Group 설정**

이제 배포할 Auto Scaling Group을 지정합니다. 기존에 사용하던 ASG를 사용하셔도 됩니다. 대신 launch configuration은 이번에 생성한걸로 지정해줘야겠죠? 만약 특정 EC2 instance에 바로 배포를 진행하는 거라면 따로 처리하지 않으셔도 됩니다.

 

## **2.5 CodeDeploy 설정**

CodeDeploy에서는 Application, Deployment group, Deployment 세 가지의 개념을 이해하셔야 합니다.

### a. Application

가장 상위 개념으로 CodeDeploy를 이용하여 배포를 진행할 프로젝트를 나타냅니다.

[![](/images/Screen-Shot-2017-04-14-at-11.14.02.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-04-14-at-11.14.02.png)

 

### b. Deployment group

같은 application 내에 어떤 종류의 배포인지를 나타냅니다. 예를 들면 test/production 등 환경일 수 있고 특정 Auto Scaling Group일 수 있습니다.

![](/images/Screen-Shot-2017-04-14-at-11.15.31.png)

생성 시 deployment type를 정할 수 있으며 배포할 대상(EC2, ASG 등)을 정할수도 있습니다.

![](/images/Screen-Shot-2017-04-14-at-11.16.50.png)

 

### c. Deployments

실제 배포 건을 나타냅니다.

[![](/images/Screen-Shot-2017-04-14-at-11.42.27.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-04-14-at-11.42.27.png)

 

## **2.6 배포**

이제 배포를 진행합니다. 어떤 application의 어떤 그룹에다가 어떤 commit을 배포를 진행할지 적습니다.

[![](/images/Screen-Shot-2017-04-14-at-12.03.26.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-04-14-at-12.03.26.png)

배포 이력에서 배포 진행 현황을 살펴볼 수 있고, 성공 여부도 볼 수 있습니다.

[![](/images/Screen-Shot-2017-04-14-at-12.03.51.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-04-14-at-12.03.51.png)

View Events를 통하여 각 hook 부분 당 얼만큼의 시간이 소요되었으며 현재 어떤 과정을 거치고 있는지 실시간으로 확인할 수 있습니다.

[![](/images/Screen-Shot-2017-04-14-at-12.04.41.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-04-14-at-12.04.41.png)

에러가 났을 경우에는 script 실행 중 어떤 로그를 발생하면서 에러가 났는지도 확인할 수 있습니다.

[![](/images/Screen-Shot-2017-03-30-at-11.04.59.png)](https://blog.dramancompany.com/wp-content/uploads/2017/03/Screen-Shot-2017-03-30-at-11.04.59.png)

 

##### Tip!

- CodeDeploy가 Rerouting traffic 단계로 넘어가기 전에 instance가 정상적으로 준비되었는지 확인하는 기준은 ELB의 health-check 경로입니다. 실제 instance에서 해당 주소를 호출했을 때 응답이 200으로 잘 오는지 확인하세요.

 

# **3\. 그리고**

## 3.1 In-place vs Blue/Green Deployments

2017년 1월에 In-place 배포 방법 외에 Blue/Green의 배포 방식이 추가되었습니다. ([https://aws.amazon.com/ko/about-aws/whats-new/2017/01/aws-codedeploy-introduces-blue-green-deployments/](https://aws.amazon.com/ko/about-aws/whats-new/2017/01/aws-codedeploy-introduces-blue-green-deployments/)) Blue/Green의 배포 방식을 진행할 경우 다음과 같은 이점들이 있습니다.

- 서버에 코드를 배포한 뒤 실제 요청을 받기 전에 테스트용 ELB 연결하여 테스트를 진행해볼 수 있습니다.
- 만약 새로 배포된 코드에 문제가 있을 경우, 요청을 예전 그룹으로 돌리기만 하기 때문에 재배포를 진행하는 것 보다 훨씬 빠르게 장애에 대응할 수 있습니다.
- 하나의 ASG에 3개의 서버가 떠있다고 가정했을 때, in-place 방식을 사용하면 최소 1대의 서버가 배포를 진행하느라 빠지기 때문에 나머지 서버들이 같은 양의 요청을 처리해야 합니다. 이는 장애의 위험을 증가시킵니다. Blue/Green 방식을 사용하면 기존의 3개는 요청을 처리하고 있고 새로운 3개가 추가되어 배포를 진행하기 때문에 이런 위험이 없습니다.

따라서 저희는 기존에 사용하기도 했던 Blue/Green 방식을 이용하여 배포를 하려고 했습니다. Blue/Green 배포 방식을 사용하면 하나의 Auto Scaling Group만 갖고 있어도 Code Deploy에서 자동으로 해당 ASG의 설정과 값들을 복사하여 배포를 진행합니다. 하지만 나온지 얼마 되지 않은 기능이라 그런지 다음과 같은 이유들 때문에 사용하기 힘들다고 판단하여 in-place 방식을 택했습니다.

- Auto Scaling Group의 description 탭에서 현재 이 Auto Scaling Group이 어떤 ELB에 물려있는지 확인해야 하는데, CodeDeploy로 생성된 그룹에서는 해당 ELB가 보이지 않습니다(마치 아무 ELB에도 연결되어있지 않는 것으로 보입니다). 실제로 요청은 올바르게 들어옵니다. ELB를 물렸다 빼는 일은 굉장히 자주 일어나는 일이기 때문에 이런 작동 방식은 문제를 일으킬 위험이 매우 높다고 판단되었습니다. (이는 AWS 문의 결과 정상이라고 합니다.)
- 하나의 ASG에 하나의 ELB밖에 연결할 수 없습니다. (이는 AWS에 문의 결과 인지하고 있으며, 개선을 고려하고 있다고 합니다.)
- 하나의 서버에 하나의 프로젝트밖에 배포할 수 없습니다. Blue/Green의 로직 상, 아무런 소스코드도 깔려있지 않은 AMI로 만든 깡통 인스턴스가 실행되고 거기에 프로젝트를 배포하는 것이기 때문에 하나의 서버에 여러 프로젝트를 배포할 수 없습니다. (이도 AWS에 문의 결과 인지하고 있으며, 개선을 고려하고 있다고 합니다.)
- 새로 생성된 ASG은 임의의 이름으로 생성되기 때문에, CloudWatch alarm을 새로 만들어야 하고 CloudWatch dashboard에 새로 추가해야 합니다(..). 따라서 배포를 할 때마다 Scaling Policy를 위한 알람을 다시 매번 만들어주고 CloudWatch dashboard에 계속 추가하고 예전 그룹을 제거해줘야 합니다(...).

위 내용은 글이 작성된 시점 (2017년 4월)에 확인된 내용이니 미래에는 바뀔 수 있습니다.

 

## 3.2 In-place 방식으로 Blue/Green 배포 진행하기

위의 이유 때문에 어쩔 수 없이 in-place 방식을 택했습니다만, 기존까지 사용했던 Blue/Green의 이점도 포기하기 힘들었습니다. 따라서 조금 더 수작업이 들어가더라도 배포 방식을 약간 더 변경했습니다.

- 기존처럼 ASG를 2개 만들어 둡니다.
- 새로 배포할 그룹에 배포를 in-place로 배포합니다.
- 테스트용 ELB를 물려서 테스트를 진행한 뒤 문제가 없을 경우 새로 배포된 그룹에 ELB를 물리고, 이전 그룹에서는 ELB를 제거합니다.

ELB를 직접 관리해야한다는 번거로움은 있지만, 가장 불편한 AMI, Launch configuration 생성 과정은 생략할 수 있고 Blue/Green의 이점을 가져올 수 있기 때문에 이 방법을 택하기로 했습니다.

 

## 3.3 또 할 수 있는 것

- 이걸로 배포 자동화의 첫 단추를 끼웠습니다. 앞으로 Code Pipeline, Code Build 등와 연동하여 완성된 Continuous Delivery를 맞춰나갈 계획입니다.
- 예를 들면 Github webhook을 통해서 특정 branch에 배포가 이루어지면 자동으로 배포를 진행할 수 있습니다. 또한 Travis CI와 같은 CI tool들을 이용하신다면 빌드, 테스트가 성공적일 경우에 자동으로 배포를 진행할 수 있습니다. 테스트 서버와 develop branch를 연결해두면 참 편리하겠죠?
- 배포 상태(진행, 성공, 실패 등)에 대하여 SNS를 통해 이메일, Slack 등으로 알림도 받아볼 수 있습니다.
- 이 글에서는 Amazon Linux, Ruby 언어를 기준으로 배포를 진행했지만 Windows 등 다른 OS를 지원하고 코드의 언어에 전혀 종속적이지 않습니다.
