#include <SparkFunLSM6DS3.h>
#include <SensorFusion.h>
#include <Wire.h>
 
uint8_t i2CAddressMotor = 0x30;
String hapticData = "";
float hapticX, hapticY; 

LSM6DS3 myIMU(I2C_MODE, 0x6A);
SF fusion;
float gX, gY, gZ, aX, aY, aZ, mX, mY, mZ;
float pitch, roll, yaw;
float deltat;

void setup() {
  Serial.begin(115200); // check Serial Monitor's baud rate
  Wire.begin();
  myIMU.begin();
  delay(500);
  
  enableDriver();
  controlMotor(0, 0, 0, 0);
}

void loop() {
  while (Serial.available()) {
    char incoming = Serial.read();
    if (incoming !='\n') {
      hapticData += incoming;
    } else if (incoming == '\n'){
      break;
    } 
  }
  
  splitHapticData();
  vibrate(hapticX, hapticY);
  // TODO: interrupt
  
  sendIMUData();
  delay(500);
}

/* send IMU data over serial port */
void sendIMUData() {
  gX = myIMU.readFloatGyroX() * DEG_TO_RAD; 
  gY = myIMU.readFloatGyroY() * DEG_TO_RAD; 
  gZ = myIMU.readFloatGyroZ() * DEG_TO_RAD; 
  aX = myIMU.readFloatAccelX();
  aY = myIMU.readFloatAccelY();
  aZ = myIMU.readFloatAccelZ();

  deltat = fusion.deltatUpdate();
  fusion.MahonyUpdate(gX, gY, gZ, aX, aY, aZ, deltat);

  roll = fusion.getRoll(); // rotation X-axis - roll
  pitch = fusion.getPitch(); // rotation Y-axis - pitch
  yaw = fusion.getYaw(); // rotation Z-axis - yaw
  
  Serial.print(roll, 3); 
  Serial.print(",");
  Serial.print(pitch, 3); 
  Serial.print(",");
  Serial.print(yaw, 3); 
  Serial.println();
}

/* split haptic data received from Processing */
void splitHapticData() {
  int commaIndex = hapticData.indexOf(',');
  hapticX = hapticData.substring(0, commaIndex).toFloat();
  hapticY = hapticData.substring(commaIndex + 1).toFloat();
  hapticData = "";
}

/* control motors to send vibrotactile feedback */
void vibrate(float x, float y) { 
  int16_t pwm1 = 0;
  int16_t pwm2 = 0;
  int16_t pwm3 = 0;
  int16_t pwm4 = 0;
  
  x = constrain(x, -500, 500);
  y = constrain(y, -500, 500);
  
  // TODO: change time delay
  // float dis = sqrt((abs(x) * abs(x)) + (abs(b) * abs(b))); 
  // int16_t timeDelay = (int16_t) map(dis, 0, 500, 0, 1500);
   
  if (x < 0) { 
    pwm2 = (int16_t) map(abs(x), 0, 500, 1023, 0); // M2 
  } else {
    pwm4 = (int16_t) map(x, 0, 500, 1023, 0); // M4 
  }
  
  if ( y < 0) {  
    pwm3 = (int16_t) map(abs(y), 0, 500, 1023, 0); // M3
  } else {  
    pwm1 = (int16_t) map(y, 0, 500, 1023, 0); // M1 
  }

  controlMotor(pwm1, pwm2, pwm3, pwm4); 
  delay(10);
} 

/* sending PWM signals to 4 motors */
void controlMotor(int16_t m1_pwm, int16_t m2_pwm, int16_t m3_pwm, int16_t m4_pwm) { // 0-1023
  i2cWrite2bytes(i2CAddressMotor, 0x10, m1_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x11, m2_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x12, m3_pwm);
  i2cWrite2bytes(i2CAddressMotor, 0x13, m4_pwm);
}

/* change delay time */
void changeDelay(int16_t delayTime) { 
  i2cWrite2bytes(i2CAddressMotor, 0x20, delayTime); // default: 200(ms)
}

void enableDriver() {
  i2cWrite(i2CAddressMotor, 0x40);
}

void deactivateDriver() {
  i2cWrite(i2CAddressMotor, 0x41);
}

void i2cWrite2bytes(uint8_t address,uint8_t channel, uint16_t data) { 
  Wire.beginTransmission(address); 
  Wire.write(channel);
  Wire.write(data>>8); 
  Wire.write(data);
  Wire.endTransmission();
  delay(15);
}

void i2cWrite(uint8_t address,uint8_t channel) { 
  Wire.beginTransmission(address); 
  Wire.write(channel);
  Wire.endTransmission();
  delay(15);
}
