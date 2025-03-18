local alert_types = {
    NOTE = true,
    TIP = true,
    IMPORTANT = true,
    CAUTION = true,
    WARNING = true
}

function BlockQuote(el)
    -- 检测 [!TYPE] 模式
    local first_para = el.content[1]
    if first_para and first_para.t == "Para" then
        local first_text = first_para.content[1]
        if first_text and first_text.text then
            local alert_type = first_text.text:match("%[!([A-Z]+)%]")
            if alert_type and alert_types[alert_type] then
                -- 创建新 DIV 结构
                local title_div = pandoc.Div({
                    pandoc.Para({
                        pandoc.Str(alert_type)
                    })
                }, {class = "title"})

                local content = {}
                -- 保留除第一行外的其他内容
                for i=2, #el.content do
                    table.insert(content, el.content[i])
                end

                return pandoc.Div({
                    title_div,
                    pandoc.Div(content)
                }, {class = string.lower(alert_type)})
            end
        end
    end
    return el
end
