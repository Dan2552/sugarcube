module SugarCube
  # Extensions to make CGRect a "real class"
  module CGRectExtensions

    def empty?
      CGRectIsEmpty(self)
    end

    def infinite?
      self.size.infinite?
    end

    def null?
      CGRectIsNull(self)
    end

    def left
      return CGRectGetMinX(self)
    end

    def right
      return CGRectGetMaxX(self)
    end

    def width
      return CGRectGetWidth(self)
    end

    def top
      return CGRectGetMinY(self)
    end

    def bottom
      return CGRectGetMaxY(self)
    end

    def height
      return CGRectGetHeight(self)
    end

    def center
      return SugarCube::CoreGraphics::Point(CGRectGetMidX(self), CGRectGetMidY(self))
    end

    def to_s
      "#{self.class.name}([#{self.origin.x}, #{self.origin.y}],{#{self.size.width} × #{self.size.height}})"
    end

    def to_hash
      CGRectCreateDictionaryRepresentation(self)
    end

    def inspect ; to_s ; end

    # # returns an intersection of self and rect, or moves the Rect using Point,
    # or increases the size using Size
    def +(rect)
      case rect
      when CGRectArray, CGRect
        SugarCube::CoreGraphics::Rect(CGRectUnion(self, rect))
      when CGPointArray, CGPoint
        SugarCube::CoreGraphics::Rect(CGRectOffset(self, rect.x, rect.y))
      when CGSizeArray, CGSize
        SugarCube::CoreGraphics::Rect(CGRectInset(self, - rect.width, - rect.height))
      else
        super
      end
    end

    def intersection(rect)
      SugarCube::CoreGraphics::Rect(CGRectIntersection(self, rect))
    end

    def intersects?(rect_or_point)
      case rect_or_point
      when CGPointArray, CGPoint
        CGRectContainsPoint(self, rect_or_point)
      when Array, CGRect
        CGRectIntersectsRect(self, rect_or_point)
      else
        super
      end
    end

    def contains?(rect_or_point)
      case rect_or_point
      when CGPointArray, CGPoint
        CGRectContainsPoint(self, rect_or_point)
      when Array, CGRect
        CGRectContainsRect(self, rect_or_point)
      else
        super
      end
    end

    def ==(rect)
      CGRectEqualToRect(self, rect)
    end

  end

  # Extensions to make CGPoint a "real class"
  module CGPointExtensions

    def intersects?(rect)
      CGRectContainsPoint(rect, self)
    end

    def ==(point)
      CGPointEqualToPoint(self, point)
    end

    def to_s
      "#{self.class.name}(#{self.x}, #{self.y})"
    end

    def to_hash
      CGPointCreateDictionaryRepresentation(self)
    end

    def inspect ; to_s ; end

  end

  # Extensions to make CGSize a "real class"
  module CGSizeExtensions

    def infinite?
      infinity = CGRect.null[0][0]
      self.width == infinity or self.height == infinity
    end

    def ==(size)
      CGSizeEqualToSize(self, size)
    end

    def to_s
      "#{self.class.name}(#{self.width} × #{self.height})"
    end

    def to_hash
      CGSizeCreateDictionaryRepresentation(self)
    end

    def inspect ; to_s ; end

  end
end


class CGRect
  include SugarCube::CGRectExtensions

  class << self
    def empty
      SugarCube::CoreGraphics::Rect(CGRectZero)
    end

    def null
      SugarCube::CoreGraphics::Rect(CGRectNull)
    end

    def infinite
      SugarCube::CoreGraphics::Rect([0, 0], CGSize.infinite)
    end

    def from_hash(hash)
      ret = Pointer.new(CGRect.type)
      if CGRectMakeWithDictionaryRepresentation(hash, ret)
        ret[0]
      else
        nil
      end
    end
  end
end


class CGRectArray < Array
  include SugarCube::CGRectExtensions

  def initialize args
    if args.length == 4
      super [CGPointArray.new([args[0], args[1]]), CGSizeArray.new([args[2], args[3]])]
    else
      unless CGPointArray === args[0]
        args[0] = SugarCube::CoreGraphics::Point(args[0])
      end
      unless CGSizeArray === args[1]
        args[1] = SugarCube::CoreGraphics::Size(args[1])
      end
      super [args[0], args[1]]
    end
  end

  def origin
    return self[0]
  end

  def origin= val
    self[0] = SugarCube::CoreGraphics::Point(val)
  end

  def size
    return self[1]
  end

  def size= val
    self[1] = SugarCube::CoreGraphics::Size(val)
  end

end


class CGPoint
  include SugarCube::CGPointExtensions

  class << self
    def from_hash(hash)
      ret = Pointer.new(CGPoint.type)
      if CGPointMakeWithDictionaryRepresentation(hash, ret)
        ret[0]
      else
        nil
      end
    end
  end
end


class CGPointArray < Array
  include SugarCube::CGPointExtensions

  def x
    return self[0]
  end

  def x= val
    self[0] = val
  end

  def y
    return self[1]
  end

  def y= val
    self[1] = val
  end

  # adds a vector to this point, or creates a Rect by adding a size
  def +(point)
    case point
    when CGPointArray, CGPoint
      x = self.x + point.x
      y = self.y + point.y
      CGPointArray[x, y]
    when CGSizeArray, CGSize
      CGRectArray[self, point]
    else
      super
    end
  end

end


class CGSize
  include SugarCube::CGSizeExtensions

  class << self
    def infinite
      infinity = CGRect.null[0][0]
      SugarCube::CoreGraphics::Size(infinity, infinity)
    end

    def from_hash(hash)
      ret = Pointer.new(CGSize.type)
      if CGSizeMakeWithDictionaryRepresentation(hash, ret)
        ret[0]
      else
        nil
      end
    end
  end
end


class CGSizeArray < Array
  include SugarCube::CGSizeExtensions

  def width
    return self[0]
  end

  def width= val
    self[0] = val
  end

  def height
    return self[1]
  end

  def height= val
    self[1] = val
  end

  # adds the sizes
  def +(size)
    case size
    when CGSizeArray, CGSize
      width = self.width + size.width
      height = self.height + size.height
      CGSizeArray[width, height]
    when CGPointArray, CGPoint
      CGRectArray[size, self]
    else
      super
    end
  end

end


class UIEdgeInsetsArray < Array

  def top
    return self[0]
  end

  def top= val
    self[0] = val
  end

  def left
    return self[1]
  end

  def left= val
    self[1] = val
  end

  def bottom
    return self[2]
  end

  def bottom= val
    self[2] = val
  end

  def right
    return self[3]
  end

  def right= val
    self[3] = val
  end

end


class UIOffsetArray < Array

  def horizontal
    return self[0]
  end

  def horizontal= val
    self[0] = val
  end

  def vertical
    return self[1]
  end

  def vertical= val
    self[1] = val
  end

end

module SugarCube
  module CoreGraphics
    PI = 3.141592654
    module_function

    def Size(w_or_size, h=nil)
      if not h
        case w_or_size
        when CGSize
          w = w_or_size.width
          h = w_or_size.height
        when Array
          w = w_or_size[0]
          h = w_or_size[1]
        else
          raise RuntimeError.new("Invalid argument sent to Size(#{w_or_size.inspect})")
        end
      else
        w = w_or_size
      end
      return CGSizeArray.new([w, h])
    end

    def Point(x_or_origin, y=nil)
      if not y
        case x_or_origin
        when CGPoint
          x = x_or_origin.x
          y = x_or_origin.y
        when Array
          x = x_or_origin[0]
          y = x_or_origin[1]
        else
          raise RuntimeError.new("Invalid argument sent to Point(#{x_or_origin.inspect})")
        end
      else
        x = x_or_origin
      end
      return CGPointArray.new([x, y])
    end

    # Accepts 1, 2 or 4 arguments.
    # 1 argument should be an Array[4], CGRectArray, or CGRect
    # 2 arguments should be a Point/CGPoint and a Size/CGSize,
    # 4 should be x, y, w, h
    def Rect(x_or_origin, y_or_size=nil, w=nil, h=nil)
      if not y_or_size
        case x_or_origin
        when CGRect
          x = x_or_origin.origin.x
          y = x_or_origin.origin.y
          w = x_or_origin.size.width
          h = x_or_origin.size.height
        when UIView, CALayer
          x = x_or_origin.frame.origin.x
          y = x_or_origin.frame.origin.y
          w = x_or_origin.frame.size.width
          h = x_or_origin.frame.size.height
        when CGRectArray
          x = x_or_origin[0][0]
          y = x_or_origin[0][1]
          w = x_or_origin[1][0]
          h = x_or_origin[1][1]
        when Array
          if x_or_origin.length == 2
            x = x_or_origin[0][0]
            y = x_or_origin[0][1]
            w = x_or_origin[1][0]
            h = x_or_origin[1][1]
          elsif
            x = x_or_origin[0]
            y = x_or_origin[1]
            w = x_or_origin[2]
            h = x_or_origin[3]
          else
            raise RuntimeError.new("Invalid argument sent to Rect(#{x_or_origin.inspect})")
          end
        else
          raise RuntimeError.new("Invalid argument sent to Rect(#{x_or_origin.inspect})")
        end
      elsif not w and not h
        x_or_origin = Point(x_or_origin) unless x_or_origin.is_a? CGPointArray
        x = x_or_origin.x
        y = x_or_origin.y
        y_or_size = Size(y_or_size) unless y_or_size.is_a? CGSizeArray
        w = y_or_size.width
        h = y_or_size.height
      else
        x = x_or_origin
        y = y_or_size
      end
      return CGRectArray.new([[x, y], [w, h]])
    end

    # Accepts 1 or 4 arguments.
    # 1 argument should be an Array[4] or UIEdgeInset,
    # 4 should be top, left, bottom, right
    def EdgeInsets(top_or_inset, left=nil, bottom=nil, right=nil)
      unless left or bottom or right
        case top_or_inset
        when UIEdgeInsets
          top = top.top
          left = top.left
          bottom = top.bottom
          right = top.right
        when Array
          top = top_or_inset[0]
          left = top_or_inset[1]
          bottom = top_or_inset[2]
          right = top_or_inset[3]
        when Numeric
          top = left = bottom = right = top_or_inset
        else
          raise RuntimeError.new("Invalid argument sent to EdgeInsets(#{top_or_inset.inspect})")
        end
      else
        top = top_or_inset
      end
      return UIEdgeInsetsArray.new([top, left, bottom, right])
    end

    # Accepts 1 or 2 arguments.
    # 1 argument should be an Array[2] or UIOffset,
    # 2 should be horizontal, vertical
    def Offset(horizontal_or_offset, vertical=nil)
      if not vertical
        case horizontal_or_offset
        when UIOffset
          horizontal = horizontal_or_offset.horizontal
          vertical = horizontal_or_offset.vertical
        when Array
          horizontal = horizontal_or_offset[0]
          vertical = horizontal_or_offset[1]
        when Fixnum
          horizontal_or_offset =
          vertical = horizontal_or_offset[0]
        else
          raise RuntimeError.new("Invalid argument sent to Offset(#{horizontal_or_offset.inspect})")
        end
      else
        horizontal = horizontal_or_offset
      end
      return UIOffsetArray.new([horizontal, vertical])
    end

  end
end
