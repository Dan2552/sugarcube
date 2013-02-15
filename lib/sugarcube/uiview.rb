class UIView

  class << self

    # returns the first responder, starting at the Window and searching every subview
    def first_responder
      UIApplication.sharedApplication.keyWindow.first_responder
    end

    def attr_updates(*attrs)
      attr_accessor(*attrs)
      attrs.each do |attr|
        define_method(attr.setter) { |value|
          if instance_variable_get(attr.ivar) != value
            setNeedsDisplay
          end
          instance_variable_set(attr.ivar, value)
        }
      end
    end

    # If options is a Numeric, it is used as the duration.  Otherwise, duration
    # is an option, and defaults to 0.3.  All the transition methods work this
    # way.
    def animate(options={}, &animations)
      if options.is_a? Numeric
        duration = options
        options = {}
      else
        duration = options[:duration] || 0.3
      end

      after_animations = options[:after]
      if after_animations
        if after_animations.arity == 0
          after_adjusted = ->(finished){ after_animations.call }
        else
          after_adjusted = after_animations
        end
      else
        after_adjusted = nil
      end

      UIView.animateWithDuration( duration,
                           delay: options[:delay] || 0,
                         options: options[:options] || UIViewAnimationOptionCurveEaseInOut,
                      animations: proc,
                      completion: after_adjusted
                                )
      nil
    end

    # Animation chains are great for consecutive animation blocks.  Each chain can
    # take the same options that UIView##animate take.
    def animation_chain(options={}, &first)
      chain = SugarCube::AnimationChain.new
      if first
        chain.and_then(options, &first)
      end
      return chain
    end

  end

  # returns the first responder, or nil if it cannot be found
  def first_responder
    if self.firstResponder?
      return self
    end

    found = nil
    self.subviews.each do |subview|
      found = subview.first_responder
      break if found
    end

    return found
  end

  # returns the nearest nextResponder instance that is a UIViewController. Goes
  # up the responder chain until the nextResponder is a UIViewController
  # subclass, or returns nil if none is found.
  def controller
    if nextResponder && nextResponder.is_a?(UIViewController)
      nextResponder
    elsif nextResponder
      nextResponder.controller
    else
      nil
    end
  end

  # superview << view
  # => superview.addSubview(view)
  def <<(view)
    self.addSubview(view)
    return self
  end

  def unshift(view)
    self.insertSubview(view, atIndex:0)
    return self
  end

  def show
    self.hidden = false
    self
  end

  def hide
    self.hidden = true
    self
  end

  # Same as UIView##animate, but acts on self
  def animate(options={}, &animations)
    if options.is_a? Numeric
      duration = options
      options = {}
    else
      duration = options[:duration] || 0.3
    end

    assign = options[:assign] || {}

    UIView.animate(options) {
      animations.call if animations

      assign.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    }
    self
  end

  # Changes the layer opacity.
  def fade(options={}, &after)
    if options.is_a? Numeric
      options = { opacity: options }
    end

    options[:after] = after

    animate(options) {
      self.layer.opacity = options[:opacity]
    }
  end

  # Changes the layer opacity to 0.
  # @see #fade
  def fade_out(options={}, &after)
    if options.is_a? Numeric
      options = { duration: options }
    end

    options[:opacity] ||= 0.0

    fade(options, &after)
  end

  # Changes the layer opacity to 1.
  # @see #fade
  def fade_in(options={}, &after)
    if options.is_a? Numeric
      options = { duration: options }
    end

    options[:opacity] ||= 1.0

    fade(options, &after)
  end

  # Changes the layer opacity to 0 and then removes the view from its superview
  # @see #fade_out
  def fade_out_and_remove(options={}, &after)
    if options.is_a? Numeric
      options = { duration: options }
    end

    original_opacity = self.layer.opacity

    after_remove = proc {
      removeFromSuperview
      self.layer.opacity = original_opacity
      after.call if after
    }

    fade_out(options, &after_remove)
  end

  def move_to(position, options={}, &after)
    if options.is_a? Numeric
      options = { duration: options }
    end

    options[:after] = after

    animate(options) {
      f = self.frame
      f.origin = SugarCube::CoreGraphics::Point(position)
      self.frame = f
    }
  end

  def delta_to(delta, options={}, &after)
    f = self.frame
    delta = SugarCube::CoreGraphics::Point(delta)
    position = SugarCube::CoreGraphics::Point(f.origin)
    to_position = CGPoint.new(position.x + delta.x, position.y + delta.y)
    move_to(to_position, options, &after)
    self
  end

  def rotate_to(options={}, &after)
    if options.is_a? Numeric
      options = { angle: options }
    end

    options[:after] = after

    animate(options) {
      self.transform = CGAffineTransformMakeRotation(options[:angle])
    }
  end

  def slide(direction, options={}, &after)
    if options.is_a? Numeric
      options = {size: options}
    end

    size = options[:size]
    case direction
    when :left
      size ||= self.bounds.size.width
      delta_to([-size, 0], options, &after)
    when :right
      size ||= self.bounds.size.width
      delta_to([size, 0], options, &after)
    when :up
      size ||= self.bounds.size.height
      delta_to([0, -size], options, &after)
    when :down
      size ||= self.bounds.size.height
      delta_to([0, size], options, &after)
    else
      raise "Unknown direction #{direction.inspect}"
    end
    self
  end

  # Vibrates the target. You can trick this thing out to do other effects, like:
  # @example
  #   # wiggle
  #   view.shake(offset: 0.1, repeat: 2, duration: 0.5, keypath: 'transform.rotation')
  #   # slow nodding
  #   view.shake(offset: 20, repeat: 10, duration: 5, keypath: 'transform.translation.y')
  def shake(options={})
    if options.is_a? Numeric
      duration = options
      options = {}
    else
      duration = options[:duration] || 0.3
    end

    offset = options[:offset] || 8
    repeat = options[:repeat] || 3
    if repeat == Float::INFINITY
      duration = 0.1
    else
      duration /= repeat
    end
    keypath = options[:keypath] || 'transform.translation.x'

    origin = options[:origin] || 0
    left = origin - offset
    right = origin + offset

    animation = CAKeyframeAnimation.animationWithKeyPath(keypath)
    animation.duration = duration
    animation.repeatCount = repeat
    animation.values = [origin, left, right, origin]
    animation.keyTimes = [0, 0.25, 0.75, 1.0]
    self.layer.addAnimation(animation, forKey:'shake')
    self
  end

  # Moves the view off screen while slowly rotating it.
  #
  # Based on https://github.com/warrenm/AHAlertView/blob/master/AHAlertView/AHAlertView.m
  def tumble(options={}, &after)
    if options.is_a? Numeric
      default_duration = options
      options = {}
    else
      default_duration = 0.3
    end

    options[:duration] ||= default_duration
    options[:options] ||= UIViewAnimationOptionCurveEaseIn
    reset_transform = self.transform
    reset_after = ->(finished) {
      self.transform = reset_transform
    }

    if after
      options[:after] = ->(finished) {
        reset_after.call(finished)

        if after.arity == 0
          after.call
        else
          after.call(finished)
        end
      }
    else
      options[:after] = reset_after
    end

    self.animate(options) {
       offset = CGPoint.new(0, self.superview.bounds.size.height * 1.5)
       offset = CGPointApplyAffineTransform(offset, self.transform)
       self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(-Math::PI/4))
       self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y)
    }
  end

  # Easily take a snapshot of a UIView
  def uiimage
    scale = UIScreen.mainScreen.scale
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
    layer.renderInContext(UIGraphicsGetCurrentContext())
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  end

end
