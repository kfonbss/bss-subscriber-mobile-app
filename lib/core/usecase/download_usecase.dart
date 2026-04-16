abstract class DownloadUseCase<R, Params, OnReceiveProgress, CancelToken> {
  Future<R> call({
    Params param,
    OnReceiveProgress onReceiveProgress,
    CancelToken cancelToken,
  });
}
