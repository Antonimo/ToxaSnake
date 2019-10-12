import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:toxasnake/size_config.dart';

void main() => runApp(MyApp());

const SPRITE_TILE_SIZE = 64.0;
const SCREEN_TILE_SIZE = 32.0;

ImageMap _images;
Map<String, SpriteTexture> _textures = {};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toxa Snake',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SnakeGame snakeGame;

  bool assetsLoaded = false;

  Future<Null> _loadAssets(AssetBundle bundle) async {
    // Load images using an ImageMap
    _images = ImageMap(bundle);
    await _images.load(<String>[
      'assets/snake-graphics.png',
    ]);

    var spriteSheet = SpriteTexture(_images['assets/snake-graphics.png']);

    _textures['headU'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(3 * SPRITE_TILE_SIZE, 0 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['headU'].pivot = Offset(0.0, 0.0);
    _textures['headR'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(4 * SPRITE_TILE_SIZE, 0 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE - 1),
    );
    _textures['headR'].pivot = Offset(0.0, 0.0);
    _textures['headD'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(4 * SPRITE_TILE_SIZE, 1 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['headD'].pivot = Offset(0.0, 0.0);
    _textures['headL'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(3 * SPRITE_TILE_SIZE, 1 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE - 1),
    );
    _textures['headL'].pivot = Offset(0.0, 0.0);

    _textures['tailU'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(3 * SPRITE_TILE_SIZE, 2 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['tailU'].pivot = Offset(0.0, 0.0);
    _textures['tailR'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(4 * SPRITE_TILE_SIZE, 2 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['tailR'].pivot = Offset(0.0, 0.0);
    _textures['tailD'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(4 * SPRITE_TILE_SIZE, 3 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['tailD'].pivot = Offset(0.0, 0.0);
    _textures['tailL'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(3 * SPRITE_TILE_SIZE, 3 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['tailL'].pivot = Offset(0.0, 0.0);

    _textures['bodyRU'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(0 * SPRITE_TILE_SIZE, 1 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyRU'].pivot = Offset(0.0, 0.0);
    _textures['bodyDR'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(0 * SPRITE_TILE_SIZE, 0 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyDR'].pivot = Offset(0.0, 0.0);
    _textures['bodyLR'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(1 * SPRITE_TILE_SIZE, 0 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyLR'].pivot = Offset(0.0, 0.0);
    _textures['bodyLD'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(2 * SPRITE_TILE_SIZE, 0 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyLD'].pivot = Offset(0.0, 0.0);
    _textures['bodyUD'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(2 * SPRITE_TILE_SIZE, 1 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyUD'].pivot = Offset(0.0, 0.0);
    _textures['bodyUL'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(2 * SPRITE_TILE_SIZE, 2 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['bodyUL'].pivot = Offset(0.0, 0.0);

    _textures['food'] = spriteSheet.textureFromRect(
      Rect.fromLTWH(0 * SPRITE_TILE_SIZE, 3 * SPRITE_TILE_SIZE, SPRITE_TILE_SIZE, SPRITE_TILE_SIZE),
    );
    _textures['food'].pivot = Offset(0.0, 0.0);
  }

  @override
  void initState() {
    super.initState();

    // Get our root asset bundle
    AssetBundle bundle = rootBundle;

    print('got size? $SizeConfig');

    _loadAssets(bundle).then((_) {
      setState(() {
        assetsLoaded = true;
        snakeGame = SnakeGame(Size(500, 500));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // 320/5 256/4  64 64

    final horizontal_padding = (SizeConfig.safeAreaWidth % SCREEN_TILE_SIZE / 2);
    final vertical_padding = (SizeConfig.safeAreaHeight % SCREEN_TILE_SIZE / 2);

    final gameWidth = (SizeConfig.safeAreaWidth / SCREEN_TILE_SIZE).floor() * SCREEN_TILE_SIZE;
    final gameHeight = (SizeConfig.safeAreaHeight / SCREEN_TILE_SIZE).floor() * SCREEN_TILE_SIZE;

    if (assetsLoaded) {
      snakeGame.size = Size(gameWidth, gameHeight);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        //        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: horizontal_padding, vertical: vertical_padding),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                color: Color(0xFF004D40),
                child: assetsLoaded ? SpriteWidget(snakeGame) : Container(),
              ),
              Positioned(
                right: 15,
                bottom: 30,
                width: 200,
                height: 200,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      right: 0,
                      bottom: 50,
                      child: FloatingActionButton(
                        onPressed: () {
                          print('presed > ');
                          snakeGame.move(1, 0);
                        },
                        child: Icon(Icons.keyboard_arrow_right),
                        backgroundColor: Colors.white70,
                      ),
                    ),
                    Positioned(
                      right: 100,
                      bottom: 50,
                      child: FloatingActionButton(
                        onPressed: () {
                          print('presed < ');
                          snakeGame.move(-1, 0);
                        },
                        child: Icon(Icons.keyboard_arrow_left),
                        backgroundColor: Colors.white70,
                      ),
                    ),
                    Positioned(
                      right: 50,
                      bottom: 100,
                      child: FloatingActionButton(
                        onPressed: () {
                          print('presed ^ ');
                          snakeGame.move(0, -1);
                        },
                        child: Icon(Icons.keyboard_arrow_up),
                        backgroundColor: Colors.white70,
                      ),
                    ),
                    Positioned(
                      right: 50,
                      bottom: 0,
                      child: FloatingActionButton(
                        onPressed: () {
                          print('presed v ');
                          snakeGame.move(0, 1);
                        },
                        child: Icon(Icons.keyboard_arrow_down),
                        backgroundColor: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum TileOrientation { UP, RIGHT, DOWN, LEFT }

enum SnakeParts {
  HEAD,
  BODY_RU,
  BODY_DR,
  BODY_LR,
  BODY_LD,
  BODY_UD,
  BODY_UL,
  TAIL,
}

class Position {
  int x;
  int y;

  // direction
  int dx = 1;
  int dy = 0;

  Position(this.x, this.y);
}

class GameSprite extends Sprite {
  Size size = Size(SCREEN_TILE_SIZE, SCREEN_TILE_SIZE);
}

class SnakePart extends GameSprite {
  SnakeParts part;
  Position coordinates;

  TileOrientation orientation;

  SnakePart({this.part, this.orientation, this.coordinates}) {
    position = Offset(coordinates.x * SCREEN_TILE_SIZE, coordinates.y * SCREEN_TILE_SIZE);

    if (part == SnakeParts.HEAD) {
      if (orientation == TileOrientation.UP) {
        texture = _textures['headU'];
      }
      if (orientation == TileOrientation.RIGHT) {
        texture = _textures['headR'];
      }
      if (orientation == TileOrientation.DOWN) {
        texture = _textures['headD'];
      }
      if (orientation == TileOrientation.LEFT) {
        texture = _textures['headL'];
      }
    }

    if (part == SnakeParts.BODY_RU) {
      texture = _textures['bodyRU'];
    }
    if (part == SnakeParts.BODY_DR) {
      texture = _textures['bodyDR'];
    }
    if (part == SnakeParts.BODY_LR) {
      texture = _textures['bodyLR'];
    }
    if (part == SnakeParts.BODY_LD) {
      texture = _textures['bodyLD'];
    }
    if (part == SnakeParts.BODY_UD) {
      texture = _textures['bodyUD'];
    }
    if (part == SnakeParts.BODY_UL) {
      texture = _textures['bodyUL'];
    }

    if (part == SnakeParts.TAIL) {
      if (orientation == TileOrientation.UP) {
        texture = _textures['tailU'];
      }
      if (orientation == TileOrientation.RIGHT) {
        texture = _textures['tailR'];
      }
      if (orientation == TileOrientation.DOWN) {
        texture = _textures['tailD'];
      }
      if (orientation == TileOrientation.LEFT) {
        texture = _textures['tailL'];
      }
    }
    pivot = texture.pivot;
  }
}

class Snake extends Node {
  Position coordinates;

  List<SnakePart> parts = [];
  int growSize = 0;

  // render data
  int columns;
  int rows;

  // provide starting coordinates
  Snake(
    this.coordinates,
    this.columns,
    this.rows,
  ) {
    // place initial parts
    addPart(SnakeParts.TAIL, TileOrientation.RIGHT, coordinates.x - 3, coordinates.y);
    addPart(SnakeParts.BODY_LR, TileOrientation.RIGHT, coordinates.x - 2, coordinates.y);
    addPart(SnakeParts.BODY_LR, TileOrientation.RIGHT, coordinates.x - 1, coordinates.y);
    addPart(SnakeParts.HEAD, TileOrientation.RIGHT, coordinates.x, coordinates.y);
  }

  void move(int dx, int dy) {
    if (dx == coordinates.dx || dy == coordinates.dy) {
      return;
    }
    coordinates.dx = dx;
    coordinates.dy = dy;
  }

  bool step() {
    coordinates.x += coordinates.dx;
    coordinates.y += coordinates.dy;
    if (coordinates.x >= columns) {
      coordinates.x = 0;
    }
    if (coordinates.y >= rows) {
      coordinates.y = 0;
    }
    if (coordinates.x < 0) {
      coordinates.x = columns - 1;
    }
    if (coordinates.y < 0) {
      coordinates.y = rows - 1;
    }

    if (!checkCollision()) {
      return false;
    }

    var orientation = TileOrientation.UP;

    if (coordinates.dx > 0) {
      orientation = TileOrientation.RIGHT;
    }
    if (coordinates.dy > 0) {
      orientation = TileOrientation.DOWN;
    }
    if (coordinates.dx < 0) {
      orientation = TileOrientation.LEFT;
    }

    if (parts.last.orientation == orientation) {
      if (orientation == TileOrientation.RIGHT || orientation == TileOrientation.LEFT) {
        replacePart(parts.last, SnakeParts.BODY_LR, orientation);
      } else {
        replacePart(parts.last, SnakeParts.BODY_UD, orientation);
      }
    } else {
      if (parts.last.orientation == TileOrientation.LEFT && orientation == TileOrientation.UP) {
        replacePart(parts.last, SnakeParts.BODY_RU, orientation);
      }
      if (parts.last.orientation == TileOrientation.UP && orientation == TileOrientation.RIGHT) {
        replacePart(parts.last, SnakeParts.BODY_DR, orientation);
      }
      if (parts.last.orientation == TileOrientation.RIGHT && orientation == TileOrientation.DOWN) {
        replacePart(parts.last, SnakeParts.BODY_LD, orientation);
      }
      if (parts.last.orientation == TileOrientation.DOWN && orientation == TileOrientation.LEFT) {
        replacePart(parts.last, SnakeParts.BODY_UL, orientation);
      }

      if (parts.last.orientation == TileOrientation.DOWN && orientation == TileOrientation.RIGHT) {
        replacePart(parts.last, SnakeParts.BODY_RU, orientation);
      }
      if (parts.last.orientation == TileOrientation.LEFT && orientation == TileOrientation.DOWN) {
        replacePart(parts.last, SnakeParts.BODY_DR, orientation);
      }
      if (parts.last.orientation == TileOrientation.UP && orientation == TileOrientation.LEFT) {
        replacePart(parts.last, SnakeParts.BODY_LD, orientation);
      }
      if (parts.last.orientation == TileOrientation.RIGHT && orientation == TileOrientation.UP) {
        replacePart(parts.last, SnakeParts.BODY_UL, orientation);
      }
    }

    addPart(SnakeParts.HEAD, orientation, coordinates.x, coordinates.y);

    if (growSize > 0) {
      growSize--;
    } else {
      removePart(parts.first);
    }
    replacePart(parts.first, SnakeParts.TAIL, parts.first.orientation);

    return true;
  }

  void addPart(SnakeParts snakePart, TileOrientation orientation, int x, int y) {
    var part = SnakePart(part: snakePart, orientation: orientation, coordinates: Position(x, y));
    parts.add(part);
    addChild(part);
  }

  void replacePart(SnakePart oldPart, SnakeParts snakePart, TileOrientation orientation) {
    var part = SnakePart(part: snakePart, orientation: orientation, coordinates: oldPart.coordinates);
    parts[parts.indexOf(oldPart)] = part;
    removeChild(oldPart);
    addChild(part);
  }

  void removePart(SnakePart part) {
    parts.remove(part);
    removeChild(part);
  }

  void grow() {
    growSize++;
  }

  bool checkCollision() {
    for (var part in parts) {
      if (part == parts.last) {
        return true;
      }
      if (part.coordinates.x == coordinates.x && part.coordinates.y == coordinates.y) {
        return false;
      }
    }
    return true;
  }
}

class Food extends GameSprite {
  Position coordinates;

  Food(this.coordinates) {
    texture = _textures['food'];
    pivot = texture.pivot;
    position = Offset((coordinates.x) * SCREEN_TILE_SIZE, coordinates.y * SCREEN_TILE_SIZE);
  }
}

class SnakeGame extends NodeWithSize {
  Snake snake;
  Food food;

  Map<Offset, Sprite> gameMap;
  int columns;
  int rows;

  SnakeGame(Size size) : super(size) {
    columns = (SizeConfig.safeAreaWidth / SCREEN_TILE_SIZE).floor();
    rows = (SizeConfig.safeAreaHeight / SCREEN_TILE_SIZE).floor();

    print('${SizeConfig.safeAreaWidth} ${SizeConfig.safeAreaHeight} > $columns  $rows');

    resetGame();
//
//    var sprite = Sprite(_textures['bodyDR']);
//
//    sprite.position = Offset(0, 0);
//
//    sprite.size = Size(SCREEN_TILE_SIZE, SCREEN_TILE_SIZE);
//
////    sprite.position = Offset(x * 64.0 + SizeConfig.safeAreaHorizontal / 2, y * 64.0 + SizeConfig.safeAreaVertical / 2);
//
//    addChild(sprite);

//    for (var x = 0; x < columns; x++) {
//      for (var y = 0; y < rows; y++) {
//        var sprite = Sprite(texture);
//        sprite.size = Size(SCREEN_TILE_SIZE, SCREEN_TILE_SIZE);
//        sprite.position = Offset(x * SCREEN_TILE_SIZE, y * SCREEN_TILE_SIZE);
//
//        addChild(sprite);
//      }
//    }


    // runs every 1 second
    Timer.periodic(new Duration(milliseconds: 190), (timer) {
      debugPrint(timer.tick.toString());

      if (!snake.step()) {
        resetGame();
      }
      if (snake.coordinates.x == food.coordinates.x && snake.coordinates.y == food.coordinates.y) {
        snake.grow();
        putFood();
      }
    });
  }

  void move(int dx, int dy) {
    snake.move(dx, dy);
  }

  void putFood() {
    if (food != null) {
      removeChild(food);
    }
    food = Food(Position(Random().nextInt(columns - 1), Random().nextInt(rows - 1)));
    addChild(food);
  }

//  @override
//  void update(double dt) {
////    print('update: $dt');
//  }

  void resetGame(){
    removeAllChildren();

    snake = Snake(
      Position((columns / 2).floor(), (rows / 2).floor()),
      columns,
      rows,
    );

    addChild(snake);

    putFood();
  }
}

/*

todo:

review the snake game demo code

 */
