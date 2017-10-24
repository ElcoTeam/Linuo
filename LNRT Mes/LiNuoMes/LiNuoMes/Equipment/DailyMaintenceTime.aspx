<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyMaintenceTime.aspx.cs" Inherits="LiNuoMes.Equipment.DailyMaintenceTime" %>

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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
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
     <script>
         var OPaction = "";
         var currenttime = request('currentdate');

         $(function () {
             GetDailyTime();
         });

         //得到当月预算产量
         function GetDailyTime()
         {
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 data: {
                     Action: "GetDailyMaintenceTime",
                     CurrentMonth: currentdate(),
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     $("#TotalTime").val(data.TotalTime);
                     
                     if ($("#TotalTime").val() == "")
                     {
                         OPaction = "DailyMaintenceTime_Add";
                     }
                     else
                     {
                         OPaction = "DailyMaintenceTime_Edit";
                     }
                 },
                 error: function (XMLHttpRequest, textStatus, errorThrown) {
                     Loading(false);
                     dialogMsg(errorThrown, -1);
                 }
             });
         }

         //保存表单
         function AcceptClick() {

             var TotalTime = $("#TotalTime").val().trim();

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceManCRUD.ashx",
                 data: {
                     Action: OPaction,
                     TotalTime: TotalTime,
                     CurrentTime: currenttime,
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

         var currentdate = function () {
             var date = new Date();
             var seperator1 = "-";

             var month = date.getMonth() + 1;
             var strDate = date.getDate();
             if (month >= 1 && month <= 9) {
                 month = "0" + month;
             }
             if (strDate >= 0 && strDate <= 9) {
                 strDate = "0" + strDate;
             }
             var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate;
             return currentdate;
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
           <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">当日维护时间统计<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="TotalTime" type="text" class="form-control" isvalid="yes" checkexpession="PositiveNum"/>             
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


