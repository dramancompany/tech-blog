---
layout: "post"
title: "Learning to Rank"
author: "mgpark"
date: "2022-04-06"
categories: 
  - "ailab"
---

안녕하세요!😀  빅데이터센터 AI Lab 박민규입니다.

저번달에 작성한 Document Understanding 글에서 저희 빅데이터센터에서는 Recommendation System을 연구하고 있다고 했었는데요. 이번 글에서는 Recommendation System에서 사용되는 **Learning to Rank(LTR)**에 대해 소개하려고 합니다.

## Learning to Rank(LTR)이란 무엇일까?

Learning to Rank(LTR)란 Ranking System에서 머신러닝을 사용하는 방법론을 말합니다.

Ranking System은 아래와 같은 분야에서 사용되고 있습니다.

- **Search Engines** : 구글 같은 웹페이지에서 검색 시 나오는 결과들(문서)를 연관성이 높은 순서로 정렬하기.

![](/images/5UabfeBH5b.png)

Figure 1. Searching “artificial intelligence” in Google Search Engines.

- **Recommendation System** : 유저의 특성에 따라 가장 유저에게 알맞을 것 같은 Item을 추천 점수가 높은 순서대로 정렬하기.

![](/images/4WudIwqr1D.png)

Figure 2. Personalized ranked contents in Netflix.

Ranking System은 Query(검색어, 유저의 특성 등)에 따라 Item들(문서, 컨텐츠 등)이 연관성 높은 순서로 정렬되는 알고리즘이라고 말할 수 있습니다.

LTR은 이러한 Ranking System을 **머신러닝에 적용하여 Query와 Item의 연관성 점수를 예측**합니다. 머신러닝을 사용하기 이전에는 **Vector Space Model, Probabilistic model**과 같은 전통적 방법을 사용하여 Item의 Ranking을 구했습니다.

## 머신러닝 이전 Model

1\. Vector Space Model

- TF-IDF(여러 문서 안에서 단어의 상대적인 중요도)와 같은 방법으로 Query와 Item(문서)를 각각 임베딩하여 Query-Item relevance score(cosine similarity)를 구하고 높은 유사도 값을 가지는 Item을 상위에 위치시킬 수 있습니다.

2\. Probabilistic Model

- BM25 : TF와 IDF, 문서 길이 등을 가지고 Query와 Item(문서)의 relevancy를 구하는 방법으로 TF-IDF보다 성능이 좋을 것으로 알려졌습니다.
- Language model : Likelihood 방법을 활용하여 Query가 Item의 임의의 샘플로 관찰될 확률에 따라 Item 순위를 구합니다.

## Ranking에 사용되는 Metric

Ranking에서는 모델이 얼마나 Item에 대한 순위를 잘 매기는지 측정하기 위해 다음과 같은 metric(평가 지표)를 사용합니다.

### MRR(Mean Reciprocal Rank)

![](/images/aR1jKtdBxe.png)

각 Query마다 1위 Item을 맞춘 점수를 평균하는 방법입니다. Query에 대해 여러 Item들이 rank됐을 때 test set의 정답(1위)인 Item이 몇위에 있는가에 따라 reciprocal rank가 계산됩니다. 그리고 모든 Query의 reciprocal rank를 평균하면 MRR 점수가 산출됩니다.

해당 방법은 1위의 item의 위치만 파악하기에 다른 Item의 관련성은 무시한다는 한계점을 가집니다.

## Precision at k

![]({{ site.baseurl }}/images/RspfzvROsY.png)

Precision은 추천된 top k의 Item 중 관련성 있는 아이템의 비율을 의미합니다. 해당 metric은 관련이 있는지 없는지만 판단합니다. 즉, rank에 대한 점수는 계산하지 않는다는 한계점을 가집니다.

### nDCG(normalized Discounted Cumulative Gain)

![](/images/ck7nPEFOWS.png)

![](/images/8a7Pw2DKBQ.png)

![](/images/mBtK1QqOAz.png)

![](/images/LC0hEv6jin.png)

nDCG는 MRR과 Precision의 단점을 모두 보완한 metric입니다.

- DCG
    - DCG는 Ranking 순서에 따라 점점 비중을 줄여 discounted된 관련 점수를 계산하는 방법입니다. 순위가 하위로 갈 수록 패널티를 준다고 보면 됩니다. Ranking 순서보다 관련성에 비중을 두고 싶으면 위 계산식 중에 두 번째 식을 사용하면 됩니다.

- IDCG → nDCG
    - DCG는 Ranking 결과 길이인 p에 따라 값이 많이 변하기에 일정 스케일의 값을 가지도록 normalize가 필요합니다. IDCG를 구하여 이를 해결할 수 있습니다.
    - DCG를 IDCG로 나누면 nDCG를 구할 수 있습니다.

## LTR을 위한 머신러닝 모델

![]({{ site.baseurl }}/images/BIQEGyzRqq.png)

Figure 3. Learning to Rank framework.

Figure 3은 LTR의 framework입니다. n개의 Query에 대해서 각 Item에 대한 m개의 feature(x)가 있고, n개의 relevance score y(예. 유저의 클릭 수, 평점 등)이 있습니다. 이 학습데이터로 모델 h를 만들어 테스트데이터를 입력했을 때 relevance score를 예측합니다. LTR에서 중요한 것은 “**어떤 손실함수(Loss Function)을 활용해 모델을 학습하는가**” 입니다.

### Loss Function

#### **Point-wise**

한개의 입력 데이터에 대해 예측된 y값과 ground truth y값에 대한 차이만 계산하는 방법입니다. MSE(Mean Square Error) loss가 대표적인 예라고 볼 수 있습니다.

#### **Pair-wise**

두개의 Item을 비교해 어느 Item이 Query와 가장 유사한지 판단하는 방법입니다. Point-wise 방법을 사용하기 위해서는 테스트데이터에 대한 ground truth값이 모두 절대적이어야 하는데 현실에서는 그러한 데이터를 찾기가 어렵습니다. 이에 대한 해결책으로 Pair-wise 방법은 두 Item 사이의 상대적인 relevancy를 학습합니다.

- RankNet : Binary Cross Entropy loss를 사용하여 Pair-wise를 학습합니다.
- LambdaRank : 높은 rank에 해당하는 Item은 높은 gradients를 주는 방식으로 학습합니다.
- LambdaMART: Grdient Boosting 방법을 활용하여 LambdaRank보다 더 좋은 성능을 냅니다.

#### **List-wise**

해당 방법은 Pair를 넘어서 Item list에 대한 모든 relevancy를 계산합니다. Ranking metric을 최대화하는 방법이기에 가장 좋은 성능을 기대할 수 있습니다.

- LambdaRank, LambdaMART는 List-wise에서도 사용가능합니다.
- SoftRank : 각 Item에 대한 rank 확률 분포를 구합니다.
- ListNet : Plackett-Luce model를 사용하여 모든 rank 조합(permutation)에 대한 loss를 계산합니다.

## 최신 LTR 연구들

딥러닝을 LTR에 적용하는 최신 연구들을 살펴보겠습니다.

### **GSF(Groupwise Scoring Function)**

![](/images/2efVal3Wqh.png)

Figure 4. GSF architecture

GSF\[2\]는 여러 Item feature들(x1, x2, x3)에 대한 조합(\[x1, x2\], \[x1, x3\], …)을 만들고 MLP를 통과시켜 각 Item에 대한 output들을 합산하여 하나의 output으로 만듭니다.

### **seq2slate**

![](/images/GgiRpvwZd2.png)

Figure 5. seq2slate architecture

seq2slate\[3\]는 Point Network의 varient와 조합된 RNN을 사용하는 방법입니다.

- 여기서 Pointer Network는 결과 출력 시 입력 문장 중 정답에 해당하는 부분의 index를 출력하는 네트워크입니다. seq2seq의 변형으로 고정된 길이의 결과를 출력하는 기존 RNN과 달리 입력에 따라 유동적인 출력이 가능합니다.

### **DLCM(Deep Listwise Context Model)**

![](/images/jE3r2J3HgF.png)

Figure 6. DLCM architecture

DLCM\[1\]은 Query와 Item의 feature를 역방향으로 GRU에 통과시킨 각 결과와 마지막 결과에 대해 local ranking function을 적용하여 score를 얻는 방법입니다.

### **Context-Aware Ranker**

![](/images/ugMGQuA07h.png)

Figure 7. Context-Aware Ranker architecture

Context-Aware Ranker\[6\]는 각 Query와 Item에 대한 feature vector를 하나로 만들어 (FF)Feed Forward Network에 입력하고, transformer를 거쳐 다시 FF에 통과시킨 후 최종 score를 얻는 방법입니다.

LTR 벤치마크 데이터셋인 MSLR-WEB30K에서 가장 좋은 성능(SOTA)을 보이고 있습니다.

## 마무리 하며

이번 포스팅에서는 LTR의 기본적인 개념과 최신연구를 살펴봤습니다. 드라마앤컴퍼니에서는 LTR의 최신연구를 활용하여 인재 추천 서비스, 광고 추천 서비스에 대한 연구를 수행하고 있습니다. AI Lab에서 구체적으로 LTR을 어떻게 적용하고 있는지는 다음에 공유하도록 하겠습니다.

궁금하신 사항은 댓글을 통해 문의해주시면 감사하겠습니다. 부족한 글 읽어주셔서 감사드립니다. 다음번에 더 좋은 글로 찾아뵙겠습니다 🤗

## Reference

\[1\] Ai, Q., Bi, K., Guo, J., & Croft, W. B. (2018, June). Learning a deep listwise context model for ranking refinement. In _The 41st international ACM SIGIR conference on research & development in information retrieval_ (pp. 135-144).

\[2\] Ai, Q., Wang, X., Bruch, S., Golbandi, N., Bendersky, M., & Najork, M. (2019, September). Learning groupwise multivariate scoring functions using deep neural networks. In _Proceedings of the 2019 ACM SIGIR international conference on theory of information retrieval_ (pp. 85-92).

\[3\] Bello, I., Kulkarni, S., Jain, S., Boutilier, C., Chi, E., Eban, E., ... & Meshi, O. (2018). Seq2slate: Re-ranking and slate optimization with rnns. _arXiv preprint arXiv:1810.02019._

\[4\] [https://en.wikipedia.org/wiki/Learning\_to\_rank](https://en.wikipedia.org/wiki/Learning_to_rank)

\[5\] Liu, T. Y. (2009). Learning to rank for information retrieval. _Foundations and Trends® in Information Retrieval_, _3_(3), 225-331.

\[6\] Pobrotyn, P., Bartczak, T., Synowiec, M., Białobrzeski, R., & Bojar, J. (2020). Context-aware learning to rank with self-attention. _arXiv preprint arXiv:2005.10084_.
