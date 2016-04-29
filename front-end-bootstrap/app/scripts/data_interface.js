/*
global Sortable:true,
global epidemium_config:true
global add_plot: true,
global add_plot_local_only: true
*/

// **********************************
// FONCTIONS POUR GERER LA LISTE DE DONNEES DEROULANTE
// **********************************

function create_list_div(str, str_a_afficher) {
    /*
    var str_a_afficher = str;
    if(str_a_afficher.length > 15) {
        str_a_afficher = str_a_afficher.slice(0,14);
    }
    */
    var new_div = $("<div/>", {
        "class": "list-group-item data-item",
        "text": " " + str_a_afficher,
        "id": 'data|' + str
    });
    // new_div.data('column_name', str);
    // ajoute une icone pour bouger
    new_div.prepend($('<span/>', {
        "class": "glyphicon glyphicon-move",
        "aria-hidden": "true",
        "style": "float:right;"
    }));
    //new_div.append($('<div/>', {class: "data_content"}).data('column_name', str));
    return new_div;
}

function add_elements_in_datalist(str_list) {
    var target_div = $("#datalist");
    target_div.empty();
    for(var i = 0; i < str_list.length; i++) {
        var item = str_list[i];
        target_div.append(
            create_list_div(item[0], item[1])
        );
    }
}

/**
Update the elements in the datalist based on the users input
*/
function update_data_list() {
    var list_of_data_items = epidemium_config.data_lists;
    var text_val = $("#data-text-search").val().toLowerCase().split(" ");  // array of words as input
    if(!text_val) {
        add_elements_in_datalist(list_of_data_items);
    }
    else {
        var str_to_display = [];
        for(var i = 0; i < list_of_data_items.length; i++){
            var item = list_of_data_items[i];
            var addit = true;
            for(var j = 0; j< text_val.length; j++){
                if(item[0].toLowerCase().indexOf(text_val[j]) < 0 & item[1].toLowerCase().indexOf(text_val[j]) < 0){
                    addit = false;
                }
            }
            if(addit){
                str_to_display.push(item); 
            }
        }
        if(!str_to_display) {
            add_elements_in_datalist(list_of_data_items);
        }
        add_elements_in_datalist(str_to_display);
    }
}

// **********************************
// FONCTIONS DE GESTION DU DRAG AND DROP
// **********************************

function set_drag_drop() {
    var datalist = document.getElementById("datalist");
    Sortable.create(datalist,{ 
        group: {
                name: "datalist",
                pull: "clone",
                put: false
            
        }
    });
    var datadest = document.getElementById("datadest");
    Sortable.create(datadest, { 
        group: {
            name: "datadest",
            pull: false,
            put: ['datalist']
        },
        animation: 0,
        onAdd: function(evt) {
            // s'execute quand l'element est ajoute a la liste
            // ajoute une icone pour supprimer
            var current_item = evt.item;
            //console.log($(current_item).data('column_name'));
            //console.log($(current_item).data('column_name'));
            var del_div = $('<span/>', {
                class: "glyphicon glyphicon-remove",
                style: "float:left;color:red;"
            });
            del_div.mousedown(function() {
                current_item.remove();
            });
            $(current_item).append(del_div);
        }
    });
}


// **********************************
// BOUTON DE CREATION DU PLOT
// **********************************


function get_data_name_from_div(elt){
    // pour récupérer le nom des colonnes on utilise l'attribu "id"
    // qui est formatté en "data|<column_name>"
    return $(elt).attr('id').split('|')[1];
}

function get_parameters_and_create_graph(){

    var where_to_plot = document.getElementById("main_pannel");
    // var graph_url = "http://20.20.21.172:8001/plotPost" ;
    var graph_url = "http://localhost:8001/plotPost";
    //var graph_url = "http://20.20.21.96:8001/plotPost" ;
    // get list of elements from datadest
    var data_items = [];
    $("#datadest").children(".data-item").each(function(i, elt){
        var name = get_data_name_from_div(elt);
        if(data_items.indexOf(name) < 0){
            data_items.push(name);
        }
    });


    // define graph_parameters from list of elements
    console.log(data_items); 
    if(data_items.length < 1){
        // plot default
        add_plot_local_only("rien", "rien", where_to_plot);
    }
    else {
        var parameters = {};
        parameters["var1"] = data_items[0];
        if(data_items.length>1) {
            parameters["var2"] = data_items[1];
            parameters["factor"] = [];
        }
        add_plot(parameters, where_to_plot);

    }
}



// **********************************
// SCRIPT START
// **********************************

$(document).ready(function() {

    console.log('starting when dom ready');    
    set_drag_drop();

    // set default values for data list
    update_data_list();
    // attach event to search box
    $("#data-text-search").keyup(update_data_list);
    // attach event to click button
    $("#createbutton").click(get_parameters_and_create_graph);
});
