---
layout: "post"
title: "웹 퍼포먼스 개선을 위한 Lighthouse CI 도입기"
author: "jiseop.han"
date: "2021-04-21"
categories: 
  - "develop"
---

안녕하세요. 리멤버의 웹 프론트엔드 개발을 하고 있는 한지섭입니다.

최근에는 직장인들의 고민해결을 위한 서비스인 '리멤버 커뮤니티'를 개발하고 있는데요,

이번 글에서는 사용자들이 리멤버 커뮤니티를 더 쾌적하게 이용할수 있도록 웹 페이지 성능을 측정하고 개선하는 과정에 대해 얘기해보려고 합니다.

## "커뮤니티가 너무 느려졌어요"

빠른 속도로 기능 개발을 하다보면 성능과 관련된 부분을 충분히 체크하지 못하고 작업을 할때가 있습니다.

이로인해 배포되고 한참 뒤에야 특정 페이지가 너무 느려졌다는 제보를 받고 급하게 대응하고는 했습니다.

이 과정에서 제가 느낀 문제점은 크게 두가지 였는데요.

1. 웹 페이지가 느리다는것은 어떻게 정의할것인가? 얼마나 느려야 대응을 할것인가? 애매하다.
2. 정확히 어떤 시점부터 어떤 페이지가 느려진것인지, 즉 어떤 작업으로 인해 느려졌는지 파악하기 어렵다.

우선 첫번째 문제점부터 하나하나 얘기해보겠습니다!

## 웹페이지의 속도를 정의해봅시다

웹페이지의 퍼포먼스를 지속적으로 개선하기 위해서는 측정할수 있는, 수치화된 지표가 필요합니다.

이 지표로 저희 팀에서는 [Web Vitals](https://web.dev/vitals/) 를 따르고 있습니다.

Web Vitals란 구글에서 제안하는, 더 나은 웹페이지를 개발하기 위한 가이드라인으로, 아래에서 설명할 세가지 핵심 지표들을 포함하고 있습니다.

**LCP(Largest Contentful Paint)**

<figure>

[![](/images/lUSvuuZiaH.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img1.png)

<figcaption>

[community.rememberapp.co.kr/post/25955](https://community.rememberapp.co.kr/post/25955) 여러분은 어떻게 생각하시나요?

</figcaption>

</figure>

LCP는 페이지의 내용이 화면에 얼마나 빨리 나오는지를 측정하기 위한 지표입니다.

LCP란, 뷰포트 내에서 이미지/비디오/텍스트 블록중 시각적으로 가장 큰 사이즈를 차지하는 블록이 처음으로 브라우저에 paint 되기까지의 시간을 의미합니다.

위 화면에서는 기영이 그림이 가장 큰 블록이니, 기영이가 처음으로 등장하기까지의 시간이 해당 페이지의 LCP가 됩니다.

**FID(First Input Delay), TBT(Total Blocking Time)**

<figure>

[![](https://blog.dramancompany.com/wp-content/uploads/2021/04/img2.svg)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img2.svg)

<figcaption>

출처: [https://web.dev/fid/](https://web.dev/fid/)

</figcaption>

</figure>

페이지에 내용이 모두 나온 후에도 끝난것은 아닙니다.

좋아요를 누르는 등 유저가 인풋을 주었을 때 바로 반응이 오지 않을수 있습니다.

브라우저의 자바스크립트 엔진은 기본적으로 싱글스레드로 작동하는데, 메인스레드에 남은 작업이 있다면 사용자가 인터랙션을 하더라도 이벤트 핸들러가 바로 동작하지 않기 때문입니다.

이런 유저 인터랙션의 Delay를 측정하기 위한 지표가 FID입니다.

FID는 유저의 인터랙션 이후 이에 대한 이벤트 핸들러를 실행할 준비가 되기(= 메인 스레드가 idle 해지기)까지의 시간을 의미합니다.

[자동화된 테스트 환경](https://web.dev/user-centric-performance-metrics/#in-the-lab)에서는 실제 유저가 인터랙션을 하지 않기 때문에 FID를 측정할 수 없습니다. 대신 이를 간접적으로 측정하는 지표인 [TBT](https://web.dev/tbt/)를 사용합니다.

**CLS(Cumulative Layout Shift)**

<figure>

[![](/images/zyr2gxQfcF.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img3.png)

<figcaption>

출처: [https://web.dev/optimize-cls/](https://web.dev/optimize-cls/) 갑자기 등장한 광고배너를 잘못 클릭해본적 있나요?

</figcaption>

</figure>

웹 페이지 구성요소의 일부분은 최초 렌더 이후 추가적으로 로드됩니다.

리멤버 커뮤니티의 경우 댓글이 그런 요소인데요, 이렇게 추가적인 요소들이 그려지는 과정에서 기존의 요소들이 밀려나는(Layout Shift) 상황이 벌어질수 있습니다.

이로인해 유저가 의도하지 않는 요소를 클릭하게 되는 등 사용자 경험에 악형향을 줄 수 있습니다.

CLS 값은 밀려나는 요소의 크기가 클수록, 밀려나는 거리가 길수록 커집니다.

> 각종 지표들의 엄밀한 정의와 이를 개선하기 위한 방법은 구글의 웹 기술 관련 페이지인 web.dev에 자세히 설명되어 있습니다.
> 
> 글 하단에 관련 링크들을 넣어 놓겠습니다.

## 그럼 이 지표를 어떻게 측정하나요?

구글에서는 웹의 퍼포먼스, 접근성, SEO 등과 관련된 지표들을 측정할수 있는 [Lighthouse](https://developers.google.com/web/tools/lighthouse) 라는 오픈소스 도구를 공개했습니다.

아래 그림과 같이 크롬에서 측정할 페이지에 접속한후 디버거의 Lighthouse 탭에서 테스트를 돌리고, 결과 리포트를 확인할수 있습니다.

[![](/images/sV6tHPThZT.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img4.png)

[![](/images/WHHLtZbIoY.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img5.png)

## 좋네요 점수도 확인했고, 그럼 다 된건가요?

지금까지 우리는 측정 지표를 정의했고, 해당 지표를 측정하는 방법도 찾았습니다.

글의 앞부분에서 언급한, 제가 해결하려고 하는 두번째 문제를 다시 생각해보면

```
웹 페이지가 느려졌을때 정확히 어떤 시점부터 어떤 페이지가 느려진것인지
즉 어떤 작업으로 인해 느려졌는지 파악하기 어렵다.
```

이 문제를 해결하기 위해 아래 사항들이 추가적으로 해결된 시스템을 설계했습니다.

1. 배포할때마다 자동으로 테스트를 돌려야한다
2. 테스트 결과는 관련 커밋과 연결하여 DB에 축적해야한다
3. 축적한 결과는 언제든지 쉽게 볼수 있어야한다.

## Lighthouse CI

이러한 시스템을 조금더 수월하게 구축할수 있도록 [Lighthouse CI 프로젝트](https://github.com/GoogleChrome/lighthouse-ci)가 공개돼있습니다.

Lighthouse CI는 아래의 요소들을 포함하고 있습니다.

1. CLI로 테스트 실행
2. 테스트 결과를 업로드할수 있고, 대시보드를 통해 데이터를 시각화해서 보여주는 Node.js 서버

이제 이 Lighthouse CI 를 기존의 리멤버 커뮤니티 배포 파이프라인과 연동해보겠습니다.

## 인프라 구축

구축한 인프라를 간단하게 요약하면 그림과 같습니다.

[![](/images/l2n3l0O3BR.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img6.png)

배포를 시작하면 AWS CodeBuild 에서 빌드와 테스트를 진행합니다.

테스트 결과는 Lighthouse 서버에 업로드, DB에 저장됩니다. 그러면 이후 개발자는 대시보드 주소에 접속하여 결과를 확인합니다.

## 그럼 테스트 결과를 한번 볼까요?

Lighthouse 대시보드에 접속하면 웹 페이지를 분석하는데에 도움이 되는 다양한 기능이 있습니다.

[![](/images/KYZWWTIar6.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img7.png)

우선 테스트를 수행한 빌드 목록을 확인할수 있습니다.

[![](/images/BrNHahEoDf.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img8.png)

목록에서 빌드를 클릭하면 해당빌드의 상세한 측정결과를 확인할수 있습니다.

위에서 언급했던 LCP, TBT, CLS 외에도 다양한 지표들에 대해 측정 결과를 보여줍니다.

또한 퍼포먼스 외에도 접근성, SEO와 관련된 테스트 결과도 확인할 수 있습니다.

[![](/images/2HhgHvMSEh.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img9.png)

단순히 측정 결과만 알려주는게 아니라 어떻게 개선할수 있는지를 파악하는 데에도 도움을 줍니다.

<figure>

[![](/images/w9zLyym5xc.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img10.png)

<figcaption>

출처: [https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/server.md](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/server.md)

</figcaption>

</figure>

여러 빌드에 거쳐 점수가 어떻게 변화했는지 추이를 확인할 수 있습니다.

## 한계

Lighthouse는 소스 코드를 분석하는 도구가 아닙니다.

따라서 웹페이지의 모든 문제점을 파악할 수 없으며, 점수를 개선하기 위해 코드를 분석하고 개선 방향을 세우는것은 온전히 개발자의 몫입니다.

또한 Lighthouse 는 일관적인 측정 결과를 위해 [통제된 환경](https://web.dev/user-centric-performance-metrics/#in-the-lab)속에서 테스트를 돌리는 도구이기 때문에 실제 유저가 체감하는 성능과는 차이가 있을수 있습니다.

그럼에도 객관적인 지표를 통해 웹 페이지의 문제점을 파악하고 개선하는 데에 충분히 유용하게 사용될수 있습니다.

## 그래서, 개선하기 위해 뭘 했나요?

최근에 완료하거나 진행중인 작업들은 다음과 같습니다.

- API 응답 속도 줄이기
- Javascript 비동기 처리 개선
- SWR 라이브러리의 [local mutate](https://swr.vercel.app/docs/mutation#mutation-and-post-request) 활용
- Layout Shift 를 방지하기 위한 구조 개선
- 불필요한 API 호출, rerendering 줄이기
- 페이지 전환시 답답함을 해소하기 위한 애니메이션 추가
- Bundle 사이즈를 크게 만드는 라이브러리 교체

[![](/images/M7okHu7V7R.png)](https://blog.dramancompany.com/wp-content/uploads/2021/04/img11.png)

이러한 작업들을 통해 최근에 TBT, CLS를 큰폭으로 개선할수 있었고 앞으로도 지속적으로 개선할 예정입니다.

다음에 기회가 된다면 이러한 개선 작업들에 대해서도 자세히 다뤄보겠습니다.

* * *

리멤버는 많은 분들께 리멤버를 알린 명함 관리를 넘어 다양한 서비스를 웹으로 운영하며 종합 비즈니스 플랫폼으로 변화하고 있습니다.

- 더 나은 커리어 기회를 제공하는 '리멤버 커리어'
- 일 관련 지식을 나누고 고민을 해소하는 '리멤버 커뮤니티'
- 전문적인 경제/경영 컨텐츠를 제공하는 '리멤버 나우'
- 아직 공개되지 않은 프로젝트, 내부 어드민 등

이러한 서비스를 만드는 과정에서 저희 팀은 사용자에게, 개발자에게 더 나은 경험을 주기 위해 새로운 기술을 배우고, 팀원들과 공유하고, 적절한 단계에서 도입하는 문화가 잘 정착되어 있습니다.

현재 저희팀은 Web Frontend 개발자를 채용중입니다. 자세한 채용 안내는 [https://dramancompany.com/joinus](https://dramancompany.com/joinus) 에서 확인해주세요.

질문은 댓글로 남겨주시면 자세히 답변 드리겠습니다. 읽어주셔서 감사합니다 🙂

### 참고

- [https://web.dev/vitals/](https://web.dev/vitals/)
- [https://web.dev/lighthouse-ci/](https://web.dev/lighthouse-ci/)
- [https://web.dev/user-centric-performance-metrics/](https://web.dev/user-centric-performance-metrics/)
- [https://web.dev/lcp/](https://web.dev/lcp/)
- [https://web.dev/fcp/](https://web.dev/fcp/)
- [https://web.dev/cls/](https://web.dev/cls/)
- [https://web.dev/fid/](https://web.dev/fid/)
- [https://web.dev/tti/](https://web.dev/tti/)
- [https://web.dev/tbt/](https://web.dev/tbt/)
