<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquMaintenceStandradEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquMaintenceStandradEdit" %>


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
             //GetDeviceName();
             if (equid == undefined) {
                 equid = 0;
             }
             //查看
             if (actionname == 1) {
                 $("#ProcessName").attr("disabled", "disabled");
                 $("#DeviceName").attr("disabled", "disabled");
                 $("#PmSpecCode").attr("disabled", "disabled");
                 $("#PmSpecName").attr("disabled", "disabled");
                 $("#PmLevel").attr("disabled", "disabled");

                 $("#PmSpecFile").attr("disabled", "disabled");
                 $("#PmSpecFile").css("background-color", "#eee");
                 $("#btn_upload").attr("disabled", true);
                 $("#Description").attr("disabled", true);
             }

             if (actionname == 1 || actionname == 2) {
                 $.ajax({
                     url: "../Equipment/hs/GetEquMaintenceStandardCRUD.ashx",
                     data: {
                         "Action": "EquMaintenceStandrad_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceName").val(data.DeviceName);
                         $("#PmSpecCode").val(data.PmSpecCode);
                         $("#PmSpecName").val(data.PmSpecName);
                         $("#PmLevel").val(data.PmLevel);
                         $("#PmSpecFile").val(data.PmSpecFile);

                         $("#Description").val(data.PmSpecComment);
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
             if (actionname == 2) {
                 OPaction = "EquMaintenceStandrad_Edit";
             }
             if (actionname == 0) {
                 OPaction = "EquMaintenceStandrad_Add";
             }
         });
         
         //构造select
         function CreateSelect() {
             $("#ProcessName").empty();
             $("#DeviceName").empty();
             var optionstring = "";
             var optionstring1 = "";
             $.ajax({
                 url: "EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
                 async: false,
                 contentType: "application/json;charset=utf-8",
                 success: function (data) {
                     //var data1 = JSON.parse(data);
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
                         optionstring1 += "<option value=\"" + data1[i].DeviceName + "\" >" + data1[i].DeviceName.trim() + "</option>";
                     }
                     $("#DeviceName").html("<option value=''>请选择...</option> " + optionstring1);
                 },
                 error: function (msg) {
                     alert("数据访问异常");
                 }
             });
              
         }

         //保存表单
         function AcceptClick(grid) {
             var ProcessName = $("#ProcessName").val().trim();
             var DeviceName = $("#DeviceName").val().trim();
             var PmSpecCode = $("#PmSpecCode").val().trim();
             var PmSpecName = $("#PmSpecName").val().trim();
             var PmLevel = $("#PmLevel").val().trim();
             var PmSpecFile = $("#PmSpecFile").val().trim();
             var PmSpecComment = $("#Description").val().trim();
             var UploadedPmSpecFile = $("#UploadedPmSpecFile").val();
             
             if (UploadedPmSpecFile == "")
             {
                 UploadedPmSpecFile = $("#PmSpecFile").val();
             }
             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquMaintenceStandardCRUD.ashx",
                 data: {
                     Action: OPaction,
                     EquID: equid,
                     ProcessName: ProcessName,
                     DeviceName: DeviceName,
                     PmSpecCode: PmSpecCode,
                     PmSpecName: PmSpecName,
                     PmLevel: PmLevel,
                     PmSpecFile: PmSpecFile,
                     PmSpecComment: PmSpecComment,
                     UploadedPmSpecFile: UploadedPmSpecFile
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

         //上传设备操作说明
         function onUpload(keyword) {
             dialogOpen({
                 id: "UploadifyManu",
                 title: '上传设备保养规范',
                 url: './UploadifyPmSpecFile.aspx',
                 width: "600px",
                 height: "180px",
                 callBack: function (iframeId) {
                     top.frames[iframeId].AcceptClick($("#PmSpecFile"), $("#UploadedPmSpecFile"));
                 }
             });
         }

    </script>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle">工序名称<font face="宋体">*</font></th>
                    <td class="formValue">
                       <select class="form-control" id="ProcessName" isvalid="yes" checkexpession="NotNull">
                       </select>
                    </td>
                    <th class="formTitle">设备名称<font face="宋体">*</font></th>
                    <td class="formValue">
                       
                        <select class="form-control" id="DeviceName" isvalid="yes" checkexpession="NotNull">
                       </select>
                    </td>
                </tr>
                 <tr>
                    <th class="formTitle">保养规范编号<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input id="PmSpecCode" type="text" class="form-control" placeholder="请输入保养规范编号" isvalid="yes" checkexpession="NotNull"  />
                    </td>
                   
                </tr>
                <tr >
                    <th class="formTitle">保养规范名称</th>
                    <td class="formValue">
                         <input id="PmSpecName" type="text" class="form-control" placeholder="请输入保养规范名称" />           
                    </td>
                </tr>
                 <tr >
                    <th class="formTitle">保养类型<font face="宋体">*</font></th>
                    <td class="formValue">
                       <select class="form-control" id="PmLevel" isvalid="yes" checkexpession="NotNull">
                           <option value=''>请选择...</option>
                           <option value='一级保养'>一级保养</option>
                           <option value='二级保养'>二级保养</option>
                       </select>    
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">保养规范<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="PmSpecFile" isvalid="yes" checkexpession="NotNull" readonly/>
                        <input type="hidden" id="UploadedPmSpecFile" value=""/>              
                    </td>
                     <td style="vertical-align:top">
                        <a id="btn_upload" class="btn btn-default" onclick="onUpload(event)" style="height:26px; padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        保养规范说明
                    </th>
                   <td class="formValue" colspan="3">
                        <textarea id="Description"  class="form-control" style="height: 150px;"  placeholder="请输入保养规范说明"></textarea>
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