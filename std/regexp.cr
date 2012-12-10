lib PCRE("pcre")
  fun pcre_compile(pattern : Char*, options : Int, errptr : Char**, erroffset : Int*, tableptr : Long) : Long
  fun pcre_exec(code : Long, extra : Long, subject : Char*, length : Int, offset : Int, options : Int,
                ovector : Int*, ovecsize : Int) : Int
end

class Regexp
  ANCHORED = 16

  def initialize(str)
    @source = str
    errptr = Pointer.malloc(0).as(Char)
    erroffset = 1
    @re = PCRE.pcre_compile(str.cstr, 8, errptr.ptr, erroffset.ptr, 0L)
    if @re == 0
      puts "#{errptr.as(String)} at #{erroffset}"
      exit 1
    end
  end

  def match(str, pos = 0, options = 0)
    ovector = Pointer.malloc(3 * 4).as(Int)
    ret = PCRE.pcre_exec(@re, 0L, str.cstr, str.length, pos, options, ovector, 3)
    return nil unless ret > 0
    MatchData.new(self, str, pos, ovector)
  end

  def source
    @source
  end

  def to_s
    "/#{source}/"
  end
end

class MatchData
  def initialize(regex, string, pos, ovector)
    @regex = regex
    @string = string
    @pos = pos
    @ovector = ovector
  end

  def regex
    @regex
  end

  def begin(n)
    @ovector[n * 2]
  end

  def end(n)
    @ovector[n * 2 + 1]
  end

  def string
    @string
  end

  def [](index)
    @string.slice(self.begin(index), self.end(index) - self.begin(index))
  end
end