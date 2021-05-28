import 'dart:html' as html;

/// Injects the library by its [url].
/// Throws an [UnsupportedError] if the [dart:html] library is not present.
///
/// This works by adding a new script tag to the html page with the src tag set to url.
Future<void> importLibrary(String url) {
  return _importJsLibraries([url]);
}

/// Injects the javascript code [src] into the page.
/// Throws an [UnsupportedError] if the [dart:html] library is not present.
///
/// This works by adding a new script tag to the html page with innerText set to src.
Future<void> injectScript(String src) {
  return _injectJsSource([src]);
}

/// Checks if a library is present in the page.
/// Throws an [UnsupportedError] if the [dart:html] library is not present.
///
/// This happens by checking the src field of all script tags in the html page.
bool isImported(String url) {
  return _isLoaded(_htmlHead(), url);
}

html.ScriptElement _createScriptTagFromUrl(String library) =>
    html.ScriptElement()
      ..type = "text/javascript"
      ..charset = "utf-8"
      ..async = true
      //..defer = true
      ..src = library;

html.ScriptElement _createScriptTagFromSrc(String src) => html.ScriptElement()
  ..type = "text/javascript"
  ..charset = "utf-8"
  ..async = false
  //..defer = true
  ..innerText = src;

Future<void> _importJsLibraries(List<String> libraries) {
  List<Future<void>> loading = <Future<void>>[];
  html.Element head = _htmlHead();
  libraries.forEach((String library) {
    if (!isImported(library)) {
      final scriptTag = _createScriptTagFromUrl(library);
      head.children.add(scriptTag);
      loading.add(scriptTag.onLoad.first);
    }
  });
  return Future.wait(loading);
}

Future<void> _injectJsSource(List<String> src) {
  List<Future<void>> loading = <Future<void>>[];
  html.Element head = _htmlHead();
  src.forEach((String script) {
    final scriptTag = _createScriptTagFromSrc(script);
    head.children.add(scriptTag);
    loading.add(scriptTag.onLoad.first);
  });
  return Future.wait(loading);
}

html.Element _htmlHead() {
  html.Element? head = html.querySelector('head');
  if (head != null) {
    return head;
  } else {
    throw new StateError('Could not fetch html head element!');
  }
}

bool _isLoaded(html.Element head, String url) {
  if (url.startsWith("./")) {
    url = url.replaceFirst("./", "");
  }
  for (var element in head.children) {
    if (element is html.ScriptElement) {
      if (element.src.endsWith(url)) {
        return true;
      }
    }
  }
  return false;
}