// class to describe the spring displayed as a line
class Spring {
  MouseJoint mouseJoint;

  // constructor
  Spring() {
    // at first it doesn't exist
    mouseJoint = null;
  }

  // set target to the mouse location 
  void update(float x, float y) {
    if (mouseJoint != null) {
      // convert to world coordinates
      Vec2 mouseWorld = box2d.coordPixelsToWorld(x,y);
      mouseJoint.setTarget(mouseWorld);
    }
  }

  void display() {
    if (mouseJoint != null) {
      // get the two anchor points
      Vec2 v1 = new Vec2(0,0);
      mouseJoint.getAnchorA(v1);
      Vec2 v2 = new Vec2(0,0);
      mouseJoint.getAnchorB(v2);
      
      // convert to screen coordinates
      v1 = box2d.coordWorldToPixels(v1);
      v2 = box2d.coordWorldToPixels(v2);
      
      // draw the line
      stroke(0);
      strokeWeight(1);
      line(v1.x,v1.y,v2.x,v2.y);
    }
  }


  /* attach the spring to an x,y location and the Box object's location */
  void bind(float x, float y, Box box) {
    // define the joint
    MouseJointDef md = new MouseJointDef();
    
    // body A is just a fake ground body for simplicity (there isn't anything at the mouse)
    md.bodyA = box2d.getGroundBody();
    // body 2 is the box's body
    md.bodyB = box.body;
    
    // get the mouse location in world coordinates
    Vec2 mp = box2d.coordPixelsToWorld(x,y);
    
    // set the target
    md.target.set(mp);
    md.maxForce = 1000.0 * box.body.m_mass;
    md.frequencyHz = 2.0;
    md.dampingRatio = 0.9;

    // make the joint
    mouseJoint = (MouseJoint) box2d.world.createJoint(md);
  }

  void destroy() {
    // get rid of the joint when the mouse is released
    if (mouseJoint != null) {
      box2d.world.destroyJoint(mouseJoint);
      mouseJoint = null;
    }
  }
}
