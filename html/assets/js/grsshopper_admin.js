var url = 'http://www.mooc.ca/cgi-bin/api.cgi';


function onclick_function(col_name,persist) {

    $('#'+col_name+'_button').show();
    if (persist) { return; }
    $('#'+col_name+'_result').hide();
}

function submit_function(table,id,col_name,content,type) {

        $.ajax({
            url: url,
            data: {type:type,table_id:id,table_name:table,updated:1,value:content,col_name:col_name,type:type},
            error: function(value) {
                $('#'+col_name+'_result').html("<span class=\"error\">An error has occurred</span>");
                $('#'+col_name+'_result').show(); },
            success: function(value) {
                $('#'+col_name+'_result').html("<span class=\"success\">"+value+"</span>");
                $('#'+col_name+'_result').show();
                $('#record_summary').load("admin.cgi?"+table+"="+id+"&format=summary"); },
            type: "post",
        });


}

function search_function(query,types,sort,format,col_name) {

        $.ajax({
            url: url,
            data: {types:types,query:query,sort:sort,search:1,col_name:col_name,format:format},
            error: function(value) {
              alert("error");
                $('#'+col_name).html("<span class=\"error\">An error has occurred</span>");
                $('#'+col_name).show(); },
            success: function(value) {
                $('#'+col_name).html(value);
                $('#'+col_name).show(); },
            type: "post",
        });


}
