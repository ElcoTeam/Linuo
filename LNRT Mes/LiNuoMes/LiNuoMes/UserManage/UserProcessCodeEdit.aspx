﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProcessCodeEdit.aspx.cs" Inherits="LiNuoMes.UserManage.UserProcessCodeEdit" %>

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
    
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">登录账号<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input type="text" class="form-control" id="userno" isvalid="yes" checkexpession="NotNull" readonly="readonly"/>
                    </td>
                    <th class="formTitle">员工姓名<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="username" type="text" class="form-control" isvalid="yes" checkexpession="NotNull" readonly="readonly" />
                    </td>
                </tr>
                 <tr>
                    
                 
                     <th class="formTitle">所属工序</th>
                    <td class="formValue">
                       <select class="form-control" id="processname">
                       </select>                
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        人员说明
                    </th>
                </tr>
                <tr>
                    <td class="formValue" colspan="4">
                        <textarea id="Description"  class="form-control" style="height: 150px; margin-left:5px;"  placeholder="请输入人员说明"></textarea>
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
     <script>
         var id = "";
         var userid = '<%=Session["UserID"] %>';
         $(function () {
             CreateSelect();
             InitialPage();
         });

         function InitialPage() {
             $.ajax({
                 url: "UserProcessCodeEdit.aspx/GetUserInfo",
                 data: "{UserID:'" + userid + "'}",
                 type: "post",
                 dataType: "json",
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     if (data == null) return false;
                     $.each(data.d, function (i, row) {
                         id = row.ID;
                         $("#userno").val(row.UserID);
                         $("#username").val(row.UserName);
                         // $("#rolename").val("" + row.RoleID.trim() + "");
                         $("#processname").val("" + row.ProcessCode.trim() + "");
                         $("#Description").val(row.Description);
                     });
                     Loading(false);
                 }, beforeSend: function () {
                     Loading(true);
                 }
             });
         }

         //构造select
         function CreateSelect() {
             //$("#rolename").empty();

             //var optionstring = "";
             var optionstring1 = "";
             //$.ajax({
             //    url: "UserInfo.aspx/GetUserRole",    //后台webservice里的方法名称  
             //    type: "post",
             //    dataType: "json",
             //    data: "{deviceid:''}",
             //    async: false,
             //    contentType: "application/json;charset=utf-8",
             //    success: function (data) {
             //        var data1 = eval('(' + data.d + ')');
             //        var i = 0;//和for循环一样 i做计数
             //        for (i in data1) {
             //            optionstring += "<option value=\"" + data1[i].RoleID + "\" >" + data1[i].RoleName.trim() + "</option>";
             //        }
             //        $("#rolename").html("<option value=''>请选择...</option> " + optionstring);
             //        //$("#roleselect").html("<option value=''>请选择...</option> " + optionstring);
             //    },
             //    error: function (msg) {
             //        alert("数据访问异常");
             //    }
             //});
             $.ajax({
                 url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: false,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     var data1 = eval('(' + data.d + ')');
                     var i = 0;
                     for (i in data1) {
                         optionstring1 += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";

                     }
                     $("#processname").html("<option value=''>请选择...</option> " + optionstring1);

                 },
                 error: function (msg) {
                     dialogMsg("数据访问异常", -1);
                 }
             });
         }

         //保存表单
         function AcceptClick(grid) {
             var userno = $('#userno').val();
             var username = $('#username').val();
             // var rolename = $('#rolename').val();
             var Description = $('#Description').val();
             var ProcessCode = $('#processname').val();
             var useroldid = userid;
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "UserProcessCodeEdit.aspx/SaveUserInfo",
                 data: JSON.stringify({ UserID: userno, UserName: username, Description: Description, ProcessCode: ProcessCode, UserOldID: useroldid }),
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

    </script>
</body>
</html>

