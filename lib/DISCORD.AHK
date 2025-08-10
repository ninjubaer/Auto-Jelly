#Include %A_LineFile%\..\WebSocket.ahk
class Discord {
	__New(intents, eventObj, token) {
		this.__last_sent := 0, this.ping := 0, this.s := 'null'
		this.ws := WebSocket("wss://gateway.discord.gg/?v=10&encoding=json", {
			message: onmsg,
			close: onclose
		})
		_rest_prototype := {
			__Class: "Discord.REST",
			GET: GET,
			POST: POST,
			PUT: PUT,
			PATCH: PATCH,
			DELETE: DELETE,
			token: ""
		}
		this.REST := {
			base: _rest_prototype,
			token: token
		}

		for key, value in eventObj.OwnProps() {
			if SubStr(key, 1, 2) = "on" {
				this.%key% := value
			}
		}

		identify()

		onmsg(ws, msg) {
			data := JSON.parse(msg)
			(data.Has("s") && this.s := data["s"])
			switch data["op"] {
				case 10: ; HELLO
					heartbeatinterval := data["d"]["heartbeat_interval"]
					SetTimer(startheartbeat.bind(heartbeatinterval), -2000)
				case 11: ; HEARTBEAT ACK
					DllCall("GetSystemTimeAsFileTime", "int64*", &time := 0)
					tooltip this.ping := Round((time - this.__last_sent) / 10000) ; 100ns to ms
				case 0: ; DISPATCH
					if this.HasMethod("on" . data["t"])
						return this.%"on" . data["t"]%.Call(this, data["d"])
					if this.HasMethod("onDispatch")
						return this.onDispatch.Call(this, data["t"], data["d"])
				default: FileAppend(data["op"], "*")
			}
		}
		onclose(ws, status, reason) {
			FileAppend("close`n", "*")
			if this.HasMethod("__Delete")
				this.__Delete()
		}

		; REST Object:
		GET(url, requestobj) {
			getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
			has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)

			whr := ComObject("WinHttp.WinHttpRequest.5.1")
			whr.Open("GET", url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
			if has(requestobj, "headers") {
				for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
					whr.SetRequestHeader(key, value)
				}
			}
			whr.SetRequestHeader("Authorization", "Bot " this.token)
			whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
			return async ? whr : whr.ResponseText
		}
		POST(url, requestobj) {
			getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
			has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
			whr := ComObject("WinHttp.WinHttpRequest.5.1")
			whr.Open("POST", url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
			if has(requestobj, "headers") {
				for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
					whr.SetRequestHeader(key, value)
				}
			}
			whr.SetRequestHeader("Authorization", "Bot " this.token)
			whr.SetRequestHeader("Content-Type", "application/json")
			whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
			return async ? whr : whr.ResponseText
		}
		PUT(url, requestobj) {
			getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
			has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
			whr := ComObject("WinHttp.WinHttpRequest.5.1")
			whr.Open("PUT", url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
			if has(requestobj, "headers") {
				for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
					whr.SetRequestHeader(key, value)
				}
			}
			whr.SetRequestHeader("Authorization", "Bot " this.token)
			whr.SetRequestHeader("Content-Type", "application/json")
			whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
			return async ? whr : whr.ResponseText
		}
		PATCH(url, requestobj) {
			getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
			has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
			whr := ComObject("WinHttp.WinHttpRequest.5.1")
			whr.Open("PATCH", url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
			if has(requestobj, "headers") {
				for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
					whr.SetRequestHeader(key, value)
				}
			}
			whr.SetRequestHeader("Authorization", "Bot " this.token)
			whr.SetRequestHeader("Content-Type", "application/json")
			whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
			return async ? whr : whr.ResponseText
		}
		DELETE(url, requestobj) {
			getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
			has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
			whr := ComObject("WinHttp.WinHttpRequest.5.1")
			whr.Open("DELETE", url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
			if has(requestobj, "headers") {
				for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
					whr.SetRequestHeader(key, value)
				}
			}
			whr.SetRequestHeader("Authorization", "Bot " this.token)
			whr.SetRequestHeader("Content-Type", "application/json")
			whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
			return async ? whr : whr.ResponseText
		}


		identify(*) {
			this.ws.sendText(
				'{"op":2,"d":{"token":"' token '","intents":' intents ',"properties":{"$os":"windows","$browser":"ninju`'s library","$device":"natro macro"},"presence":{"status":"online","activities":[{"name":"natro macro","type":0}],"since": null,"afk": false}}}'
			)
		}
		heartbeat(*) {
			this.ws.sendText(
				'{"op":1,"d":' this.s '}'
			)
			DllCall("GetSystemTimeAsFileTime", "int64*", &time := 0)
			this.__last_sent := time
		}
		StartHeartbeat(heartbeatinterval) {
			heartbeat()
			SetTimer(heartbeat, heartbeatinterval)
			this.DefineProp("__Delete", {
				Call: this => SetTimer(heartbeat, 0)
			})
		}
	}
}