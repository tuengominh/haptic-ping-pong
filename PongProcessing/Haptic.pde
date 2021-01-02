class Haptic {
  int x = 2;
  int y = 2;
  float[][] hapticPosition = new float[2][2];
  
  // constructor
  Haptic(){
    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){
        hapticPosition[i][j] = 90;
      }
    }
  }
  
  void updatePosition(float x_, float y_){
    x_ = map(x_, 0, width, 0, x-1);
    y_ = map(y_, 0, height, 0, y-1);
    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){
        hapticPosition[j][i] = constrain(10/pow((sqrt(abs(y_-i) + abs(x_-j)) + 0.01), 2), 0, 40);
      }
    }
  }
  
  void display(){
    pushMatrix();
      translate(width/3, height/2);
      for(int i=0; i<x; i++){
        for(int j=0; j<y; j++){
          ellipse(i * (width/2 - width/3),
                  j * (width/2 - width/3),
                  hapticPosition[i][j],
                  hapticPosition[i][j]);
        }
      }
    popMatrix();
  }
}
