import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

  int ballSize = 20; 
  int paddleHeight = 100; 
  int paddleWidth = 10; 
  float ballMoveX; 
  float ballMoveY; 
  float ballX; 
  float ballY; 
  float tempBallX;
  float tempBallY; 
  float playerX; 
  float playerY; 
  float oppX;
  float oppY; 
  float oscBallX; 
  float oscBallY; 
  int playerScore; int oppScore; 
  int controlMode; 
  Boolean viewOppBall = false; 
  float oldOSCBallX; 
  float oldOSCBallY;
  int port = 9000; 

void setup() {
  size(500,500);
  background(0); 
  frameRate(25);
  
  oscP5 = new OscP5(this,port);
  
  playerX = 10.0; playerY= 200.0;
  oppX = 490.0; oppY=200.0; 
  ballMoveX = -5.0; 
  ballMoveY = genBallMoveY(); 
  ballX = 250; ballY = 250;     
  rectMode(CENTER); 
  fill(255); 
  controlMode = 1; 
  myRemoteLocation = new NetAddress("192.168.43.247",port);
  
  println("Sending Test"); 
  OscMessage testMessage = new OscMessage("/test");
  testMessage.add(3.14); 
  oscP5.send(testMessage, myRemoteLocation); 
}

void draw() {
  background(0); 
  fill(255); 
  rect(ballX, ballY, ballSize, ballSize); 
  rect(playerX, playerY, paddleWidth, paddleHeight); 
  rect(oppX, oppY, paddleWidth, paddleHeight); 
  
  if(controlMode == 0) { 
    // check borders
    if (ballY<1 || ballY>490) {ballMoveY *= -1;}
    
    // check scores 
    if (ballX<1) {
      oppScore += 1;
      println("player score: " +playerScore + " opponent score: " + oppScore); 
      ballX = 250.0; ballY = 250.0; ballMoveX = 5.0; ballMoveY = genBallMoveY();
    }
    if (ballX>499) {
      playerScore += 1;
      println("player score: " +playerScore + " opponent score: " + oppScore); 
      ballX = 250.0; ballY = 250.0; ballMoveX = -5.0; ballMoveY = genBallMoveY();
    }
    
    // check paddles
    if (abs(ballY - playerY)<50 && abs(ballX-playerX) < 10 || abs(ballY - oppY)<50 && abs(oppX-ballX) < 10) {
      ballMoveX *= -1; ballMoveY = genBallMoveY(); 
    }
    
    
    
    ballX += ballMoveX; ballY += ballMoveY;
    OscMessage ballMessage = new OscMessage("/ball/position");
    ballMessage.add(ballX);
    ballMessage.add(ballY); 
    oscP5.send(ballMessage, myRemoteLocation); 
   

  } else if(controlMode == 1) {
    ballX = oscBallX; ballY= oscBallY; 
  }
  
  if(viewOppBall == true) { 
    fill(119,136,153);
    rect(oscBallX, oscBallY, ballSize, ballSize); 
  
  }
  
  
}

void keyPressed() {
  if (key == CODED){
    if (keyCode == UP) {
       if(playerY>50) {playerY -= 20.0;}
        OscMessage playerMessage = new OscMessage("/player/position");
        println("sending position: " + playerX + "," + playerY); 
        playerMessage.add(playerX);
        playerMessage.add(playerY); 
        oscP5.send(playerMessage, myRemoteLocation);        
    } else if (keyCode == DOWN) {
       if(playerY<450) {playerY += 20.0;} 
       OscMessage playerMessage = new OscMessage("/player/position");
       println("sending position: " + playerX + "," + playerY); 
       playerMessage.add(playerX);
       playerMessage.add(playerY); 
       oscP5.send(playerMessage, myRemoteLocation);       
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  println("### received addrpattern: "+theOscMessage.addrPattern());
  println(" values(x): "+theOscMessage.get(0).floatValue()+" (y): "+theOscMessage.get(1).floatValue());
  
  if (theOscMessage.checkAddrPattern("/player/position")) {
    println("Got opponent"); 
   // oppX = theOscMessage.get(0).floatValue(); 
    oppY = theOscMessage.get(1).floatValue(); 
    println("opponent y: " + oppY); 
  } else if (theOscMessage.checkAddrPattern("/ball/position")) {
    // oldOSCBallX = oscBallX; oldOSCBallY = oscBallY;
    println ("Got Ball"); 
    oscBallX = theOscMessage.get(0).floatValue(); 
    oscBallY = theOscMessage.get(1).floatValue(); 
  }
  
}

float genBallMoveY() {
  float tempBallMoveY = random(-5,5);
  if(0 < tempBallMoveY && tempBallMoveY< 2) {tempBallMoveY = 2;}
  if(-2 < tempBallMoveY && tempBallMoveY< 0) {tempBallMoveY = -2;}
  return tempBallMoveY;
}