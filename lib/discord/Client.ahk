Class client {
    __New(intents) {
        this.events := {
            HELLO: [], READY: [], RESUMED: [], RECONNECT: [], INVALID_SESSION: [],
            CHANNEL_CREATE: [], CHANNEL_UPDATE: [], CHANNEL_DELETE: [], CHANNEL_PINS_UPDATE: [],
            THREAD_CREATE: [], THREAD_UPDATE: [], THREAD_DELETE: [], THREAD_LIST_SYNC: [],
            THREAD_MEMBER_UPDATE: [], THREAD_MEMBERS_UPDATE: [],
            GUILD_CREATE: [], GUILD_UPDATE: [], GUILD_DELETE: [], GUILD_BAN_ADD: [], GUILD_BAN_REMOVE: [],
            GUILD_EMOJIS_UPDATE: [], GUILD_STICKERS_UPDATE: [], GUILD_INTEGRATIONS_UPDATE: [],
            GUILD_MEMBER_ADD: [], GUILD_MEMBER_REMOVE: [], GUILD_MEMBER_UPDATE: [], GUILD_MEMBERS_CHUNK: [],
            GUILD_ROLE_CREATE: [], GUILD_ROLE_UPDATE: [], GUILD_ROLE_DELETE: [],
            GUILD_SCHEDULED_EVENT_CREATE: [], GUILD_SCHEDULED_EVENT_UPDATE: [], GUILD_SCHEDULED_EVENT_DELETE: [],
            GUILD_SCHEDULED_EVENT_USER_ADD: [], GUILD_SCHEDULED_EVENT_USER_REMOVE: [],
            INTEGRATION_CREATE: [], INTEGRATION_UPDATE: [], INTEGRATION_DELETE: [],
            INTERACTION_CREATE: [], INVITE_CREATE: [], INVITE_DELETE: [],
            MESSAGE_CREATE: [], MESSAGE_UPDATE: [], MESSAGE_DELETE: [], MESSAGE_DELETE_BULK: [],
            MESSAGE_REACTION_ADD: [], MESSAGE_REACTION_REMOVE: [], MESSAGE_REACTION_REMOVE_ALL: [], MESSAGE_REACTION_REMOVE_EMOJI: [],
            PRESENCE_UPDATE: [], STAGE_INSTANCE_CREATE: [], STAGE_INSTANCE_UPDATE: [], STAGE_INSTANCE_DELETE: [],
            TYPING_START: [], USER_UPDATE: [], VOICE_STATE_UPDATE: [], VOICE_SERVER_UPDATE: [],
            VOICE_CHANNEL_STATUS_UPDATE: [], WEBHOOKS_UPDATE: []
        }

        this.s := JSON.null
        this.intents := intents
        this.ws := WebSocket("wss://gateway.discord.gg/", {
            message: (self, msg) => this.omsg(msg),
            disconnect: (self, code, reason) => MsgBox("Disconnected: " code " " reason)
        })
    }
    login(token) {
        this.BotToken := token
        this.ws.sendText(('{"op":2,"d":{"token":"' token '", "intents":' this.intents ', "properties":{"os":"windows","browser":"ahk","device":"ahk"}}}'))
        this.rest := REST(token)
    }
    omsg(msg) {
        data := JSON.parse(msg, true, false)
        switch data.op {
            case 10:
                this.heartbeatInterval := data.d.heartbeat_interval
                SetTimer(this.sendHeartbeat.bind(this), this.heartbeatInterval)
            case 0:
                this.s := data.s
                this.handleEvent(data)
        }
    }
    handleEvent(data) {
        switch data.t {
            case "READY":
                this.user := data.d.user
        }
        this.CallEvents(data.t, data.d)
    }
    sendHeartbeat(*) {
        this.ws.sendText('{"op":1,"d":' this.s '}')
    }
    on(event, function) {
        this.events.%event%.push({ f: function, once: false })
    }
    once(event, function) {
        this.events.%event%.push({ f: function, once: true })
    }
    waitFor(event, callback, timeout := 1000) {
        happened := false, args := []
        this.once(event, (a*) => (happened := true, args := a))
        s := QPC()
        loop {
            if happened
                return (callback(args*), true)
            if (QPC() - s) > timeout
                return false
        }
    }
    CallEvents(event, args*) {
        if !this.events.hasProp(event)
            return
        for i, e in this.events.%event% {
            (e.f)(args*)
            if e.once
                this.events.%event%.RemoveAt(i)
        }
    }
    setPresence(presence) =>
        this.ws.sendText('{"op":3,"d":' JSON.stringify(presence, false, "") '}')
    __Delete() {
        this.ws.close()
    }
}
Class Interaction {
    __New(self, data) {
        this.data := data, this.client := self
    }
    reply(content) {
        contentType := "application/json"
        if !content.hasProp("data")
            content := { type: 4, data: content }
        if content.data.hasProp("embeds")
            for i, j in content.data.embeds
                if j is EmbedBuilder
                    content.data.embeds[i] := j.embedObj
        if content.data.hasProp("components")
            for i, j in content.data.components
                if j is ActionRowBuilder
                    content.data.components[i] := j.actionRow
        if content.data.hasProp("files") {
            form := FormData()
            for i, j in content.data.files {
                if !j is AttachmentBuilder
                    throw Error("expected AttachmentBuilder")
                if j.isBitmap
                    form.AppendBitmap(j.file, j.fileName)
                else form.AppendFile(j.file, j.contentType)
                content.data.files[i] := j.attachmentName
            }
            form.AppendJSON("payload_json", content)
            contentType := form.contentType, body := form.data()
        }
        return (this.client.rest)("POST", "interactions/" this.data.id "/" this.data.token "/callback", {
            body: body ?? content,
            headers: { %"Content-Type"%: contentType }
        })
    }
    isCommand => this.data.hasProp("data") && this.data.data.hasProp("name")
    isButton => this.data.hasProp("data") && this.data.data.hasProp("component_type") && this.data.data.component_type = 2
    isSelectMenu => this.data.hasProp("data") && this.data.data.hasProp("component_type") && this.data.data.component_type = 3
    getOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name
                return j.value
    }
    getStringOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 3
                return j.value
        return JSON.null
    }
    getIntegerOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 4
                return j.value
        return JSON.null
    }
    getBooleanOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 5
                return j.value
        return JSON.null
    }
    getUserOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 6
                return j.value
        return JSON.null
    }
    getChannelOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 7
                return j.value
        return JSON.null
    }
    getRoleOption(name) {
        if !this.isCommand
            return
        for i, j in this.data.data.options
            if j.name = name && j.type = 8
                return j.value
        return JSON.null
    }

    editReply(content) {
        contentType := "application/json"
        if content.hasProp("embeds")
            for i, j in content.embeds
                if j is EmbedBuilder
                    content.embeds[i] := j.embedObj
        if content.hasProp("components")
            for i, j in content.components
                if j is ActionRowBuilder
                    content.components[i] := j.actionRow
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
            form.AppendJSON("payload_json", content)
            contentType := form.contentType, body := form.data()
        }
        return (this.client.rest)("PATCH", "webhooks/" this.client.user.id "/" this.data.token "/messages/@original", {
            body: body ?? content,
            headers: { %"Content-Type"%: contentType }
        })
    }
    deleteReply() {
        return (this.client.rest)("DELETE", "webhooks/" this.client.user.id "/" this.data.token "/messages/@original")
    }
    deferReply() {
        return (this.client.rest)("POST", "interactions/" this.data.id "/" this.data.token "/callback", {
            body: { type: 5 },
            headers: { %"Content-Type"%: "application/json" }
        })
    }
    getSelectedOptions() {
        if !this.isSelectMenu
            return
        return this.data.data.values
    }
}

Class presence {
    static playing := 0,
        streaming := 1,
        listening := 2,
        watching := 3
}
Class intents {
    static GUILDS := 1 << 0,
        GUILD_MEMBERS := 1 << 1,
        GUILD_BANS := 1 << 2,
        GUILD_EMOJIS_AND_STICKERS := 1 << 3,
        GUILD_INTEGRATIONS := 1 << 4,
        GUILD_WEBHOOKS := 1 << 5,
        GUILD_INVITES := 1 << 6,
        GUILD_VOICE_STATES := 1 << 7,
        GUILD_PRESENCES := 1 << 8,
        GUILD_MESSAGES := 1 << 9,
        GUILD_MESSAGE_REACTIONS := 1 << 10,
        GUILD_MESSAGE_TYPING := 1 << 11,
        DIRECT_MESSAGES := 1 << 12,
        DIRECT_MESSAGE_REACTIONS := 1 << 13,
        DIRECT_MESSAGE_TYPING := 1 << 14,
        MESSAGE_CONTENT := 1 << 15,
        GUILD_SCHEDULED_EVENTS := 1 << 16
}