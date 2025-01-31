import java.util.*;


class TileService {

  public int w, h;

  public int bombNumberDivider = 6;

  private Tile[][] tiles;

  public GameState gameState = GameState.PREGAME;

  ArrayList<Tuple<Integer, Integer>> neighbourPositions = new ArrayList<>();

  TileService(int tilesWidth, int tilesHeight) {

    this.w = tilesWidth;
    this.h = tilesHeight;

    tiles = new Tile[w][h];

    initNeighbourPositions();
  }

  private void initNeighbourPositions() {
    this.neighbourPositions.add(new Tuple<>(-1, -1));
    this.neighbourPositions.add(new Tuple<>(0, -1));
    this.neighbourPositions.add(new Tuple<>(1, -1));

    this.neighbourPositions.add(new Tuple<>(-1, 0));
    this.neighbourPositions.add(new Tuple<>(1, 0));

    this.neighbourPositions.add(new Tuple<>(-1, 1));
    this.neighbourPositions.add(new Tuple<>(0, 1));
    this.neighbourPositions.add(new Tuple<>(1, 1));
  }

  private void initTiles() {
    int totalTiles = this.w * this.h;
    int numberOfBombs = totalTiles / this.bombNumberDivider;



    HashSet<Integer> bombPositions = new HashSet<>();


    while (bombPositions.size() < numberOfBombs) {
      int randomPos = (int) random(totalTiles);
      bombPositions.add(randomPos);
    }


    for (int i = 0; i < this.h; i++) {
      for (int j = 0; j < this.w; j++) {

        int currentIndex = i * this.w + j;

        Boolean isBomb = bombPositions.contains(currentIndex);

        this.tiles[i][j] = new Tile(j + 1, i + 1, isBomb);
      }
    }
  }

  private void initBombNumbers() {

    for (int i = 0; i < this.h; i++) {
      for (int j = 0; j < this.w; j++) {


        int x = j + 1;
        int y = i + 1;

        Tile tile = getTileAt(x, y);

        if (tile.getIsBomb()) {

          tile.adjacentBombs = -1;
          setTileAt(x, y, tile);
          continue;
        }


        for (int k = 0; k < this.neighbourPositions.size(); k++) {

          Tuple<Integer, Integer> relativePositions = this.neighbourPositions.get(k);

          if (x + relativePositions.first < 1  || x + relativePositions.first > this.w  || y + relativePositions.second < 1 || y + relativePositions.second > this.h) {
            continue;
          }

          Tile neighbour = getTileAt(x + relativePositions.first, y + relativePositions.second);

          if (neighbour.getIsBomb()) {
            tile.adjacentBombs++;
          }
        }

        setTileAt(x, y, tile);
      }
    }
  }

  public void regenerate() {
    initTiles();
    initBombNumbers();

    this.gameState = GameState.INGAME;
  }

  public Tile[][] getAll() {

    return this.tiles;
  }

  public Tile getTileAt(int x, int y) {

    if (x < 1 || x > this.w || y < 1 || y > this.h) {
      return null;
    }

    return this.tiles[y - 1][x - 1];
  }

  public void setTileAt(int x, int y, Tile tile) {
    if (x < 1 || x > this.w || y < 1 || y > this.h) {
      return;
    }

    this.tiles[y - 1][x - 1] = tile;
  }

  public void tryFlagAt(int x, int y) {
    Tile tile = getTileAt(x, y);

    int flagNumbers = 0;

    for (int i = 0; i < this.h; i++) {
      for (int j = 0; j < this.w; j++) {

        if (getTileAt(j + 1, i + 1).status == TileStatus.FLAGGED) {
          flagNumbers++;
        }
      }
    }

    if (tile.status == TileStatus.COVERED && this.w * this.h / this.bombNumberDivider > flagNumbers) {
      tile.status = TileStatus.FLAGGED;
    } else if (tile.status == TileStatus.FLAGGED) {
      tile.status = TileStatus.COVERED;
    }
  }

  public void tryUncoverAt(int x, int y) {
    Tile tile = getTileAt(x, y);

    if (tile.status == TileStatus.COVERED && !tile.getIsBomb()) {
      tile.status = TileStatus.UNCOVERED;

      if (tile.adjacentBombs == 0) {

        ArrayList<Tuple<Integer, Integer>> uncoveredEmptyTiles = new ArrayList<>();

        ArrayList<Tile> otherEmptyTiles = new ArrayList<>();

        uncoveredEmptyTiles.add(new Tuple<>(x, y));


        otherEmptyTiles = uncoverNeighboursAndReturnEmptyOnes(tile, uncoveredEmptyTiles).first;

        while (otherEmptyTiles.size() > 0) {


          for (int i = 0; i < otherEmptyTiles.size(); i++) {
            otherEmptyTiles = uncoverNeighboursAndReturnEmptyOnes(otherEmptyTiles.get(i), uncoveredEmptyTiles).first;
          }
        }
      }
    } else if (tile.getIsBomb()) {
      tile.status = TileStatus.UNCOVERED;
      this.gameState = GameState.GAMEOVER;
    }

    setTileAt(x, y, tile);
  }

  private ArrayList<Tile> getNeighbours(int x, int y) {
    ArrayList<Tile> tiles = new ArrayList<>();

    for (int k = 0; k < this.neighbourPositions.size(); k++) {
      Tuple<Integer, Integer> relativePositions = this.neighbourPositions.get(k);

      if (x + relativePositions.first < 1  || x + relativePositions.first > this.w  || y + relativePositions.second < 1 || y + relativePositions.second > this.h) {
        continue;
      }

      tiles.add(getTileAt(x + relativePositions.first, y + relativePositions.second));
    }

    return tiles;
  }

  private Tuple<ArrayList<Tile>, ArrayList<Tuple<Integer, Integer>>> uncoverNeighboursAndReturnEmptyOnes(Tile tile, ArrayList<Tuple<Integer, Integer>> doneTiles) {


    ArrayList<Tile> otherEmptyTiles = new ArrayList<>();

    ArrayList<Tile> neighbours = getNeighbours(tile.x, tile.y);

    for (int i = 0; i < neighbours.size(); i++)
    {
      Tile neighbour = neighbours.get(i);

      Tuple<Integer, Integer> positions = new Tuple<>(neighbour.x, neighbour.y);

      Boolean tileAlreadyDone = false;

      for (int j = 0; j < doneTiles.size(); j++) {

        if (doneTiles.get(j).first == positions.first &&   doneTiles.get(j).second == positions.second) {

          tileAlreadyDone = true;
          break;
        }
      }




      if (!neighbour.getIsBomb() && !tileAlreadyDone) {


        if (neighbour.adjacentBombs == 0) {
          otherEmptyTiles.add(neighbour);
        }

        neighbour.status = TileStatus.UNCOVERED;

        setTileAt(neighbour.x, neighbour.y, neighbour);

        doneTiles.add(positions);
      }
    }

    return new Tuple<>(otherEmptyTiles, doneTiles);
  }
}

enum GameState {
  PREGAME, INGAME, GAMEOVER;
}
