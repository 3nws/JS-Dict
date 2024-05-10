import "package:flutter/material.dart";

import "error_indicator.dart";

class LoaderWidget<T> extends StatefulWidget {
  const LoaderWidget(
      {super.key,
      required this.onLoad,
      required this.handler,
      this.placeholder = const Text(""),
      this.isOnAction = false});

  final Future<T> Function() onLoad;
  final Widget Function(T data) handler;
  final Widget placeholder;
  final bool isOnAction;

  @override
  State<LoaderWidget<T>> createState() => _LoaderWidgetState<T>();
}

class _LoaderWidgetState<T> extends State<LoaderWidget<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.onLoad();
  }

  void _retry() {
    setState(() {
      _future = widget.onLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                  width: widget.isOnAction ? 15 : null,
                  margin: const EdgeInsets.all(20),
                  child: const CircularProgressIndicator()),
            );
          }

          if (snapshot.connectionState == ConnectionState.none) {
            return widget.placeholder;
          }

          if (snapshot.hasError) {
            return ErrorIndicator(
              snapshot.error!,
              stackTrace: snapshot.stackTrace,
              onRetry: _retry,
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return widget.handler(snapshot.data as T);
          }

          throw AssertionError();
        });
  }
}
