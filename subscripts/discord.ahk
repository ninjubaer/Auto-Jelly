#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, Off 
;=============INCLUDES=============
#Include .\..\lib\DISCORD.AHK
#Include .\..\lib\FormData.ahk
#Include .\..\lib\Gdip_All.ahk
#Include .\..\lib\JSON.ahk
#Include .\..\lib\WebSockets.ahk
#include .\..\lib\Roblox.ahk
#include .\..\lib\DarkMsgbox.ahk
;=============SETUP================
CoordMode 'Mouse', 'Screen'
CoordMode 'Pixel', 'Screen'
Persistent 1
DetectHiddenWindows 1
pToken := Gdip_Startup()
;=============GLOBALS==============
if A_Args.Length < 5
    MsgBox("This Script needs to be run by Auto-Jelly.ahk!","Auto-Jelly", "iconx"),ExitApp()
BotToken := A_Args[1]
userID := A_Args[2]
channelID := A_Args[3]
WebhookURL := A_Args[4]
discordMode := A_Args[5]


authorAttachment := AttachmentBuilder('.\..\images\birb.png')
author := {name: "Auto-Jelly", icon_url: authorAttachment.attachmentName}

if discordMode {
    Bot := client(513)
    Bot.once("READY", (*)=>(Bot.rest.SendMessage(channelID, {embeds: [EmbedBuilder().setTitle("Bot is ready!").setAuthor(author).setTimeStamp()], files: [authorAttachment]})))
    Bot.login(BotToken)
    bot.on("Interaction_create", (obj)=>(myInteraction:=Interaction(Bot, obj), interactionHandler(myInteraction)))
}
else
    webhook := WebHookBuilder(WebhookURL)



OnMessage(0x7001, KeepReplace)

InteractionHandler(myInteraction) {
    if myInteraction.data.data.HasProp("custom_id") {
        if myInteraction.data.data.custom_id == "0" {
            WinActivate("Auto-Jelly!"), Send("n{Enter}")
        }
        else if myInteraction.data.data.custom_id == "1" {
            WinActivate("Auto-Jelly!"), Send("y{Enter}")
        }
    }
}

KeepReplace(*) {
    if (!discordMode) {
        attachment := AttachmentBuilder(pBitmap := Gdip_BitmapFromScreen())
        obj := {}
        obj.embeds := [EmbedBuilder().setTitle("Found a match!").setAuthor(author).setImage(attachment).setTimeStamp()]
        obj.files := [attachment, authorAttachment]
        if userID
            obj.content := "<@" userID ">"
        webhook.send(obj)
        return
    }
    pBitmap:=Gdip_BitmapFromScreen()
    attachment := AttachmentBuilder(pBitmap)
    actionRow := ActionRowBuilder().AddButton({style:ActionRowBuilder.ButtonStyles.Red, label: 'NO', disabled: false, custom_id: '0'}).AddButton({style:ActionRowBuilder.ButtonStyles.Green, label: 'YES', disabled: false, custom_id: '1'})
    Bot.rest.SendMessage('1207367046313283596', {
        embeds: [EmbedBuilder().setTitle("Do you want to keep this?").setImage(attachment).setAuthor(author).setTimeStamp()],
        components: [actionRow],
        files: [attachment, authorAttachment],
        content: userID ? "<@" userID ">" : ""
    })
}
