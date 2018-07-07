#include "ofApp.h"

//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    ARFaceTrackingConfiguration *configuration = [ARFaceTrackingConfiguration new];
    
    [session runWithConfiguration:configuration];
    
    this->session = session;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
}

vector <ofPrimitiveMode> primModes;
int currentPrimIndex;

//--------------------------------------------------------------
void ofApp::setup() {
    ofBackground(127);
    ofSetFrameRate(60);
    ofEnableDepthTest();

    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;

    processor = ARProcessor::create(session);
    processor->setup();
    
    
    // OSC
    for (int i = 0; i < 20; ++i) {
        ofxOscSender newSender;
        newSender.setup(hostIP, port + i);
        senders.push_back(newSender);
    }
    
    keyboard = new ofxiOSKeyboard(2,40,320,32);
    keyboard->setVisible(true);
    keyboard->setBgColor(255, 255, 255, 255);
    keyboard->setFontColor(0,0,0, 255);
    keyboard->setFontSize(26);
    
    ofSetFrameRate(40);
}

//--------------------------------------------------------------
void ofApp::update(){
    processor->update();
    processor->updateFaces();
}

//--------------------------------------------------------------
void ofApp::draw() {
    
    ofDisableDepthTest();
   // processor->draw();
    
    camera.begin();
    processor->setARCameraMatrices();
    //auto orientations = processor->getMatricesForOrientation();

    for (auto & face : processor->getFaces()){
        ofFill();
        ofMatrix4x4 temp = ARCommon::toMat4(face.raw.transform);
        
        ofPushMatrix();
        ofMultMatrix(temp);
        
        auto tempInv = temp.getInverse();

        ofxOscMessage m;
        m.setAddress("/custom/face");
        
        size_t counter{0};
        
        ofPushStyle();
        ofSetColor(0, 0, 255);
        
        size_t currentSender{0};
        for (size_t idx = 0; idx < face.vertices.size(); ++idx)
        {
            counter++;
            if (counter % 80 == 0)
            {
                senders[currentSender].sendMessage(m);
                currentSender = (currentSender + 1);// % senders.size();
                if (currentSender == senders.size())
                {
                    break;
                }
                m.clear();
                m.setAddress("/custom/face");
                
            }
            ofVec4f lel;
            lel.x = face.vertices[idx].x;
            lel.y = face.vertices[idx].y;
            lel.z = face.vertices[idx].z;
            lel.w = 1;
            
            lel = lel * temp;
            
            m.addIntArg(idx);
            m.addFloatArg(static_cast<float>(lel.x));
            m.addFloatArg(static_cast<float>(lel.y));
            m.addFloatArg(static_cast<float>(lel.z));
            
            ofDrawBox(face.vertices[idx], 0.001, 0.001, 0.001);
        }
        ofPopStyle();

        ofPopMatrix();
    }
    
    camera.end();
    
    ofPushStyle();
    ofSetColor(0, 255);
    ofDrawBitmapString("tap the textfield to open the keyboard", 2, 35);
    ofSetColor(20, 160, 240, 255);
    ofDrawBitmapString("text entered = "+  keyboard->getText() , 2, 100);
    
    keyboardText = keyboard->getText();
    if (lastKeyboardInput != keyboard->getText()) {
        hostIP = keyboard->getText();
        senders[0].setup(hostIP, port);
    }
    lastKeyboardInput = keyboardText;
    
    ofPopStyle();
}

void ofApp::exit() {}

void ofApp::handleSingleTouch(ofTouchEventArgs &touch) {}

void ofApp::touchDown(ofTouchEventArgs &touch){
    if (touch.id == 1){
        
        if(!keyboard->isKeyboardShowing()){
            keyboard->openKeyboard();
            keyboard->setVisible(true);
        } else{
            keyboard->setVisible(false);
        }
        
    }
}

void ofApp::touchMoved(ofTouchEventArgs &touch){}

void ofApp::touchUp(ofTouchEventArgs &touch){}

void ofApp::touchDoubleTap(ofTouchEventArgs &touch){}

void ofApp::lostFocus(){}

void ofApp::gotFocus(){}

void ofApp::gotMemoryWarning(){}

void ofApp::deviceOrientationChanged(int newOrientation){
    processor->updateDeviceInterfaceOrientation();
    processor->deviceOrientationChanged();
}

void ofApp::touchCancelled(ofTouchEventArgs& args){}
