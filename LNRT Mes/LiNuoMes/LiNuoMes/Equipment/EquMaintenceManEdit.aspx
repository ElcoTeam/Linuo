<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceManEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintenceManEdit" %>
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
         //var plandate = request('plandate');
         //var dotimes = request('dotimes');
         
         $(function () {
             if (equid == undefined) {
                 equid = 0;
             }
             var id = '<%=Session["UserName"] %>';
             $("#PmOper").val(id);
             $("#ProcessName").attr("disabled", "disabled");
             $("#DeviceName").attr("disabled", "disabled");
             $("#PmSpecName").attr("disabled", "disabled");
             $("#PmPlanName").attr("disabled", "disabled");
             $("#PmFirstDate").attr("disabled", "disabled");
             $("#PmFirstDate").val(plandate);

             //查看
             if (actionname == 1 || actionname==4)
             {
                 $("#PmStartDate").css("background-color", "#eee");
                 $("#PmFinishDate").css("background-color", "#eee");
                 $("#PmStartDate").attr("disabled", "disabled");
                 $("#PmFinishDate").attr("disabled", "disabled");
                 $("#PmOper").attr("disabled", "disabled");
                 $("#PmComment").attr("disabled", "disabled");
             }

             if (actionname == 1 || actionname == 2)
             {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                     data: {
                         "Action": "EquMaintenceMan_DetailFinish",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(data.DeviceName);
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmPlanName").val(data.PmPlanName);
                         //$("#PmFirstDate").val(data.PmFirstDate);

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
             if (actionname == 4 || actionname==3 ) {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                     data: {
                         "Action": "EquMaintenceMan_DetailUnFinish",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(data.DeviceName);
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmPlanName").val(data.PmPlanName);
                        
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
             var PmSpecName = $("#PmSpecName").val().trim();
             var PmPlanName = $("#PmPlanName").val().trim();
             var PmFirstDate = $("#PmFirstDate").val().trim();
             var PmStartDate = $("#PmStartDate").val().trim();
             var PmFinishDate = $("#PmFinishDate").val();
             var PmOper = $("#PmOper").val();
             var PmComment = $("#PmComment").val();

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }

             //执行保养
             if (actionname == 3) {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                     data: {
                         Action: "ExcuteEquMaintenceMan",
                         //EquID: equid,
                         ProcessName: ProcessName,
                         DeviceName: DeviceName,
                         PmSpecName: PmSpecName,
                         PmPlanName: PmPlanName,
                         PmFirstDate: PmFirstDate,
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
             }

             //编辑保养
             else if (actionname == 4) {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                     data: {
                         Action: "EquMaintenceManEdit",
                         EquID: equid,
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
             }
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
                         <input id="ProcessName" type="text" class="form-control"/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">设备名称</th>
                    <td class="formValue">
                        <input id="DeviceName" type="text"  class="form-control"/>
                    </td>
                    <th class="formTitle">保养规范名称</th>
                    <td class="formValue">
                         <input id="PmSpecName" type="text" class="form-control"/>           
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">保养计划名称</th>
                    <td class="formValue">
                         <input id="PmPlanName" type="text" class="form-control"/>           
                    </td>
                    <th class="formTitle">计划开始时间</th>
                    <td class="formValue">
                         <input id="PmFirstDate" type="text" class="form-control"/>           
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">实际开始时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmStartDate" type="text"  class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" onclick="WdatePicker()"/>  
                    </td>
                    <th class="formTitle">实际完成时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="PmFinishDate" type="text" class="Wdate timeselect" isvalid="yes" checkexpession="NotNull" onclick="WdatePicker()"/>  
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
    .timeselect{
        width:193px;
        height:30px;
    }
    </style>
</body>
</html>
