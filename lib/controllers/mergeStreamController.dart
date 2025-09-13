import 'package:rxdart/rxdart.dart';

class MyCombinedData<T1, T2> {
  final T1 data1;
  final T2 data2;

  MyCombinedData(this.data1, this.data2);
}


Stream<MyCombinedData<T1, T2>> combineStreams<T1, T2>(
    Stream<T1> stream1, Stream<T2> stream2) {
  return Rx.combineLatest2<T1, T2, MyCombinedData<T1, T2>>(
    stream1,
    stream2,
    (data1, data2) => MyCombinedData(data1, data2),
  );
}
