Class SlashCommandBuilder {
    __New() {
        this.commandObject := {}, this.guildId := JSON.null
    }
    setName(name) {
        this.commandObject.name := name
        this.name := name
        return this
    }
    setDescription(description) {
        this.commandObject.description := description
        return this
    }
    addStringOption() {
        if !this.commandObject.hasProp('options')
            this.commandObject.options := [{type:3}]
        else
            this.commandObject.options.push({type:3})
        return SlashCommandBuilder.Option(this,this.commandObject.options[this.commandObject.options.length])
    }
    addIntegerOption() {
        if !this.commandObject.hasProp('options')
            this.commandObject.options := [{type:4}]
        else
            this.commandObject.options.push({type:4})
        return SlashCommandBuilder.Option(this,this.commandObject.options[this.commandObject.options.length])
    }
    addBooleanOption() {
        if !this.commandObject.hasProp('options')
            this.commandObject.options := [{type:5}]
        else
            this.commandObject.options.push({type:5})
        return SlashCommandBuilder.Option(this,this.commandObject.options[this.commandObject.options.length])
    }
    addUserOption() {
        if !this.commandObject.hasProp('options')
            this.commandObject.options := [{type:6}]
        else
            this.commandObject.options.push({type:6})
        return SlashCommandBuilder.Option(this,this.commandObject.options[this.commandObject.options.length])
    }
    Class Option {
        __New(command, optionsObject) {
            this.command := command
            this.option:=optionsObject

        }
        setName(name) {
            this.option.name := name
            return this
        }
        setDescription(description) {
            this.option.description := description
            return this
        }
        setType(type) {
            this.option.type := type
            return this
        }
        setRequired(required) {
            this.option.required := JSON.%(required ? "true": "false")%
            return this
        }
        addChoice(name, value) {
            value := value = "true" ? JSON.true : value = "false" ? JSON.false : value
            if this.option.hasProp('choices')
                this.option.choices.push({name: name, value: value})
            else
                this.option.choices := [{name: name, value: value}]
            return this
        }
        addOption(options) {
            if this.option.hasProp('options')
                this.option.options.push(options)
            else
                this.option.options := [options]
            return SlashCommandBuilder.Option(this.command, this.option.options[this.option.options.length])
        }
    }
}
