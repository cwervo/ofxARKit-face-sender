#pragma once

#include "ofxiOS.h"
#include "ofxARKit.h"

#include "ofxOsc.h"
#include "ofxiOSKeyboard.h"

class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    ofTrueTypeFont font;
    
    ofCamera camera;
    ofImage img;
    
    int port{12345};
    
    // GUI stuff
    void handleSingleTouch(ofTouchEventArgs &touch);
    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARRef processor;
    
    void generateCircles(ofVec3f point);
    
    ofMesh faceMesh;
    
    vector <ofColor> colors;
    vector <ofColor> colors_backlog;
    
    bool bDrawDebug;
    
    vector<ofxOscSender> senders;
    void sendOSC();
    
    ofxiOSKeyboard * keyboard;
    
    std::string hostIP;
    std::string keyboardText;
    std::string lastKeyboardInput;
};


