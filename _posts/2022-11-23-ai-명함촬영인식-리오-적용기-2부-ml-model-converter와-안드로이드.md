---
layout: "post"
title: "AI 명함촬영인식 '리오(RIO)' 적용기 2부 - ML Model Converter와 안드로이드 앱 적용기"
author: "minseokkang"
date: "2022-11-23"
categories: 
  - "ailab"
tags: 
  - "ai-명함-촬영-인식"
  - "client-side-computing"
  - "edge-computing"
  - "intermediate-representation"
  - "ml-model-converter"
  - "rio"
  - "tensorflow-lite"
  - "리오"
---

안녕하세요. 빅데이터센터 AI Lab 강민석입니다.

이번 **AI 명함 촬영 인식 ‘리오(RIO)’** 적용기 2부에서는 리멤버 앱에 AI 명함 촬영 인식 ‘리오(RIO)’의 모델을 Client-Side Computing로 적용하기 위한 다양한 시행착오들을 공유하고자 합니다. 학습된 PyTorch Model을 ONNX와 Tensorflow 모델을 거쳐 TF Lite Model로의 변환과정과 모델 추론 안드로이드 샘플 환경에서의 테스트까지 내용을 소개 하고자 합니다. 이 글에서 AI 명함 촬영 인식 ‘리오(RIO)’ 적용을 위해 최종적으로 진행된 **ML 모델의 변환 방법**과 **모델 추론을 위한 안드로이드 테스트 환경**에 대해 설명 드리고자 합니다.

이 AI 명함 촬영 인식 ‘리오’ 적용기 포스팅은 1부와 2부로 나누어 포스팅 되어 있습니다. 이번 AI 명함 촬영 인식 ‘리오’ 적용기 2부에서는 ML Model Converter와 안드로이드 앱 적용기에 대해 작성 되어있습니다.

- **AI 명함 촬영 인식 ‘리오(RIO)’ 적용기 1부 - 명함 촬영 인식 위한 Instance Segmentation & Computer Vision**

- **AI 명함 촬영 인식 ‘리오(RIO)’ 적용기 2부 - ML Model Converter와 안드로이드 앱 적용기**

## **Client-Side Computing (또는 Edge Computing)**

**Client-Side Computing**은 데이터를 클라우드 서버로 보내는 대신 로컬 기기에서 처리하는 것입니다. 기계 학습과 관련하여 Client-Side Computing은 장치에서 추론이 직접 수행하는 것을 의미합니다. AI 명함 촬영 인식 ‘리오(RIO)’가 Client-Side Computing 사용 해야 하는 데에는 4가지 주된 이유가 있습니다.

1. **실시간 추론** : 리멤버 앱이 동작하는 모바일 장치의 ML 모델 추론 계산은 네트워크를 통해 API 결과를 기다리는 것보다 빠릅니다. 실시간으로 사용자에게 명함의 위치를 보여주고 명함의 영역을 잘라내 제공합니다.
2. **오프라인 기능** : Client-Side Computing은 인터넷 연결 없이도 명함이 촬영되는 순간부터 명함의 위치와 명함의 영역 잘라서 명함의 이미지만을 제공하게 됩니다.
3. **데이터 프라이버시** : 인터넷을 통해 전송되거나 클라우드 데이터베이스에 추가로 저장되는 위험을 낮춰 줍니다.
4. **비용 절감** : ML 서버가 필요하지 않으므로 서버 비용이 절감됩니다. 이 외에도 명함 이미지가 서버로 전송되지 않기 때문에 데이터 전송 네트워크 비용이 절감됩니다.

Client-Side Computing의 경우 큰 장점들이 있지만 다양한 제약 사항들이 생기게 됩니다. 모바일 기기의 처리능력의 제한, 모델 크기(용량)에 대한 제한, 모바일 적용을 위한 ML 프레임워크의 의존성에 대한 제약 사항들이 생기게 되고 이를 해결 하려는 다양한 리서치를 진행 하게 되었습니다. 이 과정에서 생긴 시행착오와 다양한 고민을 공유하여 관련 연구자 또는 개발자들의 시간을 절약하게 되었으면 좋겠습니다.

# **ML Model Converter**

학습된 ML 모델을 모바일과 같은 사용자의 장치에서 적용하기 위해서는 지연 시간, 개인 정보 보호, 다양한 기기와의 연결성, 모델의 크기, 전력 소비 등을 고려해야 한다는 문제가 존재합니다. 저희는 Pytorch Model을 TF Lite Model로 최종 모델로 변환하기로 하였는데, 그 이유는 산업과 관련된 제한 사항과 요구 사항에 대해 오랜 기간 긴밀히 발전해오고 있는 Tensorflow Lite의 안정성과 Arm CPU 연산에 최적화된 더 많은 사례가 있으므로 타 프레임워크 환경들과 비교하여 더 나은 성능을 쉽고 빠르게 적용 가능 하다고 판단했습니다.

아래의 글에서 Pytorch Model을 TF Lite Model로 변환하는 과정을 설명하고자 합니다. 변환 과정은 **PyTorch Model → ONNX Graph(+TorchScript)→ Tensorflow Model → TF Lite Model** 순으로 진행하였습니다. 관련 기술을 소개하고 변환하는 방법에 대해 설명해 드리도록 하겠습니다.

## **PyTorch Model을 ONNX Graph(+TorchScript)로의 변환**

최종 모델인 Tensorflow Lite 모델로 변환하기 위해서는 중간 과정에 Tensorflow 모델로 변환이 필요한데, Pytorch Model을 직접 Tensorflow 모델로 변환하는 기능이 제공되어 있지 않습니다. 그래서 먼저 상호 운용가능한 ONNX 그래프로 변환을 하게 됩니다. PyTorch에서 제공되는 ONNX 그래프로 변환하는 **`torch.onnx.export()`** 함수를 통해 PyTorch 모델을 ONNX\*로 변환하였습니다.

> **ONNX**는 Open Neural Network Exchange의 줄인 말로서 이름과 같이 다른 ML 프레임워크 환경(Tensorflow, PyTorch 등)에서 만들어진 모델들을 서로 호환될 수 있도록 만들어진 공유 플랫폼입니다.

![]{{ site.baseurl }}/images/4zN8hbGHaQ.png)

그림 1. TorchScript의 Script Mode 변환\[1\]

`**torch.onnx.export()**` 함수의 실제 동작은 내부적으로 TorchScript를 통해 코드를 Eager Mode에서 Script Mode로 변환하여 중간 표현(Intermediate Representation, IR)\* 그래프를 ONNX 그래프로 변환하기 전에 생성하게 됩니다. 그 이후에 Pytorch의 Script Mode의 중간 표현(IR)\*을 ONNX 그래프로 변환하여 반환하게 됩니다.

> **중간표현(Intermediate Representation, IR)**은 소스 코드를 나타내기 위해 컴파일러 또는 가상 머신에서 내부적으로 사용하는 데이터 구조 또는 코드입니다. IR은 최적화 및 모델 변환과 같은 추가적인 처리 과정에 도움이 되도록 설계되어 있습니다.

![]{{ site.baseurl }}/images/Jlg6NjoVbw.png)

그림 2. ONNX의 상호 운용성 \[2\]

ONNX 그래프로 모델 표현 하게 되면 다른 프레임 워크로 모델 표현(Framework Interoperability)이 가능한 것 뿐만 아니라, 이 과정에서 ONNX에서 제공되는 것 이외에도 최적화된 구조의 그래프 표현이 유지된 상태(Shared Optimization)로 변환될 수 있다는 이점이 있습니다. 이 과정에서 산업영역의 여러 하드웨어와 ML 컴파일러에 대한 다양한 선택지를 제공 받았던 것 같습니다.

## **ONNX Graph를 Tensorflow Lite model로의 변환**

ONNX Graph를 Tensorflow Lite model(.tflite 파일 확장자로 식별되는 최적화된 FlatBuffer 형식)로 변환하기 위해서는 중간 과정으로 Tensorflow Model로의 변환이 필요합니다. 이를 위해서 ONNX를 위한 Tensorflow 백엔드 onnx-tensorflow\[3\]에서 제공되는 `**onnx_tf.backend.prepare(onnx_model)**` 함수를 사용하여 ONNX Graph를 Tensorflow 모델로 변환해줍니다. 그 이후에 TensorFlow Lite\*\[4\]에서 제공되는 `**tf.lite.TFLiteConverter.from_saved_model(tf_model_path)**` 함수를 사용하여 Tensorflow 모델을 Tensorflow Lite model로 변환해주는 작업을 진행합니다.

> **TensorFlow Lite**는 Android 및 iOS, 내장형 Linux 및 마이크로 컨트롤러 등의 기기에서 모델을 실행할 수 있는 기능을 제공하기 위해 On-device에서 ML을 위한 해석기(Interpreter)와 라이브러리를 지원하는 프레임워크 입니다.

![]{{ site.baseurl }}/images/gSBDpq92eR.png)

그림 3. 모델 변환을 위한 high-level workflow\[4\]

Pytorch Model을 TF Lite Model로의 변환 과정을 코드로 보면 20줄 내외의 간단한 API 호출 몇 줄로 표현되지만, 내부적인 동작에 대해 상세하게 설명해 보았습니다. Quantization을 추가로 실험하였지만 정확도가 다소 떨어지는 경향이 있었습니다. 아래의 표에서는 모델의 크기를 단순 비교한 테이블입니다. 각 모델에 대한 속도에 대한 비교는 각각 목표 하드웨어에 따라 최적화 방법이 달라 비교하지 않고 Quantization을 제외한 모든 비교 모델에서의 정확도 차이가 크게 나타나지 않아 표기하지 않았습니다.

![]({{ site.baseurl }}/images/NDgIKxKatq.png)

표 1. 모델 표현 방법에 따른 모델 사이즈 비교

# **모델 추론을 위한 안드로이드 테스트** **데모** **앱**

## **On-deivce 모델 추론을 위한 Tensorflow Lite Interpreter**

![]{{ site.baseurl }}/images/OaJ6rbAFf3.png)

그림 4. On-device에서의 TensorFlow Lite를 사용하여 모델 배포 \[5\]

위의 내용에서 AI 명함 촬영 인식 ‘리오(RIO)’를 Client-Side Computing에서 사용하기 위해 ML Model Converter에 관해 소개했습니다. 실제 모바일 기기에서 ‘리오(RIO)’ 모델의 추론을 진행하기 위해 Tensorflow Lite Interpreter를 활용하게 되는데 위의 그림 4와 같이 모바일 기기의 하드웨어를 사용하게 됩니다.

![]{{ site.baseurl }}/images/EBXjsVS4Xs.png)

그림 5. TensorFlow Lite의 아키텍처 디자인 \[6\]

앱 내에서는 그림 5와 같이 Tensorflow Lite는 앱 내에서 추론 모델을 로드하고 인터프리터를 호출하는 C++ API , 주변의 Convenience Wrapper 역할을 하는 Android 앱용 Java API가 제공됩니다. Java API를 통해 모델을 호출하고 Tensorflow Lite 인터프리터를 사용하여 Tensorflow Lite 모델의 앱내 추론을 진행하게 됩니다.

## **JNI과 OpenCV를 활용한 Post Processing**

Tensorflow Lite Interpreter 모델 추론을 통해 얻게 된 결과는 아웃풋 차원 변환, NMS(Non-maximum Suppression), 다양한 후처리가 필요한 이전의 저차원의 피처 값들로 반환하게 되어 있습니다. 이를 처리하기 위해서는 Python 인터프리터의 사용 없이 자바에서 구현이 되어야 하는데 자바보다는 속도 측면의 이점이 있고 OpenCV 활용이 수월한 C++로 구현한 다음 JNI 통해 호출하도록 구현하였습니다.

다양한 차원 변환 함수와 NMS(Non-maximum Suppression)는 직접 구현하여 호출하도록 설계 하였고 AI 명함 촬영 인식 ‘리오(RIO)’ 적용기 1부에서 설명된 Post Processing의 여러 함수는 OpenCV를 활용하여 구현하게 되었습니다.

## **AI 명함 촬영 인식 ‘리오(RIO)’ 테스트용 데모 앱**

![]{{ site.baseurl }}/images/tf68lTTmM9.png)

그림 6. AI 명함 촬영 인식 ‘리오(RIO)’ 테스트용 데모앱 그림

![]({{ site.baseurl }}/images/DvUxsqkCuT.gif)

그림 7. AI 명함 촬영 인식 ‘리오(RIO)’ 배포 버전

AI 명함 촬영 인식 ‘리오(RIO)’를 안드로이드 앱에서 실험하기 위해 그림 6과 같이 테스트용 앱을 제작해 다양한 실험을 진행했습니다. 주로 안드로이드 앱에서의 모델 로드, 모델 추론, 다양한 후처리에 대한 동작 테스트를 진행하고 보다 다양한 환경에서 촬영해가며 리멤버 앱 사용자가 촬영할만한 상황을 연출하여 테스트를 진행했습니다. 이 과정에서 안드로이드 테스트용 앱 제작부터 실험 작업까지 동료분들의 많은 도움을 받아 진행하게 되었습니다.

# **AI 명함 촬영 인식 ‘리오(RIO)’ 적용기 1부~2부를 마치며**

AI 명함 촬영 인식 ‘리오(RIO)’ 적용기 1부 - 명함 촬영 인식 위한 Instance Segmentation & Computer Vision을 거쳐, 2부 - ML Model Converter와 안드로이드 앱 적용기까지 내용을 설명해 드렸습니다. AI 명함 촬영 인식 ‘리오(RIO)’ 를 개발하면서 다양한 기술을 실험하고 테스트해나가면서 많은 시행착오를 겪었던 것 같습니다. 일련의 과정을 해결해 나가는 데 있어서 리멤버의 동료가 지니고 있는 “고객 WOW를 위한 빠른 실행을 팀웍으로”의 리멤버 Way를 직접 느꼈던 프로젝트였습니다. 프로젝트 관련해 도움을 주신 많은 분들께 다시 한번 감사드립니다.

# **Reference**

\[1\] TorchScript — PyTorch documentation

\[2\] ONNX: Preventing Framework Lock in | Fernando López | Medium

\[3\] onnx/onnx-tensorflow: Tensorflow Backend for ONNX | github.com

\[4\] 모바일 및 에지 장치용 ML | TensorFlow Lite

\[4\] Convert TensorFlow models | TensorFlow Lite

\[5\]Tensorflow Lite- machine learning at the edge!! | by Maheshwar Ligade | techwasti | Medium

\[6\] Google Developers Blog: Announcing TensorFlow Lite | googleblog.com
