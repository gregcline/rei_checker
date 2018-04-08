require "./product.cr"
require "./json_types.cr"
require "http"

# Represents a single query. It has a name and URI for the query.
class QueryURI
  getter name : String
  getter uri : String

  def initialize(name, uri, params)
    @name = name.to_s
    @uri = uri + "?" + HTTP::Params.encode(params)
  end

  def debug
    uri
  end
end

# Creates a group of queries from a JSON query file. It makes a QueryURI for
# each query and implements Enumerable for the set of querys.
class QueryURIs
  include Enumerable(QueryURI)

  @uri : String

  def initialize(query_file)
    file = File.read(query_file)
    uri_data = URIData.from_json(file)
    @uri = uri_data.url
    @queries = make_uris(uri_data.queries)
  end

  def each
    queries.each do |query|
      yield query
    end
  end

  private getter queries : Array(QueryURI)
  private getter uri

  def make_uris(data) : Array(QueryURI)
    # I had to use .as(QueryURI) at the end here to please the compiler.
    data.map do |query|
      QueryURI.new(query.name, uri, query.params).as(QueryURI)
    end
  end
end

# Represents a response from the REI API. It will make Products out of all the
# products returned. Depending on which configuration options the program is run
# with, its to_s will change.
class Response
  getter name : String, results : Array(Product), raw : String

  def initialize(name, info, ops)
    @name = name
    @raw = info
    @results = productify(JSONResponse.from_json(info).results)
    @config = configure(ops)
  end

  def to_s
    return debug if debug?
    return sales if sales?
    "Here are the products available for #{name}:\n".colorize.white.underline.to_s +
      "#{results.map(&.to_s).join("\n")}\n"
  end

  private getter config : Configs

  # The to_s implementation for debug mode.
  private def debug
    "Here is the raw JSON returned for #{name}:\n".colorize.white.underline.to_s +
      "#{raw}\n"
  end

  # The to_s implementation for sales mode
  private def sales
    "Here are the products on sale for #{name}:\n".colorize.white.underline.to_s +
      "#{results.select(&.on_sale?).map(&.to_s).join("\n")}\n"
  end

  private def productify(results)
    results.map { |product| Product.new(product) }
  end

  private def debug?
    config.debug
  end

  private def sales?
    config.sales
  end

  # A simple struct to represent the configuration values for the app
  struct Configs
    property debug : Bool, sales : Bool

    def initialize(debug, sales)
      @debug = debug
      @sales = sales
    end
  end

  private def configure(ops)
    Configs.new(ops["debug"], ops["sales"])
  end
end
