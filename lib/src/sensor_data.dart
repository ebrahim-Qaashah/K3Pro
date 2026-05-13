class SensorData {
  final String? mID;
  final String? mType;
  final double? mVal;

  SensorData({
    this.mID,
    this.mType,
    this.mVal,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      mID: json['mID'] as String?,
      mType: json['mType'] as String?,
      mVal: json['mVal'] != null ? (json['mVal'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mID != null) 'mID': mID,
      if (mType != null) 'mType': mType,
      if (mVal != null) 'mVal': mVal,
    };
  }

  @override
  String toString() {
    return 'SensorData(mID: $mID, mType: $mType, mVal: $mVal)';
  }
}
