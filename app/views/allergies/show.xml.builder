xml.instruct!
xml.allergy('xmlns' => "http://projecthdata.org/hdata/schemas/2009/06/allergy",
            'xmlns:core' => "http://projecthdata.org/hdata/schemas/2009/06/core") do |allergy|
           allergy.product("displayName" => @allergy.free_text_product, "code" => @allergy.product_code, "codeSystem" => "RxNorm")
           allergy.tag!("core:date", @allergy.start_event.xmlschema)

end