// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/register_usecase.dart';

import 'package:quizflow_frontend/main.dart';
import 'package:quizflow_frontend/features/auth/domain/usecases/login_usecase.dart';

// 1️⃣ LoginUseCase를 Mock 객체로 생성
class FakeLoginUseCase extends Mock implements LoginUseCase {}
class FakeRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  testWidgets('로그인 테스트', (WidgetTester tester) async {
    // 2️⃣ 가짜 LoginUseCase 인스턴스 생성
    final fakeLoginUseCase = FakeLoginUseCase();
    final fakeRegisterUseCase = FakeRegisterUseCase();

    // 3️⃣ MyApp을 생성할 때 fakeLoginUseCase 전달
    await tester.pumpWidget(MyApp(
        loginUseCase: fakeLoginUseCase,
        registerUseCase: fakeRegisterUseCase,
    ));

    // 4️⃣ 초기 상태 검증
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 5️⃣ '+' 버튼 클릭
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 6️⃣ 값이 증가했는지 확인
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
