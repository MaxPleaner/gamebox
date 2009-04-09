require 'actor_view'

class AnimatedActorView < ActorView
  def draw(target)
    x = @actor.x
    y = @actor.y

    img = @actor.image

    w,h = *img.size
    x = x-w/2
    y = y-h/2
    img.blit target.screen, [x,y]
  end
end