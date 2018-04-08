require "json"

# This file defines mappings from JSON to Crystal classes. These and the
# product/query classes can probably be combined but I haven't gotten to it yet.

class SearchData
  JSON.mapping(
    name: String,
    params: Hash(String, String)
  )
end

class URIData
  JSON.mapping(
    url: String,
    queries: Array(SearchData)
  )
end

class JSONResponse
  JSON.mapping(
    results: Array(JSONResult)
  )
end

class JSONResult
  JSON.mapping(
    availableColors: Array(JSONColor),
    cleanTitle: String,
    displayPrice: JSONPrice
  )
end

class JSONColor
  JSON.mapping(
    color: String,
    vendorColor: String
  )
end

class JSONPrice
  JSON.mapping(
    priceDisplay: JSONPriceDisplay
  )
end

class JSONPriceDisplay
  JSON.mapping(
    price: {type: String, nilable: true},
    salePrice: {type: String, nilable: true},
    savingsPercent: {type: String, nilable: true}
  )

  def sale?
    !salePrice.nil?
  end
end
