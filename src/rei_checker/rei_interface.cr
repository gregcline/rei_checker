require "./queries.cr"
require "./product.cr"

class ReiInterface
  property query_uris : QueryURIs, results

  def initialize(query_uris, ops = {} of String => Bool)
    @query_uris = query_uris
    @ops = defaults.merge(ops)
  end

  def fetch
    puts query_uris.map{ |query_uri| run_query(query_uri) }
                  .map(&.to_s)
                  .join("\n")
  end

  private getter ops : Hash(String, Bool)

  private def debug?
    ops["debug"]
  end

  private def defaults
    {
      "debug" => false,
      "sales" => false,
    }
  end

  private def run_query(query_uri : QueryURI)
    begin
      puts query_uri.debug if debug?

      response = HTTP::Client.get(query_uri.uri)
      Response.new(query_uri.name, response.body, ops)
    rescue e
      puts e
      FetchError
    end
  end
end

class FetchError < Exception
  def to_s
    "There was an issue fetching the data from the REI site"
  end
end
