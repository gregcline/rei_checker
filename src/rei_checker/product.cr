require "colorize"

alias ColorString = (Colorize::Object(String) | String)

module JSONInterface
  def missing(field_name)
    "#{field_name} seems to be missing here, run with --debug to see the raw JSON".colorize(:red).to_s
  end
end

class Product
  include JSONInterface

  getter name : ColorString, colors : Array(Color), price : Price

  def initialize(info)
    @name = info.cleanTitle
    @colors = info.availableColors.map { |color| colorify(color)}
    @price = pricify(info.displayPrice.priceDisplay)
  end

  def to_s
    "The #{name} is available in these colors:
    #{display_colors}
And costs:
    #{price.to_s}\n"
  end

  def on_sale?
    price.sale?
  end

  private def display_colors
    colors.map(&.to_s)
          .join(", ")
  end

  private def colorify(color)
    Color.new(color)
  end

  private def pricify(displayPrice)
    # if displayPrice.nil?
    #   missing("displayPrice")
    # else
      Price.new(displayPrice)
    # end
  end
end

class Color
  include JSONInterface

  getter color : ColorString, vendor_color : ColorString

  def initialize(color)
    @color = color.color
    @vendor_color = color.vendorColor
    # @color = color["color"] || missing("color")
    # @vendor_color = color["vendorColor"] || missing("vendorColor")
  end

  def to_s
    "#{vendor_color} AKA #{color}"
  end
end

class Price
  include JSONInterface

  alias MaybeString = (String | Nil)

  getter price : MaybeString, savings : MaybeString

  def initialize(price)
    if price.sale?
      @price = price.salePrice
      @savings = price.savingsPercent
    else
      @price = price.price
      @savings = "0%"
    end
  end

  def to_s
    if failure?
      missing("displayPrice")
    elsif sale?
      "#{price} with #{savings} off".colorize(:green).to_s
    else
      "#{price}"
    end
  end

  def sale?
    savings != "0%"
  end

  def failure?
    savings.nil? && price.nil?
  end
end

