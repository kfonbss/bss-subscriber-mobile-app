abstract class DownloadUseCase<Type, Param, OnReceiveProgress, CancelToken> {
  Future<Type> call({
    Param param,
    OnReceiveProgress onReceiveProgress,
    CancelToken cancelToken,
  });
}
