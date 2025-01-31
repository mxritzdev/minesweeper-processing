class RenderService {

  private TileService tileService;

  private int tileWidthInPixels = 50;
  private int tileGap = 4;
  private int tileRadius = 5;
  private int windowWidth = 0;
  private int windowHeight = 0;

  private PImage flag;
  private PImage bomb;

  private color backgroundColor;
  private color[] tileColors = {
    color(0, 255, 0), // Green
    color(0, 192, 64), // Teal
    color(0, 128, 128), // Cyan
    color(0, 64, 192), // Blue
    color(0, 0, 255), // Strong Blue
    color(128, 0, 128), // Purple
    color(192, 0, 64), // Deep Pink/Red
    color(255, 0, 0)     // Red
  };

  private String gameName = "Le MineSweeper";

  PFont monospace;

  RenderService(TileService ts) {
    this.tileService = ts;

    this.windowWidth = this.tileService.w * this.tileWidthInPixels + 2 * this.tileWidthInPixels + this.tileGap * (this.tileService.w - 1);
    this.windowHeight = 5 * this.tileWidthInPixels + this.tileService.h * tileWidthInPixels + this.tileGap * (this.tileService.h - 1);

    // this.tileService.regenerate();
  }

  public Tuple<Integer, Integer> GetWindowSize() {


    return new Tuple<>(this.windowWidth, this.windowHeight);
  }

  public void onSetup() {

    surface.setTitle("Le MineSweeper");

    this.backgroundColor = color(150);

    this.monospace = createFont("Monospaced", 16);
    
    this.flag = loadImage("flag.png");
    this.bomb = loadImage("bomb.png");
  }

  public void onDraw() {
    background(this.backgroundColor);

    drawTitle();




    if (this.tileService.gameState != GameState.PREGAME) {
      drawGame();
    }

    if (this.tileService.gameState == GameState.GAMEOVER) {
      drawGameOver();
    } else if (this.tileService.gameState == GameState.PREGAME) {
      drawPregame();
    }
  }

  public void onMouseClicked() {

    Tuple<Integer, Integer> mineFieldStartPositions = new Tuple<>(this.tileWidthInPixels, 4 * this.tileWidthInPixels);
    Tuple<Integer, Integer> mineFiledEndPositions = new Tuple<>(this.tileWidthInPixels + this.tileService.w * this.tileWidthInPixels + this.tileGap * (this.tileService.w - 1), 4 * this.tileWidthInPixels + this.tileService.h * this.tileWidthInPixels + this.tileGap * (this.tileService.h - 1));


    if (this.tileService.gameState == GameState.INGAME) {

      if (Utils.isBetween(new Tuple<>(mouseX, mouseY), mineFieldStartPositions, mineFiledEndPositions)) {
        int newMouseX = mouseX - mineFieldStartPositions.first;
        int newMouseY = mouseY - mineFieldStartPositions.second;


        int tileX = (newMouseX - (newMouseX % (this.tileWidthInPixels + this.tileGap))) / (this.tileWidthInPixels + this.tileGap) + 1;
        int tileY = (newMouseY - (newMouseY % (this.tileWidthInPixels + this.tileGap))) / (this.tileWidthInPixels + this.tileGap) + 1;

        if (mouseButton == LEFT) {
          this.tileService.tryUncoverAt(tileX, tileY);
        } else if (mouseButton == RIGHT) {

          this.tileService.tryFlagAt(tileX, tileY);
        }
      }
    } else if (this.tileService.gameState == GameState.PREGAME || this.tileService.gameState == GameState.GAMEOVER) {

      if (Utils.isBetween(new Tuple<>(mouseX, mouseY), mineFieldStartPositions, mineFiledEndPositions)) {
        this.tileService.regenerate();
      }
    }
  }

  private void drawTitle() {
    textFont(this.monospace);

    textSize(70);
    fill(100);

    text(this.gameName, (this.windowWidth - textWidth(this.gameName)) / 2, 2 * this.tileWidthInPixels);
  }

  private void drawGameOver() {

    int startY = 4 * this.tileWidthInPixels;
    int endY = startY + this.tileService.h * this.tileWidthInPixels + this.tileGap * (this.tileService.h - 1);

    int startX = this.tileWidthInPixels;
    int endX = this.tileWidthInPixels + this.tileService.w * this.tileWidthInPixels + this.tileGap * (this.tileService.w - 1);

    fill(0, 0, 0, 127);
    noStroke();
    rect(startX, startY, endX - startX, endY - startY, this.tileRadius);

    textSize(30);

    Tile[][] tiles = this.tileService.getAll();

    int totalBombs = this.tileService.w * this.tileService.h / this.tileService.bombNumberDivider;
    int flaggedBombs = 0;

    for (int i = 0; i < this.tileService.h; i++) {
      for (int j = 0; j < this.tileService.w; j++) {

        if (tiles[i][j].getIsBomb() && tiles[i][j].status == TileStatus.FLAGGED) {
          flaggedBombs++;
        }
      }
    }

    String startText = "Game over. Found " + flaggedBombs + "/" + totalBombs + " Bombs.";

    fill(0);

    text(startText, startX + (endX - startX) / 2 - textWidth(startText) / 2, startY + (endY - startY) / 2 - 15);
  }

  private void drawPregame() {

    int startY = 4 * this.tileWidthInPixels;
    int endY = startY + this.tileService.h * this.tileWidthInPixels + this.tileGap * (this.tileService.h - 1);

    int startX = this.tileWidthInPixels;
    int endX = this.tileWidthInPixels + this.tileService.w * this.tileWidthInPixels + this.tileGap * (this.tileService.w - 1);

    fill(200);
    noStroke();
    rect(startX, startY, endX - startX, endY - startY, this.tileRadius);

    textSize(30);

    String startText = "Click here to start the game.";

    fill(100);

    text(startText, startX + (endX - startX) / 2 - textWidth(startText) / 2, startY + (endY - startY) / 2 - 15);
  }

  private void drawGame() {

    int startY = 4 * this.tileWidthInPixels;
    int endY = startY + this.tileService.h * this.tileWidthInPixels + this.tileGap * (this.tileService.h - 1);

    int startX = this.tileWidthInPixels;
    int endX = this.tileWidthInPixels + this.tileService.w * this.tileWidthInPixels + this.tileGap * (this.tileService.w - 1);

    fill(150);
    noStroke();
    rect(startX, startY, endX - startX, endY - startY, this.tileRadius);

    Tile[][] tiles = this.tileService.getAll();

    for (int i = 0; i < this.tileService.h; i++) {
      for (int j = 0; j < this.tileService.w; j++) {

        fill(200);

        int vertGap = 0;
        int horiGap = 0;

        if (i != 0) {
          vertGap = this.tileGap;
        }
        if (j != 0) {
          horiGap = this.tileGap;
        }


        int tileStartX = startX + j * this.tileWidthInPixels + horiGap * j;
        int tileStartY = startY + i * this.tileWidthInPixels + vertGap * i;

        if (tiles[i][j].status == TileStatus.COVERED && Utils.isBetween(new Tuple<>(mouseX, mouseY), new Tuple<>(tileStartX, tileStartY), new Tuple<>(tileStartX + this.tileWidthInPixels, tileStartY + this.tileWidthInPixels))) {
          fill(220);
        } else if (tiles[i][j].status == TileStatus.UNCOVERED) {
          fill(180);
        } else if (tiles[i][j].status == TileStatus.FLAGGED) {
          fill(120);
        }


        rect(tileStartX, tileStartY, this.tileWidthInPixels, this.tileWidthInPixels, this.tileRadius);


        if (tiles[i][j].status == TileStatus.FLAGGED)
        {
          image(this.flag, tileStartX + this.tileRadius, tileStartY + this.tileRadius, this.tileWidthInPixels - 2 * this.tileRadius, this.tileWidthInPixels - 2 * this.tileRadius);
        }
        
        if (tiles[i][j].getIsBomb() && tiles[i][j].status == TileStatus.UNCOVERED)
        {
          image(this.bomb, tileStartX + this.tileRadius, tileStartY + this.tileRadius, this.tileWidthInPixels - 2 * this.tileRadius, this.tileWidthInPixels - 2 * this.tileRadius);
        }

        if (tiles[i][j].status == TileStatus.UNCOVERED && !tiles[i][j].getIsBomb()) {

          textSize(this.tileWidthInPixels / 2);

          if (tiles[i][j].adjacentBombs <= 0) {          
            continue;
          }


          fill(tileColors[tiles[i][j].adjacentBombs - 1]);

          text(tiles[i][j].adjacentBombs, (tileStartX + this.tileWidthInPixels / 2 - textWidth(str(tiles[i][j].adjacentBombs)) / 2), (tileStartY + this.tileWidthInPixels / 2 + this.tileWidthInPixels / 4));
        }
      }
    }
  }
}
