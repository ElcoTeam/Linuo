<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquInfoEdit.aspx.cs" Inherits="LiNuoMes.Equipment.EquInfoEdit" %>

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
   <%-- <link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
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
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>                  var actionname = request('actionname');         var equid = request('equid');         var OPaction = "";         $(function () {
             CreateSelect();
             if (equid == undefined) {
                 equid = 0;
             }
             //查看
             if (actionname == 1) {
                 $("#ProcessName").attr("disabled", "disabled");
                 $("#DeviceCode").attr("disabled", "disabled");
                 $("#DeviceName").attr("disabled", "disabled");
                 $("#DeviceVendor").attr("disabled", "disabled");
                 $("#PmStartDate").attr("disabled", "disabled");
                 $("#Description").attr("disabled", "disabled");

                 $("#DevicePartsFile").attr("disabled", true);
                 $("#DeviceManualFile").attr("disabled", true);
                 $("#btn_upload").attr("disabled", true);
                 $("#btn_upload1").attr("disabled", true);
             }
             if(actionname==1||actionname==2){
                 $.ajax({
                     url: "../Equipment/hs/GetEquDeviceCRUD.ashx",
                     data: {
                         "Action": "Equ_Detail",
                         "EquID": equid
                     },
                     type: "post",
                     datatype: "json",
                     success: function (data) {
                         data = JSON.parse(data);
                         //console.log(data);
                         $("#ProcessName").val("" + data.ProcessCode + "");
                         $("#DeviceCode").val(data.DeviceCode);
                         $("#DeviceName").val(data.DeviceName.trim());
                         $("#DeviceVendor").val(data.DeviceVendor);
                         $("#PmStartDate").val(data.DeviceUseDate);
                         $("#DevicePartsFile").val(data.DevicePartsFile);
                         $("#DeviceManualFile").val(data.DeviceManualFile);
                         
                         $("#Description").val(data.DeviceComment);
                         Loading(false);
                     }, beforeSend: function () {
                         Loading(true);
                     }
                 });
             }
             if (actionname==2) {
                 OPaction = "Equ_Edit";
             }
             if(actionname==0){
                 OPaction = "Equ_Add";
             }
          
         });                  //构造select
         function CreateSelect() {
             $("#ProcessName").empty();
             var optionstring = "";
             $.ajax({
                 url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
                 type: "post",
                 dataType: "json",
                 data: "{deviceid:''}",
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

         }
         //保存表单
         function AcceptClick(grid) {
             var ProcessName = $("#ProcessName").val().trim();
             var DeviceCode = $("#DeviceCode").val().trim();
             var DeviceName = $("#DeviceName").val().trim();
             var DeviceVendor = $("#DeviceVendor").val().trim();
             var PmStartDate = $("#PmStartDate").val().trim();
             var DevicePartsFile= $("#DevicePartsFile").val().trim();
             var DeviceManualFile = $("#DeviceManualFile").val().trim();  
             var Description = $("#Description").val();
             var UploadedFile = $("#UploadedFile").val();
             var UploadedManualFile = $("#UploadedManualFile").val();

             if (!$('#ruleinfo').Validform()) {
                 return false;
             }
             $.ajax({
                 url: "../Equipment/hs/GetEquDeviceCRUD.ashx",
                 data: {
                     Action: OPaction,
                     EquID: equid,
                     ProcessName: ProcessName,
                     DeviceCode: DeviceCode,
                     DeviceName: DeviceName,
                     DeviceVendor: DeviceVendor,
                     PmStartDate: PmStartDate,
                     DevicePartsFile: DevicePartsFile,
                     DeviceManualFile: DeviceManualFile,
                     Description: Description,
                     UploadedFile: UploadedFile,
                     UploadedManualFile: UploadedManualFile
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
         }         function request(name) {
             var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
             var r = window.location.search.substr(1).match(reg);
             if (r != null) return unescape(r[2]); return null;
         }         //上传设备操作说明
         function onUpload1(keyword) {
             dialogOpen({
                 id: "UploadifyManu",
                 title: '上传设备操作说明书',
                 url: './UploadifyManu.aspx',
                 width: "600px",
                 height: "180px",
                 callBack: function (iframeId) {
                     top.frames[iframeId].AcceptClick($("#DeviceManualFile"), $("#UploadedFile"));
                 }
             });
         }

         //上传硬件组成明细表
         function onUpload(keyword) {
             dialogOpen({
                 id: "UploadifyManu",
                 title: '上传硬件组成明细表',
                 url: './UploadifyPartsFile.aspx',
                 width: "600px",
                 height: "180px",
                 callBack: function (iframeId) {
                     top.frames[iframeId].AcceptClick($("#DevicePartsFile"), $("#UploadedManualFile"));
                 }
             });
         }    </script>
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
                    <th class="formTitle">设备编号<font face="宋体">*</font></th>
                    <td class="formValue">
                         <input id="DeviceCode" type="text" class="form-control" placeholder="请输入设备编号" isvalid="yes" checkexpession="NotNull"  />
                    </td>
                    <th class="formTitle">设备名称<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input id="DeviceName" type="text" class="form-control" placeholder="请输入设备名称" isvalid="yes" checkexpession="NotNull"  />
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">供应厂商</th>
                    <td class="formValue">
                         <input id="DeviceVendor" type="text" class="form-control" placeholder="请输入供应厂商" />           
                    </td>
                    <th class="formTitle">投产时间</th>
                    <td class="formValue">
                         <input id="PmStartDate"  type="text" onclick="WdatePicker()" class="Wdate form-control" style="height:26px;" />          
                    </td>
                </tr>
                 <tr >
                    <th class="formTitle">硬件组成明细表<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="DevicePartsFile" isvalid="yes" checkexpession="NotNull" readonly/>
                        <input type="hidden" id="UploadedFile" value=""/>           
                    </td>
                     <td style="vertical-align:top">
                        <a id="btn_upload" class="btn btn-default" onclick="onUpload(event)" style="height:26px; padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
                    </td>
                </tr>
                <tr >
                    <th class="formTitle">设备操作说明书<font face="宋体">*</font></th>
                    <td class="formValue">
                        <input type="text" class="form-control" id="DeviceManualFile" isvalid="yes" checkexpession="NotNull" readonly/>
                        <input type="hidden" id="UploadedManualFile" value=""/>              
                    </td>
                     <td style="vertical-align:top">
                        <a id="btn_upload1" class="btn btn-default" onclick="onUpload1(event)" style="height:26px; padding-top:2px"><i class="fa fa-upload"></i>&nbsp;上传</a>
                    </td>
                </tr>
               <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        设备说明
                    </th>
                   <td class="formValue" colspan="3">
                        <textarea id="Description"  class="form-control" style="height: 150px;"  placeholder="请输入设备说明"></textarea>
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


