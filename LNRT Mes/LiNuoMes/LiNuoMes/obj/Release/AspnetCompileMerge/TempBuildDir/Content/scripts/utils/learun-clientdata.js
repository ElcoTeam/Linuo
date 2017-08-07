$(function () {
    $.getclientdata();
})
var clientdataItem = [];

$.getclientdata = function () {
    $.ajax({
        url:"/fMenu.aspx/GetMenuList",
        type: "post",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            clientdataItem = data.d;
            alert(data.d);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            dialogMsg(errorThrown, -1);
        }
    });
    //alert(clientdataItem);
}