Class REST {
    __New(token, version?) {
        this.token := token, this.version := version ?? 10, this.baseAPI := 'https://discord.com/api/v' this.version '/'
        this.defaultHeaders := {
            Authorization: "Bot " this.token, %"User-Agent"%: "DiscordBot (by Ninju)"
        }
    }
    Call(method, endpoint, options) {
        (whr := ComObject("WinHttp.WinHttpRequest.5.1")).Open(method, this.baseAPI . endpoint, false)
        for i, j in this.defaultHeaders.OwnProps()
            whr.SetRequestHeader(i, j)
        for i, j in (options.hasProp("headers") ? options.headers : {}).OwnProps()
            whr.SetRequestHeader(i, j)
        whr.Send(options.hasProp("body") ? ((IsObject(options.hasProp("body") ? options.body : "") && !(options.body is ComObjArray || options.body is FormData)) ? JSON.stringify(options.hasProp("body") ? options.body : "") : (options.body is FormData) ? (options.body).data() : options.hasProp("body") ? options.body : "") : "")
        return { status: whr.Status, text: whr.ResponseText, json: JSON.parse(whr.ResponseText) }
    }
    Get(endpoint, options) {
        return this.Call("GET", endpoint, options)
    }
    Post(endpoint, options) {
        return this.Call("POST", endpoint, options)
    }
    Patch(endpoint, options) {
        return this.Call("PATCH", endpoint, options)
    }
    Put(endpoint, options) {
        return this.Call("PUT", endpoint, options)
    }
    Delete(endpoint, options) {
        return this.Call("DELETE", endpoint, options)
    }
    SendMessage(channelId, content) {
        if content.hasProp("embeds") {
            embeds := []
            for i, j in content.embeds {
                if j is EmbedBuilder
                    embeds.Push(j.embedObj)
                else embeds.Push(j)
            }
            content.embeds := embeds
        }
        if content.hasProp("components") {
            components := []
            for i, j in content.components {
                if j is ActionRowBuilder
                    components.Push(j.actionRow)
                else components.Push(j)
            }
            content.components := components
        }
        if content.hasProp("files") {
            form := FormData()
            for i, j in content.files {
                if !j is AttachmentBuilder
                    throw Error("expected AttachmentBuilder")
                if j.isBitmap
                    form.AppendBitmap(j.file, j.fileName)
                else form.AppendFile(j.file, j.contentType)
                content.files[i] := j.attachmentName
            }
            form.AppendJSON("payload_json", { content: content.hasProp("content") ? content.content : "", embeds: embeds ?? [], files: [], components: components ?? []})
            contentType := form.contentType, body := form.data()
        }
        return this("POST", "channels/" channelId "/messages", {
            body: body ?? content,
            headers: { %"Content-Type"%: contentType ?? "application/json" }
        })
    }
    __Call(method, endpoint, options) {
        return this.Call(method, endpoint, options)
    }
    createSlashCommand(command) {
        if !command is SlashCommandBuilder
            throw Error("expected SlashCommandBuilder but instead got a " Type(command))
        if !command.commandObject.hasProp("name") || !command.commandObject.name || !command.commandObject.hasProp("description") || !command.commandObject.description
            throw Error("name and description are required")
        return this("POST", "applications/1069637978114240612/commands" (!command.guildId or command.guildId = JSON.null ? "" : "?guild_id=" command.guildId), {
            body: command.commandObject, headers: { %"Content-Type"%: "application/json" }
        })
    }
    removeSlashCommand(commandId, guildId) =>
        this("DELETE", "applications/1069637978114240612/commands/" commandId (!guildId or guildId = JSON.null ? "" : "?guild_id=" guildId))
}
