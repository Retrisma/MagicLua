local curl = require("cURL")
local json = require("lib/json")

local function get(url)
    local response = {}

    curl.easy{
        url = url,
        httpheader = {
            "User-Agent: MagicLua/dev",
            "Accept: */*"
        },
        writefunction = function(str)
            table.insert(response, str)
            return #str
        end
    }:perform():close()

    response = table.reduce(response, function(a, b) return a .. b end)

    response = json.decode(response)

    local data = response.data

    if response.has_more then
        os.execute("sleep 0.1")
        table.append(data, get(response.next_page))
    end

    return data
end

local function make_request(endpoint)
    endpoint = string.gsub(endpoint, " ", "%%20")
    endpoint = "https://api.scryfall.com/cards/search?q=" .. endpoint

    local response = get(endpoint)

    return response
end

return {
    get_card = function (name)
        local endpoint = "!'" .. name .. "'"

        return make_request(endpoint)
    end,

    search = function (query)
        return make_request(query)
    end
}