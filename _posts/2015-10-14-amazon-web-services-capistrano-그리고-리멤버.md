---
layout: "post"
title: "Amazon Web Services, Capistrano 그리고 리멤버"
author: "Jaden"
date: "2015-10-14"
categories: 
  - "develop"
tags: 
  - "autoscaling"
  - "aws"
  - "capistrano"
  - "deploy"
  - "ruby"
  - "ruby-on-rails"
---

안녕하세요. 드라마앤컴퍼니 개발팀 Jaden입니다. 얼마전 리멤버 서버 배포과정을 개발팀 내에서 공유하는 시간이 있었습니다. 이때 소개했던 Capistrano와 Amazon Web Services(이하 AWS) 에서의 배포 과정을 공유 드리고자 합니다.

### 개발자와 피할 수 없는 숙명, 배포

모든 개발자에게 있어 개발과 배포는 떼려야 뗄 수 없는 관계입니다. 특히 서버의 경우엔 서비스 규모가 커짐에 따라 배포에 대한 부담이 커지기 마련입니다. 그리고 플랫폼에 따라, 사용하는 언어에 따라 배포 방법도 천차만별입니다. 리멤버 서버는 Ruby on Rails(이하 ROR) 기반으로 개발되었는데요. ROR에서는 Capistrano라는 아주 유용한 배포툴이 있습니다. 이에 대해 자세히 알아보기 전에 먼저 다음 배포 시나리오를 보셨으면 합니다.

지금 우리가 배포하려는 서버는 다음과 같은 구조를 가지고 있다고 가정합니다.

[![서버구조](/images/8yVXHQuTvF.png)](https://blog.dramancompany.com/wp-content/uploads/2015/09/스크린샷-2015-09-25-14.42.22.png)

이와같은 구조에서 배포를 할 경우 일단 ELB 구성이 되어 있으므로 다음과 같은 순서로 무중단 배포는 가능합니다.

1. instance-1을 LoadBalancer에서 제외
2. 제외한 서버에서 서비스 종료
3. 업데이트된 코드 배포 및 필요 할 경우 추가 작업
4. 서비스 재시작
5. 다시 instance-1을 LoadBalancer에 추가
6. 이와 같은 과정을 나머지 인스턴스에 대해 반복

1대의 인스턴스에 배포하는 과정은 그다지 어렵지 않지만, 배포 할 인스턴스 수가 증가 할 수록 실수에 대한 위험과 배포하는 사람에 있어서도 부담과 피로도가 증가 합니다. 그리고 만일 하나 배포에 문제가 생겼을 경우 다시 롤백하는데도 어려움이 있습니다.

그래서 좀더 안정적이고 쉬운 배포를 위해 다음과 같이 구성을 해봅시다.

[![](/images/EC5JG2mg9L.png)](https://blog.dramancompany.com/wp-content/uploads/2015/09/스크린샷-2015-09-25-16.17.37.png)

AWS에서는 훌륭한 Auto Scaling 서비스를 무료로 제공하고 있습니다. Auto Scaling은 쉽게말해 **Amazon Machine Image(이하 AMI)**를 설정한 조건에 따라 인스턴스를 늘리거나 줄이는 일을 합니다. 여기서 제가 주목하는 점은 'AMI'입니다. AMI는 말 그대로 머신 이미지를 말하는데 이를 이용하면 AMI를 생성하기 위한 서버 1대만 있으면 이를 이용해 이미지를 생성한 후 똑같은 서버를 원하는 만큼 생성할 수 있습니다.

이를 이용하면 만약 신규 배포 후 문제가 생겼을 경우 바로 이전에 사용하던 AMI 이미지로 교체만 해주면 되기 때문에 롤백에 대한 대처도 쉬워집니다.

 

### 쉬운 배포, Capistrano

> #### Capistrano is a remote server automation tool.

공식 문서에 적혀 있는데로 Capistrano는 원격 서버 자동화 도구입니다. 이에 대해 알아보기 전에 제가 리멤버 서비스를 오픈하기 위해 처음으로 배포 했을때를 이야기 해 드려야 할 것 같습니다. 저희는 코드관리를 처음부터 github을 이용했습니다. (그리고 좀 더 쉽고 효과적인 branch 관리를 위해 [git flow](http://nvie.com/posts/a-successful-git-branching-model/)를 사용했습니다.) 테스트가 끝난 최종 코드를 master에 merge를 하고, 미리 세팅 해 놓은 서버에 git pull을 받은 후 설정을 마치고 1차로 전 직원이 다시한번 내부 테스트를 진행하였습니다. 모두 테스트에 문제가 없다고 생각한 후 미리 등록해둔 안드로이드 앱을 Google Play Console에서 릴리즈 하였는데요. 다시 생각해도 이때의 감정은 말로 다 표현 할 수 없을 것 같습니다.

여담이 좀 섞였지만, 핵심은 서비스 오픈 초반만 해도 배포할 서버가 1대였고 접속자가 많지 않았기 때문에 이와 같은 방법에 큰 불편함이 없었습니다. 하지만 점차 이용자가 많아짐에 따라 서버 대수가 늘어나가 되었고 이에 따라 배포할 때 매번 각 서버에 접속해서 똑같은 작업을 해야 했고, 혹시라도 문제가 생겼을 경우 다시 각 서버에 들어가 수정 또는 롤백을 해야 했습니다. 그리고 가능한 무중단 배포를 지향 하면서 더 이상은 이 방법으로 안되겠다는 결론이 났고, 많은 ROR 개발자들이 추천하는 Capistrano를 이용하기로 결정했습니다.

아래는 현재 리멤버 서버 배포시 구성을 간략히 그려보았습니다.

[![]({{ site.baseurl }}/images/ShCmmzxgrH.png)](https://blog.dramancompany.com/wp-content/uploads/2015/09/스크린샷-2015-09-30-12.14.13.png)

AMI 생성용 서버에 Capistrano를 이용해 배포 후 AWS web console에서 설정만 해주면 쉽게 모든 서버 업데이트를 마칠 수 있도록 되어 있습니다. 그럼 Capistrano를 어떻게 설치하고 설정 하는지 알아보도록 하겠습니다.

### Capistrano 설치부터 배포까지

설치는 독립 Gem으로 설치하여 사용하거나 Rails project Gemfile에 추가한 후 **bundle install** 명령어로 설치 할 수 있습니다. 사용 방법은 두가지 모두 같으니 여기서는 독립 Gem 설치 기준으로 알려드리겠습니다.

```
$ gem install capistrano
```

간단하죠? 그 다음 아래 명령어를 실행하면 관련 파일들이 추가됩니다.

```
$ cap install
```

```
├── Capfile
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

아래 2개의 파일은 배포하는데 있어 반드시 설정이 필요합니다.

```
# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'remember' # 프로젝트 이름
set :repo_url, 'git@dramancompany.com:jaden/remember.git' # 저장소 주소

# 브랜치, 기본값 :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# 배포 경로, 기본값 /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# 소스코드관리, 기본값 :git
# set :scm, :git

# 포맷, 기본값 :pretty
# set :format, :pretty

# 로그 레벨, 기본값 :debug
# set :log_level, :debug

# Pseudoterminal, 기본값 false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

```

```
set :branch, :master
set :rails_env, :production
set :deploy_to, '/home/ec2-user/server'

server '0.0.0.0',
  user: 'ec2-user',
  roles: %w{app},
  ssh_options: {
    user: 'ec2-user',
    keys: %w(~/.ssh/id_rsa ~/cert/aws.pem),
    auth_methods: %w(publickey)
  }
```

저장소 주소, 서버 IP등 세부 설정 항목은 사용 환경에 따라 수정해 주셔야 합니다. 저희같은 경우 서버가 test, stage, final, production 이렇게 4개의 서버가 있어 공통 설정은 **config/deploy.rb** 파일에서 해주었고, IP, branch, 배포경로 등 서버마다 값이 다른 것들은 **config/deploy/\[STAGE\].rb** 파일에서 설정해주었습니다.

이렇게 해서 Capistrano를 사용하기 위한 최소한의 설정이 끝났습니다. 그럼 이제 서버에 배포해 봐야 되겠죠? 일단 다음 명령어를 통해 지금까지 설정한 사항들이 이상 없는지 확인 해봅니다.

```
$ cap production deploy:check
INFO [fd7165b1] Running /usr/bin/env mkdir -p /tmp/remember/ as ec2-user@0.0.0.0
...
INFO [18830886] Finished in 0.240 seconds with exit status 0 (successful).

```

이상이 없으면 실제로 배포를 합니다.

```
$ cap production deploy
INFO [f93823c2] Running /usr/bin/env mkdir -p /tmp/remember/ as ec2-user@0.0.0.0
...
INFO [4856654e] Finished in 0.265 seconds with exit status 0 (successful).
```

맨 마지막에 sucessful을 보셨나요? 그렇다면 배포에 성공한 것입니다. log\_level을 debug로 했을 경우 좀더 상세한 로그를 볼 수 있습니다. Capistrano가 실행하는 명령어가 모두 표시되니 무슨 작업이 현재 진행되고 있는지도 알기 쉽습니다. 이제 배포된 서버에 접속해서 보시면 다음과 같은 구조로 배포가 이루어 졌음을 확인할 수 있습니다.

```
├── current -> /home/ec2-user/server/releases/20150120114500/
├── releases
│   ├── 20150080072500
│   ├── 20150090083000
│   ├── 20150100093500
│   ├── 20150110104000
│   └── 20150120114500
├── repo
│   └── <VCS related data>
├── revisions.log
└── shared
    └── <linked_files and linked_dirs>
```

- **current** : 최근 릴리즈를 가리키고 있는 symlink입니다. 배포에 성공될 경우에만 해당 릴리즈로 갱신됩니다.
- **releases** : 배포되었던 모든 버전이 저장되어 있습니다. rollback 실행시 current는 이곳에 있는 이전 버전의 릴리즈를 가리키게 됩니다.
- **repo** : 저장소와 관련된 설정들이 저장되어 있습니다.
- **revisions.log** : 모든 배포 또는 롤백에 대한 로그입니다.
- **shared** : 설정파일에서 linked\_files와 linked\_dirs를 추가했다면 이곳에 해당 파일들이 있어야 합니다. 이곳에 있는 파일들이 symlink 됩니다.

그러나 아무리 배포 준비를 열심히 했다고해서 문제가 없을 수는 없습니다. 문제가 생겼을때 우리는 배포 했던 코드를 빠르게 이전 버전으로 복구해야 합니다. capistrano 역시 rollback 기능을 제공합니다. rollback 역시 간단히 아래 명령어로 할 수 있습니다.

```
$ cap production deploy:rollback
INFO [a0b8018a] Running /usr/bin/env mkdir -p /tmp/Remember/ as ec2-user@0.0.0.0
...
INFO [c1d94609] Finished in 0.343 seconds with exit status 0 (successful).

```

rollback 되는 코드는 배포 경로에 tar 파일로 저장되고 기본적으로 직전 릴리즈 코드로 복구 되며 옵션을 통해 특정 리비전으로 복구할 수 도 있습니다.

여기까지 배포와 롤백하는 방법에 대해서 알아 보았습니다. 하지만 Capistrano는 이뿐만 아니라 다른 많은 작업이 가능합니다. 예를 들어 다음 코드는 배포 후 자동으로 **bundle install**을 실행하는 코드입니다.

```
task :bundle do
  on roles(:app) do
    within release_path do
      execute :bundle, 'install'
    end
  end
end

after :deploy, :bundle
```

이 코드를 추가하면 배포 후 자동으로 배포경로에서 **bundle install**을 실행하게 됩니다. 물론 bundle install 같은 것은 이렇게 직접 구현하지 않고 [capistrano-bundler](https://github.com/capistrano/bundler/)와 같은 gem을 이용하셔도 됩니다. ruby 답게 capistrano와 관련된 유용한 gem들도 많으니 미리 찾아보고 사용한다면 직접 구현하는 수고를 덜 수 있습니다.

### 마지막으로

여기까지 AWS 구성부터 Capistrano를 이용한 배포방법을 소개해 드렸습니다. 더욱 자세한 사용 방법은 capistrano documentation에 자세히 설명되어 있습니다. 앞으로 Docker 또는 이를 지원하는 Amazon EC2 Container Service(ECS)를 이용하여 배포하는 방법도 고려 중입니다. 그럼 여기서 마치며 이 글이 배포에 대해 고민하시는 분들께 조금이라도 도움이 되었으면 좋겠습니다.

### 참고링크

[Capistrano](http://capistranorb.com/)

[AWS AutoScaling](http://docs.aws.amazon.com/ko_kr/AutoScaling/latest/DeveloperGuide/WhatIsAutoScaling.html)
