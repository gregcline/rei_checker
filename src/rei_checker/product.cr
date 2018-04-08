require "colorize"

# Represents a single product returned by the API.
class Product
  getter name : String, colors : Array(Color), price : Price

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
      Price.new(displayPrice)
  end
end

# Represents a color. Vendor color is what the product's manufacturer calls the
# color and color is how REI refers to it for things like refinements. I include
# both to be a little more descriptive.
class Color
  getter color : String, vendor_color : String

  def initialize(color)
    @color = color.color
    @vendor_color = color.vendorColor
  end

  def to_s
    "#{vendor_color} AKA #{color}"
  end
end

# Represents a price. It will display differently depending on whether the
# product is on sale.
class Price
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

  private def failure?
    savings.nil? && price.nil?
  end

  private def missing(field_name)
    "#{field_name} seems to be missing here, run with --debug to see the raw JSON".colorize(:red).to_s
  end
end

