<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquAlarmEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquAlarmEdit" %>

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
     <script>
         var actionname = request('actionname');
         var equid = request('equid');
         var OPaction = "";
        
         $(function () {
             var id = '<%=Session["UserName"] %>';
             $("#DealWithOper").val(id);

             if (equid == undefined) {
                 equid = 0;
             }
             //查看
             if (actionname == 1) {
                 $("#ProcessName").attr("disabled", "disabled");
                 $("#DeviceName").attr("disabled", "disabled");
                 $("#AlarmItem").attr("disabled", "disabled");
                 $("#AlarmTime").attr("disabled", "disabled");
                 $("#DealWithTime").attr("disabled", "disabled");
                 $("#DealWithOper").attr("disabled", true);
                 $("#DealWithComment").attr("disabled", true);
             }

             if (actionname == 1 || actionname == 2) {
                 
                 $.ajax({
                     url: "../Equipment/hs/GetAlarmCRUD.ashx",
                     data: {
                         "Action": "EquAlarm_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(window.parent.$('#gridTable').jqGridRowValue("DeviceName").trim());
                         $("#AlarmItem").val(data.AlarmItem.trim());
                         $("#AlarmTime").val(data.AlarmTime);
                         $("#DealWithTime").val(data.DealWithTime);
                         $("#DealWithOper").val(data.DealWithOper);
                         $("#DealWithComment").val(data.DealWithComment.trim());
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
             if (actionname == 2) {
                 OPaction = "EquAlarm_Edit";
             }
             if (actionname == 3) {
                 OPaction = "EquAlarm_Handle";
                 $.ajax({
                     url: "../Equipment/hs/GetAlarmCRUD.ashx",
                     data: {
                         "Action": "EquAlarm_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(window.parent.$('#gridTable').jqGridRowValue("DeviceName").trim());
                         $("#AlarmItem").val(data.AlarmItem.trim());
                         $("#AlarmTime").val(data.AlarmTime);
                         
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
         });
         
         //保存表单
         function AcceptClick(grid) {
             var ProcessName = $("#ProcessName").val().trim();
             var DeviceName = $("#DeviceName").val().trim();
             var AlarmItem = $("#AlarmItem").val().trim();
             var AlarmTime = $("#AlarmTime").val().trim();
             var DealWithTime = $("#DealWithTime").val().trim();
             var DealWithOper = $("#DealWithOper").val().trim();
             var DealWithComment = $("#DealWithComment").val().trim();
            
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetAlarmCRUD.ashx",
                 data: {
                     Action: OPaction,
                     EquID: equid,
                     ProcessName: ProcessName,
                     DeviceName: DeviceName,
                     AlarmItem: AlarmItem,
                     AlarmTime: AlarmTime,
                     DealWithTime: DealWithTime,
                     DealWithOper: DealWithOper,
                     DealWithComment: DealWithComment
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

         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                 <tr>
                    <th class="formTitle">工序名称</th>
                    <td class="formValue">
                        <input class="form-control" id="ProcessName" readonly>
                    </td>
                 </tr>
                 <tr>
                    <th class="formTitle">设备名称</th>
                    <td class="formValue">
                       <input id="DeviceName"  style="height:30px;" class="form-control" readonly>
                    </td>
                    <th class="formTitle">报警项</th>
                    <td class="formValue">
                       <input id="AlarmItem"   class="form-control" readonly>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">报警时间</th>
                    <td class="formValue">
                       <input id="AlarmTime" type="text" class="form-control" readonly/>   
                    </td>
                </tr>
                 <tr>
                    <th class="formTitle">处理完成时间<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="DealWithTime" type="text" class="Wdate form-control" isvalid="yes" checkexpession="NotNull" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm'})"/>  
                    </td>
                    <th class="formTitle">处理人<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="DealWithOper" type="text" class="form-control" isvalid="yes" checkexpession="NotNull" readonly/>     
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        处理说明
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="DealWithComment"  class="form-control" style="height: 150px;"  placeholder="请输入处理说明"></textarea>
                    </td>
                 </tr> 
            </table>
       </div>
   <style>
    .form .formTitle {
        width:100px;
        font-size:9pt;
    }
    .timeselect{
        width:200px;
        height:30px;
    }
    </style>
</body>
</html>

