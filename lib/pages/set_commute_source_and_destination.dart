 class SourceAndDestinationCoordinates {
  double sourceLat;
  double sourceLong;
  double destLat;
  double destLong;

  SourceAndDestinationCoordinates({
    this.sourceLat = 0.0,
    this.sourceLong = 0.0,
    this.destLat = 0.0,
    this.destLong = 0.0,
  }) {
    print('SourceAndDestinationCoordinates created with '
        'sourceLat: $sourceLat, sourceLong: $sourceLong, '
        'destLat: $destLat, destLong: $destLong');
  }
}
