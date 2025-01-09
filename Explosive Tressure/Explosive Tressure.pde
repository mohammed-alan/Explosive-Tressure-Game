import ddf.minim.*;
PImage explosionImage;
Minim minim;
AudioSample clickSound;
AudioSample explosionSound;

boolean startClicked = false;
boolean secondPage = false;
int rows = 5; // Number of rows
int cols = 4; // Number of columns
int rectWidth;
int rectHeight;
int spacing = 15; // Spacing between rectangles and canvas edges
color[] rectColors; // Array to store colors of rectangles
int previousColor = -1; // Variable to store the previous color of the box
boolean displayWinner = false; // Flag to control the display of the winner message
boolean isRedTurn = true; // Flag to track whose turn it is
int explosiveBoxIndex = -1; // Index of the box with explosives
boolean gameOver = false; // Flag to track game over state
int blueScore = 0; // Score for the blue team
int redScore = 0; // Score for the red team
boolean explosionHandled = false; // Flag to ensure explosion is handled only oncer
boolean blinkState = true; // State for blinking effect
int blinkTimer = 0; // Timer for blinking effect

void setup() {
  fullScreen(); // Adjust canvas size as needed
  rectWidth = (width - (cols + 1) * spacing) / cols;
  rectHeight = (height - (rows + 1) * spacing) / rows;
  
  // Initialize colors of rectangles
  rectColors = new color[rows * cols];
  for (int i = 0; i < rectColors.length; i++) {
    rectColors[i] = color(255);
  }
  
  // Load explosion image
  explosionImage = loadImage("boom.png");
  
  // Initialize Minim and load the sound files
  minim = new Minim(this);
  clickSound = minim.loadSample("click.wav");
  explosionSound = minim.loadSample("boom.wav");
  
}

void draw() {
  if (!startClicked) {
    startPage();
  } else if (secondPage) {
    secondPage();
  }
}

void startPage() {
  background(90,50,120);
  // Display title
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("The Explosive Tressure", width/2, height/2 - 100);
  textSize(25);
  text("Athletic Leadership Tournament", width/2, height/2 - 50);
  
  // Draw start button
  fill(0);
  rect(width/2 - 50, height/2 - 25, 100, 50);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Start", width/2, height/2);
}


void secondPage() {
  background(187,165, 61);
  
  // Draw rectangles and numbers
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int index = i * cols + j;
      int x = j * (rectWidth + spacing) + spacing;
      int y = i * (rectHeight + spacing) + spacing;
      // Draw rectangles
      fill(rectColors[index]);
      rect(x, y, rectWidth, rectHeight);
      // Draw numbers on rectangles
      fill(0);
      textSize(30); // Increase text size
      textAlign(CENTER, CENTER);
      text(index+1, x + rectWidth/2, y + rectHeight/2);
    }
  }
  
  // Display boom image on the explosive box if clicked
  if (explosiveBoxIndex != -1 && rectColors[explosiveBoxIndex] != color(255)) {
    int rowIndex = explosiveBoxIndex / cols;
    int colIndex = explosiveBoxIndex % cols;
    int x = colIndex * (rectWidth + spacing) + spacing;
    int y = rowIndex * (rectHeight + spacing) + spacing;
    if (isRedTurn) {
      tint(0, 0, 255, 150); // Blue tint for the boom image if red player loses
      if (!explosionHandled) {
        redScore++; // Increment blue score if red player loses
        explosionHandled = true; // Explosion handled, don't increment again
      }
    } else {
      tint(255, 0, 0, 150); // Red tint for the boom image if blue player loses
      if (!explosionHandled) {
        blueScore++; // Increment red score if blue player loses
        explosionHandled = true; // Explosion handled, don't increment again
      }
    }
    image(explosionImage, x, y, rectWidth, rectHeight);
    noTint(); // Reset tint
  }
  
  // Display winner message
  if (displayWinner) {
    if (millis() - blinkTimer > 500) {
      blinkState = !blinkState;
      blinkTimer = millis();
    }
    if (blinkState) {
      fill(255); // Text color
      textSize(24);
      textAlign(CENTER, CENTER);
      if (isRedTurn) {
        fill(0, 0, 255, 200); // Semi-transparent blue background for "BLUE EXPLODED"
        rect(width/2 - 150, height/2 - 40, 300, 80);
        fill(255); // Text color
        text("BLUE EXPLODED!", width/2, height/2);
      } else {
        fill(255, 0, 0, 200); // Semi-transparent red background for "RED EXPLODED"
        rect(width/2 - 150, height/2 - 40, 300, 80);
        fill(255); // Text color
        text("RED EXPLODED!", width/2, height/2);
      }
    }
    
    // Display scoreboard in a box on the top right corner
    fill(200, 200, 200, 200); // Light gray background
    rect(width - 220, 10, 200, 70);
    fill(0); // Text color
    textSize(20); // Font size
    textAlign(RIGHT); // Align text to the right
    text("Blue Score: " + blueScore, width - 30, 40);
    text("Red Score: " + redScore, width - 30, 70);
  }
}

void mousePressed() {
  if (!startClicked && mouseX > width/2 - 50 && mouseX < width/2 + 50 && mouseY > height/2 - 25 && mouseY < height/2 + 25) {
    startClicked = true;
    secondPage = true;
    // Select a random box to contain explosives
    explosiveBoxIndex = int(random(rows * cols));
  } else if (startClicked && !gameOver) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int x = j * (rectWidth + spacing) + spacing;
        int y = i * (rectHeight + spacing) + spacing;
        int index = i * cols + j;
        if (mouseX > x && mouseX < x + rectWidth && mouseY > y && mouseY < y + rectHeight) {
          if (isRedTurn) {
            rectColors[index] = color(255, 0, 0); // Red color for left click
            if (index == explosiveBoxIndex) {
              // Play the explosion sound
              explosionSound.trigger();
              displayWinner = true;
              gameOver = true; // Set game over flag after displaying the explosion image
            }
          } else {
            rectColors[index] = color(0, 0, 255); // Blue color for left click
            if (index == explosiveBoxIndex) {
              // Play the explosion sound
              explosionSound.trigger();
              displayWinner = true;
              gameOver = true; // Set game over flag after displaying the explosion image
            }
          }
          isRedTurn = !isRedTurn; // Switch turns
          // Play the click sound
          clickSound.trigger();
        }
      }
    }
  }
}

void keyPressed() {
  if (keyCode == ENTER && secondPage) {
    // Select a new random box to contain explosives
    explosiveBoxIndex = int(random(rows * cols));
    // Reset game state
    displayWinner = false;
    gameOver = false;
    explosionHandled = false; // Reset explosion handling
    // Reset rectangles
    for (int i = 0; i < rectColors.length; i++) {
      rectColors[i] = color(255);
    }
  } else if (key == 'r' || key == 'R') {
    // Reset scores when 'r' or 'R' is pressed
    blueScore = 0;
    redScore = 0;
  } else if (key == 'g') {
    if (rows > 1) { // Ensure rows don't go below 1
      rows--;
      adjustGameField();
    }
  } else if (key == 'h') {
    rows++;
    adjustGameField();
  } else if (key == 'n') {
    if (cols > 1) { // Ensure cols don't go below 1
      cols--;
      adjustGameField();
    }
  } else if (key == 'm') {
    cols++;
    adjustGameField();
  }
}

// Adjust the game field according to new rows and columns
void adjustGameField() {
  rectWidth = (width - (cols + 1) * spacing) / cols;
  rectHeight = (height - (rows + 1) * spacing) / rows;
  rectColors = new color[rows * cols]; // Reinitialize the colors array to match new grid
  for (int i = 0; i < rectColors.length; i++) {
    rectColors[i] = color(255); // Reset color
  }
  // If currently showing the second page, update the explosive box index to a valid value
  if (secondPage) {
    explosiveBoxIndex = int(random(rows * cols));
  }
}
