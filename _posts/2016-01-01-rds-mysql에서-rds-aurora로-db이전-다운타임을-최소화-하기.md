---
layout: "post"
title: "RDS MySQL에서 RDS Aurora로 DB이전 다운타임 최소화 하기"
author: "devyrlee"
date: "2016-01-01"
categories: 
  - "develop"
---

얼마 전 저희 [리멤버](http://rememberapp.co.kr)의 DB서버 이전이 있었습니다. 기존엔 AWS RDS에서 MySQL을 사용하고 있었으나 AuroraDB로 서버 이전을 하였고, 손쉽게(?) 작업을 마무리 할 수 있었습니다. 이전을 할 때 데이터 소실없이 이전 하는 것이 첫 번째로 중요했고, 두 번째로 중요했던 건 서비스의 다운타임을 최소화 하는 것 이었습니다. 첫 번째로 중요했던 데이터의 소실 없이 이전 하는건 철저한 검증을 통해 확인과 복원을 하면 되었지만, 두번째 중요했던 다운타임 최소화 문제는 조금 난감했습니다. DB이전과 함께 여러가지 밀려있던 작업을 위해 주말 새벽 5시간의 서비스 다운타임을 이용자들에게 공지했고, 저희는 이 시간 안에 예정된 모든 작업을 끝내야 했습니다. 결과적으로 공지 했던 시간 보다 2시간을 단축해 3시간만에 모든 작업을 끝낼 수 있었습니다. DB이전 작업엔 거의 시간이 들지 않았으니까요.

DB이전을 할 때 다운타임을 최소화 하기 위한 방법은 놀라울 정도로 간단합니다.

1. RDS MySQL의 최신 스냅샷을 Migrate기능을 이용해 AuroraDB로 이전
2. Migrate하는 동안의 데이터 변경분처리. (AuroraDB를 Replica server로 활용)
3. 각 Applications에서 DB Endpoint를  AuroraDB의 Endpoint로 변경.

참 쉽죠? 2번에 대해 좀 더 정리해보자면, AuroraDB가 migrate되는 시간 동안 기존에 사용하던 MySQL DB에는 계속 데이터가 변경되고, 쌓여가고, 사라지고 있을 겁니다. Migrate하는 시간 동안의 데이터 Gap은 AuroraDB의 Migrate작업이 완료 된 후 이를 MySQL Master DB의 replica server화 하여 두 서버간 데이터의 동기화 합니다.

사실, AWS에서 이러한 방법에 대해 도큐먼트를 제공하고 있긴 하지만 자세한 방법까지는 다루고 있지 않기 때문에 이 글에서는 조금 전 설명드린 과정에 대해 그 방법을 풀어 볼 생각입니다.

### 0\. 시작하기 전에

본격적으로 서버 이전을 진행하기 전에 RDS의 MySQL에서 한 가지 설정을 바꿔주고 시작 해야 하는데, "binlog retention hours"라는 RDS의 configuration 값을 바꿔 주어야 합니다. AWS Console의 Parameter Groups의 항목이 아니기때문에 브라우저가 아닌 터미널을 열어서 MySQL에 Master계정으로 접속을 해 주세요. RDS MySQL은 기본적으로 binlog를 삭제하는 주기가 빠르기 때문에 AuroraDB에 Migrate하는 동안의 binlog는 기록되어 보관될 수 있도록 설정 값을 바꿔야합니다. 아래와 같은 프로시저를 호출 해주세요.

> call mysql.rds\_set\_configuration('binlog retention hours', 48);

혹시나 하는 마음에 binlog 보관 주기를 48시간으로 설정 했지만 24시간이면 충분 할 것 같습니다. **_위 설정을 변경하기 전 스토리지가 충분한지 확인 후 변경하시기 바랍니다._**

### 1\. AuroraDB 인스턴스 생성

우선 AuroraDB의 인스턴스를 생성해 보겠습니다. 생성 시 기존에 사용하던 MySQL Master DB의 최신 Snapshot을 이용해 AuroraDB로 Migrate합니다. MySQL MasterDB를 선택하고, 상단의 Instance Actions탭에서 "Take Snapshot"을 눌러 현재 시점의 스냅샷을 준비해주세요.

[![Migrate Lastest Snapshot](/assets/post/images/스크린샷-2015-12-09-오후-12.45.08.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-12.45.08.png)

스냅샷이 준비되었다면, "Migrate Latest Snapshot"를 눌러줍니다.

[![스크린샷 2015-12-09 오후 12.48.50](/assets/post/images/스크린샷-2015-12-09-오후-12.48.50.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-12.48.50.png)

다음과 같은 화면이 나오면 기본적인 설정을 해 줍니다. 기존 MySQL Master DB의 설정을 따라가기 때문에 DB Instance Identifier와 Availability Zone지정 외에 별다른 작업이 필요 없을 것 같습니다.

_**자, Migrate버튼을 누르기 전에 이쯤에서 정말 중요한 메모를 하나 할 것입니다.**_ 이 메모를 한 후 재빠르게 Migrate버튼을 눌러 AuroraDB인스턴스를 생성 할 겁니다. MySQL에 접속한 후 다음과 같은 명령어를 통해 binary log 정보를 확인합니다.  _**File과 Position을 잘 메모해 둡니다.**_

> SHOW MASTER STATUS;

[![스크린샷 2015-12-09 오후 6.11.10](/assets/post/images/스크린샷-2015-12-09-오후-6.11.10.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-6.11.10.png)

확인 하셨나요? 그러면 재빨리 Migrate버튼을 눌러 인스턴스를 생성합니다.

[![스크린샷 2015-12-09 오후 12.58.16](/assets/post/images/스크린샷-2015-12-09-오후-12.58.16.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-12.58.16.png)

마이그레이션이 완료 되고 인스턴스가 생성될 때 까지 잠시(?) 기다려 줍니다. [아마존 블로그](https://aws.amazon.com/ko/blogs/aws/now-available-amazon-aurora/)의 문구를 인용해보자면, 소요되는 시간은 대략 다음과 같습니다.

> a coffee break might be appropriate, depending on the size of your database

데이터 용량에 따라 걸리는 시간이 다르겠지만, 커피 한잔 즐길시간이면 될 것이라 하니 한 30분정도 기다려 봅니다. 사실 전 커피 한잔 마시는데 10분이면 되는데 말이죠.

1시간 더 기다려 봅니다.

1시간 더 기다려 봅니다!!

1시간 더 기다려 봅니다!!!!

**1시간 더 기다려 봅니다!!!!!!!!!!!**

드디어 되었군요. 4시간 반의 티 타임 끝에 AuroraDB 인스턴스가 준비되었습니다. 이 글을 읽으시는 분 들은 마이그레이션이 언제 완료되나 무작정 기다리지 마시고, "DB Cluster Details"탭의 "Migration Progress"를 참고하시면 현재 진행 상황을 자세하게 알려주니, 저처럼 무작정 기다리지 않으셔도 될 것 같습니다.(있는 줄 몰랐습니다..)

[![스크린샷 2015-12-09 오후 4.19.13](/assets/post/images/스크린샷-2015-12-09-오후-4.19.13.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-4.19.13.png)

AuroraDB 인스턴스가 준비되었다면, 다음 단계로 넘어가도록 하겠습니다.

### 2\. VPC 설정

앞서 생성 한 AuroraDB를 MySQL의 Replica DB로 구성하기 위해선, AuroraDB가 MySQL에 접근할 수 있도록 VPC설정이 필요합니다.

먼저, AuroraDB의 IP를 확인합니다. AuroraDB의 Endpoint를 확인 한 후 console에서 host명령을 이용해 IP를 확인할 수 있습니다.

> $ host \[aurora-db-end-point\]

IP를 잘 적어둔 후, RDS Instances 콘솔에 접속한 후 MySQL의 Security Groups에서 사용하고 있는 해당 그룹 링크를 클릭합니다.  이동 한 Security Groups에서 해당 그룹을 선택한 후 상단 Actions탭의 "Edit inbound rules"를 클릭합니다.

[![스크린샷 2015-12-09 오후 5.29.29](/assets/post/images/스크린샷-2015-12-09-오후-5.29.29.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-5.29.29.png)

창이 열리면, "Add Rule"를 해 Row하나를 추가 한 후 Type은 "_**All traffic**_"으로 지정하고, 아까 적어 둔 AuroraDB의 아이피를 다음과 같이 적어줍니다. "1.1.1.1/32" (DB 이전을 완료 한 후에는 방금 추가한 Rule을 삭제해 주세요.)

[![스크린샷 2015-12-09 오후 6.06.52](/assets/post/images/스크린샷-2015-12-09-오후-6.06.52.png)](https://blog.dramancompany.com/wp-content/uploads/2015/12/스크린샷-2015-12-09-오후-6.06.52.png)

이제 VPC 설정은 다 되었습니다.

### 3\. MySQL에 Replication전용 계정 추가

이제 AuroraDB가 MySQL에 Replication을 위해 접근할 계정을 만들도록 하겠습니다. (DB 이전을 완료 한 후 방금 추가한 계정은 삭제를 해 주세요.)

> CREATE USER 'repl\_user'@'%' IDENTIFIED BY 'yourpassword';

계정을 추가한 후 replication 권한을 부여합니다.

> GRANT REPLICATION CLIENT, REPLICATION SLAVE ON \*.\* TO 'repl\_user'@'%' IDENTIFIED BY 'yourpassword';

### 5\. Replication설정 및 시작

이제 마지막 입니다. RDS에서 제공하는 procedure를 사용해 replication설정을 마무리 할 것입니다. 우선 MySQL의 Endpoint와 앞서 메모해 두었던 binlog의 "File"과 "Position"을 이용해 프로시저에 파라미터를 채워줍니다. AuroraDB에 접속한 후 아래의 명령을 수행합니다.

> CALL mysql.rds\_set\_external\_master('mysql end point', 3306, 'repl\_user', 'yourpassword', 'mysql-bin-changelog.188412', 788, 0);

external master설정을 마치셨으면 이제 복제를 시작하겠습니다.

> CALL mysql.rds\_start\_replication;

### 6\. Replica Error 처리하기

무사히 Replication 설정까지 마쳤으나 한가지 시련이 남았습니다. 복제 설정이 완료 된 AuroraDB에 접속해 "show slave status"라는 질의를 해 보시기 바랍니다. 정말 운이 좋다면 에러 없이 정상적으로 리플리케이션이 진행중일 테지만 십중 팔구는 에러가 발생해 리플리케이션이 중단 된 상태 일 것입니다. 1번 과정에서 인스턴스 생성 시 메모해 두었던 Binlog의 위치 정보가 유효하지 않기 때문에 발생한 에러인데, MasterDB의 정확한 스냅샷 시점과 맞지 않아 발생하는 문제입니다. 이를 해결하기 위해서 조금 야매(?) 스럽지만 한번 헤쳐나가 보겠습니다.

> call mysql.rds\_skip\_repl\_error;

위와 같은 프로시저를 slave 에러가 발생하지 않을 때 까지 실행해 주세요. 한 건 마다 에러발생 유무를 확인하고 실행하면 시간이 얼마나 걸릴지 모르기 때문에 저 같은 경우는 프로시저를 10,000번 수행하는 스크립트를 만들어서 돌렸습니다.  프로시저를 호출했는데 발생한 에러가 없는 경우는 그냥 PASS하니 저렇게 실행해도 괜찮을 것 같습니다. 다만, 에러 처리 완료 시점까지의 로그는 반드시 기록을 해 두고, 그 근처의 데이터들을 전수 조사하여 문제가 없는지 반드시 확인을 해야합니다. 아마 대부분의 경우 문제가 없을텐데, 문제가 있을 경우 해당 시점의 binlog파일을 열어 하나씩 정합성을 맞추어 주거나, 위 작업을 새로 시도를 하시는게 좋을 것 같다는 생각입니다.

### 마치며

MySQL에서 Aurora로 Migrate를 할 때 걸리는 4시간 반이 매우 부담스러운 시간이었습니다. DB이전만 할 게 아니라 이전 후에도 할 작업이 많았기 때문에 장시간의 다운타임이 필요했던 상황 이었지만 덕분에 4시간 반을 아낄 수 있었습니다. 다만, 주의 할 점은 Replication을 구성하기 전 binlog의 리플레이 시점을 잘 기록을 해 두셔야 합니다. 이 내용은 RDS MySQL to RDS AuroraDB에만 가능한 방법이 아니라 RDS MariaDB로 이전시에도 적용이 가능합니다.

### References

[Importing Data to an Amazon RDS MySQL or MariaDB DB Instance with Reduced Downtime](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Procedural.Importing.NonRDSRepl.html)

[Virtual Private Clouds (VPCs) and Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.html)

[Amazon Aurora – New Cost-Effective MySQL-Compatible Database Engine for Amazon RDS](https://aws.amazon.com/ko/blogs/aws/highly-scalable-mysql-compat-rds-db-engine/)
