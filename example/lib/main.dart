import 'dart:math' as math;

import 'package:english_words/english_words.dart';
import 'package:example/page/chat.dart';
import 'package:example/utils/event_bus_utils.dart';
import 'package:example/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

final busUtils = EventBusUtils();

void main() {
  runApp(MusicAppDemo());
}

class MusicAppDemo extends StatelessWidget {
  MusicAppDemo({super.key});

  final MusicDatabase database = MusicDatabase.mock();
  final GoRouter _router = GoRouter(
    initialLocation: '/library',
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            MusicAppShell(
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => FadeTransitionPage(
              child: const LibraryScreen(),
              key: state.pageKey,
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'album/:albumId',
                builder: (BuildContext context, GoRouterState state) =>
                    AlbumScreen(
                  albumId: state.params['albumId'],
                ),
                routes: [
                  GoRoute(
                    path: 'song/:songId',
                    // Display on the root Navigator
                    builder: (BuildContext context, GoRouterState state) {
                      return SongScreen(
                        songId: state.params['songId']!,
                      );
                      // return  MyApp();
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/recents',
            pageBuilder: (context, state) => FadeTransitionPage(
              child: const RecentlyPlayedScreen(),
              key: state.pageKey,
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'song/:songId',
                // Display on the root Navigator.
                builder: (BuildContext context, GoRouterState state) =>
                    SongScreen(
                  songId: state.params['songId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) {
              final query = state.queryParams['q'] ?? '';
              return FadeTransitionPage(
                child: SearchScreen(
                  query: query,
                ),
                key: state.pageKey,
              );
            },
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => FadeTransitionPage(
              child: const ChatPage(),
              key: state.pageKey,
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Music app',
        theme: ThemeData(primarySwatch: Colors.green),
        routerConfig: _router,
        builder: (context, child) => MusicDatabaseScope(
          state: database,
          child: child!,
        ),
      );
}

const MaterialColor white = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

class MusicAppShell extends StatefulWidget {
  const MusicAppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<StatefulWidget> createState() => _Container();
}

class _Container extends State<MusicAppShell> {
  bool _showBottomNav = true;

  @override
  Widget build(BuildContext context) {
    EventBusUtils().eventBus.on<BottomNavEvent>().listen((event) {
      setState(() {
        _showBottomNav = event.show;
      });
    });
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _showBottomNav
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_activity),
                  label: '??????',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: '??????',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '??????',
                ),
              ],
              currentIndex: _calculateSelectedIndex(context),
              onTap: (int idx) => _onItemTapped(idx, context),
            )
          : null,
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final route = GoRouter.of(context);
    final location = route.location;
    if (location.startsWith('/recents')) {
      return 1;
    } else if (location.startsWith('/search')) {
      return 2;
    } else {
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 1:
        RouteUtils.route(context, '/recents');
        break;
      case 2:
        RouteUtils.route(context, '/search');
        break;
      case 0:
      default:
        RouteUtils.route(context, '/library');
        break;
    }
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = MusicDatabase.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('??????'),
      ),
      body: ListView.builder(
        itemBuilder: (context, albumId) {
          final album = database.albums[albumId];
          return AlbumTile(
            album: album,
            onTap: () {
              // GoRouter.of(context).go('/library/album/$albumId');
              // GoRouter.of(context).go('/');
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context)=> const ChatPage()),
              // );
              RouteUtils.route(context, '/chat');
            },
          );
        },
        itemCount: database.albums.length,
      ),
    );
  }
}

class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = MusicDatabase.of(context);
    final songs = database.recentlyPlayed;
    return Scaffold(
      appBar: AppBar(
        title: const Text('??????'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final song = songs[index];
          final albumIdInt = int.tryParse(song.albumId)!;
          final album = database.albums[albumIdInt];
          return SongTile(
            album: album,
            song: song,
            onTap: () {
              // RouteUtils.route(context, '/recents/song/${song.fullId}');
              RouteUtils.route(context, '/chat');
            },
          );
        },
        itemCount: songs.length,
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _currentQuery;

  @override
  Widget build(BuildContext context) {
    final database = MusicDatabase.of(context);
    final songs = database.search(widget.query);
    return Scaffold(
      appBar: AppBar(
        title: const Text('??????'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newSearch) {
                _currentQuery = newSearch;
              },
              onEditingComplete: () {
                RouteUtils.route(context, '/search?q=$_currentQuery');
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongTile(
                  album: database.albums[int.tryParse(song.albumId)!],
                  song: song,
                  onTap: () {
                    // RouteUtils.route(context,
                    //     '/library/album/${song.albumId}/song/${song.fullId}');
                    RouteUtils.route(context, '/chat');
                  },
                );
              },
              itemCount: songs.length,
            ),
          ),
        ],
      ),
    );
  }
}

class AlbumScreen extends StatelessWidget {
  final String? albumId;

  const AlbumScreen({
    required this.albumId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final database = MusicDatabase.of(context);
    final albumIdInt = int.tryParse(albumId ?? '');
    final album = database.albums[albumIdInt!];
    return Scaffold(
      appBar: AppBar(
        title: Text('Album - ${album.title}'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Container(
                    color: album.color,
                    margin: const EdgeInsets.all(8),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      album.artist,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final song = album.songs[index];
                  return ListTile(
                    title: Text(song.title),
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Container(
                        color: album.color,
                        margin: const EdgeInsets.all(8),
                      ),
                    ),
                    trailing: SongDuration(
                      duration: song.duration,
                    ),
                    onTap: () {
                      RouteUtils.route(context, '/chat');
                      // RouteUtils.route(context,
                      //     '/library/album/$albumId/song/${song.fullId}');
                    },
                  );
                },
                itemCount: album.songs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongScreen extends StatelessWidget {
  final String songId;

  const SongScreen({
    super.key,
    required this.songId,
  });

  @override
  Widget build(BuildContext context) {
    final database = MusicDatabase.of(context);
    final song = database.getSongById(songId);
    final albumIdInt = int.tryParse(song.albumId);
    final album = database.albums[albumIdInt!];

    return Scaffold(
      appBar: AppBar(
        title: Text('Song - ${song.title}'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Container(
                  color: album.color,
                  margin: const EdgeInsets.all(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MusicDatabase {
  final List<Album> albums;
  final List<Song> recentlyPlayed;
  final Map<String, Song> _allSongs = {};

  MusicDatabase(this.albums, this.recentlyPlayed) {
    _populateAllSongs();
  }

  factory MusicDatabase.mock() {
    final albums = _mockAlbums().toList();
    final recentlyPlayed = _mockRecentlyPlayed(albums).toList();
    return MusicDatabase(albums, recentlyPlayed);
  }

  Song getSongById(String songId) {
    if (_allSongs.containsKey(songId)) {
      return _allSongs[songId]!;
    }
    throw ('No song with ID $songId found.');
  }

  List<Song> search(String searchString) {
    final songs = <Song>[];
    for (var song in _allSongs.values) {
      final album = albums[int.tryParse(song.albumId)!];
      if (song.title.contains(searchString) ||
          album.title.contains(searchString)) {
        songs.add(song);
      }
    }
    return songs;
  }

  void _populateAllSongs() {
    for (var album in albums) {
      for (var song in album.songs) {
        _allSongs[song.fullId] = song;
      }
    }
  }

  static MusicDatabase of(BuildContext context) {
    final routeStateScope =
        context.dependOnInheritedWidgetOfExactType<MusicDatabaseScope>();
    if (routeStateScope == null) throw ('No RouteState in scope!');
    return routeStateScope.state;
  }

  static Iterable<Album> _mockAlbums() sync* {
    for (var i = 0; i < Colors.primaries.length; i++) {
      final color = Colors.primaries[i];
      final title = WordPair.random().toString();
      final artist = WordPair.random().toString();
      final songs = <Song>[];
      for (var j = 0; j < 12; j++) {
        final minutes = math.Random().nextInt(3) + 3;
        final seconds = math.Random().nextInt(60);
        final title = WordPair.random();
        final duration = Duration(minutes: minutes, seconds: seconds);
        final song = Song('$j', '$i', '$title', duration);

        songs.add(song);
      }
      yield Album('$i', title, artist, color, songs);
    }
  }

  static Iterable<Song> _mockRecentlyPlayed(List<Album> albums) sync* {
    for (var album in albums) {
      final songIndex = math.Random().nextInt(album.songs.length);
      yield album.songs[songIndex];
    }
  }
}

class MusicDatabaseScope extends InheritedWidget {
  final MusicDatabase state;

  const MusicDatabaseScope({
    required this.state,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      oldWidget is MusicDatabaseScope && state != oldWidget.state;
}

class Album {
  final String id;
  final String title;
  final String artist;
  final Color color;
  final List<Song> songs;

  Album(this.id, this.title, this.artist, this.color, this.songs);
}

class Song {
  final String id;
  final String albumId;
  final String title;
  final Duration duration;

  Song(this.id, this.albumId, this.title, this.duration);

  String get fullId => '$albumId-$id';
}

class AlbumTile extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;

  const AlbumTile({super.key, required this.album, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Container(
            color: album.color,
          ),
        ),
        title: Text(album.title),
        subtitle: Text(album.artist),
        onTap: onTap,
      );
}

class SongTile extends StatelessWidget {
  final Album album;
  final Song song;
  final VoidCallback? onTap;

  const SongTile(
      {super.key, required this.album, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Container(
            color: album.color,
            margin: const EdgeInsets.all(8),
          ),
        ),
        title: Text(song.title),
        trailing: SongDuration(
          duration: song.duration,
        ),
        onTap: onTap,
      );
}

class SongDuration extends StatelessWidget {
  final Duration duration;

  const SongDuration({
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
        '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
      );
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation.drive(_curveTween),
            child: child,
          ),
        );

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
