<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserAttendenceEdit.aspx.cs" Inherits="LiNuoMes.UserManage.UserAttendenceEdit" %>

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
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
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
         var date = request('date');
         $(function () {
             InitialPage();
         });

         function InitialPage() {
             $.ajax({
                 url: "UserAttendenceEdit.aspx/GetAttendenceInfo",
                 data: "{DATE:'" + date + "'}",
                 type: "post",
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data == null) return false;
                     $.each(data.d, function (i, row) {
                         $("#AttendanceNum").val(row.AttendenceNum);
                         $("#WorkHours").val(row.WorkHours);
                         $("#TotalAttendenceHours").val(row.TotalAttendenceHours.trim());
                         $("#ActiveWorkHours").val(row.ActiveWorkHours.trim());
                     });
                     Loading(false);
                 }, beforeSend: function () {
                     Loading(true);
                 }
             });
         }

         //保存表单
         function AcceptClick(grid) {
             var AttendanceNum = $('#AttendanceNum').val();
             var WorkHours = $('#WorkHours').val();
             var TotalAttendenceHours = $('#TotalAttendenceHours').val();
             var ActiveWorkHours = $('#ActiveWorkHours').val();

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }

             if(ActiveWorkHours>TotalAttendenceHours){
                 dialogMsg("有效生产时间不能大于出勤时间", 0);
                 return false;
             }

             $.ajax({
                 url: "UserAttendenceEdit.aspx/SaveAttendenceInfo",
                 data: JSON.stringify({ DATE: date, AttendanceNum: AttendanceNum, WorkHours: WorkHours, TotalAttendenceHours: TotalAttendenceHours, ActiveWorkHours: ActiveWorkHours }),
                 type: "post",
                 async: true,
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data.d == "success") {
                         Loading(false);
                         dialogMsg("保存成功", 1);
                         dialogClose();
                         grid.trigger("reloadGrid");
                     }
                     else if (data.d == "falut") {
                         dialogMsg("保存失败", -1);
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

         function attendnum() {
             var attendnum = $("#AttendanceNum").val();
             var workhours = $("#WorkHours").val();
             $("#TotalAttendenceHours").val(attendnum * workhours);
         }

         function workhours() {
             var attendnum = $("#AttendanceNum").val();
             var workhours = $("#WorkHours").val();
             $("#TotalAttendenceHours").val(attendnum * workhours);
         }
    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">出勤人数<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input type="text" class="form-control" id="AttendanceNum" isvalid="yes" checkexpession="isPositiveDouble" onblur="attendnum()">
                    </td>
                   
                </tr>
                <tr>
                     <th class="formTitle">当日工作时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="WorkHours" type="text" class="form-control" isvalid="yes" checkexpession="isPositiveDouble" onblur="workhours()"/>
                    </td>
                </tr>            
                <tr>
                    <th class="formTitle">出勤时间<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="TotalAttendenceHours" type="text" class="form-control" isvalid="yes" checkexpession="NotNull" readonly  />
                    </td>
                </tr>
                <tr>
                    
                    <th class="formTitle">有效生产时间<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="ActiveWorkHours" type="text" class="form-control" isvalid="yes" checkexpession="isPositiveDouble"  />             
                    </td>
                </tr>
            </table>
    </div>
   <style>
    .form .formTitle {
        width:90px;
        font-size:9pt;
    }
  
    </style>
</body>
</html>


