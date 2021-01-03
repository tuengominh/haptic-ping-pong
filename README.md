# Haptic Ping-Pong Game for Visually Impaired People
A 2D physics ping-pong game with a sensory substitution engine.

## Setup
* HandPose-OSC: Download the [application](https://github.com/faaip/HandPose-OSC/releases).
* Processing: Install [Box2D](https://github.com/shiffman/Box2D-for-Processing) library.
* Arduino: Install [SensorFusion](https://github.com/aster94/SensorFusion) library.

## Usage
* Flash the _PongArduino.ino_ sketch to the Arduino board.
* Run the HandPose-OSC app and turn on camera.
* Check and modify (if necessary) the serial port and baud rate of both the _PongArduino.ino_ and _PongProcessing.pde_ sketches.
* Run the _PongProcessing.pde_ sketch to play the ping-pong game.