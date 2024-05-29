import { createApp } from "vue"

$(document).ready( () => {

    $(':root').css('--primary', theme.primaryColor);
    $(':root').css('--secondary', theme.secondaryColor);
    $(':root').css('--alternative', theme.alternativeColor);
    $(':root').css('--disabled', theme.disabledColor);

    let firstTimeOpened = false

    const app = createApp({
        data () {
            return {
                menu: {
                    isOpen: false, 
                    header: {},
                    options: []
                }
            }
        },
        methods: {
            headerClicked () {
                if ( !this.menu.disabled && this.menu.params ) {
                    this.menu.isOpen = false
                    $.post('http://qb-menu/onClick', JSON.stringify({
                        params: this.menu.params,
                        isHeader: true
                    }))
                }
            },
            optionClicked (index) {
                const option = this.menu.options[index]
                if (!option.disabled && !option.hidden ) {
                    this.menu.isOpen = false
                    $.post('http://qb-menu/onClick', JSON.stringify({
                        params: option.params,
                        isHeader: false, 
                        index: index
                    }))
                }
               
            }
        }
    })

    const App = app.mount("#app")
    const appData = App.$data

    $('#menu').hide()

    window.addEventListener('message', (e) => {
        var data = e.data 

        if ( data.show ) {
            appData.menu.header = data.header 
            appData.menu.options = data.options 

            if ( !firstTimeOpened ) { 
                firstTimeOpened = true
                $('#menu').show() 
            }

            appData.menu.isOpen = true 

            return 
        } 

        appData.menu.isOpen = false

    })

})

