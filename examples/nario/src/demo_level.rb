require 'physical_level'
require 'physical_director'
class DemoLevel < PhysicalLevel
  def setup
    # TODO fix this to be configurable cleanly
    @space.gravity = vec2(0,0.02)
    @space.iterations = 3
    @space.damping = 0.7

    @bg = create_actor :nario_background

    @ground = create_actor :ground
    @ground.warp vec2(0,700)
    @ground.shape.e = 0.0004
    @ground.shape.u = 0.0004

    @nario = create_actor :nario
    @nario.warp vec2(300,500)

    # stand nario upright
    @nario.body.a -= 1.57
  end

  def draw(target)
    target.fill [25,25,25,255]
  end
end
