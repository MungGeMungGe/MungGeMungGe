class MgLocation {
  final int seq;
  final String name; // 장소명
  final String detail; // 장소에 대한 설명
  final double latitude; // 위도
  final double longitude; // 경도
  final String institution; // 관리기관명
  final int capacity; // 최대 수용 가능 인원
  final bool is_wifi; // 와이파이 여부
  final bool is_charge; // 충천 가능 여부
  final bool is_vantilation; // 환기 시설 여부
  final String place_class; // 장소구분, 실내인지 실외인지 등...
  final String address_jibun; // 지번 주소
  final String address_road; // 도로명 주소

  MgLocation({
    required this.seq,
    required this.name,
    required this.detail,
    required this.latitude,
    required this.longitude,
    required this.institution,
    required this.capacity,
    required this.is_wifi,
    required this.is_charge,
    required this.is_vantilation,
    required this.place_class,
    required this.address_jibun,
    required this.address_road
  });

  Map<String, dynamic> toMap() {
    return {
      'seq': seq,
      'name': name,
      'detail': detail,
      'latitude': latitude,
      'longitude': longitude,
      'institution': institution,
      'capacity': capacity,
      'is_wifi': is_wifi,
      'is_charge': is_charge,
      'is_vantilation': is_vantilation,
      'place_class': place_class,
      'address_jibun': address_jibun,
      'address_road': address_road
    };
  }
}
