<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceExtraManEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintenceExtraManEdit" %>

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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>

    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <link href="../css/void_autocomplete.css" rel="stylesheet" />
    <script src="../js/void_autocomplete.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>         var actionname = request('actionname');         var equid = request('equid');         var OPaction = "";                 $(function () {
             var id = '<%=Session["UserName"] %>';
             $("#PmOper").val(id);
             CreateSelect();
             //GetDeviceName();
             if (equid == undefined) {
                 equid = 0;
             }
             //查看
             if (actionname == 1) {
                 $("#ProcessName").attr("disabled", "disabled");
                 $("#DeviceName").attr("disabled", "disabled");
                 $("#PmSpecName").attr("disabled", "disabled");
                 $("#PmStartDate").attr("disabled", "disabled");
                 $("#PmFinishDate").attr("disabled", "disabled");
                 //$("#PmSpecFile").css("background-color", "#eee");
                 $("#PmOper").attr("disabled", true);
                 $("#PmComment").attr("disabled", true);
             }

             if (actionname == 1 || actionname == 2) {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                     data: {
                         "Action": "EquMaintenceExtraMan_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(data.DeviceName);
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmStartDate").val(data.PmStartDate);
                         $("#PmFinishDate").val(data.PmFinishDate);
                         $("#PmOper").val(data.PmOper);
                         $("#PmComment").val(data.PmComment);
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
             if (actionname == 2) {
                 OPaction = "EquMaintenceExtraMan_Edit";
             }
             if (actionname == 0) {
                 OPaction = "EquMaintenceExtraMan_Add";
             }
         });                  //保存表单
         function AcceptClick(grid) {
             var ProcessName = $("#ProcessName").val().trim();
             var DeviceName = $("#DeviceName").val().trim();
             var PmType = "计划外保养";
             var PmSpecName = $("#PmSpecName").val().trim();
             var PmStartDate = $("#PmStartDate").val().trim();
             var PmFinishDate = $("#PmFinishDate").val().trim();
             var PmOper = $("#PmOper").val().trim();
             var PmComment = $("#PmComment").val().trim();
             console.log(DeviceName);
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 data: {
                     Action: OPaction,
                     EquID: equid,
                     ProcessName: ProcessName,
                     DeviceName: DeviceName,
                     PmType:PmType,
                     PmSpecName: PmSpecName,
                     PmStartDate: PmStartDate,
                     PmFinishDate: PmFinishDate,
                     PmOper: PmOper,
                     PmComment: PmComment
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
         }         //构造select
         function CreateSelect() {

             //工序名称
             $("#ProcessName").empty();
             var optionstring = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: false,
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
                     alert("数据访问异常");
                 }
             });

             //保养规范名称
             $("#PmSpecName").empty();
             var optionstring1 = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetPmSpecName",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: false,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring1 += "<option value=\"" + data1[i].PmSpecName + "\" >" + data1[i].PmSpecName.trim() + "</option>";
                     }
                     $("#PmSpecName").html("<option value=''>请选择...</option> " + optionstring1);
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });

             //设备名称
             $("#DeviceName").empty();
             var optionstring2 = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetDeviceName",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: false,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring2 += "<option value=\"" + data1[i].DeviceName + "\" >" + data1[i].DeviceName.trim() + "</option>";
                     }
                     $("#DeviceName").html("<option value=''>请选择...</option> " + optionstring2);
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });
         }
         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }           </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">工序名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <select class="form-control" id="ProcessName" isvalid="yes" checkexpession="NotNull">
                        </select> 
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">设备名称<font face="宋体">*</font></th>
                    <td class="formValue">
                         <select class="form-control" id="DeviceName" isvalid="yes" checkexpession="NotNull">
                        </select>
                        
                    </td>
                    <th class="formTitle">保养规范名称</th>
                    <td class="formValue">
                        <select class="form-control" id="PmSpecName" isvalid="yes" checkexpession="NotNull">
                        </select>         
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">实际开始时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmStartDate" type="text"  class="Wdate form-control" isvalid="yes" checkexpession="NotNull" onclick="WdatePicker()"/>  
                    </td>
                    <th class="formTitle">实际完成时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmFinishDate" type="text"  class="Wdate form-control" isvalid="yes" checkexpession="NotNull" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PmStartDate\')}'})"/>  
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">保养人<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmOper" type="text" class="form-control" isvalid="yes" checkexpession="NotNull" readonly/>        
                    </td>
                   
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        保养说明
                    </th>
                   <td class="formValue" colspan="3">
                        <textarea id="PmComment"  class="form-control" style="height: 150px;"  placeholder="请输入保养说明"></textarea>
                    </td>
                </tr> 
            </table>
       </div>
   <style>
    .form .formTitle {
        width:100px;
        font-size:9pt;
    }
   
    </style>
</body>
</html>

