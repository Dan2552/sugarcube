module SugarCube
  module_function

  def adjust view=nil
    return @@sugarcube_view if not view

    @@sugarcube_view = view
    @@sugarcube_restore = view.frame
    view
  end
  alias :a :adjust

  ##|  ORIGIN
  def left val=1
    SugarCube::right -val
  end
  alias :l :left

  def right val=1
    f = @@sugarcube_view.frame
    f.origin.x += val
    @@sugarcube_view.frame = f
  end
  alias :r :right

  def up val=1
    SugarCube::down -val
  end
  alias :u :up

  def down val=1
    f = @@sugarcube_view.frame
    f.origin.y += val
    @@sugarcube_view.frame = f
  end
  alias :d :down

  def origin x, y=nil
    f = @@sugarcube_view.frame
    if y
      f.origin.x = x
      f.origin.y = y
    else
      f.origin = x
    end
    @@sugarcube_view.frame = f
  end
  alias :o :origin

  ##|  SIZE
  def thinner val=1
    SugarCube::wider -val
  end
  alias :n :thinner

  def wider val=1
    f = @@sugarcube_view.frame
    f.size.width += val
    @@sugarcube_view.frame = f
  end
  alias :w :wider

  def taller val=1
    SugarCube::shorter -val
  end
  alias :t :taller

  def shorter val=1
    f = @@sugarcube_view.frame
    f.size.height += val
    @@sugarcube_view.frame = f
  end
  alias :s :shorter

  def size w, h=nil
    f = @@sugarcube_view.frame
    if h
      f.size.width = w
      f.size.height = h
    else
      f.size = w
    end
    @@sugarcube_view.frame = f
  end
  alias :z :size

  ##|  RESTORE
  def restore
    @@sugarcube_view.frame = @@sugarcube_restore
  end
  alias :r :restore

end
