import 'dart:math';

class RandomNicknameGenerator {
  // 형용사 리스트
  static const List<String> adjectives = [
    "배부른",
    "행복한",
    "용감한",
    "활기찬",
    "지혜로운",
    "즐거운",
    "슬기로운",
    "긍정적인",
    "평화로운",
    "창의적인",
  ];

  // 명사 리스트
  static const List<String> nouns = [
    "토끼",
    "사자",
    "호랑이",
    "고양이",
    "강아지",
    "여우",
    "나무늘보",
    "팬더",
    "코알라",
    "펭귄",
    "햄스터",
    "다람쥐",
    "앵무새",
    "알파카",
    "쿼카",
  ];

  // 랜덤 생성기
  static final Random _random = Random();

  // 닉네임 생성 메서드
  static String generateNickname() {
    // 형용사와 명사 리스트에서 랜덤으로 하나씩 선택
    String adjective = adjectives[_random.nextInt(adjectives.length)];
    String noun = nouns[_random.nextInt(nouns.length)];

    // 0에서 9999 사이의 랜덤 숫자 생성
    int number = _random.nextInt(10000);

    // 닉네임 조합
    return "$adjective $noun $number";
  }
}
