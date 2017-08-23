<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcConfigDetailEdit.aspx.cs" Inherits="LiNuoMes.BaseConfig.ProcConfigDetailEdit" %>

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
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var ProcId   = "";
         var OPtype   = "";
         var OPaction = "";

         $(function () {
                ProcId = request('ProcId');
                OPtype = request('OPtype');

             if (ProcId == undefined) {
                 ProcId = 0;
             }
         
             if (OPtype == undefined) {
                 OPtype = "CHECK";
             }

             if (OPtype == "CHECK") {
                 OPaction = "MES_PROC_CONFIG_DETAIL";
             }
             else if (OPtype == "EDIT") {
                 OPaction = "MES_PROC_CONFIG_EDIT";
             }
             else if (OPtype == "ADD") {
                 OPaction = "MES_PROC_CONFIG_ADD";
             }
             else {
                 return;
             }
             InitialPage();             
         });
         
         function InitialPage() {
             if (OPtype == "CHECK") {
                 $(".form-control").attr("disabled", true);
                 $("#btn_upload").attr("disabled", true);
             }
             $("#btn_upload").height($("[text]").height());
             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     "Action": "MES_PROC_CONFIG_DETAIL",
                     "ProcID": ProcId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#ProcessCode").val(data.ProcessCode);
                     $("#ProcessName").val(data.ProcessName);
                     $("#ProcessBeat").val(data.ProcessBeat);
                     $("#ProcessDsca").val(data.ProcessDsca);
                     $("#InturnNumber").val(data.InturnNumber);
                     $("#ProcessManual").val(data.ProcessManual);
                     if (data.ReservedFlag=="1") {
                         $("[myReserved]").attr("disabled", true);
                     }
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

             var ProcessCode   = $("#ProcessCode").val().trim().toUpperCase();
             var ProcessName   = $("#ProcessName").val().trim();
             var ProcessBeat   = $("#ProcessBeat").val().trim();
             var ProcessDsca   = $("#ProcessDsca").val().trim();
             var InturnNumber  = $("#InturnNumber").val().trim();
             var ProcessManual = $("#ProcessManual").val().trim();
             var UploadedFile = $("#UploadedFile").val().trim();

             $("#ProcessCode").val(ProcessCode);

             if (ProcessCode.length == 0) {
                 dialogMsg("请录入工序编号!", -1);
                 $("#ProcessCode").focus();
                 return;
             }

             if (ProcessName.length == 0) {
                 dialogMsg("请录入工序名称!", -1);
                 $("#ProcessName").focus();
                 return;
             }

             if (ProcessBeat.length == 0) {
                 dialogMsg("请录入工序节拍!", -1);
                 $("#ProcessBeat").focus();
                 return;
             }

             if (!parseInt(ProcessBeat, 10)) {
                 dialogMsg("工序节拍必须为整型数字!", -1);
                 return;
             }

             if (ProcessDsca.length == 0) {
                 dialogMsg("请录入工序简介!", -1);
                 $("#ProcessDsca").focus();
                 return;
             }

             if (InturnNumber.length == 0) {
                 dialogMsg("请录入工序序号!", -1);
                 $("#InturnNumber").focus();
                return;
             }

             if (!parseInt(InturnNumber, 10)) {
                 dialogMsg("工序序号必须为整型数字!", -1);
                 $("#InturnNumber").focus();
                 return;
             }

             if (ProcessManual.length == 0) {
                 dialogMsg("请录入操作规范!", -1);
                 $("#ProcessManual").focus();
                 return;
             }

             $.ajax({
                 url: "GetSetBaseConfig.ashx",
                 data: {
                     Action        : OPaction,
                     ProcID        : ProcId,
                     ProcessCode   : ProcessCode,
                     ProcessName   : ProcessName,
                     ProcessBeat   : ProcessBeat,
                     ProcessDsca   : ProcessDsca,
                     InturnNumber  : InturnNumber,
                     ProcessManual : ProcessManual,
                     UploadedFile  : UploadedFile
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

         //上传原始文件
         function onUpload(keyword) {
             dialogOpen({
                id: "UploadifyManu",
                title: '上传文件',
                url: './UploadifyManu.aspx',
                width: "600px",
                height: "180px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#ProcessManual"), $("#UploadedFile"));
                }
            });
         }


    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 10px;">
            <table class="form" id="ruleinfo" style="margin-top:0px;" border="0">
                <tr>
                    <th class="formTitle">工序序号<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" myReserved="true" class="form-control" id="InturnNumber" isvalid="yes" checkexpession="NotNull" />
                    </td>
                     <td></td>
                </tr>
                <tr>
                    <th class="formTitle">工序编号<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" myReserved="true" class="form-control" id="ProcessCode" isvalid="yes" checkexpession="NotNull" />
                    </td>
                     <td></td>
                </tr>
                <tr>
                    <th class="formTitle">工序名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="ProcessName" isvalid="yes" checkexpession="NotNull" />
                    </td>
                     <td></td>
                 </tr>
                 <tr>
                    <th class="formTitle">工序节拍<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="ProcessBeat" isvalid="yes" checkexpession="NotNull" />
                    </td>
                     <td></td>
                <tr>
                    <th class="formTitle">操作规范<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="ProcessManual" isvalid="yes" checkexpession="NotNull" readonly/>
                        <input type="hidden" id="UploadedFile" value=""/>
                    </td>
                    <td style="vertical-align:top">
                        <a id="btn_upload" class="btn btn-default" onclick="onUpload(event)" style="padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" style="vertical-align:top;">工序简介</th>
                    <td class="formValue" colspan="2">
                        <textarea id="ProcessDsca"  class="form-control" style="height: 180px;"></textarea>
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

