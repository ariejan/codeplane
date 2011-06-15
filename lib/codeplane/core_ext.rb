class String
  def color(color_code)
    coloring? ? "#{color_code}#{self}\e[0m" : self
  end

  def coloring?
    STDOUT.isatty
  end

  def bold
    color("\e[1m")
  end

  def gray
    color("\e[30m")
  end

  def red
    color("\e[31m")
  end

  def green
    color("\e[32m")
  end

  def yellow
    color("\e[33m")
  end

  def blue
    color("\e[34m")
  end

  def magenta
    color("\e[35m")
  end

  def cyan
    color("\e[36m")
  end

  def white
    color("\e[37m")
  end
end
