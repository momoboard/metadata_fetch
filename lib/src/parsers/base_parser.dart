/// The base class for implementing a parser
import 'package:html/dom.dart';

mixin MetadataKeys {
  static const keyTitle = 'title';
  static const keyDescription = 'description';
  static const keyImage = 'image';
  static const keyUrl = 'url';
  static const keyLogo = 'logo';
}

class Favicon implements Comparable<Favicon> {
  String url;
  int width;
  int height;

  Favicon(this.url, {this.width = 0, this.height = 0});

  @override
  int compareTo(Favicon other) {
    // If both are vector graphics, use URL length as tie-breaker
    if (url.endsWith('.svg') && other.url.endsWith('.svg')) {
      return url.length < other.url.length ? -1 : 1;
    }

    // Sort vector graphics before bitmaps
    if (url.endsWith('.svg')) return -1;
    if (other.url.endsWith('.svg')) return 1;

    // If bitmap size is the same, use URL length as tie-breaker
    if (width * height == other.width * other.height) {
      return url.length < other.url.length ? -1 : 1;
    }

    // Sort on bitmap size
    return (width * height > other.width * other.height) ? -1 : 1;
  }

  @override
  String toString() {
    return '{Url: $url, width: $width, height: $height}';
  }
}

mixin BaseMetadataParser {
  String? title;
  String? description;
  String? image;
  String? url;
  String? logo;

  Metadata parse() {
    final m = Metadata();
    m.title = title;
    m.description = description;
    m.image = image;
    m.url = url;
    m.logo = logo;
    return m;
  }

  List<String> parseFavicons(Document? document) {
    var faviconUrls = <String>[];

    if(document == null || url == null) return faviconUrls;

    Uri uri = Uri.parse(url!);
    for (var rel in ['icon', 'shortcut icon']) {
      for (var iconTag in document.querySelectorAll("link[rel='$rel']")) {
        if (iconTag.attributes['href'] != null) {
          var iconUrl = iconTag.attributes['href']!.trim();
          if (iconUrl.startsWith('//')) {
            iconUrl = uri.scheme + ':' + iconUrl;
          }
          if (iconUrl.startsWith('/')) {
            iconUrl = uri.scheme + '://' + uri.host + iconUrl;
          }
          if (!iconUrl.startsWith('http')) {
            iconUrl = uri.scheme + '://' + uri.host + '/' + iconUrl;
          }
          iconUrl = iconUrl.split('?').first;
          faviconUrls.add(iconUrl);
        }
      }
    }

    var iconUrl = uri.scheme + '://' + uri.host + '/favicon.ico';
    faviconUrls.add(iconUrl);
    return faviconUrls;
  }
}

/// Container class for Metadata
class Metadata with BaseMetadataParser, MetadataKeys {
  bool get hasAllMetadata {
    return (title != null &&
        description != null &&
        image != null &&
        url != null &&
        logo != null);
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, String?> toMap() {
    return {
      MetadataKeys.keyTitle: title,
      MetadataKeys.keyDescription: description,
      MetadataKeys.keyImage: image,
      MetadataKeys.keyUrl: url,
      MetadataKeys.keyLogo: logo
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  static Metadata fromJson(Map<String, dynamic> json) {
    final m = Metadata();
    m.title = json[MetadataKeys.keyTitle];
    m.description = json[MetadataKeys.keyDescription];
    m.image = json[MetadataKeys.keyImage];
    m.url = json[MetadataKeys.keyUrl];
    m.url = json[MetadataKeys.keyLogo];
    return m;
  }
}
