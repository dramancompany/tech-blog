---
layout: "post"
title: "리멤버 웹 서비스 좌충우돌 Yarn Berry 도입기"
author: "jongtaek.oh"
date: "2023-02-22"
categories: 
  - "develop"
tags: 
  - "frontend"
  - "yarn"
  - "yarn-berry"
  - "개발문화"
  - "리멤버"
  - "리멤버-웹"
  - "리멤버-채용"
  - "패키지-매니저"
  - "프론트엔드"
---

안녕하세요. 드라마앤컴퍼니에서 현재 채용 서비스를 개발하고 있는 웹 프론트엔드 개발자 오종택입니다. 이전에는 동료 분들의 비즈니스 임팩트를 극대화 하기 위한 UTS(User Targeting System, 조건에 맞는 유저를 찾아주는 쿼리 빌더) 등의 인터널 제품을 만들기도 했습니다.

리멤버 웹 팀은 리멤버 블랙, 리멤버 채용 솔루션 등 모든 서비스의 웹 애플리케이션을 개선 발전시키는 업무를 담당하고 있습니다. 이 과정에서 고객의 제품 경험을 개선하고, 이러한 개선 활동을 원활하게 지원할 수 있도록 팀의 생산성을 개선하는 일을 중요한 어젠다로 보고 있습니다.

최근에는 기존에 사용하던 패키지 매니저인 `yarn` 을 최신 버전인 `yarn berry` 로 마이그레이션 하기도 했습니다. 처음 `yarn berry` 라는 키워드를 접했을 땐, 빌드 시간을 일부 단축 시켜주고 개발 과정에서의 안정성을 높여줄 수 있다는 점에서 관심을 가지게 되었습니다.

새로운 기술은 이후에 일어날 수 있는 변화를 미리 생각해서 신중하게 도입해야 할 것입니다. 웹 파트는 지속적으로 기술을 습득하고 지식을 공유하며, 팀이 효과적으로 일할 수 있다고 판단한 기술은 빠르게 개념 증명(PoC)을 진행하여 기술의 이해도를 높여가고 있습니다.

현재 리멤버 웹 파트는 모노레포 도입을 준비하면서 `pnpm` + `Turborepo`([링크](https://turbo.build/)) 조합을 선택하게 되어 `yarn berry`는 사용하지 않게 되었습니다. 이러한 시도가 있었기에 프로덕션 레벨에서 패키지 매니저를 교체하면서 해당 기술에 대한 이해도를 높였고 이를 바탕으로 최종적으로는 가장 만족스러운 결론에 다다를 수 있었습니다.

이번 글에서는 리멤버 웹 서비스에 점진적으로 `yarn berry` 를 적용한 과정과, 트러블 슈팅 과정을 겪으며 느꼈던 점들을 공유드리고자 합니다.

## 1\. Yarn Berry를 써야 할 결심

<figure>

[![]{{ site.baseurl }}/images/J7YxaNmlSX.png)](https://blog.dramancompany.com/wp-content/uploads/2023/02/image-2.png)

<figcaption>

제로 인스톨로 탄소 감축 :가보자고:

</figcaption>

</figure>

여러 아티클을 살펴보니 `yarn berry` 를 사용하면 빌드 시간을 평균적으로 1분 정도 단축할 수 있는 것으로 보였습니다. 뿐만 아니라 종속성들을 보다 안전하게 관리하면서도 기존 node\_modules에 딸려오는 여러가지 골치 아픈 문제들을 근본적으로 해결할 수도 있을 것으로 봤습니다.

업무 기록을 살펴보니 유사한 고민이 과거에도 있었으나 당시 몇 명 없는 인원으로 운영되던 터라 개발 인프라 단에 리소스를 투자하기 어려운 상황이었기 때문에 우선 순위에서 밀렸던 것 같았습니다. 이제 그 때에 비해 프론트엔드 개발자도 늘었고, 개선 시 얻을 수 있는 임팩트도 커졌으니 명분도 충분했습니다. yarn berry 기술 자체도 처음 발표 때와 비교하여 어느 정도 관련 자료도 늘고 성숙해졌다는 판단 또한 있었습니다.

기존 리멤버의 웹 서비스는 yarn 1.x 버전의 패키지 매니저를 사용해왔습니다. 현재 yarn 1.x 버전은 classic 으로 명명되었으며, 새로운 기능 개발은 이루어지지 않고 유지보수만 이루어지는 레거시 프로젝트가 되었습니다. 즉, yarn classic을 사용하고 있는 상황이고, yarn berry냐 pnpm이냐 하는 선택지를 고민하는게 아니라면 점진적으로 berry로 마이그레이션하는게 바람직하다고 생각합니다.

(참고로 새 프로젝트를 만드는 시점이라면 `yarn init -2` 명령으로 간단하게 프로젝트를 생성할 수 있습니다. 해당 프로젝트에 대한 보다 상세한 정보는 [yarnpkg/berry](https://github.com/yarnpkg/berry) 에서 확인하실 수 있습니다.)

<figure>

![]{{ site.baseurl }}/images/EDMAWn61eP.png)

<figcaption>

yarn classic 레포지토리. 기능 개발이 중단되었음을 알리는 디스크립션이 붙어있다.

</figcaption>

</figure>

<figure>

![]{{ site.baseurl }}/images/Ufb6kj25eW.png)

<figcaption>

yarn berry 레포지토리. yarn classic과는 대조되는 'Active development' 문구가 붙어있다.

</figcaption>

</figure>

## 2\. Why ‘Yarn Berry’

<figure>

![]{{ site.baseurl }}/images/LygrDVKy0l.png)

<figcaption>

빠른 찍먹 후 공부를 곁들인...

</figcaption>

</figure>

도입을 결심한 뒤 개발이 비교적 적게 일어나고, 변경으로 인한 리스크가 적은 어드민 및 내부 라이브러리 프로젝트 부터 점진적으로 적용을 시작해나갔습니다. `yarn berry`를 적용하는 한편으로는 내부 공유를 위한 스터디 자료 준비가 이루어졌습니다.

적용 과정에서 패키지 매니저의 특징에 대해 자세히 살펴볼 수 있었습니다. yarn의 새로운 버전은 `node_modules` 라는 설계 그 자체로 인해 생기는 막대한 비효율을 해결하고자 기획 되었습니다. 물론 `npm` 은 그간 Node 생태계를 위해 많은 일을 해왔지만 가장 첫 번째로 꼽힐 용량 문제를 제외하고서라도 많은 문제를 안고 있었습니다. 아래는 [yarn 공식 문서](https://yarnpkg.com/features/pnp)에 언급되어 있는 내용에 대한 정리입니다.

### 1) 모듈 탐색 과정의 비효율

node\_modules 구조 하에서 모듈을 검색하는 방식은 기본적으로 디스크 I/O 작업입니다. 이는 node\_modules가 가진 문제이기 때문에 yarn classic과 npm 모두에 해당되는 내용입니다.

개발자가 node\_modules 내부에서 특정 라이브러리를 불러오는 상황을 가정해보겠습니다. Node.js가 모듈을 불러올 때 경로 탐색에 사용하는 몇 가지 규칙이 있는데요. 이 규칙은 [Node.js 공식 문서](https://nodejs.org/api/modules.html#loading-from-node_modules-folders)에서 확인할 수 있습니다. `require()`의 경우 1) fs, http 등의 코어 모듈이 아니면서, 2) 절대 경로를 사용할 경우 대략 아래와 같은 순서로 순회하며 모듈을 검색합니다.

다음은 `'/home/ry/projects/foo.js'` 에서 `require('bar.js')` 를 탐색할 경우입니다.

- `/home/ry/projects/node_modules/bar.js`

- `/home/ry/node_modules/bar.js`

- `/home/node_modules/bar.js`

- `/node_modules/bar.js`

이처럼 매 탐색마다 수 많은 폴더와 파일을 실제로 열고 닫으면서 검색할 수 밖에 없으며, node\_modules 중첩 등 경우에 따라서는 순회해야 하는 경로가 이보다 복잡해질 수 있습니다.

패키지 설치 과정의 경우에도 마찬가지 입니다. 설치 과정에 필요한 최소 동작만으로도 이미 비용이 많이 들고 있기 때문에 각 패키지 간 의존 관계가 유효한지 등의 추가적인 검증에 리소스를 할당하기 어렵습니다.

이처럼 모듈 탐색을 메모리 상에서 자료구조로 처리하지 않고 I/O로 직접 처리하다보니 추가적인 최적화가 어렵습니다. 실제로 yarn 개발진은 이러한 이유들로 더 이상 최적화 할 여지가 없었다고 문서에서 밝히고 있습니다. yarn berry에서는 이 뒤에서 언급될 PnP 라는 기술을 통해 이를 개선합니다.

### 2) 유령 의존성 (Phantom Dependency)

물론 npm은 속도 문제를 개선하기 위해 호이스팅 등 최적화 알고리즘을 도입하였으나 부작용으로 `유령 의존성` 이라는 문제를 새로 낳고 말았습니다.

<figure>

![](https://classic.yarnpkg.com/assets/posts/2018-02-15-nohoist/standalone-2.svg)

<figcaption>

https://classic.yarnpkg.com/blog/2018/02/15/nohoist/

</figcaption>

</figure>

npm, yarn classic 등은 중복 설치를 방지하기 위해 위 그림처럼 종속성 트리 아래에 존재하는 패키지들을 호이스팅 & 병합합니다. 그렇게 하면 패키지 최상위에서 트리 깊이 탐색하지 않고 루트 경로에서 원하는 패키지를 탐색할 수 있으므로 효율적입니다.

하지만 이런 효율의 반대 급부로는 직접 설치하지 않고, 간접 설치한 종속성에 개발자가 접근할 수 있게 되는 상황이 벌어지기도 합니다. 존재하지 않는 종속성에 의존하는 코드가 왕왕 발생할 수 있다는 뜻입니다. 이를 `유령 의존성` 이라고 합니다. 앞서 언급한 node\_modules의 단점으로 인해 의존성 트리의 유효성을 검증하기 어렵다는 것도 한 몫을 했습니다.

yarn berry에서는 이런 식의 호이스팅 동작이 일어나지 않도록 `nohoist` 옵션이 기본적으로 활성화 되어 있습니다.

### 3) Plug'n'Play (PnP)

- [https://yarnpkg.com/features/pnp](https://yarnpkg.com/features/pnp)
- [https://classic.yarnpkg.com/lang/en/docs/pnp/](https://classic.yarnpkg.com/lang/en/docs/pnp/)
- [https://github.com/yarnpkg/berry/issues/850](https://github.com/yarnpkg/berry/issues/850)

yarn berry는 **Plug'n'Play(PnP)** 라는 기술을 사용하여 이러한 문제들을 해결합니다. yarn berry는 node\_modules를 사용하지 않습니다. 대신 `.yarn` 경로 하위에 의존성들을 `.zip` 포맷으로 압축 저장하고, `.pnp.cjs` 파일을 생성 후 의존성 트리 정보를 단일 파일에 저장합니다. 이를 `인터페이스 링커 (Interface Linker)` 라고 합니다.

> _Linkers are the glue between the logical dependency tree and the way it's represented on the filesystem. Their main use is to take the package data and put them on the filesystem in a way that their target environment will understand (for example, in Node's case, it will be to generate a .pnp.cjs file)._
> 
> https://yarnpkg.com/api/interfaces/yarnpkg\_core.linker.html

링커를 논리적 종속성 트리와 파일 시스템 사이에 있는 일종의 접착제로도 비유할 수 있습니다. 이러한 링커를 사용함으로서 패키지를 검색하기 위한 비효율적이고 반복적인 디스크 I/O로부터 벗어날 수 있게 되었습니다. 의존성 또한 쉽게 검증할 수 있어 유령 의존성 문제도 해결 가능해졌습니다.

아래 코드는 pnp.cjs의 일부입니다

```
      ["@babel/helper-module-transforms", [\
        ["npm:7.19.6", {\
          "packageLocation": "./.yarn/cache/@babel-helper-module-transforms-npm-7.19.6-c73ab63519-c28692b37d.zip/node_modules/@babel/helper-module-transforms/",\
          "packageDependencies": [\
            ["@babel/helper-module-transforms", "npm:7.19.6"],\
            ["@babel/helper-environment-visitor", "npm:7.18.9"],\
            ["@babel/helper-module-imports", "npm:7.18.6"],\
            ["@babel/helper-simple-access", "npm:7.19.4"],\
            ["@babel/helper-split-export-declaration", "npm:7.18.6"],\
            ["@babel/helper-validator-identifier", "npm:7.19.1"],\
            ["@babel/template", "npm:7.18.10"],\
            ["@babel/traverse", "npm:7.19.6"],\
            ["@babel/types", "npm:7.20.2"]\
          ],\
          "linkType": "HARD"\
        }]\
      ]],\
      ["@babel/helper-optimise-call-expression", [\
        ["npm:7.18.6", {\
          "packageLocation": "./.yarn/cache/@babel-helper-optimise-call-expression-npm-7.18.6-65705387c4-e518fe8418.zip/node_modules/@babel/helper-optimise-call-expression/",\
          "packageDependencies": [\
            ["@babel/helper-optimise-call-expression", "npm:7.18.6"],\
            ["@babel/types", "npm:7.20.2"]\
          ],\
          "linkType": "HARD"\
        }]\
      ]],\
```

위와 같이 .pnp.cjs는 의존성 트리를 중첩된 맵으로 표현하였습니다. 기존 Node 가 파일시스템에 접근하여 직접 I/O 를 실행하던 require 문의 비효율을 자료구조를 메모리에 올리는 방식으로 탐색을 최적화한 것입니다. 의존성 압축을 통하여 디스크 용량 절감 효과도 볼 수 있습니다. `du -sh` 명령어로 확인해보았을 때, Next.js 기반 어드민 서비스 기준 `913MB → 247MB` 로 기존 패키지 용량 대비 약 `27%` 수준으로 패키지 관련 용량이 감소한 것을 확인할 수 있습니다.

<figure>

![]{{ site.baseurl }}/images/Z27tLAJI47.png)

<figcaption>

.yarn/cache에 다운로드 된 종속성들

</figcaption>

</figure>

<figure>

![]({{ site.baseurl }}/images/BKPYCNKNkC.png)

<figcaption>

yarn classic 에서의 node\_modules 크기 (913MB)

</figcaption>

</figure>

<figure>

![]({{ site.baseurl }}/images/TDwGaDBzLW.png)

<figcaption>

yarn berry 에서의 .yarn 크기 (247MB)

</figcaption>

</figure>

다만 .yarnrc.yml의 링커 설정을 pnp가 아닌 `node-modules` 로 하게 된다면 기존처럼 node\_modules를 설치하여 의존성을 관리하게 됩니다. 하지만 이렇게 사용할 경우 앞서 설명드린 PnP의 장점들을 활용하지 못하게 됩니다.

이에 대한 예시로 최근 \`Vercel\` 에서 모노레포 툴링으로 발표한 `Turborepo` 의 경우 패키지 매니저 중 `pnpm` 의 pnp 모드만 지원하고 있고, 메인테이너는 yarn berry의 경우 지원 계획을 취소한 상태입니다. 이 경우 앞서 말씀드린 방식으로 berry를 사용해야 합니다. 관련 이슈는 [여기](https://github.com/vercel/turbo/issues/693#issuecomment-1278886166)에서 확인하실 수 있습니다.

### 4) Zero-Installs

- [https://yarnpkg.com/features/zero-installs](https://yarnpkg.com/features/zero-installs)

`.yarn` 폴더에 받아놓은 파일들은 오프라인 캐시 역할 또한 할 수 있습니다. 커밋에 포함시켜 github에 프로젝트 코드와 함께 올려두면 어디서든 같은 환경에서 실행 가능할 것을 보장할 수 있으며 별도의 설치 과정도 필요가 없습니다.

만약 의존성에 변경이 발생하더라도 git 상에서 diff로 잡히므로 쉽게 파악 가능합니다. 개발자들 간 node\_modules가 동일한지 체크할 필요가 없다는 뜻입니다.

제가 생각했을 때 Yarn berry 도입 시 가장 강조되어야 할 중요한 지점이라고 생각합니다. 우리가 작성한 코드들이 여러 툴체인을 거치는 동안 많은 파일들이 generate 되는데, 만약 로컬에 설치된 파일과 리모트(CI 환경, 실서비스 등)에 설치된 파일이 달라 디버깅을 어렵게 한다면 대응하기 매우 어려워질 것입니다. Zero Install을 사용하게 된다면 어떤 설치 환경에서든 같은 상황임을 명시적으로 보장할 수 있습니다.

부가적인 장점으로 현재 브랜치에 맞는 package.json에 맞게 node\_modules를 갱신하기 위한 반복적인 yarn install을 할 필요 또한 없습니다. 브랜치를 체크아웃할 때마다 `.yarn/cache` 폴더에 있는 의존성도 커밋으로 잡혀있기 때문에 여타 파일들처럼 파일로 취급되어 함께 변경되기 때문입니다.

## 3\. 적용 방법

[호환성 테이블](https://yarnpkg.com/features/pnp#compatibility-table)) 에서 지원하는 버전에 해당만 한다면 마이그레이션 자체는 어렵지 않습니다. `yarn`이 이미 설치되어 있다는 가정 하에 [yarn 공식 문서](https://yarnpkg.com/getting-started/migration) 에서 설명하는 대로 진행합니다.

정말 해결할 수 없는 문제가 있다면 `.yarnrc.yml` 에서 `nodeLinker` 설정을 `loose` 혹은 `node-modules` 로 바꿔야([링크](https://yarnpkg.com/getting-started/migration#if-required-enable-the-node-modules-plugin)) 합니다.

```
nodeLinker : "pnp" # 혹은 "node-modules"
```

위에서 설명 드린 유령 의존성 문제 등의 이유로 현재 깨져 있는 종속성 트리를 수동으로 추가해주어야 하는 경우가 있을 수 있습니다. 이때는 일반적인 설치 방식으로 package.json에 종속성으로 추가해주거나, packageExtensions를 사용([링크](https://yarnpkg.com/getting-started/migration#a-package-is-trying-to-access-another-package-))하여 보완해줄 수 있습니다.

```yaml
packageExtensions:
  "debug@*":
    peerDependenciesMeta:
      "supports-color":
        optional: true
```

### 1) yarn 버전 변경

```
> yarn set version berry
```

이미 .yarnrc.yml 등 berry 관련된 파일이 생성되어 있으면 작동하지 않습니다. 만약 v1.x로 돌아가려면 `yarn set version classic` 을 입력합니다.

### 2) `.gitignore` 설정

[문서](https://yarnpkg.com/getting-started/qa#which-files-should-be-gitignored)(Zero-Installs 기준)를 따라 `.gitignore` 에 아래 경로를 추가해줍니다. `!` 는 제외할(gitignore) 경로에서 빼달라는 뜻이므로 `.yarn` 이하 경로 중 포함시킬 경로들을 명시한 것으로 생각하시면 됩니다. 부정의 부정이라 좀 혼란스러울 수는 있을 것 같습니다. 각 경로의 역할에 대한 자세한 설명은 공식 문서에서 확인하실 수 있습니다.

```
.yarn/*
!.yarn/cache
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
```

### 3) `.npmrc`, `.yarnrc`를 `.yarnrc.yml` 로 마이그레이션

berry로 버전을 변경하게 되면 루트 경로에 .yarnrc.yml 파일이 생성됩니다. 기존에 있던 .npmrc, .yarnrc는 지원하지 않기 때문에 [문서](https://yarnpkg.com/configuration/yarnrc)를 확인하여 각각의 옵션을 마이그레이션 해주면 됩니다.

.yarnrc.yml에서 nodeLinker를 `node-modules` 로 입력하면 classic에서 하던 대로 종속성들을 node\_modules에서 관리하게 됩니다. pnp 모드를 사용할 것이므로 `pnp` 라고 적혀 있는지 확인합니다.

또한 저희 프로젝트에서는 github packages로 배포한 종속성을 포함하고 있어 `yarnrc.yml` 에 추가적으로 관련 설정을 추가해줍니다. 배포 시에는 `Dockerfile` 에서 토큰 값을 넣어줍니다.

```yaml
nodeLinker: pnp

yarnPath: .yarn/releases/yarn-3.3.0.cjs

npmScopes:
  organization이름(ex. dramancompany):
    npmAlwaysAuth: true
    # NOTE: 로컬에서 설치 시 터미널에 'export NPM_AUTH_TOKEN=...' 명령어로 환경변수를 설정
    npmAuthToken: ${NPM_AUTH_TOKEN} # https://github.com/yarnpkg/berry/pull/1341
    npmRegistryServer: 'https://npm.pkg.github.com'
```

상기 세팅이 모두 끝나면 \`yarn install\` 을 입력하여 yarn classic에서 berry로 마이그레이션을 진행합니다.

```
> yarn install
```

이 과정에서 깨진 의존성들이 발견되곤 합니다. `styled-components` 사용 시 `react-is` 를 설치하라는 에러 메시지가 뜨는 것이 대표적인 케이스입니다. 터미널에 뜨는 에러 메시지를 확인하여 필요한 의존성들을 추가 설치해줍니다.

```yaml
packageExtensions:
  styled-components@*:
    dependencies:
      react-is: '*'
```

설치 시 `~/.yarn/berry/cache` 전역 경로에도 함께 설치가 되므로 `yarn cache clean` 등의 명령어를 통해 의존성이 완전히 설치되지 않은 상황을 재현하고 싶을 경우 `yarn cache clean --mirror` 를 입력([관련 문서](https://yarnpkg.com/features/offline-cache#cleaning-the-cache))해야 하므로 유의할 필요가 있습니다.

여기까지 마무리 되었으면 한번 커밋하여 진행 상황을 저장합니다.

### 4) yarn berry를 IDE와 통합 (with. TypeScript)

지금까지는 패키지 매니저 레벨에서 마이그레이션 할 것들을 처리해주었습니다. 이제 IDE에 의존성과 타입 정보를 node\_modules가 아닌 .yarn에서 읽어오도록 알려주어야 합니다. VSCode 기준으로 설명하겠습니다.  
일단 아래 세 가지 요소들을 설치합니다.

1\. `VSCode Extension에서 ZipFS 설치` (zip 파일로 설치된 종속성을 읽어올 수 있도록)

<figure>

![]{{ site.baseurl }}/images/aDPhnyO3di.png)

<figcaption>

ZipFS 설치

</figcaption>

</figure>

2\. `yarn install -D typescript eslint prettier`

3\. `yarn dlx @yarnpkg/sdks vscode` (yarn dlx = npx) 를 실행하여 관련 세팅을 포함한 `.vscode` 폴더를 생성합니다.

```json
{
  "recommendations": [
    "arcanis.vscode-zipfs",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode"
  ]
}
```

```json
{
  "search.exclude": {
    "**/.yarn": true,
    "**/.pnp.*": true
  },
  "eslint.nodePath": ".yarn/sdks",
  "prettier.prettierPath": ".yarn/sdks/prettier/index.js",
  "typescript.tsdk": ".yarn/sdks/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true
}
```

4\. 설치가 완료되면 아무 타입스크립트 파일이나 들어간 다음

5\. 우측 하단 TypeScript 클릭 or `cmd + shift + p` 를 눌러 TypeScript 검색

![]{{ site.baseurl }}/images/EFQzltz372.png)

6\. Use Workspace Version 클릭

![]{{ site.baseurl }}/images/RUs44Ru96v.png)

여기까지 진행 한 뒤 다시 한번 진행 상황 저장을 위해 커밋합니다.

### 5) Dockerfile 수정

이상 로컬에서 필요한 작업들은 모두 완료를 해주었습니다. 배포 시 도커를 사용하고 있으므로 `Dockerfile` 에도 필요한 작업을 해줍니다. 아래와 같이 작업을 해주었으며 필요한 설명은 파일 내 주석으로 추가해두었습니다.

세 가지 정도의 주의사항이 있습니다. 하나는 `yarn berry` 가 `Node 16.14+` 버전에서 동작한다는 것이고, 다른 하나는 `yarn berry` 에서 `zero install` 을 사용할 때 `yarn install` 시 `--immutable` 옵션을 사용해야 하고, Docker로 배포 시 Dockerfile에 다음과 같이 작성하여 관련 파일들을 working directory에 복사해줘야 합니다.

```
COPY package* yarn.lock .pnp*     ./
COPY .yarnrc.yml                  ./
COPY .yarn                        ./.yarn
```

위와 같은 과정을 거치면 yarn berry의 zero install을 사용할 수 있게 됩니다. 개선된 빌드 시간은 프로젝트마다 차이가 있으나 지금까지 적용해본 케이스들에서는 약 50초 ~ 1분 정도의 시간 단축이 있었습니다.

## 4\. 트러블 슈팅 (with Github issues)

`yarn berry` 가 처음 발표되었을 때에 비해 관련 자료도 많아지고, [여러 대규모 프로젝트](https://yarnpkg.com/features/pnp#compatibility-table)에서 지원하기 시작하는 등 꾸준한 개선이 있어왔지만, 기존 패키지 매니저와의 구조적인 차이 때문에 맞닥뜨리게 되는 낯선 이슈들이 여전히 존재합니다. 이번 섹션에서는 그러한 문제들을 해결했던 경험을 이야기해보겠습니다.

### 1) 커밋에 포함되지 않는 종속성 문제

`yarn install` 시 커밋에 포함되지 않는 파일들이 있습니다. `.yarn/install-state.gz` 같은 경우 최적화 관련 파일이기 때문에 애초에 커밋할 필요 없다고 공식 문서에서 안내하고 있습니다.

한편 예상치 못한 예외 케이스도 있었습니다. Next.js 등에 포함되는 \`swc\`의 경우 운영체제에 종속되는 부분이 있다보니 커밋에 포함시킬 경우 실행환경에 따라 문제를 일으킬 수 있어 커밋에서 제외되고 있습니다. 따라서 swc를 사용한다면 정상적인 빌드를 위해 최초 1회 설치 명령어가 필요합니다.

만약 설치를 실행하지 않으면 아래와 같은 오류가 발생합니다.

![]{{ site.baseurl }}/images/qDoSB3DkAz.png)

![]{{ site.baseurl }}/images/iam0VeIMxI.png)

설치 후 추가된 파일들이 .gitignore에 등록되어 있으며, 설치된 종속성의 폴더명으로부터 플랫폼 종속적이라는 사실을 추측해볼 수 있습니다. 참고로 `.yarn/unplugged` 는 zip으로 묶이지 않고 압축해제 된 종속성들이 설치되는 경로입니다. `yarn unplug` 등의 명령어를 사용하면 압축된 종속성 들을 풀어서 확인할 수 있습니다.

### 2) ESLint import/order 관련 이슈

`eslint` 에서 import 관련 룰을 사용하고 있다면 추가 세팅이 필요합니다. `eslint-plugin-import` 에서 제공하는 `import/order` 옵션을 활용해 다음과 같이 외부 의존성과 내부 의존성을 구분지어 줄바꿈 해주고 있었습니다.

![]{{ site.baseurl }}/images/crgzVf67pd.png)

이 Lint 규칙이 yarn berry 적용 후 제대로 작동하지 않는 것을 발견하였습니다. 프로젝트 내부에서 가져온 모듈과, 외부 라이브러리에서 가져오는 모듈을 구분하는 기준이 node\_modules가 경로에 포함되어 있는지 여부였을 것이라 생각하여 검색해보았습니다. [관련 이슈](https://github.com/import-js/eslint-plugin-import/issues/2164)로부터 힌트를 얻어 [README](https://github.com/import-js/eslint-plugin-import#importexternal-module-folders) 내에 언급된 해결책을 찾을 수 있었습니다.

> _If you are using yarn PnP as your package manager, add the .yarn folder and all your installed dependencies will be considered as external, instead of internal._

이 문제를 해결하려면 `.eslintrc.js` 에 다음과 같이 옵션을 추가하여 `.yarn` 경로를 외부 의존성으로 인식시켜주면 됩니다.

```js
// .eslintrc.js
// ...
  settings: {
    'import/external-module-folders': ['.yarn'],
// ...
```

### 3) yarn berry에서 pre-hook 지원하지 않음

yarn 2.x 버전 부터는 pre-hook(ex. `preinstall` , `prepare` 등) 을 지원하지 않습니다. [문서](https://yarnpkg.com/advanced/lifecycle-scripts#gatsby-focus-wrapper)에 따르면 이는 사이드 이펙트를 줄이기 위한 의도적인 변경이라고 하며, 호환성을 위해서 `preinstall` 과 `install` 은 `postinstall`의 일부로서 실행됩니다.

기존에 husky 등을 사용하기 위해 걸어둔 pre-hook이 있었다면 yarn berry 업그레이드 후 작동하지 않을 것이므로 이에 대한 처리가 필요합니다.

```
"postinstall": "husky install"
```

### 4) yarn berry와 vite를 함께 사용할 때 storybook이 실행되지 않는 문제

![]{{ site.baseurl }}/images/S4qkp0xsN2.png)

이 경우는 누락된 devDependencies를 다 깔아주면 되는 문제로 간단하게 해결할 수 있었습니다. 관련 이슈는 [여기](https://github.com/storybookjs/builder-vite/issues/141)에서 찾아볼 수 있습니다.

하지만 이 종속성들을 설치하고 나서도 storybook이 정상적으로 실행되지는 않았는데, 스토리북으로 띄운 화면 상의 콘솔에 \`"Cannot access "./util.inspect.custom" in client code."\` 라는 에러가 발생했습니다. pnp와 vite 사이에서만 발생하는 문제로 build 과정에서 서버 / 클라이언트 환경에서 실행되는 코드들이 적절히 처리되지 않아서 생기는 문제로 이해했습니다. vite 측에서 폴리필을 추가하여 해결한 것으로 보이며, 관련 이슈는 [여기](https://github.com/vitejs/vite/issues/9238), [여기2](https://github.com/vitejs/vite/issues/7576)에서 찾아볼 수 있습니다.

![]{{ site.baseurl }}/images/6J3SjfI1r0.png)

이 외에도 vite와의 조합에서 생기는 문제는 또 있었는데요. build를 실행했을 시 종속성을 제대로 찾지 못하는 문제였습니다. 이 문제는 yarn berry를 3.3.0으로 올리고 vscode sdk를 재설치한 뒤, vite를 3.2.0 버전으로 업데이트 하여 해결했습니다. 관련 이슈는 [여기](https://github.com/yarnpkg/berry/issues/4872#issuecomment-1284318301)에서 찾아볼 수 있습니다.

## 5\. 개선 결과

결과적으로 개선된 빌드 시간은 프로젝트마다 차이가 있으나 지금까지 적용해본 케이스들에서는 yarn berry 단독으로만 따졌을 때 평균적으로 약 50초 ~ 1분 정도의 시간 단축이 있었습니다. 만약 앞서 언급한 swc 관련 설치 시간을 생략할 수 있다면 20초 정도를 추가로 단축할 여지가 있습니다.

<figure>

![image](/images/HypdCkq7Fh.png)

<figcaption>

swc 설치에 소요되는 시간

</figcaption>

</figure>

빌드 시간 단축 이외에도 실제 도입해보고 나서 체감할 수 있었던 장점들이 많았습니다. 레포지토리 설치 시 종속성 크기 감소, 로컬과 리모트 환경에서의 빌드 결과물의 동일성 보장, 엄격한 종속성 트리 관리로 인한 안정성 향상 등의 이점이 기존 버전 대비 방법론적인 개선을 이룰 수 있었습니다.

개발 단계에서 git branch 변경 시 반복적으로 install 스크립트를 실행하여 node\_modules를 업데이트 해줘야 하거나, 종종 잘못 설치된 종속성 때문에 한참 디버깅을 하다 결국 node\_modules를 지우고 재설치 해야 하는 번거로움이 줄어든 것도 체감되는 부분이었습니다.

추가로 Dockerfile에 들어있던 세팅에서 불필요한 부분을 걷어내고, [AWS Codebuild에서 Docker Layer가 로컬 캐싱](https://docs.aws.amazon.com/ko_kr/codebuild/latest/userguide/build-caching.html#caching-local)될 수 있는 방법을 찾아 적용하였습니다. yarn berry와는 직접적으로 관련은 없지만 배포 성능을 개선하는 도중에 진행했던 변경이라 함께 언급해두겠습니다.

도커 파일 내 각 레이어는 변경사항이 생기지 않는 이상 새롭게 생성될 필요가 없습니다. 변경이 사항 없을 시 CodeBuild의 빌드 호스트가 자연스럽게 Docker Layer 캐싱을 이용할 수 있도록 세팅을 변경해주었습니다.

현재 AWS CodePipeline을 사용하여 배포하고 있으며, 빌드는 AWS Codebuild를 사용하고 있으므로, 해당 단계에서 생성된 빌드 결과물을 캐싱에 사용할 수 있도록 아래와 같이 체크해줍니다. 다만 이 로컬 캐시의 정확한 유효 시간(약 5 ~ 15분)이나 히트 조건에 대해서는 조금 더 확인이 필요합니다. ([링크](https://stackoverflow.com/questions/58793704/aws-codebuild-local-cache-failing-to-actually-cache))

<figure>

![]{{ site.baseurl }}/images/zo7PsfRe5l.png)

<figcaption>

AWS Codebuild - 편집 - 아티팩트 - 캐싱 메뉴 하단

</figcaption>

</figure>

이 과정에서 기존에 잘못 세팅되어 있던 Codebuild의 Buildspec을 바로 잡고 로컬 캐싱이 작동하도록 함으로서 추가적으로 빌드 시간을 단축하였습니다. Next.js 기반의 어드민 프로젝트 기준 최대 2분 가량 추가 단축한 것으로 추정됩니다.

<figure>

![image](/images/oEhoS7O3yb.png)

<figcaption>

캐시 히트 시 빌드 소요 시간 2분 37초 (직전 빌드 4분 28초 - yarn berry 적용 분 포함)

</figcaption>

</figure>

<figure>

[![]{{ site.baseurl }}/images/FSUKtdj9c4.png)](https://blog.dramancompany.com/wp-content/uploads/2023/02/image-6.png)

<figcaption>

도커 레이어 레벨에서 캐싱이 일어났을 때의 빌드 로그

</figcaption>

</figure>

한 프로젝트는 언급드린 두 가지 조치를 통하여 프로젝트에 따라 빌드 시간이 5분 30초 → 1분 50초로 드라마틱하게 감소하기도 했는데, 프로젝트별 인스턴스 세팅과 빌드 시점, 캐시 여부에 따라 개선되는 폭은 상이할 것으로 생각되어 절대적인 수치로는 참고하지 말아주시고 대략적인 수치로만 봐주시면 좋을 것 같습니다.

## 6\. 마치며

한 명의 아이를 기르기 위해 온 마을이 필요하다는 말 처럼, 하나의 웹 서비스가 만들어지기 위해서는 정말 다양한 기술이 필요합니다. 어느 개발이나 그렇겠지만 특히 최근 자바스크립트 생태계는 특히 이런 `툴체인(Toolchain)` 의 조합을 여러 방향으로 실험해보는 활발한 분위기가 느껴집니다. `npm` 과 함께 오랫동안 사랑 받아온 패키지 매니저 `yarn` 또한 개발에 필요한 라이브러리들의 설치와 종속성을 담당하는 점에서 툴체인의 중요한 일부를 담당하고 있습니다.

그 중에서도 yarn berry와 pnp는 과감하면서도 멋진 진전이라고 생각합니다. 물론 위에 말씀드린 이슈들처럼 아직 사용자들이 직접 부딪혀야 하는 문제들이 산재해있지만, 기술이 처음 공개되었을 때와 비교하면 현재 이 리스크들은 감내할 수 있는 수준이라고 생각합니다. `yarn unplug` , `yarn why` , `yarn patch` 등의 기능을 활용하여 디버깅하고, 긴급한 상황에서는 `nodeLinker: node-modules` 로 되돌리거나 `pnpMode: loose` 등의 절충점이 존재하므로 자신 있게 도입해볼 수 있을 것 같습니다.

사실 `yarn berry` 를 도입하는 과정에서 가장 좋았던 점은 성능상의 이점보다도, yarn이나 여러 패키지 내부의 코드를 살펴보며 동작 원리를 가늠하거나, Github에 올라온 issue들을 싹싹 긁어가며 읽고, peerDependencies 등 종속성들 간의 관계를 생각하며 패키지를 이리저리 설치해보던 시간들이었습니다. 가벼운 마음으로 시작했지만 역시 어떤 기술이든 직접 만져보고 굴려볼 때 이해도가 더 높아진다는 사실을 새삼스레 곱씹어보게 됐던 것 같네요.

서두에서 말씀드렸듯 결국 저희 팀에서는 비록 `Turborepo` 와의 호환 이슈로 `pnpm` 을 선택하게 되었지만 yarn berry는 충분히 매력적인 기술인만큼 검토해보시고 도입을 적극 고려해보셨으면 좋겠습니다.

이제 저희 팀의 채용 홍보로 글을 마무리 짓도록 하겠습니다. **리멤버 웹 파트에서는 이러한 기술적인 고민을 함께 나누며 성장하실 동료분을 모시고 있습니다.** 서류 검토, 기술 면접, 컬처핏 면접 절차 세 단계로 간소하게 프로세스를 진행하고 있습니다. 보다 상세한 내용은 [채용 공고](https://hello.remember.co.kr/recruit/web)를 확인 부탁드리며, 많은 관심과 지원 부탁드리겠습니다.

지금까지 긴 글 읽어주셔서 감사합니다.

[\>\_ 웹 파트 채용공고 보러가기](https://hello.remember.co.kr/recruit/web)

<figure>

[![]({{ site.baseurl }}/images/xAOHOmyavG.png)](https://blog.dramancompany.com/wp-content/uploads/2023/02/image.png)

<figcaption>

도입 초기에는 모든 에러로부터 Yarn Berry가 의심의 눈초리를 받을 수 있으니 주의 요망

</figcaption>

</figure>

## 6\. 참고 자료

- [https://yarnpkg.com/](https://yarnpkg.com/)
- [node\_modules로부터 우리를 구원해 줄 Yarn Berry](https://toss.tech/article/node-modules-and-yarn-berry)
- [yarn berry 적용기(1)](https://medium.com/wantedjobs/yarn-berry-%EC%A0%81%EC%9A%A9%EA%B8%B0-1-e4347be5987)
- [Yarn Berry, 굳이 도입해야 할까?](https://medium.com/teamo2/yarn-berry-%EA%B5%B3%EC%9D%B4-%EB%8F%84%EC%9E%85%ED%95%B4%EC%95%BC-%ED%95%A0%EA%B9%8C-d6221b9beca6)
- [npm, yarn, pnpm 비교해보기](https://yceffort.kr/2022/05/npm-vs-yarn-vs-pnpm)
