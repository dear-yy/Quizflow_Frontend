# Quizflow_Frontend


### 1. 프로젝트 개요
**타겟**: 교양 습득에 관심 있는 비독서자(MZ세대 중심)
**주요 기능**
- 사용자 입력 키워드 기반 아티클 추천 및 퀴즈 제공 (GPT 활용)
- 실시간 WebSocket 기반 1:1 배틀
- 랭킹 시스템

### 2. 프로젝트 구조
```
lib/<br>
└── features/<br>
    ├── auth/         # 로그인, 회원가입 관련 기능<br>
    ├── battle/       # 실시간 퀴즈 배틀 기능<br>
    ├── chat/         # OpenAI 기반 채팅 기능<br>
    ├── home/         # 홈 화면<br>
    ├── profile/      # 사용자 프로필 관련 기능<br>
    └── ranking/      # 랭킹 시스템<br>
```

### 3. 설치 및 실행
1. jdk 17.0.13 다운 <br>
2. 환경 변수 설정: 아래 사이트 참고 <br>
       https://kincoding.com/entry/Flutter-%EA%B0%9C%EB%B0%9C-%ED%99%98%EA%B2%BD-%EC%B4%88%EA%B8%B0-%EC%84%B8%ED%8C%85-12-Java-%EC%84%A4%EC%B9%98-%EB%B0%8F-%ED%99%98%EA%B2%BD-%EB%B3%80%EC%88%98-%EC%84%B8%ED%8C%85 <br>
3. 플러터 jdk 버전 변경 확인
   ```flutter doctor``` <br>
5. flutter doctor 전부 체크 될 수 있도록 확인하기 <br>
6. 안드로이드 스튜디오 -
   SDK manager - Languages&Frameworks - Android SDK - SDK Tools - Android SDK Command-line Tools 업데이트 <br>
8. 안드로이드 스튜디오 -
   new Flutter Project - 코틀린 선택 <br>
10. pubspec.yaml 파일에서 pub get 클릭
    또는 터미널에 입력
    ```pub get``` <br>
12. main.dart에서 get Dependencies <br>
13. Git repo 연결 <br>
14. git pull <br>
15. 로컬 서버 주소 확인 후 실행 (BE repo 참고)
    ```flutter run```

### 4. 참고
[BE repo](https://github.com/dear-yy/Quizflow_Backend)<br>
[프로젝트 기획 및 기술 보고서](https://github.com/dear-yy/CapstoneDesignProject/blob/main/Capstone-2ndReport-25-%EB%94%94%EC%96%B4%EB%A6%AC%20v1-2025-05-06.md)<br>
[초기 프롬프팅 기록](https://github.com/dear-yy/Quizflow_OpenAI)


