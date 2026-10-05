/// Status pemuatan data yang dipakai seluruh halaman.
///
/// Sengaja modelled sebagai enum sederhana agar nanti bisa diganti dengan
/// `AsyncSnapshot`/package state management tanpa mengubah widget.
enum DataStatus { loading, success, empty, error }

/// Wadah hasil pemuatan data + statusnya untuk conditional rendering.
class DataResult<T> {
  const DataResult.loading()
    : status = DataStatus.loading,
      data = null,
      errorMessage = null;

  const DataResult.success(T value)
    : status = DataStatus.success,
      data = value,
      errorMessage = null;

  const DataResult.empty()
    : status = DataStatus.empty,
      data = null,
      errorMessage = null;

  const DataResult.error(String message)
    : status = DataStatus.error,
      data = null,
      errorMessage = message;

  final DataStatus status;
  final T? data;
  final String? errorMessage;

  bool get isLoading => status == DataStatus.loading;
  bool get isSuccess => status == DataStatus.success;
  bool get isEmpty => status == DataStatus.empty;
  bool get isError => status == DataStatus.error;
}
