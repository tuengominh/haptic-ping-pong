import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;

/* HandPose OSC comm */
OscP5 myOSC;
// NetAddress myRemoteLocation;
static final int OSC_PORT = 8008;
float topX, topY, botX, botY;
float handX, handY;

/* IMU + vibromotor serial comm */
Serial mySerial;
static final String SERIAL_PORT = Serial.list()[1]; // check the correct port in Arduino
static final int BAUDRATE = 115200; // check the correct baud rate
String valFromSerial;
float roll, pitch, yaw; 
float rotation = 0; // paddle rotation
String hapticStr;
Haptic haptic; // matrix displaying haptic patterns

/* Box2D */
Box2DProcessing box2d;
Particle ball;
Boundary wallL, wallR, wallT, wallB;
Box humanPlayer, cpuPlayer; // players as rectangle paddles
Spring springHuman, springCPU; // springs that will attach to the boxes

void setup() {
  size(700,700);
  smooth();
  
  initBox2d();
  initOSC();
  initSerial();

  // initialize the players
  humanPlayer = new Box(width/2, height/2);
  cpuPlayer = new Box(width/2, 40);
  
  // initialize the springs - they don't really get initialized until the mouse is clicked
  springHuman = new Spring();
  springHuman.update(500, 2);
  springHuman.bind(width/2, height/2, humanPlayer);
  springCPU = new Spring();
  springCPU.update(100, 0.8);
  springCPU.bind(width/2, 40, cpuPlayer);

  // initialize the ball
  ball = new Particle(width/2, 100, 10);
  ball.body.applyForce(new Vec2(random(-500, 500), -30000), ball.body.getPosition());
  
  // create boundaries
  wallR = new Boundary(width, height/2, 10, height);
  wallL = new Boundary(0, height/2, 10, height);
  wallT = new Boundary(width/2, 0, width, 10);
  wallB = new Boundary(width/2, height, width, 10);
  
  // initialize the haptic matrix
  haptic = new Haptic();
}

void initBox2d() {
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -2);
  box2d.listenForCollisions();
}

void initOSC() {
  myOSC = new OscP5(this, OSC_PORT); 
  // myRemoteLocation = new NetAddress("127.0.0.1", 1234); 
  handX = width/2;
  handY = height/2;
}

void initSerial() {
  mySerial = new Serial(this, SERIAL_PORT, BAUDRATE); 
}

void draw() {
  background(255);
  checkIMUData();
  box2d.step();

  /* update global position based on OSC data */
  springHuman.update(handX, handY);
  // springHuman.update(mouseX, mouseY);
  springHuman.display();
  springCPU.update(box2d.getBodyPixelCoord(ball.body).x, 40);
  springCPU.display();
  
  /* update local rotation based on serial data */
  humanPlayer.body.setAngularVelocity(-humanPlayer.body.getAngle());
  humanPlayer.body.applyAngularImpulse(rotation);
  // println("angle = ", humanPlayer.body.getAngle());

  /* display and update all graphic elements */
  wallR.display();
  wallL.display();
  wallT.display();
  wallB.display();
  humanPlayer.display();
  cpuPlayer.display();
  ball.display();
  
  /* send haptic feedback to Arduino */
  haptic.updatePosition(box2d.getBodyPixelCoord(ball.body).x, 
                        box2d.getBodyPixelCoord(ball.body).y);                  
  haptic.display(); // display visual haptic patterns
  
  hapticStr = getHapticData(box2d.getBodyPixelCoord(humanPlayer.body).x,
              box2d.getBodyPixelCoord(humanPlayer.body).y,
              box2d.getBodyPixelCoord(ball.body).x,
              box2d.getBodyPixelCoord(ball.body).y);             
  mySerial.write(hapticStr); // send to Arduino
  mySerial.clear();
  
  stroke(5);
  rectMode(CORNERS);
  // rect((1 - topX) * width, (topY + 0.5) * height, (1 - botX) * width, (botY + 0.5) * height);
  stroke(1);
}

// listen to HandPose
void oscEvent(OscMessage msg) {
   if(msg.checkAddrPattern("/boundingBox/topLeft") == true) {
      topX = msg.get(0).floatValue()/720;
      topY = msg.get(1).floatValue()/720;
   }
   if(msg.checkAddrPattern("/boundingBox/bottomRight") == true) { 
      botX = msg.get(0).floatValue()/720;
      botY = msg.get(1).floatValue()/720;
   }
   handX = ((1 - topX) * width + (1 - botX) * width)/2;
   handY = (botY + 0.25) * height;
}

// listen to Arduino
void checkIMUData(){
  if (mySerial != null) {
    while(mySerial.available() > 0) {  
      valFromSerial = mySerial.readStringUntil('\n'); 
      println("val = ", valFromSerial);
      try {
       String[] res = valFromSerial.split(",");
       roll = Float.parseFloat(res[0]);
       pitch = Float.parseFloat(res[1]);
       yaw = Float.parseFloat(res[2]);
      }
      catch (Exception e)
      {
         roll = 0;
         pitch = 0;
         yaw = 0;
      }
    }  
    rotation = roll * 10;
    // println("rotation = ", rotation);
  } 
}

String getHapticData(float x_paddle, float y_paddle, float x_ball, float y_ball) {
  String res = "";
  PVector v = new PVector(x_paddle - x_ball, y_paddle - y_ball);
  v.rotate(PI/4);
 
  pushMatrix();
  translate(400, 400);
  rotate(-PI/4);
  // line(0, 0, -v.x, -v.y);
  popMatrix();
  
  res += v.x + "," + v.y + "\n";
  // println(res);
  return res;
}
