# Quizflow_Frontend
책을 읽지 않고 교양을 얻고 싶은 사람들을 위한 OpenAI 기반 퀴즈 서비스


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
### 참고
[프로젝트 기획 및 기술 보고서](https://github.com/dear-yy/CapstoneDesignProject/blob/main/Capstone-2ndReport-25-%EB%94%94%EC%96%B4%EB%A6%AC%20v1-2025-05-06.md)<br>
[초기 프롬프팅 기록](https://github.com/dear-yy/Quizflow_OpenAI)
