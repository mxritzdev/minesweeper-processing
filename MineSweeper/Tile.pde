class Tile {
  int x, y;

  private Boolean isBomb;

  public TileStatus status = TileStatus.COVERED;
  
  public int adjacentBombs = 0; 

  Tile(int x, int y, Boolean isBomb) {
    this.x = x;
    this.y = y;

    this.isBomb = isBomb;
  }


  public Boolean getIsBomb() {
    return this.isBomb;
  }
  
}

enum TileStatus {
  COVERED, UNCOVERED, FLAGGED;
}
