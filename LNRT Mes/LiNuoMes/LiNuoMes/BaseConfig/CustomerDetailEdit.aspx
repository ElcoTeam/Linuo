<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDetailEdit.aspx.cs" Inherits="LiNuoMes.BaseConfig.CustomerDetailEdit" %>

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
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var CustId = "";
         var OPtype   = "";
         var OPaction = "";

         $(function () {
             CustId = request('CustId');
             OPtype = request('OPtype');

             if (CustId == undefined) {
                 CustId = 0;
             }
         
             if (OPtype == undefined) {
                 OPtype = "CHECK";
             }

             if (OPtype == "CHECK") {
                 OPaction = "MES_CUSTOMER_CONFIG_DETAIL";
             }
             else if (OPtype == "EDIT") {
                 OPaction = "MES_CUSTOMER_CONFIG_EDIT";
             }
             else if (OPtype == "ADD") {
                 OPaction = "MES_CUSTOMER_CONFIG_ADD";
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
                 url: "../BaseConfig/GetSetBaseConfig.ashx",
                 data: {
                     "Action": "MES_CUSTOMER_CONFIG_DETAIL",
                     "CustID": CustId
                 },
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     data = JSON.parse(data);
                     $("#CustomerName").val(data.CustomerName);
                     $("#CustomerLogo").val(data.CustomerLogo);
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

             var CustomerName = $("#CustomerName").val().trim();
             var CustomerLogo = $("#CustomerLogo").val().trim();
             var UploadedFile = $("#UploadedFile").val().trim();


             if (CustomerName.length == 0) {
                 dialogMsg("请录入客户名称!", -1);
                 $("#CustomerName").focus();
                 return;
             }

             if (CustomerLogo.length == 0) {
                 dialogMsg("请录入客户Logo!", -1);
                 $("#CustomerLogo").focus();
                 return;
             }

             $.ajax({
                 url: "../BaseConfig/GetSetBaseConfig.ashx",
                 data: {
                     Action      : OPaction,
                     CustID      : CustId,
                     CustomerName: CustomerName,
                     CustomerLogo: CustomerLogo,
                     UploadedFile: UploadedFile
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
                id: "UploadifyLogo",
                title: '上传文件',
                url: '../BaseConfig/UploadifyLogo.aspx',
                width: "600px",
                height: "180px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#CustomerLogo"), $("#UploadedFile"));
                }
            });
         }


    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 10px;">
            <table class="form" id="ruleinfo" style="margin-top:0px;" border="0">
                <tr>
                    <th class="formTitle">客户名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control"  id="CustomerName" isvalid="yes" checkexpession="NotNull" />
                    </td>
                     <td></td>
                 </tr>
                <tr>
                    <th class="formTitle">客户Logo<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="CustomerLogo" isvalid="yes" checkexpession="NotNull" readonly/>
                        <input type="hidden" id="UploadedFile" value=""/>
                    </td>
                    <td style="vertical-align:top">
                        <a id="btn_upload" class="btn btn-default" onclick="onUpload(event)" style="padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
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

