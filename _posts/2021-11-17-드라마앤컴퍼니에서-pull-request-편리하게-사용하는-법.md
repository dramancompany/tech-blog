---
layout: "post"
title: "리멤버에서 Pull Request 편리하게 사용하는 법"
author: "sj.sa"
date: "2021-11-17"

---

여러 사람이 협업을 하다 보면 코드에 변경 사항에 대한 코드 리뷰를 받기 위하여 Pull Request를 생성하곤 합니다. 리멤버에서는 리뷰어가 좀 더 쉽게 리뷰를 진행할 수 있도록 Pull Request에 작업 내용, 고민됐던 부분, 희망 리뷰 완료일 등 다양한 정보를 적고 있습니다. 이런 코드 리뷰 프로세스를 더 잘 정착시키고 효율적으로 진행할 수 있도록 리멤버의 서버 개발자들이 고민하고 적용했던 몇 가지 방법에 대해 공유하고자 합니다.

## **CODEOWNERS로 리뷰어 자동으로 지정하기**

GitHub에서는 Pull Request 생성 시 리뷰어를 요청하는 기능이 있습니다. 지정하는 방법에 대해서는 간단하지만, 매번 같은 사람 혹은 팀을 리뷰어로 매번 지정하는 건 여간 귀찮은 일이 아닙니다. CODEOWNERS는 코드에 변경 사항이 있는 Pull Request 생성 시 자동으로 개인, 팀 단위의 리뷰어를 지정해주는 기능입니다.

### **사용 방법**

해당 기능을 사용하기 위해서는 CODEOWNERS라는 파일을 생성해야 합니다. 루트 디렉터리 기준으로 **docs/**, **.github/** 중 한 곳에 CODEOWNERS 파일을 생성한 뒤 리뷰어를 지정합니다. ex) @ace9809, @roharon  

파일을 생성하면 Pull Request 요청 시 자신이 소유자로 지정된 파일의 변경 사항이 있을 때 자동으로 검토 요청받게 됩니다. CODEOWNERS 설정 파일의 크기는 3MB 초과하게 되면 불러오지 못하며 CODEOWNERS 파일의 디렉터리 경로는 대소문자를 구분하여 리포지토리의 경로와 정확하게 일치해야 합니다.  

제가 개발하고 있는 커뮤니티 프로젝트에서는 모든 파일에 대해서 프로젝트에 관련된 리뷰어가 지정되도록 하였습니다.

![]({{ site.baseurl }}/images/eKamUHuPED.png)

### **문법 예시**

CODEOWNERS는 특정 언어, 팀, 디렉터리 별로도 세부적으로 리뷰어가 지정이 가능합니다. 자세한 문법에 대해서는 아래 예시를 참고하시길 바랍니다.

```
# This is a comment.
# Each line is a file pattern followed by one or more owners.

# These owners will be the default owners for everything in
# the repo. Unless a later match takes precedence,
# @global-owner1 and @global-owner2 will be requested for
# review when someone opens a pull request.
*       @global-owner1 @global-owner2

# Order is important; the last matching pattern takes the most
# precedence. When someone opens a pull request that only
# modifies JS files, only @js-owner and not the global
# owner(s) will be requested for a review.
*.js    @js-owner

# You can also use email addresses if you prefer. They'll be
# used to look up users just like we do for commit author
# emails.
*.go docs@example.com

# Teams can be specified as code owners as well. Teams should
# be identified in the format @org/team-name. Teams must have
# explicit write access to the repository. In this example,
# the octocats team in the octo-org organization owns all .txt files.
*.txt @octo-org/octocats

# In this example, @doctocat owns any files in the build/logs
# directory at the root of the repository and any of its
# subdirectories.
/build/logs/ @doctocat

# The `docs/*` pattern will match files like
# `docs/getting-started.md` but not further nested files like
# `docs/build-app/troubleshooting.md`.
docs/*  docs@example.com

# In this example, @octocat owns any file in an apps directory
# anywhere in your repository.
apps/ @octocat

# In this example, @doctocat owns any file in the `/docs`
# directory in the root of your repository and any of its
# subdirectories.
/docs/ @doctocat

# In this example, @octocat owns any file in the `/apps`
# directory in the root of your repository except for the `/apps/github`
# subdirectory, as its owners are left empty.
/apps/ @octocat
/apps/github 
```

코드 소유자로 지정된 사람이 Approve를 하지 않을 때 머지를 할 수 없도록 설정하고 싶은 경우 Settings -> Branches -> Add rules에서 옵션을 설정하는 것도 가능합니다.

![]({{ site.baseurl }}/images/c2gocthIaf.png)

### **Pull Request 생성하여 리뷰어 확인**

Pull Request 생성 단계에서는 리뷰어가 추가되지 않으며 실제로 생성 한 후 Open 상태일 경우 리뷰어가 추가됩니다. Reviewers 탭이 아래 사진과 같이 보인다면 정상적으로 기능이 동작하게 된 것입니다. 추가된 리뷰어에게도 메일이 정상적으로 가는 것도 확인하실 수 있습니다.

![]({{ site.baseurl }}/images/FiZYCyebcE.png)

![]({{ site.baseurl }}/images/MGUV20b469.png)

## **Pull Request 템플릿 사용하기**

<figure>

![]({{ site.baseurl }}/images/VUdz1gAE4E.png)

<figcaption>

(PR 템플릿을 적용하기 전)

</figcaption>

</figure>

입사 후 얼마 되지 않았을 때 제가 작성한 PR description입니다. 어떤 느낌이 드시나요? 매우 불친절해 보입니다. 709줄이나 변경됐는데 API 스펙문서, 해당 기능에 대한 기획 문서 링크, 희망 리뷰 완료 일자 등 리뷰를 하기에 앞서 필요한 정보들이 존재하지 않습니다. 이러한 PR description은 작업한 부분을 인지하는 데 시간이 오래 걸리며 필요한 정보에 대해서 Pull Request 요청자와 커뮤니케이션을 통해 정보를 얻어야 하는 피로감을 줍니다. 또한 고민됐던 부분, 중점적으로 리뷰를 받고 싶은 부분에 대해서도 적지 않았기 때문에 좋은 리뷰를 받기가 어렵습니다.

사람마다 Pull Request를 작성하는 템플릿이 다르다보니 누군가는 자세하지 않게 쓸 수 있습니다. 혹은 자세하게 쓰는 사람도 매번 완벽하게 똑같은 템플릿을 유지할 수 없습니다.  
필요한 정보를 까먹고 적지 않는 일도 있고 이전에 작성했던 Pull Request description을 보고 빠진 부분이 없는지 확인하거나 템플릿을 매번 똑같이 만드는 반복되는 작업에 대해서도 시간을 단축하고 싶습니다. 이러한 문제점들을 Pull Request 템플릿을 통하여 매우 간단하게 일관된 description을 작성하여 생산성을 높일 수 있습니다.

<figure>

![]({{ site.baseurl }}/images/945hmFOumk.png)

<figcaption>

(PR 템플릿을 적용한 후)

</figcaption>

</figure>

### **사용 방법**

루트 디렉터리에서 **.github** 디렉터리에 **PULL\_REQUEST\_TEMPLATE.md** 파일을 만듭니다. 회사마다 description에 필요한 정보가 다르겠지만 리멤버 서버팀이 사용하는 PR 템플릿 항목에 대해서 이야기해보도록 하겠습니다.

```
## 작업 내용 (Content)
- 리뷰어가 중점적으로 봐야 하는 부분을 바로 알 수 있도록 변경된 내용을 나열합니다.
- List up changes so that reviewer can quickly understand the important parts.

## 링크 (Links)
- [JIRA 티켓 이름](http://jiraaddress.com/browse/API-1)
- [API 스펙 문서](http://wikiaddress.com/)
- [개발 문서](http://wikiaddress.com/)
- [기획 문서](http://wikiaddress.com/)
- [디자인 문서](http://wikiaddress.com/)

## 기타 사항 (Etc)
- PR에 대한 추가 설명이나 작업하면서 고민이 되었던 부분 등
- Additional information about this PR or any troubles working on this PR.

## Merge 전 필요 작업 (Checklist before merge)
- [ ] 예) XX 테이블 추가, 앱 배포 등
- [ ] eg) Create XX table, Deploy app etc
## 희망 리뷰 완료 일 (Expected due date)
202X. X. X. Wed
```

#### **작업 내용**

작업한 내용에 대해서 나열합니다. 어떤 기능을 개발했는지, 리팩토링 한 내용 등 수정한 부분에 대해서 리뷰하는 사람이 쉽게 인지할 수 있도록 작성합니다.

#### **링크**

리멤버에서는 단순히 완성된 코드만을 리뷰하는 것이 아니라 작업한 부분에 대해서 제대로 이해하고 더 좋은 리뷰를 주기 위해 노력합니다. 기획 문서, API 스펙 문서, 개발문서 등 리뷰하기 위해 필요한 링크들을 작성합니다.

#### **기타 사항**

개발하면서 고민됐던 부분들에 대해서 작성합니다. API path naming에 대한 고민, 구현 방법 등 작업하면서 고민됐던 부분 및 같이 논의해봤으면 하는 것들에 대해서 상세히 적고 리뷰어가 해당 부분에 대해서 조금 더 중점적으로 리뷰를 할 수 있도록 합니다.

#### **Merge 전 필요 작업**

개발을 완료하고 프로덕션 환경에서 테이블이나 환경 변수 추가 등 머지 및 배포하기 전에 선행되어야 할 부분을 잊지 않고 리마인드 하기 위한 자신만의 체크리스트입니다.

#### **희망 리뷰일**

리뷰를 완료 받고 싶은 날짜입니다. 여담이지만 서버팀에서는 원활하게 리뷰가 되도록 매주 수요일에 리뷰가 안된 것들이 있는지 점검하여 리뷰가 원활하게 되도록 합니다.

## **마무리**

리멤버에서는 위와 같이 간단한 기능들을 이용하여 Pull Request 요청 및 리뷰시에 생산성을 높였습니다. 기존에 저희가 Pull Request를 생성할 때 겪었던 문제들과 같은 고민을 하고 있다면 적극적으로 사용하시길 권장합니다. :)

## 참고

- [](https://medium.com/expedia-group-tech/owning-your-codeowners-file-332e288c1d12)[https://medium.com/expedia-group-tech/owning-your-codeowners-file-332e288c1d12](https://medium.com/expedia-group-tech/owning-your-codeowners-file-332e288c1d12)
- [](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-file-location)[https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-file-location](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-file-location)
- [https://github.blog/2017-07-06-introducing-code-owners/](https://github.blog/2017-07-06-introducing-code-owners/)
- [https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
