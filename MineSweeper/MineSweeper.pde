int cols = 10;
int rows = 10;

TileService tileService = new TileService(cols, rows);
RenderService renderService = new RenderService(tileService);


Tuple<Integer, Integer> sizes;

void settings() {
  sizes = renderService.GetWindowSize();
  size(sizes.first, sizes.second);
}

void setup() {
 
  renderService.onSetup();
  
}

void draw() {
  
  renderService.onDraw();
  
}

void mouseClicked() {
  renderService.onMouseClicked();
}
