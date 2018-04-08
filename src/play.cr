require "json"
require "./rei_checker/json_types.cr"

module JSONReader
  extend self

  def json
    data = File.read("./queries.json")
    URIData.from_json(data)
  end
end
