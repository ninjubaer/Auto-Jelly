Class ActionRowBuilder {
    static ButtonStyles := {
        PRIMARY: 1,
        SECONDARY: 2,
        SUCCESS: 3,
        DANGER: 4,
        LINK: 5,
        Red: 4,
        Green: 3,
        Blue: 1,
        Gray: 2,
        URL: 5,
    }
    __New() {
        this.actionRow := {type: 1, components: []}
    }
    AddButton(obj) {
        content := {
            type: 2,
            style: obj.hasProp('style') ? obj.style : 1,
            label: obj.hasProp('label') ? obj.label : 'Button',
            disabled: obj.hasProp('disabled') && obj.disabled = true ? JSON.true : JSON.false,
        }
        if obj.hasProp('custom_id')
            content.custom_id := obj.custom_id
        else 
            if obj.style != 5
                throw Error('Buttons must have a custom_id')
        if obj.hasProp('url') && content.style = 5
            content.url := obj.url
        this.actionRow.components.push(content)
        return this
    }
    AddSelectMenu(obj) {
        content := {
            type: 3,
            placeholder: obj.hasProp('placeholder') ? obj.placeholder : 'Select an option',
            options: obj.hasProp('options') ? obj.options : [],
            disabled: obj.hasProp('disabled') && obj.disabled = true ? JSON.true : JSON.false,
            min_values: obj.hasProp('min_values') ? obj.min_values : 1,
            max_values: obj.hasProp('max_values') ? obj.max_values : 1,
        }
        if obj.hasProp('placeholder')
            content.placeholder := obj.placeholder
        for i in obj.options
            if !(i.hasProp('label') && i.hasProp('value') && i.label && i.value)
                throw Error('Options must have a label and value')
        if obj.hasProp('custom_id')
            content.custom_id := obj.custom_id
        else
            throw Error('Select Menus must have a custom_id')
        this.actionRow.components.push(content)
        return this
    }
}
