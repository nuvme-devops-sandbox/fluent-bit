function add_metadata(tag, timestamp, record)
    local path = record["filepath"]
    if path == nil then return 2, timestamp, record end

    local container_id = string.match(path, "/var/lib/docker/containers/([^/]+)/")
    if container_id == nil then return 2, timestamp, record end
    record["container_id"] = container_id

    local config_path = "/var/lib/docker/containers/" .. container_id .. "/config.v2.json"
    local file = io.open(config_path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        if content then
            local name = string.match(content, "\"Name\":\"/?([^\"]+)\"")
            if name then record["container_name"] = name end
        end
    end

    return 2, timestamp, record
end