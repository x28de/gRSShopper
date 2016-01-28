$(function() 
{
 
$("h4").click(function() 
{
var valueid = $(this).attr("id");
var sid=valueid.split("value");
var id=sid[1];
var dataString = 'id='+ id ;
var parent = $(this).parent();
$(this).hide();
$("#formbox"+id).show();
return false;
});
	
$(".save").click(function() 
{
var A=$(this).parent().parent();
var X=A.attr('id');
var d=X.split("formbox"); // Splitting  Eg: formbox21 to 21
var id=d[1];
var Z=$("#"+X+" input.fcontent").val();
var action=$("#"+X+" input.action").val();
var table=$("#"+X+" input.table").val();
var dataString = 'name='+ id +'&value='+Z+'&action='+action+'&table='+table;
$.ajax({
type: "POST",
url: "http://www.downes.ca/cgi-bin/admin.cgi",
data: dataString,
cache: false,
timeout: 5000,
error: function(request,error) {
  $("#loading").addClass("hide");
  if (error == "timeout") {
   $("#error").append("The request timed out, please resubmit");
  }
  else {
   $("#error").append("ERROR: " + error);
  }
   alert("ERROR: " + error);
   return false;
  },

success: function(data)
{
A.hide(); 
$("#value"+id).html(Z); 
$("#value"+id).show(); 
}
});

return false;
});
	

$(".cancel").click(function() 
{
var A=$(this).parent().parent();
var X= A.attr("id");
var d=X.split("formbox");
var id=d[1];
var parent = $(this).parent();
$("#value"+id).show();
A.hide();
 

return false;
});
	
});
 