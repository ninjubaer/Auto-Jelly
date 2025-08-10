class SlashCommandBuilder {
    options := []
    set_description(description) {
        this.description := description
        return this
    }
    set_name(name) {
        this.name := name
        return this
    }
    add_string_option(option_builder_function) {
        option := SlashCommandBuilder.Option(3)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_integer_option(option_builder_function) {
        option := SlashCommandBuilder.Option(4)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_boolean_option(option_builder_function) {
        option := SlashCommandBuilder.Option(5)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_user_option(option_builder_function) {
        option := SlashCommandBuilder.Option(6)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_channel_option(option_builder_function) {
        option := SlashCommandBuilder.Option(7)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_role_option(option_builder_function) {
        option := SlashCommandBuilder.Option(8)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_mentionable_option(option_builder_function) {
        option := SlashCommandBuilder.Option(9)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    add_number_option(option_builder_function) {
        option := SlashCommandBuilder.Option(10)
        (option_builder_function)(option)
        this.options.Push(option)
        return this
    }
    to_string() {
        str := '{"name":"' this.name '","description":"' this.description '"'
        if this.options.Length {
            str .= ',"options":['
            for i, option in this.options {
                str .= option.to_string()
                if (i < this.options.Length)
                    str .= ','
            }
            str .= ']'
        }

        str .= '}'
        return str
    }

    class Option {
        type := 0, choices := []
        __New(OptionType) => this.type := OptionType
        set_name(name) {
            this.name := name
            return this
        }
        set_description(description) {
            this.description := description
            return this
        }
        set_required(required) {
            this.required := required
            return this
        }
        add_choice(name, value) {
            this.choices.push({ name: name, value: value })
            return this
        }
        add_choices(choices) {
            for choice in choices {
                if !(choice.HasProp('name') && choice.HasProp('value'))
                    throw TypeError("Choice must have 'name' and 'value' properties")
                this.add_choice(choice.name, choice.value)
            }
            return this
        }
        to_string() {
            str := '{"type":' this.type ',"name":"' this.name '","description":"' this.description '"'
            if this.HasProp('required') {
                str .= ',"required":' (this.required ? 'true' : 'false')
            }
            if this.choices.Length {
                str .= ',"choices":['
                for i, choice in this.choices {
                    str .= '{"name":"' choice.name '","value":"' choice.value '"}'
                    if (i < this.choices.Length)
                        str .= ','
                }
                str .= ']'
            }
            str .= '}'
            return str	
        }
    }
}
