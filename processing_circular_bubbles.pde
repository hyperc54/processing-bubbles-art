import com.hamoid.*;

/**
 * Sketch
 *
 * Circular bubbles Art
 * Description of the graph made in readme file
 *
 */
 

/**
 * Inputs
 */
 
String INPUT_FILE = "1901717622.csv"; // File in /data folder
float SCALE=1.5; // Scale factor to adapt to other resolutions quickly
int SPEED_MASS_BUBBLE=50; // speed of bubbles
float EASING = 0.05; // controls the smoothness of bubbles deceleration


/**
 * Variables initialisation
 */
 
Table table; // csv table
int nb_rows; // size data matrix
int nb_cols; // size data matrix
int[][] array; // data matrix
int[] minmax; 

int counter = 0; // temporality counter

VideoExport videoExport;

float pi=3.14;
 
ArrayList<Bubble> bubbleStack = new ArrayList<Bubble>(); // bubbles waiting to appear in the animation
ArrayList<Bubble> bubbleArray = new ArrayList<Bubble>(); // bubbles on the sketch

void setup() {
  // Size of the canvas
  size(1920, 1080);
  
  // Launch recording
  videoExport = new VideoExport(this);
  videoExport.startMovie();
  
  // Load csv data
  table = loadTable("../data/" + INPUT_FILE, "csv");
  println(table.getRowCount() + " total rows in table"); 

  nb_rows = table.getRowCount();
  nb_cols = table.getRow(0).getColumnCount();
  array = new int[nb_rows][nb_cols];
  
  // Ingest data in a matrix
  for (int i=0; i<nb_rows;i+=1) {
      for (int j=0; j < nb_cols; j+=1 ) {
        array[i][j] = table.getRow(i).getInt(j);
        print(array[i][j]);
        print(", ");
      }
  println(" ");
  }
  
  // Ingest min max of each row in an array
  minmax = findMinMaxArray();
  print("Data successfully loaded");
  
  // Create bubble
  for (int i=0; i < nb_rows; i += 1) {
      for (int j=0; j < nb_cols; j += 1 ) {
        bubbleStack.add(
          new Bubble(
            int(array[i][0] * 3 * SCALE),
            array[i][1] - 90,
            int(SCALE * (array[i][2] + 5) / 2),
            array[i][3])
          );
      }
  }
    
  print("Bubbles created !");
        
  
}



/**
 * class Bubble
 */
 
public class Bubble {
  int target_radius;
  int target_angle;
  int target_size;
  int genre; // genre id corresponding to the color of the bubble
  float opacity;
  
  int current_radius;
  int current_angle;
  int current_size;
  float current_opacity;
  
  // Create bubble params
  public Bubble(int a, int b, int c, int d){
    target_radius = a;
    target_angle = b;
    target_size = c * 100 / minmax[1];
    genre = d;
    
    float rnd = random(40);
    
    current_radius = target_radius + int(SCALE*(rnd+500));
    current_angle = target_angle + int(SCALE*rnd);
    current_size = target_size + int(SCALE*100);
    
    opacity = random(80) + 20;
    current_opacity = opacity;  
  }
  
  // UpdateParams change location and size of the bubble frame after frame
  void updateParams(){
    float dr = target_radius - current_radius;
    float da = target_angle - current_angle;
    float ds = target_size - current_size;
    float ddo = opacity - current_opacity;
    
    current_radius += dr * EASING;
    current_angle += da * EASING;
    current_size += ds * EASING;
    current_opacity += ddo * EASING;
  }
  
  void drawBubble(){
    printBubble(current_radius, current_angle, current_size, genre, current_opacity);
  }
  
  void bounce(){
    current_size += random(20);
  }
  
  void flicker(){
    current_opacity += random(20);
  }
}

/**
 *
 * Bubble drawing methods
 * A bubble is just a circle with a color and size
 *
 **/
void printBubble(int radius, int angle, int size, int genre, float opacity){
  // set color
  color C = getColorFromGenre(genre, opacity);
  fill(C);
  noStroke();
  strokeWeight(0); 
  drawCircle(radius, angle, size);
}

void drawCircle(int radius, int angle, int size){
  float[] cart = getCartFrompolar(radius, angle);
  
  ellipse(cart[0], cart[1], size, size);
}



/**
 * Draw method called at each frame
 *
 * - reinitialise the canvas to white
 * - Put new bubbles in the canvas
 * - update all bubbles in the canvas parameters
 * - actually draw them with their new parameters
 *
 */
void draw() {
  // reinit background
  background(255);
  
  // Add new bubbles to the canvas
  counter +=1 ;
  if (counter > 1){
    counter = 0;
    int mini_count = 0;
    while(mini_count < SPEED_MASS_BUBBLE){
      mini_count += 1;
      if(bubbleStack.size() > 0){
        Bubble b = bubbleStack.remove(0);
        bubbleArray.add(b);
      }
    }
  }
  
  // update params and draw bubles
  for (Bubble bub : bubbleArray) {
    bub.updateParams();
    bub.drawBubble();
  }
  
  videoExport.saveFrame();
}






/**
 * User interactions
 * Make the graph react to ome key pressed.
 */

void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
  if (key == 'b') {
    makeItBounce();
  }
  if (key == 'f') {
    makeItFlicker();
  }
}

void makeItBounce(){
  for (Bubble bub : bubbleArray) {
    bub.bounce();
  }
}

void makeItFlicker(){
  for (Bubble bub : bubbleArray) {
    bub.flicker();
  }
}




/**
 * Utils functions
 */

/**
 * findMinMaxArray
 * find Min and Max entry from the data for each row
 */
int[] findMinMaxArray(){
  int min = 10000;
  int max = 0;

  for (int i=0; i < nb_rows; i += 1) {
      if (array[i][2] > max){
        max = array[i][2];
      }
      if (array[i][2] < min){
        min = array[i][2];
      }
  }
  int[] res = {min, max};
  
  return res;
}

/**
 * Color matching, ID to RGB
 */
color getColorFromGenre(int genre, float opacity){

  
  color C=color(0,0,0);
  switch (genre) {
      case 0:  C = color(244, 219, 255, opacity);
               break;
      case 1:  C = color(249, 244, 79, opacity);
               break;
      case 2:  C = color(255, 89, 84, opacity);
               break;
      case 3:  C = color(65, 125, 193, opacity);
               break;
      case 4:  C = color(31, 102, 30, opacity);
               break;
      case 5:  C = color(140, 104, 53, opacity);
               break;
      case 6:  C = color(177, 71, 198, opacity);
               break;
      case 7:  C = color(88, 82, 99, opacity);
               break;
      case 8:  C = color(59, 91, 147, opacity);
               break;
      case 9:  C = color(68, 68, 68, opacity);
               break;
  }
  return C;
}

/**
 * Get cartesian coordinates from polar ones
 */
float[] getCartFrompolar(int radius, int angle){
  int center_x = width / 2;
  int center_y = height / 2;
  
  float theta = angle * pi / 180;
  
  float new_x = center_x + radius * cos(theta);
  float new_y = center_y + radius * sin(theta);
  
  float[] cart = new float[2];
  
  cart[0] = new_x;
  cart[1] = new_y;
  
  return cart;
}