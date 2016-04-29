/*
global Plotly:true,
global epidemium_config:true
*/


/** Return fake data as JSON
*/
function fake_data(){
    console.log("generate fake data");
    return {data:[{x:[1,2,3],y:[1,2,3]}], layout:{}};
}


/** Returns real data but stored locally
*/
function simulate_data(){
    return {"data":[{"type":"bar","inherit":false,"x":["giraffes","orangutans","monkeys"],"y":[20,14,23],"name":"SF Zoo","filename":"r-docs/simple-bar"}],
            "layout":{"xaxis":{"title":"c(\"giraffes\", \"orangutans\", \"monkeys\")"},"yaxis":{"title":"c(20, 14, 23)"},"margin":{"b":40,"l":60,"t":25,"r":10}},
            "url":{},"width":{},"height":{},"base_url":"https://plot.ly"};
}





/** Returns height to be used for plotly
    @param {JSON} layout - dict of layout properties
*/
function adjust_height(layout, default_height="500px"){
    if(typeof layout.height === 'undefined'){
        return default_height;
    } else {
        return layout.height;
    }
}






/** Appen a section (timeseries + sidebar), ie a new row, to the graph_zone
   @param {string} parent - Id of the div container where a section will be appended
   @param {string} layout - height of the row
*/
function append_section(parent, layout){
    // define id
    var common_date = Date.now();
    var section_id = common_date+"_section";
    var timeseries_id = common_date+"_timeseries";
    var sidebar_id = common_date+"_sidebar";

    // create div
    var section = $("<div/>", {"class": "row", "id":section_id});
    // var timeseries = $("<div/>",
    //                    {"class": "col-sm-10", "id": timeseries_id, "style":"height:500px;"});
    var timeseries = $("<div/>", {"class": "col-sm-10", "id": timeseries_id, "style": "height:500px;"});
    var sidebar = $("<div/>", {"class": "col-sm-2", "id": timeseries_id});
    

    // assign relationship
    $(parent).prepend(section);
    section.prepend(timeseries);
    section.append(sidebar); //add the sidebar on the right

    return {section: section[0], timeseries: timeseries[0], sidebar: sidebar[0]};
}






function suppress_timeserie(timeserie, sidebar){
    $(timeserie).remove();
    $(sidebar).remove();
}

 /** Add a graph (generated from content) to a div
    @param {string} where_to_plot - ID of the div to add a plot in as a child
    @param {json} content - {data:[], layout:{}} generated from API
*/
function generate_graph(where_to_plot, content, graph_parameters){
    var section = append_section(where_to_plot);
    adjust_height(content.layout);
    Plotly.newPlot(section.timeseries, content.data, content.layout);
    create_sidebar_button(where_to_plot, section.timeseries, section.sidebar, graph_parameters);
}

function update_factor(where_to_plot, graph_parameters, name){
    var graph_url = epidemium_config.graph_url;
    graph_parameters["factor"] = [];
    graph_parameters["factor"].push(name);
    var api_request = "data="+JSON.stringify(graph_parameters);
    $.post(graph_url, api_request)
        .done(function(content){
            var parsed_content = JSON.parse(content[0]);
            generate_graph(where_to_plot, parsed_content, graph_parameters);
        });
    graph_parameters["factor"] = []; //reset factor
}

/** Display side-buttons (delete, age, sex) on the right of the timeseries plot
   @param {div} timeserie - the plot div to be suppressed if suppress button is enables
   @param {div} sidebar - the div to plot the button in
   @param {dict} graph_parameters - parameters to send to API middle server
*/
function create_sidebar_button(where_to_plot, timeserie, sidebar, graph_parameters){

    //define id
    var sidebar_id = $(sidebar).attr("id");
    var suppress_id = sidebar_id+"_suppress";
    var age_id = sidebar_id+"_age";
    var sex_id = sidebar_id+"_sex";
    
    //define button suppress
    var suppress_row = $('<div/>',{"class":"row", "id":suppress_id});
    var suppress_button =  $('<img/>', {
        "src": "images/suppress_button.jpg",
        "width":50,
        "height":50
    });

    //define button age
    var age_row = $('<div/>',{"class":"row", "id":age_id});
    var age_button =  $('<img/>', {
        "src": "images/age_button.jpg",
        "width":50,
        "height":50
    });
    
    //define button sex
    var sex_row = $('<div/>',{"class":"row", "id":sex_id});
    var sex_button =  $('<img/>', {
        "src": "images/sex_button.jpg",
        "width":50,
        "height":50
    });

    
    //add button
    $(sidebar).append(suppress_row);
    $(suppress_row).append(suppress_button);
    $(sidebar).append(age_row);
    $(age_row).append(age_button);
    $(sidebar).append(sex_row);
    $(sex_row).append(sex_button);

    $(suppress_button).click(function(){
        suppress_timeserie(timeserie, sidebar);
    });
    $(age_button).click(function(){
        update_factor(where_to_plot, graph_parameters, "age.agg");
    });
    $(sex_button).click(function(){
        update_factor(where_to_plot, graph_parameters, "sexe");
    });
    
}

function display_json(where_to_plot, content){
    $(where_to_plot).append(content);
}



/** Add a subplot in a div 
    @param {string} graph_url - URL to query on API to get the graph
    @param {JSON} graph_parameters - Parameters to send as POST to get the graph
    @param {elt} where_to_plot -  div to plot in. A child will be appended to this div
*/
function add_plot(graph_parameters, where_to_plot){
    var api_request = "data="+JSON.stringify(graph_parameters);
    var graph_url = epidemium_config.graph_url;
    $.post(graph_url, api_request, "json") 
        .done(function(content){
            var parsed_content = JSON.parse(content[0]);
            generate_graph(where_to_plot, parsed_content, graph_parameters);
        });
}

/** Same than add_plot but do not require a connexion to middle server. Generate data locally
*/
function add_plot_local_only(graph_url, graph_parameters, where_to_plot){
    var parsed_content = simulate_data(); 
    generate_graph(where_to_plot, parsed_content, graph_parameters);
}
















