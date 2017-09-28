<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintencePlanEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintencePlanEdit" %>

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
             CreateSelect();
            // GetDeviceName();
             if (equid == undefined) {
                 equid = 0;
             }
             
             if (actionname == 1) {
                 CreateProcess();
                 CreateDevice();

                 $("#ProcessName").attr("disabled", "disabled");
                 $("#DeviceName").attr("disabled", "disabled");
                 $("#PmSpecName").attr("disabled", "disabled");
                 $("#PmPlanCode").attr("disabled", "disabled");
                 $("#PmPlanName").attr("disabled", "disabled");
                 $("#PmCycleTime").attr("disabled", true);
                 $("#PmTimeUsage").attr("disabled", true);
                 $("#PmFirstDate").attr("disabled", true);
                 $("#PmContinueTimes").attr("disabled", true);
                 $("#PmPreAlarmDates").attr("disabled", true);
                 $("#Description").attr("disabled", true);
                 $("#PmLevel").attr("disabled", true);
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintencePlanCRUD.ashx",
                     data: {
                         "Action": "EquMaintencePlan_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     async: true,
                     success: function (data) {
                         data = JSON.parse(data);
                         console.log(data);
                         $("#ProcessName").val(data.ProcessCode );
                         $("#PmLevel").val(data.PmLevel);
                         $("#DeviceName").val("" + data.DeviceName + "");
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmPlanCode").val(data.PmPlanCode);
                         $("#PmPlanName").val(data.PmPlanName);
                         $("#PmFirstDate").val(data.PmFirstDate);
                         if (data.PmCycleTime == 0) {
                             $("#PmCycleTime").val("");
                         }
                         else {
                             $("#PmCycleTime").val(data.PmCycleTime);
                         }
                         if (data.PmTimeUsage == 0) {
                             $("#PmTimeUsage").val("");
                         }
                         else {
                             $("#PmTimeUsage").val(data.PmTimeUsage);
                         }

                         if (data.PmContinueTimes==0) {
                             $("#PmContinueTimes").val("");
                         }
                         else {
                             $("#PmContinueTimes").val(data.PmContinueTimes);
                         }
                         $("#PmPreAlarmDates").val(data.PmPreAlarmDates);
                         $("#Description").val(data.PmPlanComment);
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
            
             if (actionname == 0) {
                 OPaction = "EquMaintencePlan_Add";
             }
       
             if (actionname == 2) {
                 CreateProcess();
                 CreateDevice();
                 OPaction = "EquMaintencePlan_Edit";
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintencePlanCRUD.ashx",
                     data: {
                         "Action": "EquMaintencePlan_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     async: true,
                     success: function (data) {
                         data = JSON.parse(data);
                         console.log(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#PmLevel").val(data.PmLevel);

                         if ($("#PmLevel").val() == '一级保养') {
                             $("#PmLevel").attr("disabled", true);

                             $("#PmCycleTime").attr("disabled", true);
                             $("#PmPreAlarmDates").attr("disabled", true);
                             $("#PmFirstDate").attr("disabled", true);
                             $("#PmTimeUsage").attr("disabled", true);
                             $("#PmContinueTimes").attr("disabled", true);
                         }
                         if ($("#PmLevel").val() == '二级保养') {
                             $("#PmCycleTime").attr("disabled", false);
                             $("#PmPreAlarmDates").attr("disabled", false);
                             $("#PmFirstDate").attr("disabled", false);
                             $("#PmTimeUsage").attr("disabled", false);
                             $("#PmContinueTimes").attr("disabled", false);
                         }

                         $("#DeviceName").val(data.DeviceName);
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmPlanCode").val(data.PmPlanCode);
                         $("#PmPlanName").val(data.PmPlanName);
                         $("#PmFirstDate").val(data.PmFirstDate);
                         if (data.PmCycleTime == 0) {
                             $("#PmCycleTime").val("");
                         }
                         else {
                             $("#PmCycleTime").val(data.PmCycleTime);
                         }
                         if (data.PmTimeUsage == 0) {
                             $("#PmTimeUsage").val("");
                         }
                         else {
                             $("#PmTimeUsage").val(data.PmTimeUsage);
                         }

                         if (data.PmContinueTimes == 0) {
                             $("#PmContinueTimes").val("");
                         }
                         else {
                             $("#PmContinueTimes").val(data.PmContinueTimes);
                         }
                         $("#PmPreAlarmDates").val(data.PmPreAlarmDates);
                         $("#Description").val(data.PmPlanComment);
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });

             }
            

             //保养规范编号选择
             $("#PmSpecName").change(function () {
                 var PmSpecCode=$("#PmSpecName").val();
                 var optionstring = "";
                
                 if (PmSpecCode == "")
                 {
                     $("#ProcessName").val("");
                     $("#DeviceName").val("");
                     return false;
                 }

                 $.ajax({
                     url: "EquMaintencePlanEdit.aspx/GetProcessInfo",
                     type: "post",
                     dataType: "json",
                     data: "{deviceid:'" + PmSpecCode + "'}",
                     async:true,
                     contentType: "application/json;charset=utf-8",
                     success: function (data) {
                         var data1 = eval('(' + data.d + ')');
                         var i = 0;
                         for (i in data1) {
                             optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                         }
                         $("#ProcessName").html(optionstring);
                         var optionstring1 = "";
                         var ProcessName = $("#ProcessName").val();
                         $.ajax({
                             url: "EquMaintencePlanEdit.aspx/GetDeviceName",
                             type: "post",
                             dataType: "json",
                             data: "{deviceid:'" + ProcessName + "'}",
                             async: true,
                             contentType: "application/json;charset=utf-8",
                             success: function (data) {
                                 var data1 = eval('(' + data.d + ')');
                                 var i = 0;
                                 for (i in data1) {
                                     optionstring1 += "<option value=\"" + data1[i].DeviceName + "\" >" + data1[i].DeviceName.trim() + "</option>";
                                 }
                                 $("#DeviceName").html(optionstring1);
                             },
                             error: function (msg) {
                                 alert("数据访问异常");
                             }
                         });

                     },
                     error: function (msg) {
                         alert("数据访问异常");
                     }
                 });

                 $.ajax({
                     url: "EquMaintencePlanEdit.aspx/GetPmLevel",
                     type: "post",
                     dataType: "json",
                     data: "{deviceid:'" + PmSpecCode + "'}",
                     async: true,
                     contentType: "application/json;charset=utf-8",
                     success: function (data) {
                         var data1 = eval('(' + data.d + ')');
                         console.log(data1[0].PmLevel);
                         $("#PmLevel").val(data1[0].PmLevel);
                         if ($("#PmLevel").val() == '一级保养') {
                             $("#PmCycleTime").attr("disabled", true);
                             $("#PmPreAlarmDates").attr("disabled", true);
                             $("#PmFirstDate").attr("disabled", true);
                             $("#PmTimeUsage").attr("disabled", true);
                             $("#PmContinueTimes").attr("disabled", true);
                             $("#PmPreAlarmDates").val("");
                         }
                         else {
                             $("#PmCycleTime").attr("disabled", false);
                             $("#PmPreAlarmDates").attr("disabled", false);
                             $("#PmFirstDate").attr("disabled", false);
                             $("#PmTimeUsage").attr("disabled", false);
                             $("#PmContinueTimes").attr("disabled", false);
                         }
                     },
                     error: function (msg) {
                         alert("数据访问异常");
                     }
                 });                
             })


             $("#ProcessName").change(function () {
                 var optionstring1 = "";
                 var ProcessName = $("#ProcessName").val();
                 $.ajax({
                     url: "EquMaintencePlanEdit.aspx/GetDeviceName",
                     type: "post",
                     dataType: "json",
                     data: "{deviceid:'" + ProcessName + "'}",
                     async: false,
                     contentType: "application/json;charset=utf-8",
                     success: function (data) {
                         var data1 = eval('(' + data.d + ')');
                         var i = 0;
                         for (i in data1) {
                             optionstring1 += "<option value=\"" + data1[i].DeviceName + "\" >" + data1[i].DeviceName.trim() + "</option>";
                         }
                         $("#DeviceName").html(optionstring1);

                     },
                     error: function (msg) {
                         alert("数据访问异常");
                     }
                 });
             })

         });
         
         //构造select
         function CreateSelect() {
             //保养规范编号
             $("#ProcessName").empty();
             $("#PmSpecName").empty();
             $("#DeviceName").empty();
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
                         optionstring1 += "<option value=\"" + data1[i].PmSpecCode + "\" >" + data1[i].PmSpecCode.trim() + "</option>";
                     }
                     $("#PmSpecName").html("<option value=''>请选择...</option> " + optionstring1);
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });
         }


         function CreateProcess() {
             var optionstring = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: true,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                     }
                     $("#ProcessName").html(optionstring);                
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });
         }


         function CreateDevice() {
             var optionstring1 = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetDeviceName",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: true,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring1 += "<option value=\"" + data1[i].DeviceName + "\" >" + data1[i].DeviceName.trim() + "</option>";
                     }
                     $("#DeviceName").html(optionstring1);
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });
         }

       
         //保存表单
         function AcceptClick(grid) {
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             var ProcessName = $("#ProcessName").val().trim();
             var PmLevel = $("#PmLevel").val();
             var DeviceName = $("#DeviceName").val().trim();
             var PmSpecName = $("#PmSpecName").val().trim();
             var PmPlanCode = $("#PmPlanCode").val().trim();
             var PmPlanName = $("#PmPlanName").val().trim();
             var PmCycleTime = $("#PmCycleTime").val().trim();
             var PmTimeUsage = $("#PmTimeUsage").val().trim();
             var PmFirstDate = $("#PmFirstDate").val().trim();
             var PmContinueTimes = $("#PmContinueTimes").val().trim();
             var PmPreAlarmDates = $("#PmPreAlarmDates").val().trim();
             var PmPlanComment = $("#Description").val().trim();

             //if(PmLevel=='二级保养'){
             //    if (!$('#ruleinfo').Validform()) {
             //        return false;
             //    }
             //}

             $.ajax({
                 url: "../Equipment/hs/GetEquMaintencePlanCRUD.ashx",
                 data: {
                     Action: OPaction,
                     EquID: equid,
                     ProcessName: ProcessName,
                     PmLevel: PmLevel,
                     DeviceName: DeviceName,
                     PmSpecName: PmSpecName,
                     PmPlanCode: PmPlanCode,
                     PmPlanName: PmPlanName,
                     PmCycleTime: PmCycleTime,
                     PmTimeUsage: PmTimeUsage,
                     PmFirstDate: PmFirstDate,
                     PmContinueTimes: PmContinueTimes,
                     PmPreAlarmDates: PmPreAlarmDates,
                     PmPlanComment: PmPlanComment
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
                    <th class="formTitle">保养规范编号<font face="宋体">*</font></th>
                    <td class="formValue">
                         <select class="form-control" id="PmSpecName" isvalid="yes" checkexpession="NotNull">
                        </select>          
                    </td>

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
                    <th class="formTitle">保养类别<font face="宋体">*</font></th>
                    <td class="formValue">
                       
                        <input id="PmLevel" type="text" class="form-control"  isvalid="yes" checkexpession="NotNull" readonly />
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">保养计划编号<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="PmPlanCode" type="text" class="form-control" placeholder="请输入保养规计划编号" isvalid="yes" checkexpession="NotNull" />   
                    </td>
                    <th class="formTitle">保养计划名称<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="PmPlanName" type="text" class="form-control" placeholder="请输入保养规计划名称" isvalid="yes" checkexpession="NotNull" />     
                    </td>
                </tr>
                 <tr>
                    <th class="formTitle">保养周期(月)</th>
                    <td class="formValue">
                       <input id="PmCycleTime" type="text" class="form-control" placeholder="请输入保养周期" isvalid="yes" checkexpession="PositiveNumOrNull"/>  
                    </td>
                    <th class="formTitle">保养耗时(分)</th>
                    <td class="formValue">
                       <input id="PmTimeUsage" type="text" class="form-control" placeholder="请输入保养耗时" isvalid="yes" checkexpession="PositiveNumOrNull"/>     
                    </td>
                   
                </tr>
                <tr >
                    <th class="formTitle">首次保养日期</th>
                    <td class="formValue">
                       <input id="PmFirstDate" type="text" class="form-control" class="Wdate timeselect" onclick="WdatePicker()"/>   
                    </td>
                    <th class="formTitle">保养持续次数</th>
                    <td class="formValue">
                       <input id="PmContinueTimes" type="text" class="form-control" isvalid="yes" checkexpession="PositiveNumOrNull"/>   
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">提前提醒天数(天)</th>
                    <td class="formValue">
                       <input id="PmPreAlarmDates" type="text" class="form-control"  isvalid="yes" checkexpession="PositiveNumOrNull"/>
                    </td>
                   
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        保养计划说明
                    </th>
                   <td class="formValue" colspan="3">
                        <textarea id="Description"  class="form-control" style="height: 150px;"  placeholder="请输入保养计划说明"></textarea>
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
