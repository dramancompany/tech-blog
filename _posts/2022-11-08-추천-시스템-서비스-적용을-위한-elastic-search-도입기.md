---
layout: "post"
title: "추천 시스템 서비스 적용을 위한 Elastic Search 도입기"
author: "hh.hwang"
date: "2022-11-08"

tags: 
  - "aws-opensearch"
  - "elasticsearch"
  - "simcse"
  - "리멤버"
  - "리멤버-커뮤니티"
  - "추천시스템"
---

안녕하세요 빅데이터 센터 AI Lab 황호현 입니다.

저희 AI Lab에서는 리멤버 유저들에게 인공지능을 통해서 WoW한 경험을 주기 위해 Recommendation System, Ranking Model, Document Understanding, NLP등 다양한 연구를 진행하고 있습니다.

이번 포스트는 입사 후 맡은 첫 번째 프로젝트인 “리멤버 커뮤니티 새 글 피드 개인화 추천”를 진행하는 과정을 공유드리고자 합니다. 머신러닝 모델을 서비스에 활용하는데 모델 학습을 정확하게 하는 것도 중요하지만, 어떤 방법을 활용해서 서비스에 제공하도록 할 것인가도 굉장히 중요한 문제입니다.

추천 로직에 대한 서비스를 제공하는데 있어서 굉장히 많은 방법들이 존재합니다. 그 중에 저희는 Elastic Search를 기반으로 하여 추천 로직을 구축했고, 그 부분에 대해서 중점적으로 소개해 드리겠습니다.

* * *

# 1\. Introduction

### 1-1. 커뮤니티 피드 개인화 필요성

리멤버에서는 직장인을 위한 커뮤니티를 운영하고 있습니다.

리멤버 커뮤니티는 크게 인사이트 / 직무 커뮤니티 / 관심사 커뮤니티 의 카테고리로 나뉩니다. 각 카테고리는 직장생활에서 얻을 수 있는 인사이트를 제공하고, 직무별로 정보를 공유할 수 있으며, 회사생활이나 기타 관심사에 대한 정보도 교류할 수 있는 공간입니다.

![]({{ site.baseurl }}/images/9v8dMqZ6Oj.png)

리멤버 커뮤니티 메인화면 \[1\]

본 연구는 리멤버 커뮤니티에 존재하는 많은 정보 중 각 유저에게 가장 적합한 콘텐츠를 찾아 필요한 인사이트를 빠르게 얻도록 하는 것을 목적으로 했습니다. 그에 따라 유저가 가장 처음 접하는 새 글 피드의 개인화 추천 프로젝트를 진행했습니다.

### 1-2. 새 글 피드에 업데이트 주기는 어떻게 되어야 하는가

커뮤니티의 유형을 나눠보자면 카페 형 커뮤니티와, 플랫폼 형 커뮤니티로 나눌 수 있습니다.

카페 형 커뮤니티는 비교적 적은 수의 소속감이 강한 회원들 사이에 정보 교류를 목적으로 이루어진 곳이라고 볼 수 있습니다. 그 안에서 양질의 정보를 공유하면서 빠른 피드백을 주고 받을 수 있습니다. 그러나 새로운 회원의 유입이 적어 다양한 정보를 얻기는 힘듭니다.

플랫폼 형 커뮤니티는 카페 형 커뮤니티와 장점과 단점이 반대라고 할 수 있습니다. 한 가지 주제에 국한되지 않는 다양한 정보가 공유되고 있지만, 정보에 대한 휘발성이 있습니다.

리멤버는 계속해서 새로운 회원의 유입이 이루어지고 있으며, 리멤버 커뮤니티는 큰 주제 안에서 다양한 정보들이 공유되고 있기에 리멤버 커뮤니티는 플랫폼 형 커뮤니티가 가깝다고 판단했습니다.

따라서 유저들에게 양질의 콘텐츠를 맞춤형으로 제공해주는 것 뿐만 아니라, 실시간으로 콘텐츠를 제공해주는 것을 목표로 프로젝트를 진행 했습니다.

* * *

# 2\. Recommendation System

## 2-1. Contents-based Recommendation

콘텐츠 기반 필터링 방식은 사용자가 특정 아이템을 선호하는 경우, 그 아이템과 비슷한 콘텐츠를 가진 다른 아이템을 추천해 주는 방식 입니다.

![]({{ site.baseurl }}/images/nyVwvzzFyz.png)

유저가 관심분야의 글을 많이 읽을 것이라는 가정하에 콘텐츠 기반 필터링 방식을 선택했습니다. 커뮤니티에서 글을 추천해주는 방식으로는 유저가 커뮤니티에서 읽은 글과 유사한 글들을 추천해주는 방식을 적용하고자 했습니다.

## 2-2. Unsupervised - SimCSE

유사한 콘텐츠를 추천해주기 위해서는 추천이 필요한 각 게시물(콘텐츠)들을 잘 표현해주는 것이 중요합니다. 저희는 각 게시물을 잘 표현하기 위한 모델로 Sentence Representation 모델인 SimCSE(Simple Contrastive Learning of Sentence Embeddings)를 채택했습니다. Input Sentence에 대해서 dropout을 noise로 사용해 contrastive object에서 스스로를 예측하는 비지도학습이 가능한 모델 입니다. 아래 그림과 같이 한 mini-batch에 있는 문장들 안에서, dropout이 적용된 같은 문장을 postive pair로서 활용, 다른 문장들을 negative pair로써 활용하여 contrastive learning을 학습하는 Sentence Representation 모델 입니다.

![]({{ site.baseurl }}/images/dAoKEQxIt0.png)

Unsupervised SimCSE 학습 과정 \[6\]

해당 모델의 loss function은 위 그림과 같습니다. 분자는 같은 문장을 다르게 표현한 것들의 유사도, 분모는 다른 문장을 다르게 표현한 것들의 유사도의 합입니다. 즉, 분자는 커지고, 분모는 작아질수록 같은 것들의 유사도는 높아지고, 다른 것들 사이의 유사도는 낮아질수록 loss가 작아지는 형태로 학습됩니다.

따라서 저희는 리멤버 커뮤니티의 글을 활용하여 Unsupervised learning(비지도학습) 방식으로 SimCSE를 fine-tuning했고 그를 통해서 리멤버 커뮤니티 도메인 최적화된 임베딩을 표현할 수 있도록 했습니다.

# 3\. Our Method

## 3-1. Contents Embedding

콘텐츠를 구성하는 데이터들을 앞서 설명한 SimCSE 모델을 기반으로 임베딩 벡터를 추출합니다. 사용한 SimCSE 인코더는 transformer 기반의 모델인 BERT를 활용했습니다. 각 콘텐츠의 임베딩 벡터는 ”제목”, “본문”, “카테고리”, “좋아요 클릭 여부”, “댓글작성 여부”를 활용하여 생성했습니다. ”커뮤니티 유형”, “입력 시간” 역시 활용하려고 하였으나 추천 결과에 대한 정성 / 정량 평가를 기준으로 표현에서 제외 하게 되었습니다.

![]({{ site.baseurl }}/images/3317qqydGX.png)

## 3-2. 가중평균을 활용한 유저 임베딩 벡터 생성

가중 평균은 데이터 세트에서 일부 요인의 상대적 중요도 또는 빈도를 고려합니다.

유저가 읽은 콘텐츠 임베딩의 가중 평균 값을 유저 임베딩으로써 활용했습니다. 유저 임베딩과 코사인 유사도가 높은 콘텐츠들을 추천해주는 방식으로 추천을 진행했습니다.

##### 변수를 가중치로써 활용

여러 변수를 검증해봤을때 가장 성능이 좋았던 좋아요와 댓글 작성 여부를 활용해서 가중치를 적용하여 가중평균한 임배딩을 산출 했습니다.

![]({{ site.baseurl }}/images/iZXwuB0CPj.png)

## 3-3. 전체 추천 로직

전체적인 추천 로직을 정리해보자면, 유저 임베딩과 유저가 참여중인 커뮤니티의 콘텐츠들과 유사도를 비교하여 가장 유사한 top K개를 추천해주는 로직 입니다.

![]({{ site.baseurl }}/images/MFSOLsoFoH.png)

* * *

# 4\. 서비스 적용에 대한 문제

## 4-1. 속도 문제

- 유저가 접속할 때 마다 모델을 활용한 추론을 통해서 임베딩을 생성하면 시간이 오래 걸릴 것이라고 판단 했습니다.
- 기존에 고려한 방식
    - MongoDB에 임베딩을 저장 후, 유저가 커뮤니티에 접속하면 임베딩을 추출하여 비교
    - MongoDB에서 추천 후보군에 대한 임베딩을 전부 추출하는데 걸리는 시간이 실시간 서비스로 적용하기에는 매우 어려운 수준
    - 서비스를 제공할때 업데이트 주기를 길게 설정하여 서비스 적용
- 변경된 방식
    - ElasticSearch 도입으로 별도의 DB조회 없이 검색엔진 안에서 벡터 간 유사도 계산

## 4-2. MongoDB

- MongoDB 란?
    - MongoDB는 기존의 테이블 기반 관계형 데이터베이스 구조가 아닌 문서 지향 데이터 모델을 사용하는 교차 플랫폼 오픈 소스 데이터베이스입니다. 이러한 유형의 모델을 사용하면 정형 및 비정형 데이터를 보다 쉽고 빠르게 통합할 수 있습니다.
- 변경 전 방법  
    ![]({{ site.baseurl }}/images/06e9PxqXRf.png)

- 처음 고려했던 서비스 제공 방식은 위와 같이 설명할 수 있습니다.
    1. 유저가 리멤버 커뮤니티에 접속
    2. MongoDB에서 유저의 임베딩 값을 추출
    3. 유저에게 추천될 수 있는 카테고리의 콘텐츠 임베딩 값들을 추출하여 유저 임베딩 값과
    4. 코사인 유사도를 비교
    5. 유저에게 추천되는 post id 들을 sorting하여 list 형태로 저장

MongoDB만을 활용해서 서비스에 적용했을때는 치명적인 문제가 있었습니다. 각 콘텐츠의 임베딩을 저장한 MongoDB collection에서 추천 후보군 몇 천 개의 임베딩을 추출하는 데 걸리는 시간이 오래걸리는 문제 입니다.

_**총 소요시간 : 5 sec**_

그래서 저희는 고민 끝에 빠른 속도로 코사인 유사도 기반 임베딩 벡터를 찾을 수 있는 검색엔진 ElasticSearch를 활용하기로 했습니다.

* * *

# 5\. ElasticSearch (OpenSearch) 도입

## 5-1. ElasticSearch란?

Elasticsearch는 시간이 갈수록 증가하는 문제를 처리하는 분산형 RESTful 검색 및 분석 엔진입니다. Elastic Stack의 핵심 제품인 Elasticsearch는 데이터를 중앙에 저장하여 손쉽게 확장되는 광속에 가까운 빠른 검색, 정교하게 조정된 정확도, 강력한 분석을 제공합니다. 프로토타입에서 운영 배포까지 이어지는 모든 과정을 원활하게 처리할 수 있습니다. 단일 클러스터에서도 300개의 노드 클러스터에서와 동일한 방식으로 Elasticsearch를 실행합니다. 수평적 확장을 통해 매초당 수많은 양의 이벤트를 처리할 수 있으며, 클러스터에서 인덱스와 쿼리 배포를 자동화하여 보다 원활한 시스템 운영을 지원합니다.

### 5-1-1. ElasticSearch 기능

- **Elastic Enterprise Search** : 데이터베이스 검색, 엔터프라이즈 시스템 오프로드, 전자 상거래, 고객 지원, 워크플레이스 콘텐츠, 웹사이트 또는 모든 애플리케이션에 Elastic을 사용하여 모든 사람이 필요한 것을 더 빨리 찾을 수 있습니다.
- **Infrastructure Monitoring** : AWS, Microsoft Azure 및 Google Cloud와 같은 클라우드 플랫폼을 포함하여 200개 이상의 통합을 지원하여 인프라를 원활하게 모니터링이 가능합니다.
- **엔드포인트를 위한 Elastic Security** : 엔드포인트를 위한 Elastic Security는 랜섬웨어 및 Malware를 방지하고, 지능적 위협을 탐지하며, 대응자에게 중요한 조사 컨텍스트를 제공합니다.

- 이 외에도 로그 모니터링, APM(Application Performance Monitoring), 위치탐색 등 모니터링 서비스와 검색 서비스를 제공하고 있습니다.

ElasticSearch의 기능을 서비스에 적용하기 위하여 저희 팀에서는 Amazon OpenSearch Service를 활용했습니다.

### 5-1-2. Amazon OpenSearch Service란?

Amazon OpenSearch Service는 인프라 관리, 모니터링 및 유지 관리에 대한 걱정이나 OpenSearch 클러스터 운영에 대한 심층적인 전문성을 쌓을 필요 없이 OpenSearch 클러스터를 실행하고 확장할 수 있는 AWS 관리형 서비스입니다. OpenSearch는 Apache Lucene 검색 라이브러리로 구동되며 k-nearest neighbors(KNN) 검색, SQL, Anomaly Detection, Machine Learning Commons, Trace Analytics, 전체 텍스트 검색 등 다수의 검색 및 분석 기능을 지원합니다. OpenSearch는 ALv2 버전의 Elasticsearch 및 Kibana에서 포크를 만들어 유지하고 있습니다. Elasticsearch에서 제공되는 새로운 기능과 유사한 기능이 OpenSearch에 포함될 수 있지만(그 반대의 경우도 마찬가지) 모든 기능의 구현은 두 프로젝트 간에 고유합니다.

#### k-NN(_k-nearest neighbors)_

k-NN을 사용하면 벡터 공간에서 포인트를 검색하고 해당 포인트에 대한 “가장 가까운 이웃”을 Euclidean 거리 또는 코사인 유사도로 찾을 수 있습니다.

![]({{ site.baseurl }}/images/AEQOtiNBnr.png)

##### HNSW (Hierarchical Navigable Small World Algorithm)

![]({{ site.baseurl }}/images/kqahmeWdgt.png)

OpenSearch에서 k-NN 검색문제에 대해서 빠르고 정확한 솔루션을 제공하기위해서 HNSW 알고리즘을 기반으로 하여 검색엔진이 동작합니다. 이 알고리즘은 적은 거리를 계산하고, 거리 계산 비용을 더 저렴하게 하도록 하는 것을 중점적으로 두고 있습니다. 입력 쿼리에 대한 가장 가까운 이웃을 찾기 위해 검색 프로세스는 최상위 계층의 그래프에서 가장 가까운 이웃을 찾고 이 점을 후속 계층에 대한 진입점으로 사용합니다.

##### OpenSearch k-NN 데이터 입력 예시

인덱스 생성 : k-NN 관련 index는 다음과 같이 설정할 수 있는데, “dimension”을 통해서 계산하는 임베딩 벡터의 차원을 사전에 정의합니다.

```
PUT /myindex
{
 "settings": {
      "index.knn": true
      },
 "mappings": {
     "properties": {
          "my_vector": {
                "type": "knn_vector",
                "dimension": 2
              }
         }
    }
}
```

데이터 입력 : 콘텐츠에 대해서 생성된 임베딩 벡터 및 데이터 입력합니다.

```
PUT /myindex/_doc/1
{
  "my_vector": [1.5, 2.5]
}

PUT/myindex/_doc/2
{
  "my_vector": [2.5, 3.5]
}
```

저희가 개발한 추천로직에서 Sentence Representation에 활용한 SimCSE 모델로 생성한 최종 임베딩 벡터는 1,638차원 입니다. OpenSearch에서는 최대 10,000 차원까지의 임베딩 벡터에 대해서 검색기능을 제공하고 있습니다.

OpenSearch에서는 3가지 다른 방법의 쿼리 벡터에 대해서 k-NN의 결과를 얻을 수 있는 3가지 다른 방법을 제공 합니다.

1. **Approximate k-NN**
    - 첫 번째 방법은 Approximate k-NN입니다. 여러 알고리즘 중 하나를 사용하여 대략적인 k-NN 결과를 쿼리 벡터로 반환합니다. 일반적으로 이러한 알고리즘은 더 짧은 대기 시간, 더 작은 메모리 공간 및 더 확장 가능한 검색과 같은 성능 이점이 있습니다. 그러나 인덱싱 속도와 검색 정확도의 성능은 일부 떨어질 수 있다는 단점이 있습니다.
2. **Script Score k-NN**
    - 두 번째 방법은 Script Score k-NN 입니다. OpenSearch의 Script Score 기능을 확장하여 나타나는 “knn\_vector”에 대하여 정확한 k-NN 검색을 수행합니다. 이 방식을 사용하면 인덱스에 있는 벡터의 하위 집합에 대해서 k-NN 검색을 실행할 수 있습니다. 따라서, 존재하는 벡터에 대해서 사전 필터링이 필요할 경우에 이 방식을 사용합니다.
3. **Painless extensions**
    - 세 번째 방법은 Painless extensions 입니다. 두 번째로 언급 드린 Script Score k-NN에 비하여 쿼리 성능이 약간 느리다는 단점이 존재합니다. 그러나 거리함수를 더 복잡한 상황에서 적용할 수 있다는 장점이 있습니다.

저희는 소속된 커뮤니티와 날짜를 관련한 필터링 조건이 필요하기 때문에 Script Score k-NN을 선택하여 진행했습니다. _(복잡하지 않은 조건이기 때문에 속도가 더 빠른 Script Score k-NN 사용)_ 이를 통해서 소속된 커뮤니티 등록 날짜 등의 조건으로 필터링된 대상에 대한 검색을 수행할 수 있었습니다.

- 변경 후 방법  
    ![]({{ site.baseurl }}/images/brnT1ol414.png)

1. 유저가 리멤버 커뮤니티에 접속
2. MongoDB에서 유저의 임베딩 값을 추출
3. 유저에게 추천될 수 있는 카테고리의 콘텐츠 임베딩 값들을 추출하여 유저 임베딩 값과
4. 코사인 유사도를 비교하여 list 형태로 해당 post id들을 반환

## 5-2. 속도 개선 결과

MongoDB를 활용하여 임베딩 벡터를 추출할 때 생겼던 병목을 OpenSearch 내에서 한번에 해결함으로써 시간을 대폭 감축할 수 있었습니다. 유저 임베딩을 업데이트하는 부분에 대해서는 NiFi 라고하는 별도의 시스템을 활용하여 구성하였습니다.

임베딩을 추출하고 유사도를 계산하는 추천 로직에 있어서 평균적으로 _**0.2 sec**_ 로 결과를 반환하는 API를 생성할 수 있었습니다.

![]({{ site.baseurl }}/images/nnAsh0YpgP.png)

* * *

# 결론

구축한 추천 로직을 활용하여 A/B test를 진행했습니다. A/B test를 통해 추천 로직으로 배포된 글과 “최신글 + 인기글(좋아요, 댓글 다수)”의 클릭률을 비교했습니다. 그 결과, 인기글 보단 클릭률이 낮았고 최신글보단 클릭률이 높은 결과가 나타났습니다.

![]({{ site.baseurl }}/images/6ir0f9EOks.png)

좀 더 다양한 변수를 활용한 고도화된 모델에 대한 연구 진행을 검토했으나 내부 사정으로 인해서 추가 연구와 서비스까지는 이어지지는 못했습니다. 그러나 머신러닝 모델에 대한 서비스 적용은 결과 평가에 앞서서 서비스에 어떻게 적용할 것인지를 고민하는 것이 중요하다는 것을 다시 한번 느끼게 해주는 프로젝트 였습니다.

실제 예시로 여러 추천 알고리즘들을 서비스에 도입 시에는 빠른 업데이트를 이유로 knn 유사도 방식으로 서비스를 제공했다고 합니다. 이처럼 머신러닝을 서비스에 적용하기 위해서는 머신러닝의 성능에 대한 고려와 서비스 제공에 대한 고려를 동시에 하는 것이 중요합니다.

리멤버 빅데이터 센터 AI Lab에서는 꾸준히 최신 연구를 활용하여 인재 추천 서비스, 광고 추천 서비스, 명함 인식 등 다양한 연구를 수행하고 있습니다. 차후 AI Lab 에서 연구하는 다른 분야를 소개하고 공유하며 찾아뵙도록 하겠습니다.

궁금하신 사항은 댓글을 통해 문의 부탁드리며 긴 글 읽어주셔서 감사합니다.

* * *

# Reference

- \[1\] [https://community.rememberapp.co.kr/main](https://community.rememberapp.co.kr/main)
- \[2\] [](https://aws.amazon.com/ko/what-is/opensearch/)[https://aws.amazon.com/ko/what-is/opensearch/](https://aws.amazon.com/ko/what-is/opensearch/)
- \[3\] opensearch knn documentation.. [https://opensearch.org/docs/latest/search-plugins/knn/index/](https://opensearch.org/docs/latest/search-plugins/knn/index/)
- \[4\] [https://opensearch.org/blog/odfe-updates/2020/04/Building-k-Nearest-Neighbor-(k-NN)-Similarity-Search-Engine-with-Elasticsearch/](https://opensearch.org/blog/odfe-updates/2020/04/Building-k-Nearest-Neighbor-(k-NN)-Similarity-Search-Engine-with-Elasticsearch/)
- \[5\] MongoDB documentation, [](https://www.mongodb.com/docs/)[https://www.mongodb.com/docs/](https://www.mongodb.com/docs/)
- \[6\] Transformer, Vaswani, Ashish, et al. "Attention is all you need." _Advances in neural information processing systems_ 30 (2017).
- \[7\] Devlin, Jacob, et al. "Bert: Pre-training of deep bidirectional transformers for language understanding." _arXiv preprint arXiv:1810.04805_ (2018).
- \[8\] SimCSE, Gao, Tianyu, Xingcheng Yao, and Danqi Chen. "Simcse: Simple contrastive learning of sentence embeddings." _arXiv preprint arXiv:2104.08821_ (2021).
