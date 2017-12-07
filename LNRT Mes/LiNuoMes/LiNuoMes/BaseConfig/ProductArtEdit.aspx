<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductArtEdit.aspx.cs" Inherits="LiNuoMes.BaseConfig.ProductArtEdit" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
       <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
<%--    <script src="../Content/adminLTE/index.js"></script>--%>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var ArtId = "";
         var OPtype   = "";
         var OPaction = "";

         $(function () {
                ArtId = request('ArtId');
                OPtype = request('OPtype');

             if (ArtId == undefined) {
                    ArtId = 0;
             }
         
             if (OPtype == undefined) {
                 OPtype = "CHECK";
             }

             if (OPtype == "CHECK") {
                 OPaction = "Process_Art_DETAIL";
             }
             else if (OPtype == "EDIT") {
                 OPaction = "Process_Art_EDIT";
             }
             else if (OPtype == "ADD") {
                 OPaction = "Process_Art_ADD";
             }
             else {
                 return;
             }
             InitialPage();
             CreateSelect();
         });
         
         function InitialPage() {
             if (OPtype == "CHECK") {
                 $(".form-control").attr("disabled", true);
                 
             }
             
             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     "Action": "Process_Art_DETAIL",
                     "ArtId": ArtId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#ProcessName").val(data.ProcessCode);
                     $("#ArtName").val(data.ArtName);
                     $("#ArtValue").val(data.ArtValue);
                   
                 },
                 error: function (msg) {
                     alert(msg.responseText);
                 }
             });
         }

         //保存表单
         function AcceptClick(grid) {
             
             if (OPtype == "CHECK")
             {
                 dialogClose();
                 return;
             }

             var ProcessCode   =  $("#ProcessName").val().trim().toUpperCase();
             var ArtName       =  $("#ArtName").val().trim();
             var ArtValue      =  $("#ArtValue").val().trim();
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
            
             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     Action        : OPaction,
                     ArtId         : ArtId,
                     ProcessCode   : ProcessCode,
                     ArtName       : ArtName,
                     ArtValue      : ArtValue
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         grid.trigger("reloadGrid");
                     }
                     else if (data.result == "failed") {
                         dialogMsg(data.msg, -1);
                     }
                 },
                 error: function (XMLHttpRequest, textStatus, errorThrown) {
                     Loading(false);
                     dialogMsg(errorThrown, -1);
                 },
                 beforeSend: function () {
                     Loading(true, "正在保存数据");
                 },
                 complete: function () {
                     Loading(false);
                 }
             });
         }


         //构造select
         function CreateSelect() {
             $("#ProcessName").empty();
             var optionstring = "";
             $.ajax({
                 url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";

                     }
                     $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);

                 },
                 error: function (msg) {
                     dialogMsg("数据访问异常", -1);
                 }
             });

         }
         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 10px;">
            <table class="form" id="ruleinfo" style="margin-top:0px;" border="0">
                <tr>
                    <th class="formTitle">工序名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <select class="form-control" id="ProcessName" isvalid="yes" checkexpession="NotNull"></select>   
                    </td>
                     
                 </tr>
                 <tr>
                    <th class="formTitle">工艺名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="ArtName" isvalid="yes" checkexpession="NotNull" />
                    </td>
                
                <tr>
                    <th class="formTitle">值<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="ArtValue" isvalid="yes" checkexpession="NotNull" />
                        
                    </td>
                </tr>
            </table>
    </div>
   <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>

