#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, Off 
;=============INCLUDES=============
#include %A_ScriptDir%/../lib/
#Include Gdip_All.ahk
#Include JSON.ahk
#include Roblox.ahk
#include DarkMsgbox.ahk
#include DISCORD.ahk
#Include EmbedBuilder.ahk
#include AttachmentBuilder.ahk
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


authorAttachment := Attachment.File('.\..\images\birb.png')
author := {name: "Auto-Jelly", icon_url: authorAttachment.attachmentName}

if discordMode {
    Bot := Discord(513, {
        onReady: (*)=>(Bot.rest.SendMessage(channelID, {embeds: [EmbedBuilder().setTitle("Bot is ready!").setAuthor(author).setTimeStamp()], files: [authorAttachment]})),
        onInteraction_Create: (obj)=>(myInteraction:=Discord.Interaction(Bot, obj), interactionHandler(myInteraction)) 
      }, BotToken)
}
else
    webhook := WebhookURL ? WebHookBuilder(WebhookURL) : 0



OnMessage(0x7001, KeepReplace)

InteractionHandler(myInteraction) {
    if myInteraction.data.data.HasProp("custom_id") {
        if myInteraction.data.data.custom_id == "0" {
            WinActivate("Auto-Jelly!"), Send("n{Enter}")
            myInteraction.reply({content: "Lets keep rolling!", flags: 64})
        }
        else if myInteraction.data.data.custom_id == "1" {
            WinActivate("Auto-Jelly!"), Send("y{Enter}")
            myInteraction.reply({content: "Let's go! 🎉", flags: 64})
        }
    }
}

KeepReplace(*) {
    if (!discordMode) {
        img := Attachment.Bitmap(pBitmap := Gdip_BitmapFromScreen())
        obj := {}
        obj.embeds := [EmbedBuilder().setTitle("Found a match!").setAuthor(author).setImage(img).setTimeStamp()]
        obj.files := [img, authorAttachment]
        if userID
            obj.content := "<@" userID ">"
        webhook.send(obj)
        return
    }
    pBitmap:=Gdip_BitmapFromScreen()
    img := Attachment.Bitmap(pBitmap)
    actionRow := ActionRowBuilder().AddButton({style:ActionRowBuilder.ButtonStyles.Red, label: 'NO', disabled: false, custom_id: '0'}).AddButton({style:ActionRowBuilder.ButtonStyles.Green, label: 'YES', disabled: false, custom_id: '1'})
    Bot.rest.SendMessage('1207367046313283596', {
        embeds: [EmbedBuilder().setTitle("Do you want to keep this?").setImage(img).setAuthor(author).setTimeStamp()],
        components: [actionRow],
        files: [img, authorAttachment],
        content: userID ? "<@" userID ">" : ""
    })
}
